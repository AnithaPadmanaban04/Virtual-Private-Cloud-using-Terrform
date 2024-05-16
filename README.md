# Provisioning a Virtual Private Cloud (VPC) in AWS with Terraform

## Project Overview:

This project aims to automate the creation of a Virtual Private Cloud (VPC) infrastructure in Amazon Web Services (AWS) using Terraform. A VPC allows users to launch AWS resources in a virtual network that is isolated from other parts of the AWS cloud. This ensures a secure environment for running applications and services.

## Project Benefits:

* Automation: Automating the provisioning of VPC infrastructure with Terraform reduces manual effort and ensures consistency across environments.
* Scalability: The Terraform configuration can be easily modified to add additional resources or adjust configurations as needed, facilitating scalability.
* Security: By creating a VPC with private and public subnets, along with appropriate routing configurations, the project enhances security by isolating resources and controlling internet access.

## Architecture Diagram

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/20773332-d372-41e6-afb3-d910438b1b95)


## Project Components:

**AWS Provider:** Configures Terraform to use AWS as the cloud provider and specifies the desired region (us-west-2 in this example).

**VPC (aws_vpc):** Defines the VPC with a specified CIDR block (172.16.0.0/16 in this example).

**Internet Gateway (aws_internet_gateway):** Creates an internet gateway and attaches it to the VPC to enable internet access for resources within the VPC.

**Public Subnet (aws_subnet):** Defines a public subnet within the VPC with a specified CIDR block (172.16.0.0/24, 172.16.1.0/24 in this example) and availability zone (us-east-1a, us-east-1b in this example).

**Private Subnet (aws_subnet):** Defines a private subnet within the VPC with a specified CIDR block (172.16.10.0/24, 172.16.11.0/24 in this example) and availability zone (us-east-1a, us-east-1b in this example).

**Route Table (aws_route_table):** Creates a route table associated with the VPC and adds a route to the internet gateway, enabling outbound internet traffic from the public subnet.

**Route Table Association (aws_route_table_association):** Associates the public subnet with the public route table to direct traffic appropriately.

**Nat Gateway (aws_nat_gateway):** Defines nat gateway to allow instances in private subnet to get internet access

## Step by Step Guide:

### Initiate Terraform Configuration

Create a folder for our terraform project where we can keep all the configurations related to our terraform environment.

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/4a08b8f0-8856-4dc1-8cc5-f855b2cd23f5)

### Provider Configuration
Create a provider file to denote Terraform which cloud platform we are going to use and specify which version of HCL syntax we are going to work with. In addition to that specify the cloud region.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}
```

Then run the following command to initiate terraform in this directory.

```hcl
terraform init
```

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/70198059-939b-4e43-a5a3-9c59a4dffdaf)

### Define input variables for Terraform

Create a file variable.tf to make dynamic Terraform configuration than hard coding variables whenever needed. 

```hcl
# Terraform Variables
# Local Values
locals {
  vpc_name     = "demo-vpc"
  environment  = "development"
}

variable "aws_region" {
  description = "Define the AWS Region"
  type        = string
  default     = "us-east-1"
}

locals {
  az_names = ["${var.aws_region}a", "${var.aws_region}b"]
}

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnets_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24"]
}

variable "private_subnets_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["172.16.10.0/24", "172.16.11.0/24"]
}

variable "amiID" {
  description ="Specify AMI ID"
  type        = string
  default     = "ami-0e001c9271cf7f3b9"
}
variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}
```

## VPC – Virtual Private Network

Let’s start defining the VPC and related components inside the necessary architecture.

# 1. Create a VPC	

```hcl
#Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = local.vpc_name
  }
}
```

Let’s apply this VPC and check with the AWS VPC dashboard on that specific region.

```hcl
terraform plan
terraform apply
```

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/6d9e2c47-e8cd-48ba-a094-76f5c87c2250)

| Architecture | VPC Dashboard Showing newly created VPC with Terraform |
| ------------ | ------------------------------------------------------ |
| ![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/b6588b92-87a9-4caf-934b-a9cb9a33ba44) | ![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/10a34600-6524-49f5-947d-befbd09f9a3b)

# Public Subnets inside VPC

Create public subnets in availability zone us-east-1a and us-east-1b

```hcl
# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.az_names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.environment}-${element(var.az_names, count.index)}-public-subnet"
    Environment = "${local.environment}"
  }
}
```

# Private Subnets inside VPC

Create private subnets in availability zone us-east-1a and us-east-1b

```hcl
# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(local.az_names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${local.environment}-${element(local.az_names, count.index)}-private-subnet"
    Environment = "${local.environment}"
  }
}
```

# Create Internet Gateway for our VPC

```hcl
#Internet gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name"        = "${local.environment}-igw"
    "Environment" = local.environment
  }
}
```

**Architecture So far**

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/983f985e-f1b4-44d1-a1f6-52796ac6a567)

# Create EIP and NAT-Gateway 

```hcl
# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  domain        = "vpc"
  depends_on    = [aws_internet_gateway.ig]
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  tags = {
    Name        = "nat-gateway-${local.environment}"
    Environment = "${local.environment}"
  }
  depends_on    = [aws_eip.nat_eip]
}
```

To verify the configuration run Terraform apply command to check

```hcl
terraform apply –auto-approve
```

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/758649d7-a413-4eb0-b809-5c25ecf0b345)

**VPC Resource map with internet gateway, public, private subnets and NAT gateway**

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/45c7400b-dc52-4e6a-b865-7099c7dc719a)

# Create Route tables for private and public subnets

```hcl
# Route table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.environment}-private-route-table"
    Environment = "${local.environment}"
  }
}

# Route table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.environment}-public-route-table"
    Environment = "${local.environment}"
  }
}
```

# Configure public route to use internet gateway for internet access

```hcl
# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
```

# Configure private route to use a NAT gateway for internet access

```hcl
# Route for NAT Gateway
resource "aws_route" "private_internet_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}
```

# Associate route tables for subnets

```hcl
# Route table associations for both Public subnet
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Route table associations for both Private subnet
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
```

# Verify Output

**VPC Resource map with public subnets associated with Public route table and Internet gateway, private subnets associated with private route table and nat gateway** 

![image](https://github.com/aniwardhan/Virtual-Private-Cloud/assets/80623694/488ff470-55be-4ded-a172-63e0d9eae069)

Finally destroy all resources created using the command

```hcl
terraform destroy
```












