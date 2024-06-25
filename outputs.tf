 output "public1_ip" {
  value = aws_instance.bastion_host.public_ip
}

/* output "public2_ip" {
  value = aws_instance.ec2_public2.public_ip
} */

output "privateUI1_ip" {
  value = aws_instance.ec2_privateUI1.private_ip  
}

output "privateUI2_ip" {
  value = aws_instance.ec2_privateUI2.private_ip  
}

output "privateAPI1_ip" {
  value = aws_instance.ec2_privateAPI1.private_ip  
}

output "privateAPI2_ip" {
  value = aws_instance.ec2_privateAPI2.private_ip  
}

output "alb_dns_name" {
  value = aws_lb.myalb.dns_name
}

output "nlb_dns_name" {
  value = aws_lb.nlb.dns_name
}

output "Private_API_Subnet1" {
  value = aws_subnet.PrivateSubnetAPI1.id
}

output "Private_API_Subnet2" {
  value = aws_subnet.PrivateSubnetAPI2.id
}



