locals {
  tron_user_data = <<TFEOF
#! /bin/bash

apt-get update && apt-get install -y supervisor curl

# Install Docker
cd /home/ubuntu
apt-get install ca-certificates curl gnupg
chmod u+x parity
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


echo "[program:tron]
command=docker run -d --name="java-tron" \
             -v /home/ubuntu/output-directory:/java-tron/output-directory \
             -v /home/ubuntu/logs:/java-tron/logs \
             -p 8090:8090 -p 18888:18888 -p 50051:50051 \
             tronprotocol/java-tron \
             -c /java-tron/config/main_net_config.conf
autostart=true
autorestart=true
stderr_logfile=/var/log/tron.err.log
stdout_logfile=/var/log/tron.out.log" >> /etc/supervisor/conf.d/tron.conf

supervisorctl reread && supervisorctl update

mkdir -p ~/.aws

echo "[default]
region=${var.region}
output=json" >> ~/.aws/config

TFEOF
}

resource "aws_instance" "tron" {
  ami               = "${data.aws_ami.ubuntu-18_04.id}"
  count             = "${var.tron_count}"
  availability_zone = "${aws_ebs_volume.tron_block_storage.*.availability_zone[0]}"
  instance_type     = "${var.instance_type}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  # and sufficent amount of networking capabilities
  security_groups = ["${aws_security_group.tron.id}"]

  key_name  = "${aws_key_pair.deployer.key_name}"
  subnet_id = "${module.vpc.first-subnet-id}"

  user_data = "${local.tron_user_data}"

  provisioner "remote-exec" {
    inline = [
      #we need to add inline for tron start
    ]
  }
  connection {
    host        = "${self.public_ip}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.ssh_private_keypath)}"
  }

  tags = {
    Name = "tron-parity-${count.index + 1}"
  }
}
