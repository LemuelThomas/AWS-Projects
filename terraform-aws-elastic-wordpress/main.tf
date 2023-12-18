terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.31.0"
      }
    }
}

# Create a Class A IPV4 VPC
resource "aws_vpc" "vpcmain" {
  cidr_block = "10.16.0.0/16"
  tags = {
    Name = "ProjectVPC"
  }
}

# Create all the subnets
resource "aws_subnet" "sn-pub" {
  vpc_id = aws_vpc.vpcmain.id
  count = 3
  availability_zone = var.azs[count.index]
  cidr_block = var.pub_cidr_blocks[count.index]
  tags = {
    Name = var.sn_pub_names[count.index]
  }
}

resource "aws_subnet" "sn-db" {
  vpc_id = aws_vpc.vpcmain.id
  count = 3
  availability_zone = var.azs[count.index]
  cidr_block = var.db_cidr_blocks[count.index]
  tags = {
    Name = var.sn_db_names[count.index]
  }
}
resource "aws_subnet" "sn-app" {
  vpc_id = aws_vpc.vpcmain.id
  count = 3
  availability_zone = var.azs[count.index]
  cidr_block = var.app_cidr_blocks[count.index]
  tags = {
    Name = var.sn_app_names[count.index]
  }
}

# Create IGW
resource "aws_internet_gateway" "igwmain" {
  vpc_id = aws_vpc.vpcmain.id

  tags = {
    Name = "project-igw"
  }
}


# Create RT
resource "aws_route_table" "rtmain" {
  vpc_id = aws_vpc.vpcmain.id

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.igwmain.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwmain.id
  }
  route {
    cidr_block = "2600:1f18:3c6c:5900::/56"
    gateway_id = "local"
  }

  tags = {
    Name = "ProjectRT"
  }
}
resource "aws_route_table_association" "rt-pub-a" {
  subnet_id = aws_subnet.sn-pub[0].id
  route_table_id = aws_route_table.rtmain.id
}
resource "aws_route_table_association" "rt-pub-b" {
  subnet_id = aws_subnet.sn-pub[1].id
  route_table_id = aws_route_table.rtmain.id
}
resource "aws_route_table_association" "rt-pub-c" {
  subnet_id = aws_subnet.sn-pub[2].id
  route_table_id = aws_route_table.rtmain.id
}
resource "aws_main_route_table_association" "rt-main-association" {
  vpc_id = aws_vpc.vpcmain.id
  route_table_id = aws_route_table.rtmain.id
}

# Create NACL
resource "aws_network_acl" "nacl-main" {
  vpc_id = aws_vpc.vpcmain.id
  
  ingress = [
    {
      rule_no     = 100
      action      = "allow"
      protocol    = -1
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      icmp_code = null
      icmp_type = null
      ipv6_cidr_block = null
    },
    {
      rule_no     = 101
      action      = "allow"
      cidr_block  = null
      protocol    = -1
      from_port   = 0
      to_port     = 0
      icmp_code = null
      icmp_type = null
      ipv6_cidr_block = "::/0"
    }
  ]

  egress = [
    {
      rule_no     = 100
      action      = "allow"
      protocol    = -1
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      icmp_code = null
      icmp_type = null
      ipv6_cidr_block = null
    },
    {
      rule_no     = 101
      action      = "allow"
      cidr_block  = null
      protocol    = -1
      from_port   = 0
      to_port     = 0
      icmp_code = null
      icmp_type = null
      ipv6_cidr_block = "::/0"
    }
  ]
  
  tags = {
    Name = "ProjectNACL"
  }
}

resource "aws_network_acl_association" "naclassocation-pub" {
  network_acl_id = aws_network_acl.nacl-main.id
  count = 3
  subnet_id = aws_subnet.sn-pub[count.index].id
}
resource "aws_network_acl_association" "naclassocation-app" {
  network_acl_id = aws_network_acl.nacl-main.id
  count = 3
  subnet_id = aws_subnet.sn-app[count.index].id
}
resource "aws_network_acl_association" "naclassocation-db" {
  network_acl_id = aws_network_acl.nacl-main.id
  count = 3
  subnet_id = aws_subnet.sn-db[count.index].id
}

resource "aws_security_group" "wordpress-sg" {
  name        = "allow-access"
  description = "Control access to Wordpress Instance(s)"
  vpc_id      = aws_vpc.vpcmain.id

  ingress {
    description      = "Allow HTTP IPv4 IN"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpcmain.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Wordpress-SG"
  }
}
resource "aws_security_group" "database-sg" {
  name        = "allow-access"
  description = "Control access to Database"
  vpc_id      = aws_vpc.vpcmain.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Database-SG"
  }
}
resource "aws_security_group_rule" "database-sg-rule" {
  type              = "ingress"
  description       = "Allow MySQL IN"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpcmain.cidr_block]
  security_group_id = aws_security_group.wordpress-sg.id
}
resource "aws_security_group" "efs-sg" {
  name        = "allow-access"
  description = "Control access to EFS"
  vpc_id      = aws_vpc.vpcmain.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "EFS-SG"
  }
}
resource "aws_security_group_rule" "efs-sg-rule" {
  type              = "ingress"
  description       = "Allow NFS/EFS IPv4 IN"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpcmain.cidr_block]
  security_group_id = aws_security_group.wordpress-sg.id
}