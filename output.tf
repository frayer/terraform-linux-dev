output "public_ip" {
    value = aws_spot_instance_request.dev_instance.public_ip
}
