output "tron-public_ip" {
  value = "${aws_instance.tron.*.public_ip}"
}

output "tron-public_dns" {
  value = "${aws_instance.tron.*.public_dns}"
}
