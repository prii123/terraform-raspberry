provider "null" {}

provider "local" {}

provider "template" {}

provider "tls" {}

provider "ssh" {}

resource "ssh_resource" "set_static_ip" {
  connection {
    type        = "ssh"
    host        = var.rpi_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'echo \"interface eth0\" >> /etc/dhcpcd.conf'",
      "sudo bash -c 'echo \"static ip_address=${var.rpi_ip}/${var.rpi_netmask}\" >> /etc/dhcpcd.conf'",
      "sudo bash -c 'echo \"static routers=${var.rpi_gateway}\" >> /etc/dhcpcd.conf'",
      "sudo bash -c 'echo \"static domain_name_servers=${var.rpi_dns}\" >> /etc/dhcpcd.conf'",
      "sudo systemctl restart dhcpcd"
    ]
  }
}

resource "ssh_resource" "install_docker" {
  depends_on = [ssh_resource.set_static_ip]

  connection {
    type        = "ssh"
    host        = var.rpi_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo usermod -aG docker ${var.ssh_user}",
      "sudo apt-get install -y docker-compose"
    ]
  }
}

resource "ssh_resource" "setup_docker_compose" {
  depends_on = [ssh_resource.install_docker]

  connection {
    type        = "ssh"
    host        = var.rpi_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.compose_dir}",
      "echo '${file("${path.module}/docker-compose.yml")}' > ${var.compose_dir}/docker-compose.yml",
      "cd ${var.compose_dir} && sudo docker-compose up -d"
    ]
  }
}

resource "ssh_resource" "setup_docker_autostart" {
  depends_on = [ssh_resource.setup_docker_compose]

  connection {
    type        = "ssh"
    host        = var.rpi_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'cat <<EOL > /etc/systemd/system/docker-compose-mysql.service\n\
      [Unit]\n\
      Description=Docker Compose Application Service\n\
      Requires=docker.service\n\
      After=docker.service\n\
      \n\
      [Service]\n\
      Restart=always\n\
      WorkingDirectory=${var.compose_dir}\n\
      ExecStart=/usr/bin/docker-compose up -d\n\
      ExecStop=/usr/bin/docker-compose down\n\
      TimeoutStartSec=0\n\
      \n\
      [Install]\n\
      WantedBy=multi-user.target\n\
      EOL'",
      "sudo systemctl enable docker-compose-mysql.service",
      "sudo systemctl start docker-compose-mysql.service"
    ]
  }
}
