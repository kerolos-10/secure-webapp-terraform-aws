# calling vpc module
module "vpc" {
  source                = "./modules/vpc"
  cidr_block            = "10.0.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  name                  = "main-vpc"
}

#=================================================================

# calling public subnets
module "public_subnets" {
  source = "./modules/subnets/public_subnet"

  vpc_id               = module.vpc.vpc_id
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  environment          = "dev"
}


# calling private subnets 
module "private_subnets" {
  source = "./modules/subnets/private_subnet"

  vpc_id               = module.vpc.vpc_id
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  environment          = "dev"
}



#=================================================================

# calling igw
module "igw" {
  source = "./modules/internet_gateway"
  name = "igw"
  environment = "dev"
  vpc_id = module.vpc.vpc_id
  route_table_name = "public_rt"
  public_subnet_ids = module.public_subnets.public_subnet_ids

  depends_on = [
    module.vpc,
    module.public_subnets
  ]
}

# calling nat_gateway
module "nat_gateway" {
  source = "./modules/nat_gateway"

  vpc_id             = module.vpc.vpc_id
  public_subnet_id   = module.public_subnets.public_subnet_ids[0]
  private_subnet_ids = module.private_subnets.private_subnet_ids
  environment        = "dev"

  depends_on = [
    module.private_subnets,
    module.private_subnets,
    module.igw
  ]
}

#=================================================================

# calling sg of public alb
module "public_alb_sg" {
  source      = "./modules/security_groups"
  name        = "public-alb-sg"
  description = "Allow HTTP from Internet to public ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "public-alb-sg"
  }

  depends_on = [module.vpc]
}

# calling sg of proxy
module "proxy_sg" {
  source      = "./modules/security_groups"
  name        = "proxy-sg"
  description = "Allow SSH and HTTP to proxy instances"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "proxy-sg"
  }

  depends_on = [module.vpc]
}

# calling sg of internal alb
module "internal_alb_sg" {
  source      = "./modules/security_groups"
  name        = "internal-alb-sg"
  description = "Allow traffic from proxy to internal ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # محدود لـ VPC CIDR بدلاً من 0.0.0.0/0
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "internal-alb-sg"
  }

  depends_on = [module.vpc]
}

# calling sg of backend
module "backend_sg" {
  source      = "./modules/security_groups"
  name        = "backend-sg"
  description = "Allow port 5000 from internal ALB and SSH"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"] # محدود للـ public subnets للـ SSH
    },
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # محدود لـ VPC CIDR
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "backend-sg"
  }

  depends_on = [module.vpc]
}



# calling sg for bastion host
module "bastion_sg" {
  source      = "./modules/security_groups"
  name        = "bastion-sg"
  description = "Allow SSH access from your local IP only"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "bastion-sg"
  }

  depends_on = [module.vpc]
}

#=================================================================

module "bastion_host" {
  source = "./modules/basion_host"
  instance_type     = "t2.micro"
  subnet_id         = module.public_subnets.public_subnet_ids[0]
  security_group_id = module.bastion_sg.id
  key_name          = "kerolos-key"
  private_key_path  = "/home/kerolos/secure-webapp-terraform-aws/kerolos-key.pem"

  depends_on = [
    module.public_subnets,
    module.bastion_sg,
    module.igw
  ]
}


#=================================================================
# calling ec2_backend 
module "backend_ec2" {
  source = "./modules/ec2-backend"
  private_subnet_id   = module.private_subnets.private_subnet_ids
  security_group_id   = module.backend_sg.id
  key_name            = "kerolos-key"
  private_key_path    = "/home/kerolos/secure-webapp-terraform-aws/kerolos-key.pem"
  instance_type       = "t2.micro"
  bastion_host        = module.bastion_host.public_ip

  depends_on = [
    module.private_subnets,
    module.backend_sg,
    module.nat_gateway
  ]
}

# calling internal_alb 
module "internal_alb" {
  source = "./modules/private-alb"
  name                = "private-alb"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.private_subnets.private_subnet_ids
  security_group_id   = module.internal_alb_sg.id
  target_group_name   = "private-tg"
  target_port         = 5000
  listener_port       = 5000
  target_instance_ids = module.backend_ec2.instance_ids
  
  tags = {
    Environment = "dev"
    Component   = "private-alb"
  }
  
  depends_on = [
    module.backend_ec2,
    module.private_subnets,
    module.internal_alb_sg
  ]
}

#===================================================================

# calling ec2 proxy
module "proxy_ec2" {
  source = "./modules/ec2-reverse-proxy"
  public_subnet_id    = module.public_subnets.public_subnet_ids
  security_group_id   = module.proxy_sg.id
  key_name            = "kerolos-key"
  private_key_path    = "/home/kerolos/secure-webapp-terraform-aws/kerolos-key.pem"
  instance_type       = "t2.micro"
  backend_target = "${module.internal_alb.dns_name}:5000" 


  depends_on = [
    module.internal_alb,
    module.public_subnets,
    module.proxy_sg,
    module.igw
  ]
  
}

#=================================================================

# calling public alb
module "public_alb" {
  source = "./modules/public-alb"
  name                = "public-alb"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.public_subnets.public_subnet_ids
  security_group_id   = module.public_alb_sg.id
  target_group_name   = "public-tg"
  target_port         = 80
  listener_port       = 80
  target_instance_ids = module.proxy_ec2.instance_ids
  
  tags = {
    Environment = "dev"
    Component   = "public-alb"
  }
  
  depends_on = [
    module.proxy_ec2,
    module.public_subnets,
    module.public_alb_sg
  ]
}