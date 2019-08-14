# Using Kubernetes Secrets and ConfigMaps for the Sock Shop application
We will be using a combination of Kubernetes Secrets and ConfigMaps to configure our application. Each microservice has its own way of accepting arguments and/or environment variables, which means each respective helm chart will have to be written appropriately.

# Solution by Microservice
## Carts - ConfigMap
The Carts microservice is backed by MongoDB. As this is a Java application we will have to provide a new Spring `application.properties` file and direct the container to read that file on startup.[^1] If we take a look at the original `application.properties` file in the carts repository, we can see a section at the top that allows us to change the uri for the database. We can copy the contents of this file and store it in a ConfigMap. We can also change the value of `spring.data.mongodb.uri` so that it will reference values in our Helm values file. 

Create a file called `carts-configmap.yaml` in the `templates` directory of the carts Helm chart:
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: "carts-cnfigmap"
data:
  application.properties: |
    server.port=${port:8081}
    spring.data.mongodb.uri=mongodb://{{ .Values.carts.cosmosdbConnectionString }:10255/carts?ssl=true&replicaSet=globaldb
    endpoints.health.enabled=false
    spring.zipkin.baseUrl=http://${zipkin_host:zipkin}:9411/
    spring.zipkin.enabled=${zipkin_enabled:false}
    spring.sleuth.sampler.percentage=1.0
    spring.application.name=carts
    # Disable actuator metrics endpoints
    endpoints.metrics.enabled=false
    endpoints.prometheus.id=metrics
```
Now we inject this ConfigMap into our deployment template. We do this by creating a volume on the pod and then mounting it on the carts container.[^2] We will also tell Kubernetes to write the ConfigMap to a file on the volume and for the carts container to use the newly written `application.properties` file when starting the carts microservice.

Setting up a volume is simple. In the `spec.template.spec.volumes` section we'll create a volume called `config-volume`. Kubernetes exposes the volume to the entire pod--this is really handy if you have multiple containers that need to share some sort of config between each other. We will also drop the contents of our ConfigMap into this volume, which if you recall we named `carts-configmap`:
```
    volumes:
      - name: config-volume
        ConfigMap:
          name: carts-configmap
          defaultMode: 420

```
Now we'll update our deployment again to create a volume mount in the `spec.template.spec.containers.carts.volumeMounts` section, which tells Kubernetes *where to mount the volume in the carts container* (`mountPath`) and *what the name of the volume is that we wish to mount* (`name`). Remember, if we had multiple volumes specified in this deployment we could choose a different volume instead of `config-volume`. The `sub_path` represents the path to the file we are creating:
```
    volumeMounts:
    - mountPath: /mnt/config
      name: config-volume
      sub_path: "application.properties"
```
Lastly, in the `spec.template.spec.containers.carts` section we modify the `command` and `args` to be:
```
    command: ["/usr/local/bin/java.sh"]
    args: ["-jar /usr/src/app/app.jar", "--port=80", "--spring.config.location=/mnt/config/application.properties"]

```
## Catalogue - K8s Secret
The Catalogue microservice accepts `-DSN` as a commandline argument, which allows us to directly specify the full connection string for the MySQL database. Kubernetes allows us to store sensitive data as a secret, which can then be injected into the container as an environment variable. We'll update the `args` section of the container spec so that the value of the `-DSN` parameter references our new environment variable, which will contain the connection string for the MySQL database.

First, we create a Kubernetes secret. This will be done using Terraform:
```
resource "kubernetes_secret" "mysql" {
  metadata {
    name = "mysqldsn"
  }

  data {
    "DSN" = "${var.mysql_dsn}"
  }

  type = "kubernetes.io/opaque"
}
```
This creates a secret in the `default` namespace called `mysqldsn`. If your application uses the sock-shop namespace, make sure you udpate your Terraform code or else your application won't be able to see the secret! This can now be referenced in our deployment template in the `spec.template.spec.containers` section.

```
        env:
        - name: DSN
          valueFrom:
            secretKeyRef:
              name: mysqldsn
              key: DSN
```
The code above tells Kubernetes to create an environment variable called DSN when running the container, and that the value of `$DSN` will be whatever is stored in the `mysqldsn` secret. Finally, we can update the `args` section to use the environment variable we defined above!
```
  args: ["-DSN=$(DSN)"]
```
## Orders - ConfigMap
This is the same solution as the Carts microservice:
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: "orders-configmap"
data:
  application.properties: |
    server.port=${port:8082}
    spring.data.mongodb.uri=mongodb://{{ .Values.cosmosdb.accountName }}:{{ .Values.cosmosdb.password }}@{{ .Values.cosmosdb.databaseHostname }}:10255/data?ssl=true&replicaSet=globaldb
    endpoints.health.enabled=false
    spring.zipkin.baseUrl=http://${zipkin_host:zipkin}:9411/
    spring.zipkin.enabled=${zipkin_enabled:false}
    spring.sleuth.sampler.percentage=1.0
    spring.application.name=orders
    # Disable actuator metrics endpoints
    endpoints.metrics.enabled=false
```
We define the volume that Kubernetes will expose to the pod:
```
      volumes:
        - name: config-volume
          configMap:
            name: orders-configmap
            defaultMode: 420

```
And now the `volumeMounts`:
```
        volumeMounts:
        - mountPath: /tmp
          name: tmp-volume
        - mountPath: /mnt/config
          name: config-volume
          sub_path: "application.properties"
```
We then update our deployment to use the new `application.properties` file:
```
        command: ["/usr/local/bin/java.sh"]
        args: ["-jar /usr/src/app/app.jar", "--port=80", "--spring.config.location=/mnt/config/application.properties"]
```
That's it!

## Users - K8s Secret
The Users microservice accepts three environment variables: `MONGO_HOST`, `MONGO_PASS`, and `MONGO_USER`. The application will join all three variables together to form the connection string to our database, wherever it resides. *Note* if you're using CosmosDB, make sure you append the port number to the hostname (`:10255`) in the Helm template.

First, we'll update the outputs for our CosmosDB module so we get three unique variables:[^3]
```
output "cosmosdb_password" {
  value               = "${azurerm_cosmosdb_account.cosmosdb.primary_master_key}"
  sensitive           = true
}

# Splitting the id on the '/', then selecting the last element which is just the cosmosdb account name
# Adding .documents.azure.com on the end for full hostname
output "cosmosdb_hostname" {
  value               = "${element(split("/", azurerm_cosmosdb_account.cosmosdb.id),8)}.documents.azure.com"
  sensitive           = true
}

# Same process as above
output "cosmosdb_user" {
  value               = "${element(split("/", azurerm_cosmosdb_account.cosmosdb.id),8)}"
  sensitive           = true
}
```

Then we'll create a secret using the Terraform Kubernetes provider containing the three values specified above:
```
resource "kubernetes_secret" "mysql" {
  metadata {
    name = "cosmosdb"
  }

  data {
    "MONGO_HOST" = "${var.cosmosdb_hostname}"
    "MONGO_USER" = "${var.cosmosdb_user}"
    "MONGO_PASS" = "${var.cosmosdb_password}
  }

  type = "kubernetes.io/opaque"
}
```
Finally, in the deployment template for the Users microservice we'll update the environment variables so they are populated by the Kubernetes secret we created:
```
        env:
        - name: MONGO_HOST
          valueFrom:
            secretKeyRef:
              name: cosmosdb
              key: MONGO_HOST:10255
        - name: MONGO_USER
          valueFrom:
            secretKeyRef:
              name: cosmosdb
              key: MONGO_USER
        - name: MONGO_PASS
          valueFrom:
            secretKeyRef:
              name: cosmosdb
              key: MONGO_PASS
```
Not too bad, eh?
# Footnotes
[^1]: Kubernetes does not (yet!) allow you to inject secrets into a ConfigMap. The best way to get around this problem securely is to store the whole ConfigMap as a secret. I won't cover how this is done here but sadly Terraform does not support this feature (yet!) either. This means we have to store our *sensitive* data plainly in the ConfigMap. In a project setting we would raise an issue with developers and ask that the application expose the necessary environment variables for configuring this securely. For the purpose of the Ops Academy we will proceed with using a ConfigMap while being fully aware of the risks involved. For argument's sake, another way around this would be to have our pipeline create the secret using kubectl before running `helm install`, however this means some parts of our application wouldn't be tracked by `helm` or `terraform` and would then have to be manually changed or modified every time the pipeline runs. Yuck.
[^2]: This is the same logic we applied earlier in the Academy when we looked at mapping volumes with docker:

`docker run -d --name nginx -v myvol2:/app nginx:latest`
[^3]: I'm sure there's a nicer way of doing a regex to grab the host from the cosmosdb id or endpoint.