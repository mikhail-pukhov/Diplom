provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_region" "current" {}

data "aws_instance" "ubuntu1" {
  instance_id = aws_instance.ubuntu1.id
}

data "aws_instance" "ubuntu2" {
  instance_id = aws_instance.ubuntu2.id
}

data "aws_instance" "ubuntu3" {
  instance_id = aws_instance.ubuntu3.id
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "diplom-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24",  "10.0.3.0/24" ]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24" ]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }  
  vpc_tags = {
    Name = "diplom-vps"
  }
}

resource "aws_security_group" "diplom" {
  name        = "Diplom"
  description = "Allow TLS,SSH,HTTP inbound traffic"
  vpc_id = module.vpc.vpc_id
  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    } 
    ,
   
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
    ,

    {
      description      = "HTTP from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }

  ] 
  
  egress = [
    {
      description      = "all to VPC"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = {
    Name = "allov_ssh_http_tsl"
  }
}

resource "aws_key_pair" "diplom" {
  key_name   = "diplom-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnQXMPZuWbQtnmoxOlBCwWyqdA9xf8FnciVBC65B/RpPrlovIhzh950vaQx3eOjW08ELBA2z/QF59ar8uKCeCWTF5Lc0iAB73UQUgQbSsSICx94yoMb/6HO0J9IEyQxDf1y8wWju3LqieeYd8/n+xnAOd8kIuAIRRM6PMo08YptYp+FWZQysgZXHoylO8BQ+npkzlI5LSVuCTUdlZBbI6UNclrngFcKnCfgXaHyDBDbvAnY+Rq2anwhk0XYsDV+dh5xvfHShXOqLFIbdW98OlWjsDYBHyTi3MN7TuI0lQ0kHLKXq71BlaMM2LqEf8mWkuV+mNg7AFy5S48Q+5C0ygAG83PI/R/TxXANYwJg1y/Ol6MdXknB/aDDWAuVhO6sOobyyz+7lpRnQIy1GQX1EmKGqPL0D74EuXL1VdspAGoUWoiijgPT072uaHnWJStCyIADFN58C+S67ASAenaFr7rFNCorq4XoM+Fn0yVcgjfaYb41WtOQKNTtbbKU3ibouE= user@LAPTOP-JPLSSIOU"

}

resource "aws_instance" "ubuntu1" {
  ami           = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.diplom.id]
  subnet_id = "subnet-0ae667f254f108fe0"
  key_name = aws_key_pair.diplom.id
  instance_type = "t3.small"
  root_block_device {
    volume_size = "100"
  }
  tags = {
    Name = "node1"
  }
}

resource "aws_instance" "ubuntu2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.diplom.id]
  subnet_id = "subnet-0ae667f254f108fe0"
  key_name = aws_key_pair.diplom.id
  root_block_device {
    volume_size = "100"
  }
  tags = {
    Name = "node2"
  }
}

resource "aws_instance" "ubuntu3" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.diplom.id]
  subnet_id = "subnet-0ae667f254f108fe0"
  key_name = aws_key_pair.diplom.id
  root_block_device {
    volume_size = "100"
  }
  tags = {
    Name = "node3"
  }
}

