resource "aws_ebs_volume" "tron_block_storage" {
  count             = "${var.tron_count}"
  size              = 500
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "${var.application}-tron-storage"
  }
}

resource "aws_volume_attachment" "tron_block_storage_attachment" {
  count             = "${var.tron_count}"
  device_name  = "/dev/sdh"
  force_detach = true
  volume_id = "${element(aws_ebs_volume.tron_block_storage.*.id, count.index)}"
  instance_id = "${element(aws_instance.tron.*.id, count.index)}"
}
