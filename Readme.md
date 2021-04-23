# Microservices in Kubernetes cluster.
This repo contains an application which substitutes certain words in a given text. The microservices are deployed on a managed Kubernetes cluster on EKS.

Access the application via this url [Substitution Application](https://demoapp.it-travellers.com)

## Application
 The application contains below microservices
- A NodeJS backend API to transform text.
- A NGINX server to serve frontend AngularJS and reverse-proxy NodeJS backend.
**Amazon ECR** is used as repo for these images

Application is deployed on **Kubernetes** via **Helm** templating.

## Infrastructure
Complete infrastructure is hosted on **AWS EKS** cluster in private subnet load balanced with **Application Load balancer** with **SSL termination**. Client entry is from **Route 53** DNS hosting.

For Compute a **spot fleet of EC2** instances are used under an **autoscaling group**.

All the resources are provisioned as code via **Terraform**  

Reference architecture in folder **architecture**.

# Application Installation
## Prerquisites

 - Configure AWS CLI V2 
 - Configure terraform V 0.13
 - Configure Docker.( Only needed in case of changes in application needed)
 - Configure Kubectl CLI
 - Configure Helm V3
 - All commands to be run from root of folders.

## Infra Provisioning
All The infra provisioning is done via terraform. To maintain the state we need to store remote state in S3. In your account create a bucket as a state store and replace it in following files
**/terraform-provision/eks/backend.tf** and **/terraform-provision/vpc/backend.tf**.

Configure the AWS CLI to your AWS account.

Now first we create the landing zone (VPC , Subnets , NAT's and Gateways). 

    cd terraform-provision/vpc/
    terraform init
    terraform apply -auto-approve

  Now we can create our kubernetes cluster. 

      cd terraform-provision/eks/

  For getting RBAC access to cluster go to file **variables .tf** and change the default value of variable **map_users** to point to your IAM user.

    terraform init
    terraform apply -auto-approve
   
This will deploy the kubernetes cluster on the VPC. Now set Kubernetes context to this EKS cluster.

    aws eks --region <region-code> update-kubeconfig --name demo-k8s-cluster
  Test your configuration by checking for nodes in Ready status.
  
    kubectl get nodes
   
   ## Application deployment
   First we will set up controllers needed for kubernetes object to interact with AWS
   1. **Kube2IAM** :- This will enable us to configure an AWS role for other controllers to intract with AWS API and not expose our keys.
    `kubectl apply -f k8s-control-plane/kube2iam.yaml` 
   2. **AWS Ingress Controller** :-  This controller gives us capability to configure our load balancer. Replace with config of your account and apply
     `kubectl apply -f k8s-control-plane/aws-ingress-controller.yaml`
   3. **AWS DNS Controller** : - This controller gives us capability to manage our DNS. Replace with config of your account and apply
   `kubectl apply -f k8s-control-plane/external-dns.yaml`
   4. **Metric Server** :- This controller will enable the capability to get resource utilization from our cluster resources. Basically it enables the UNIX top command for kubernetes cluster. 
   `kubectl apply -f k8s-control-plane/metrics-server.yaml`
   5. **Cluster Autoscalar** :- This controller scales kubernetes cluster in case of shortage of resources on worker nodes. 
   `kubectl apply -f k8s-control-plane/cluster-autoscalar.yaml`
   6. **Spot Intrupt Handler**:- Since we are using spot instances this controller is a fail check which drain and replace node in case of spot reservation is breached. 
   `kubectl apply -f k8s-control-plane/spot-intrupt-handler.yaml`

Now create application docker images and push to repo of your choice. ECR example below

    cd microservices/nodejs-microservice
    aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 002857694718.dkr.ecr.eu-west-1.amazonaws.com
    docker build -t node-api .
    docker tag node-api:latest 002857694718.dkr.ecr.eu-west-1.amazonaws.com/node-api:latest
    docker push 002857694718.dkr.ecr.eu-west-1.amazonaws.com/node-api:latest

Now we will deploy the application via helm charts as a release on dev namespace

    cd helm/demo-k8s
    helm install r1 . --namespace=dev --create-namespace

**ENJOY YOUR PRODUCTION GRADE KUBERNETES APPLICATION ON EKS!!!**

   