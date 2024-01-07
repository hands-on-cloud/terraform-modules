output "jumphost_id" {
  value = aws_instance.jumphost.id
}

output "ssm_command_jumphost_pwd_reset" {
  value = "aws ssm start-session --target ${aws_instance.jumphost.id} --document-name 'AWS-PasswordReset' --parameters username='Administrator'"
}

output "ssm_command_jumphost_port_forward" {
  value = "aws ssm start-session --target ${aws_instance.jumphost.id} --document-name 'AWS-StartPortForwardingSession' --parameters portNumber='3389',localPortNumber='53389'"
}

output "rdp_jumphost_fqdn" {
  value = "localhost:53389"
}

output "rdp_jumphost_user" {
  value = "${aws_instance.jumphost.id}\\Administrator"
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}
