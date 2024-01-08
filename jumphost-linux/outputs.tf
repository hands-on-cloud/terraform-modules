output "jumphost_id" {
  description = "The ID of the jumphost"
  value = aws_instance.jump_host.id
}

output "ssm_command_jumphost_pwd_reset" {
  description = "SSM command to reset jumphost password"
  value = "aws ssm start-session --target ${aws_instance.jump_host.id} --document-name 'AWS-PasswordReset' --parameters username='ec2-user'"
}

output "ssm_command_jumphost_port_forward" {
  description = "SSM command to port forward RDP session to jumphost"
  value = "aws ssm start-session --target ${aws_instance.jump_host.id} --document-name 'AWS-StartPortForwardingSession' --parameters portNumber='3389',localPortNumber='53389'"
}

output "ssm_command_jumphost_ssh" {
  description = "SSM command to SSH to jumphost"
  value = "aws ssm start-session --target ${aws_instance.jump_host.id}"
}

output "rdp_jumphost_fqdn" {
  description = "FQDN of jumphost RDP session"
  value = "localhost:53389"
}

output "rdp_jumphost_user" {
  description = "User of jumphost RDP session"
  value = "ec2-user"
}

output "security_group_id" {
  description = "The ID of the security group"
  value = aws_security_group.ec2_sg.id
}
