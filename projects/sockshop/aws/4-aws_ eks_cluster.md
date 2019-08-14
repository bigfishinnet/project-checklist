#Note: Make sure the region support EKS.  US West (N. California)  does not support EKS!

#Manual Steps to create a EKS cluster and add a Kubnetes Master and Node with Auto Scaling.

	1. ~/.kube | drop into kube config directory
	2. Move | mv config oldconfig | This step is required to create a new config file.
	3. Choose a region for your cluster. See note above.  Make sure the region supports clusters.
	4. Create VPC.
	• CIDR Block 10.0.0.0/16
	5. Create Security groups x2 | One required for the cluster master and one required for the nodes.  Please add info in the name fields for clarity.  Assigned each security group to the VPC.  Note the field validation for the names of security groups does not allow / like using SG or dashes.
	6. Security groups rules.
	• Master / Cluster rule = allow ssh inbound 0.0.0.0/0. Note this could be tightened down to just your IP address. Add appropriate comments in the description field.
	• Master / Cluster rule = allow all traffic for your node security group. | Note this could be tightened down to 443. Add appropriate comments in the description field.
	• Node rule = allow ssh inbound 0.0.0.0/0. Note this could be tightened down to just your IP address. Add appropriate comments in the description field.
	• Node rule = allow all traffic from the master security group.  Add appropriate comments in the description field.
	• Node rule = allow all traffic from within the node security group. Required to allow node communication across auto scaled nodes in different subnets.  Add appropriate comments in the description field.
	7. Create Internet Gateway.  Attach to VPC.
	8. Create subnets for our VPC.  Attach each subnet to a different availability in a region.  For example if you are three subnets.  Call each subnet subnet1, subnet2, subnet3 > 3 x subnets 10.0.5.0/24, 10.0.10.0/24 10.0.15.0/24.  NOTE: Some regions do not have sufficient capacity to share the networks across different availability zones - at this stage you might have to choose 'No preference'
	9. Create Route Table attached to the VPC. Associate your subnets with you routing table.  Edit the routes and add an internet route 0.0.0.0/0 to your internet gateway.  Note this assumes that everything in your VPC is going to have access to the internet.  In some cases you will require a private and public subnet.
	10. IAM roles for the cluster / master and the EC2 instances / nodes can be created at this stage.
	• IAM role for EKS. Step create IAM role using EKS service - Includes the following default role names - AWS EKS Cluster Policy, AWS EKS Service Policy
	• IAM roles for EC2.  Step create IAM roles using EC2 service.  The following role names (3) are required - AWS EKS Worker Node Policy, AWS EC2 Container Registry Read Only, AWS EKS_CNI_Policy.  NOTE: use this role ARN number in the aws-auth-yaml file.
	11. Create the Cluster. 
	• Enter Cluster name, choose the version of Kubernetes - make sure you use the latest version.
	• Select the IAM role for the cluster that you have created previously.
	• Select the VPC that you created and populate the subnet.  Note this might be automatically selected for you.
	• Select the security group for your cluster / master.
	• Note: make sure the public access toggle is switched to on.
	• Choose create cluster.  Process will take 15 minutes or so.
	12. Create EC2 Cluster.
	
	• Open this link https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html and choose an AMI that suits your version of Kubernetes and the region.  Copy the AMI identification.
	• Launch instance in EC2.  Paste and search for you AMI instance and then select the AMI from the search results.
	• Choose an appropriate instance type.  In this case choose m4 large.
	• Configure instance details: change number of instances to 2 or 3 and choose the option - Launch into the Auto Scaling Group. Note: no other options selected at this stage.
	• Select launch configuration > provide a name, choose the IAM role for your Nodes - created in step 10.  THIS STEP CREATES A GROUP.
	• At this stage open the cluster in another tab so you can copy and paste the following information into the user script, API server endpoint, Certificate authority.
	• Select the advanced details option and add the appropriate CloudINIT script for the boot strapping process.   Example below from: https://learn.hashicorp.com/terraform/aws/eks-intro
	• #!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority.0.data}' '${var.cluster-name}'
	• IP Address Type: choose assign a public IP address to every instance.
	• Add Storage: choose the defaults.
	• Configure Security Group: select the option for choose an existing security group.  Select the Security group that was created for the nodes.
	• Review: Create launch Configuration.  Select an existing SSH or create a new one.  Launch.
	• THIS STEP CREATES an AUTO SCALING GROUP.
	• Provide a group name, group size start defaults but this decides how many instances of nodes (NOTHING TO DO WITH MASTERS)
	• Choose the VPC and the appropriate number of subnets which is matched to the number of instances you created earlier.
	• Configure Scaling Policies:  Keep at initial size.
	• Configure notifications: SKIP THIS.
	• Configure Tags: VERY IMPORTANT.  Key = kubernetes.io/cluster/"cluster name"| value = owned.  MORE INFO REQUIRED.
	• Review: Confirm the details of the Auto Scaling.  Check Tags.
	13. UPDATE KUBE CONFIG FILE:  aws eks --region region update-kubeconfig --name cluster_name | this updates the ~/.kube/config file with the information need to connect to your EKS.
	14. Enable worker nodes to join cluster > https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#eks-configure-kubectl
	• Download the configuration for the AWS configuration >  curl -o aws-auth-cm.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml
	• Replace the <ARN of instance role (not instance profile)> snippet with the NodeInstanceRole value that you recorded in the previous procedure, and save the file, for eaxmple:
	• apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: <ARN of instance role (not instance profile)>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
	• Apply the configuration. This command might take a few minutes to finish, kubectl apply -f aws-auth-cm.yaml
