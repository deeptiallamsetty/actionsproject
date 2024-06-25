provider "aws" {
  region = "us-east-1"
}

terraform {
 backend "s3" {
	bucket     	= "terrfaorm-state-bucket"
	key        	= "createec2-actions"
	region     	= "us-east-1"
	encrypt    	= true
	dynamodb_table = "terrfaorm-state-bucket-lock"
  }
}


resource "aws_vpc" "myvpc1" {
  cidr_block = "10.0.0.0/16"
}

#create a igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc1.id
}

#create a public subnet 1
resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.myvpc1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Public-Subnet 1a"
  }
}

#create a public subnet 2
resource "aws_subnet" "PublicSubnet2" {
  vpc_id                  = aws_vpc.myvpc1.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Public-Subnet 1b"
  }

}

#create a private subnet 1
resource "aws_subnet" "PrivateSubnetUI1" {
  vpc_id            = aws_vpc.myvpc1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet UI 1a"
  }

}

#create a private subnet 2
resource "aws_subnet" "PrivateSubnetUI2" {
  vpc_id            = aws_vpc.myvpc1.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet UI 1b"
  }
}

resource "aws_subnet" "PrivateSubnetAPI1" {
  vpc_id            = aws_vpc.myvpc1.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet API 1a"
  }
}

resource "aws_subnet" "PrivateSubnetAPI2" {
  vpc_id            = aws_vpc.myvpc1.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet API 1b"
  }
}

#security group for public subnet
resource "aws_security_group" "publicSG" {
  name   = "web"
  vpc_id = aws_vpc.myvpc1.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-sg"
  }
}

#Security group for private subnet
resource "aws_security_group" "privateSG" {
  name   = "privateSG"
  vpc_id = aws_vpc.myvpc1.id

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.publicSG.id]
  }

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.publicSG.id]
  }

    ingress {
    description     = "API"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.publicSG.id]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private-sg"
  }
}

resource "aws_security_group" "privateAPISG" {
  name   = "privateAPISG"
  vpc_id = aws_vpc.myvpc1.id

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.privateSG.id]
  }

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.privateSG.id]
  }

    ingress {
    description     = "API"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.publicSG.id]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PrivateAPI-sg"
  }
}


#################
##Route Tables
#################

#routeTables for public subnet
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.myvpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#route table association for public subnet1
resource "aws_route_table_association" "PublicRtAssociation1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.rt_public.id
}

#route table association for public subnet2
resource "aws_route_table_association" "PublicRtAssociation2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.rt_public.id
}


#############
##NAT Gateway
#############

#creating elatic ip for NAT Gateway
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.PublicRtAssociation1
  ]
}

#allocating eip for nat gateway
resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id

  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.PublicSubnet1.id
  tags = {
    Name = "Nat-Gateway_Project"
  }
}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY
  ]
  vpc_id = aws_vpc.myvpc1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }
  tags = {
    Name = "Route Table for NAT Gateway"
  }
}

# Creating an Route Table Association of the NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = aws_subnet.PrivateSubnetUI1.id
  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

resource "aws_route_table_association" "Nat-Gateway-RT-Association2" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = aws_subnet.PrivateSubnetUI2.id
  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

resource "aws_route_table_association" "Nat-Gateway-RT-Association1a" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = aws_subnet.PrivateSubnetAPI1.id
  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

resource "aws_route_table_association" "Nat-Gateway-RT-Association1b" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = aws_subnet.PrivateSubnetAPI2.id
  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

#########################
##NAT Gateway Complete##
#########################

#EC2 Instances
resource "aws_instance" "bastion_host" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.publicSG.id]
  subnet_id              = aws_subnet.PublicSubnet1.id
  key_name               = "efs-kp"
  tags = {
    Name = "ec2_public1"
  }

/*   user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install apache2 -y
                sudo chmod 777 /var/www/html/index.html
                echo "Public Server 1" > /var/www/html/index.html
                >> 
                EOF
 */} 

/* resource "aws_instance" "ec2_public2" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.publicSG.id]
  subnet_id              = aws_subnet.PublicSubnet2.id
  key_name               = "efs-kp"
  tags = {
    Name = "ec2_public2"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install apache2 -y
                sudo chmod 777 /var/www/html/index.html
                echo "Public Server 2" > /var/www/html/index.html
                >> 
                EOF

}
 */
resource "aws_instance" "ec2_privateUI1" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.privateSG.id]
  subnet_id              = aws_subnet.PrivateSubnetUI1.id
  key_name               = "efs-kp"

  tags = {
    Name = "ec2_privateUI1"
  }

  /* user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install nginx -y
                sudo chmod 777 /var/www/html/index.html
                echo "Private Server 1" > /var/www/html/index.html
                >> 
                EOF
 */
}

resource "aws_instance" "ec2_privateUI2" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.privateSG.id]
  subnet_id              = aws_subnet.PrivateSubnetUI2.id
  key_name               = "efs-kp"

  tags = {
    Name = "ec2_privateUI2"
  }

  /* user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install nginx -y
                sudo chmod 777 /var/www/html/index.html
                echo "Private Server 2" > /var/www/html/index.html
                >> 
                EOF
  */
}

resource "aws_instance" "ec2_privateAPI1" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  #vpc_security_group_ids = [aws_security_group.privateSG.id, aws_security_group.privateAPISG.id]
  vpc_security_group_ids = [aws_security_group.publicSG.id]
  subnet_id              = aws_subnet.PrivateSubnetAPI1.id
  key_name               = "efs-kp"

  tags = {
    Name = "ec2_privateAPI1"
  }
}

resource "aws_instance" "ec2_privateAPI2" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  #vpc_security_group_ids = [aws_security_group.privateSG.id, aws_security_group.privateAPISG.id]
  vpc_security_group_ids = [aws_security_group.publicSG.id]
  subnet_id              = aws_subnet.PrivateSubnetAPI2.id
  key_name               = "efs-kp"

  tags = {
    Name = "ec2_privateAPI2"
  }
}



##########################################################################
##Load Balancer Resources##
##########################################################################
resource "aws_lb" "myalb" {
  name               = "mywebalb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.publicSG.id]
  subnets = [aws_subnet.PublicSubnet1.id, aws_subnet.PublicSubnet2.id]

  tags = {
    Name = "Public Subnet Load Balancer"
  }
}

resource "aws_lb_target_group" "mytg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc1.id
  ##target_type = "ip"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mytg.arn    
  }
}

/* resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.ec2_public1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.ec2_public2.id
  port             = 80
} */

resource "aws_lb_target_group_attachment" "attach3" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.ec2_privateUI1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach4" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.ec2_privateUI2.id
  port             = 80
}


######################################################################
#####Create Network Load Balancer###############################
######################################################################

resource "aws_lb" "nlb" {
  name               = "nlb"
  internal           = true
  load_balancer_type = "network"
  #security_groups = [aws_security_group.privateSG.id, aws_security_group.privateAPISG.id]
  security_groups = [aws_security_group.publicSG.id]
  subnets            = [aws_subnet.PrivateSubnetAPI1.id, aws_subnet.PrivateSubnetAPI2.id]

  tags = {
    Name = "my-nlb"
  }
}

# Create a target group
resource "aws_lb_target_group" "nlbtg" {
  name        = "api-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.myvpc1.id
  target_type = "instance"
}

# Register instances with the target group
resource "aws_lb_target_group_attachment" "api1" {
  target_group_arn = aws_lb_target_group.nlbtg.arn
  target_id        = aws_instance.ec2_privateAPI1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "api2" {
  target_group_arn = aws_lb_target_group.nlbtg.arn
  target_id        = aws_instance.ec2_privateAPI2.id
  port             = 80
}

# Create a listener
resource "aws_lb_listener" "nlblistener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlbtg.arn
  }
}