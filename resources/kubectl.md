## Kubernetes
# Cluster Introspection
kubectl get services                # List all services 
kubectl get pods                    # List all pods
kubectl get nodes -w                # Watch nodes continuously
kubectl version                     # Get version information
kubectl cluster-info                # Get cluster information
kubectl config view                 # Get the configuration
kubectl describe node <node>        # Output information about a node

#POD and Container Introspection
kubectl get pods                         # List the current pods
kubectl describe pod <name>              # Describe pod <name>
kubectl get rc                           # List the replication controllers
kubectl get rc --namespace="<namespace>" # List the replication controllers in <namespace>
kubectl describe rc <name>               # Describe replication controller <name>
kubectl get svc                          # List the services
kubectl describe svc <name>              # Describe service <name>

#Interacting with PODS
kubectl run <name> --image=<image-name>                             # Launch a pod called <name> 
                                                                    # using image <image-name>
 
kubectl create -f <manifest.yaml>                                   # Create a service described 
                                                                    # in <manifest.yaml>
 
kubectl scale --replicas=<count> rc <name>                          # Scale replication controller 
                                                                    # <name> to <count> instances

kubectl expose rc <name> --port=<external> --target-port=<internal> # Map port <external> to 
                                                                    # port <internal> on replication 
                                                                    # controller <name>

# Stopping Kubernetes
kubectl delete pod <name>                                         # Delete pod <name>
kubectl delete rc <name>                                          # Delete replication controller <name>
kubectl delete svc <name>                                         # Delete service <name>
kubectl drain <n> --delete-local-data --force --ignore-daemonsets # Stop all pods on <n>
kubectl delete node <name>                                        # Remove <node> from the cluster

# Debugging in Kubernetes
kubectl exec <service> <command> [-c <$container>] # execute <command> on <service>, optionally 
                                                   # selecting container <$container>
 
kubectl logs -f <name> [-c <$container>]           # Get logs from service <name>, optionally
                                                   # selecting container <$container>
 
watch -n 2 cat /var/log/kublet.log                 # Watch the Kublet logs
kubectl top node                                   # Show metrics for nodes
kubectl top pod                                    # Show metrics for pods

#Administration
kubeadm init                                              # Initialize your master node
kubeadm join --token <token> <master-ip>:<master-port>    # Join a node to your Kubernetes cluster
kubectl create namespace <namespace>                      # Create namespace <name>
kubectl taint nodes --all node-role.kubernetes.io/master- # Allow Kubernetes master nodes to run pods
kubeadm reset                                             # Reset current state
kubectl get secrets                                       # List all secrets
 
#kubectl example debugging
Kubectl get pods --all-namespaces
kubectl describe pod coredns-5f4ffb84bc-c4g2n
kubectl describe pod coredns-5f4ffb84bc-c4g2n --namespace kube-system
kubectl get configmap --all-namespaces
kubectl describe configmap
kubectl describe configmap aws-auth --namespace kube-system
kubectl get nodes
kubectl get nodes
kubectl describe configmap aws-auth --namespace kube-system
kubectl get configmap --all-namespaces
kubectl describe pod coredns-5f4ffb84bc-c4g2n --namespace kube-system
kubectl get configmap --all-namespaces
kubectl describe configmap aws-auth --namespace kube-system
kubectl config view
kubectl describe pod coredns-5f4ffb84bc-c4g2n --namespace kube-system
kubectl describe configmap aws-auth --namespace kube-system

