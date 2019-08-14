# Steps and processes to follow that are applicable to both approaches for AWS and AZURE.

    1. Test and deploy sockshop on minikube
	2. Review and understand how the micros services works and capture the principal information
		a. Databases, ports, what microservices are running, how are they connecting.  What programming languages are they using.
	3. Review the GitHUB repository for same - understand how the microservices connect.
	4. Review what services can be replaced in the sockshop with AWS / AZURE cloud services.
    5. Drawing the system.
	6. Consider the design and build of the sockshop how is the system going to represented as modules or built layer  upon layer.  What are the dependencies or logical points at which component separation can occur.
	7. Components Base / Database / EKS Cluster / Management / SockShop
	8. Manually build the sockshop in AWS / AZURE

# Databases used by the MicroServices in the Sockshop

	Carts			- AWS DocumentDB   	Azure CosmosDB
	Catalogue		- AWS RDS (MYSQL)	Azure MySQL
	Front-end		- No Change  (Works without modification - also brings up Load balancer)
	Orders			- AWS DocumentDB   	Azure CosmosDB
	Payment			- No Change
	Queue-master	- AWS SNS			Azure
	Rabbitmq		- AWS Amazon MQ		Azure Service+
	Session			- No Change
	Shipping		- No Change
	User			- AWS DocumentDB	 Azure CosmosDB