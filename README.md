# Provisioning a Virtual Private Cloud (VPC) in AWS with Terraform

## Project Overview:

This project aims to automate the creation of a Virtual Private Cloud (VPC) infrastructure in Amazon Web Services (AWS) using Terraform. A VPC allows users to launch AWS resources in a virtual network that is isolated from other parts of the AWS cloud. This ensures a secure environment for running applications and services.

## Project Benefits:

* Automation: Automating the provisioning of VPC infrastructure with Terraform reduces manual effort and ensures consistency across environments.
* Scalability: The Terraform configuration can be easily modified to add additional resources or adjust configurations as needed, facilitating scalability.
* Security: By creating a VPC with private and public subnets, along with appropriate routing configurations, the project enhances security by isolating resources and controlling internet access.

## Architecture Diagram

![image](https://github.com/AnithaPadmanaban04/Virtual-Private-Cloud-using-Terrform/assets/170385807/e903310b-5e33-43ef-89d9-2d453cc29416)

## Project Components:

**AWS Provider:** Configures Terraform to use AWS as the cloud provider and specifies the desired region (us-east-1 in this example).

**VPC (aws_vpc):** Defines the VPC with a specified CIDR block (172.16.0.0/16 in this example).

**Internet Gateway (aws_internet_gateway):** Creates an internet gateway and attaches it to the VPC to enable internet access for resources within the VPC.

**Public Subnet (aws_subnet):** Defines a public subnet within the VPC with a specified CIDR block (172.16.0.0/24, 172.16.1.0/24 in this example) and availability zone (us-east-1a, us-east-1b in this example).

**Private Subnet (aws_subnet):** Defines a private subnet within the VPC with a specified CIDR block (172.16.10.0/24, 172.16.11.0/24 in this example) and availability zone (us-east-1a, us-east-1b in this example).

**Route Table (aws_route_table):** Creates a route table associated with the VPC and adds a route to the internet gateway, enabling outbound internet traffic from the public subnet.

**Route Table Association (aws_route_table_association):** Associates the public subnet with the public route table to direct traffic appropriately.

**Nat Gateway (aws_nat_gateway):** Defines nat gateway to allow instances in private subnet to get internet access

## Detailed Guide

For a comprehensive walkthrough of the project, please refer to the detailed guide available on [Medium](https://medium.com/@anitha.padmanaban04/provisioning-a-virtual-private-cloud-vpc-in-aws-with-terraform-e8f881ad5b70).

## Connect with Me

GitHub: [GitHub Profile](https://github.com/AnithaPadmanaban04)

LinkedIn: [Linkedin](https://www.linkedin.com/in/anitha-padmanaban-7b2665264/)












