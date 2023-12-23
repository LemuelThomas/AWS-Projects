terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.31.0"
      }
    }
}

# Create LT
resource "aws_launch_template" "project-lt" {
  name = "project-lt"
  image_id = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  iam_instance_profile {
    arn = "arn:aws:iam::231442145948:instance-profile/A4LVPC-WordpressInstanceProfile-Cb6jUKO3bYMW"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Main LT"
    }
  }
  user_data = filebase64("${path.module}/user-data.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups = ["sg-04c80163e1f478289"]
  }
}

# Create SSM Parameters
resource "aws_ssm_parameter" "ssm-db-user" {
  name        = "/A4L/Wordpress/DBUser"
  description = "Wordpress Database User"
  type        = "String"
  data_type   = "text"
  tier        = "Standard"
  value       = "a4lwordpressuser"
}
resource "aws_ssm_parameter" "ssm-db-name" {
  name        = "/A4L/Wordpress/DBName"
  description = "Wordpress Database Name"
  type        = "String"
  data_type   = "text"
  tier        = "Standard"
  value       = "a4lwordpressdb"
}
resource "aws_ssm_parameter" "ssm-db-endpoint" {
  name        = "/A4L/Wordpress/DBEndpoint"
  description = "WordPress DB Endpoint Name"
  type        = "String"
  data_type   = "text"
  tier        = "Standard"
  value       = "localhost"
}
resource "aws_ssm_parameter" "ssm-db-password" {
  name        = "/A4L/Wordpress/DBPassword"
  description = "Wordpress DB Password"
  type        = "SecureString"
  data_type   = "text"
  tier        = "Standard"
  value       = "4n1m4l54L1f3"
  key_id      = "alias/aws/ssm"
}
resource "aws_ssm_parameter" "ssm-db-root-password" {
  name        = "/A4L/Wordpress/DBRootPassword"
  description = "Wordpress DBRoot Password"
  type        = "SecureString"
  data_type   = "text"
  tier        = "Standard"
  value       = "4n1m4l54L1f3"
  key_id      = "alias/aws/ssm"
}
resource "aws_ssm_parameter" "ssm-alb-dns-name" {
  name        = "/A4L/Wordpress/ALBDNSNAME"
  description = "DNS Name of the Application Load Balancer for wordpress"
  type        = "String"
  data_type   = "text"
  tier        = "Standard"
  value       = aws_alb.project-alb.dns_name
}
resource "aws_ssm_parameter" "ssm-efs-id" {
  name        = "/A4L/Wordpress/EFSFSID"
  description = "File System ID for Wordpress Content (wp-content)"
  type        = "String"
  data_type   = "text"
  tier        = "Standard"
  value       = aws_efs_file_system.project-efs.id
}