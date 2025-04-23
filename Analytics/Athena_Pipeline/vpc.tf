resource "aws_vpc_ipam" "Transfer_Fam_ipam" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_scope" "Transfer_Fam_ipam_scope" {
  ipam_id = aws_vpc_ipam.Transfer_Fam_ipam.id
}

resource "aws_vpc_ipam_pool" "Transfer_Fam_ipam_pool" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam_scope.Transfer_Fam_ipam_scope.id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "Transfer_Fam_ipam_pool_cidr" {
  ipam_pool_id = aws_vpc_ipam_pool.Transfer_Fam_ipam_pool.id
  cidr         = "10.0.0.0/16"
}

resource "aws_vpc" "Transfer_Fam_VPC" {
  ipv4_netmask_length   = 16
  ipv4_ipam_pool_id     = aws_vpc_ipam_pool.Transfer_Fam_ipam_pool.id
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "Transfer_Fam_VPC"
  }
}

locals {
  vpc_cidr = aws_vpc.Transfer_Fam_VPC.cidr_block
}

resource "aws_subnet" "Transfer_Fam_Public" {
  vpc_id                  = aws_vpc.Transfer_Fam_VPC.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 1, 0)
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Transfer_Fam_Public_Subnet"
  }
}

resource "aws_subnet" "Transfer_Fam_Private" {
  vpc_id            = aws_vpc.Transfer_Fam_VPC.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 1, 1)
  availability_zone = "${data.aws_region.current.name}a"
  tags = {
    Name = "Transfer_Fam_Private_Subnet"
  }
}

resource "aws_internet_gateway" "Transfer_Fam_Igw" {
  vpc_id = aws_vpc.Transfer_Fam_VPC.id
  tags = {
    Name = "Transfer_Fam_Igw"
  }
}

resource "aws_route_table" "Transfer_Fam_Rtb_pub" {
  vpc_id = aws_vpc.Transfer_Fam_VPC.id
  tags = {
    Name = "Transfer_Fam_Rtb_pub"
  }
}


resource "aws_route_table" "Transfer_Fam_Rtb_pri" {
  vpc_id = aws_vpc.Transfer_Fam_VPC.id
  tags = {
    Name = "Transfer_Fam_Rtb_pri"
  }
}

resource "aws_route" "Transfer_Fam_Rt_pub" {
  route_table_id         = aws_route_table.Transfer_Fam_Rtb_pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Transfer_Fam_Igw.id
}

resource "aws_route_table_association" "Transfer_Fam_Rtb_ass-pub" {
  route_table_id = aws_route_table.Transfer_Fam_Rtb_pub.id
  subnet_id      = aws_subnet.Transfer_Fam_Public.id
}

resource "aws_route_table_association" "Transfer_Fam_Rtb_ass-pri" {
  route_table_id = aws_route_table.Transfer_Fam_Rtb_pri.id
  subnet_id      = aws_subnet.Transfer_Fam_Private.id
}

resource "aws_vpc_endpoint" "Transfer_Fam_Vpc_Ep" {
  vpc_id            = aws_vpc.Transfer_Fam_VPC.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids   = [aws_route_table.Transfer_Fam_Rtb_pub.id]
  tags = {
    Name = "Transfer_Fam_Vpc_Ep"
  }
}

resource "aws_cloudwatch_log_group" "Transfer_Fam_Vpc_Lg_Grp" {
  name = "Vpc/flow-logs"
  # If set to true, wont be destroyed while giving destroy command ans its just been removed from state
  skip_destroy = false
  # kms_key_id
  retention_in_days = 14
  log_group_class = "STANDARD"
}

resource "aws_iam_role" "flow_log_role" {
  name = "VPCFlowLogsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "VPCFlowLogsPolicy"
  role = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "Transfer_Fam_Vpc_Fl_Lg" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.Transfer_Fam_Vpc_Lg_Grp.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.Transfer_Fam_VPC.id
  tags = {
    Name = "VPC Flow Logs"
  }
}

variable "allowed_ingress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["49.207.56.191/32"]
      description = "Allow SFTP"
    },
    {
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      cidr_blocks = ["49.207.56.191/32"]
      description = "Allow FTPS Control"
    },
    {
      from_port   = 8192
      to_port     = 8200
      protocol    = "tcp"
      cidr_blocks = ["49.207.56.191/32"]
      description = "Allow FTPS Data"
    }
  ]
}

resource "aws_security_group" "transfer_family_sg" {
  name        = "transfer_family_sg"
  description = "Security group for AWS Transfer Family"
  vpc_id      = aws_vpc.Transfer_Fam_VPC.id

  dynamic "ingress" {
    for_each = var.allowed_ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Transfer_Fam_Sg"
  }
}

resource "aws_network_acl" "transfer_family_nacl" {
  vpc_id = aws_vpc.Transfer_Fam_VPC.id
  subnet_ids = [
    aws_subnet.Transfer_Fam_Public.id,
    aws_subnet.Transfer_Fam_Private.id
  ]

  dynamic "ingress" {
    for_each = var.allowed_ingress
    content {
      rule_no = ingress.key + 100
      protocol    = ingress.value.protocol
      action = "allow"
      cidr_block  = ingress.value.cidr_blocks[0]
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
    }
  }

  egress {
    rule_no = 100
    protocol    = "-1"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "Transfer_Fam_NACL"
  }
}

