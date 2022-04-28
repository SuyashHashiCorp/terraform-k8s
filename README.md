# terraform-k8s

# Terraform Code and Scripts to Automate Kubernetes Setup using Kubeadm via Terraform (Compatible for Mac with M1 Chip)

# For Vagrant Setup Please see [vagrant-kubernetes](https://github.com/SuyashHashiCorp/vagrant-kubernetes)

## Documentation

To learn kubernetes, please follow learn guide at [suashk/](https://github.com/SuyashHashiCorp/terraform-k8s/tree/main/suyashk)

## Prerequisites

1. AWS Acoount.
2. 3 EC2 Instances With below Specification - 
 a. Instance Type = "t2.medium"
 b. AMI = "ami-0fb653ca2d3203ac1"

3. Public Subnet with CIDR - 10.0.1.0/16 (As this is being used for private IPs allocation as per point-4 and POD CIDR Range in K8s Cluster).
4. Private IPs will be assign as below - 
<img width="249" alt="image" src="https://user-images.githubusercontent.com/92308220/165732412-c16d4a00-08d5-429b-a2f1-2b70d3f9fd49.png">

5.  Security Group Settings - Please create or update your security group as per below table - 

<img width="1003" alt="image" src="https://user-images.githubusercontent.com/92308220/165730988-f2198303-ee82-4b36-9b38-529d08efa9b5.png">


## Usage/Examples

To provision the cluster, execute the following commands.

```shell
git clone https://github.com/SuyashHashiCorp/terraform-k8s.git
cd terraform-k8s
terraform init
terraform plan
terraform apply
```

## Set Kubeconfig file varaible.

"Terraform apply" will create the kubernetes config file and store the information in your local system in configs directory.

```shell
cd terraform-k8s
cd configs
cat config
```


## Kubernetes login token

"Terraform apply" will create the admin user token and saves in the configs directory.

```shell
cd vagrant-kubeadm-kubernetes
cd configs
cat token
```

## To destroy the cluster, 

```shell
terraform destroy -auto-approve
```

## To restart the cluster,

```shell
terraform apply -auto-approve
```
