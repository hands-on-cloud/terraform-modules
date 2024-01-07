output "jumphost_id" {
  value = aws_instance.jump_host.id
}

output "ssm_command_jumphost_pwd_reset" {
  value = "aws ssm start-session --target ${aws_instance.jump_host.id} --document-name 'AWS-PasswordReset' --parameters username='Administrator'"
}

output "ssm_command_jumphost_port_forward" {
  value = "aws ssm start-session --target ${aws_instance.jump_host.id} --document-name 'AWS-StartPortForwardingSession' --parameters portNumber='3389',localPortNumber='53389'"
}

output "rdp_jumphost_fqdn" {
  value = "localhost:53389"
}

output "rdp_jumphost_user" {
  value = "${aws_instance.jump_host.id}\\Administrator"
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}
