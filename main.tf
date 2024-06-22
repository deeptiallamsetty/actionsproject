/* data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/*20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    
    owners = ["099720109477"] # Canonical - donno what this is
}
 */

terraform {
 backend "s3" {
	bucket     	= "terrfaorm-state-bucket"
	key        	= "createec2-actions"
	region     	= "us-east-1"
	encrypt    	= true
	dynamodb_table = "terrfaorm-state-bucket-lock"
  }
}

provider "aws" {
  region  = "us-east-1"
}
resource "aws_instance" "app_server" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
#  key_name      = "efs-kp"
tags = {
    Name = "github_ec2_name"
  }
}
#adding a commentajhflashf alkwjalwkehlawrhzxfsadfasdfasdf
#making this change in root directory to commit to git branch
#adding comment to test pull request worklow