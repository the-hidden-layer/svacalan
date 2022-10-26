output "id" {
  value = [aws_spot_instance_request.node.*.id]
}

output "public-ip" {
  value = [aws_spot_instance_request.node.*.public_ip]
  description = "Public IP address"
}

output "key-name" {
  value = [aws_spot_instance_request.node.*.key_name]
}

output "spot_bid_status" {
  description = "The bid status of the AWS EC2 Spot Instance request(s)."
  value       = [aws_spot_instance_request.node.*.spot_bid_status]
}

output "spot_request_state" {
  description = "The state of the AWS EC2 Spot Instance request(s)."
  value       = [aws_spot_instance_request.node.*.spot_request_state]
}
