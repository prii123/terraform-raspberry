# Conexión SSH sin proveedor de DigitalOcean
resource "null_resource" "configuracion_droplet" {

  # Ejecutar comandos en el droplet
  provisioner "remote-exec" {
    inline = [
      # Actualizar y actualizar paquetes
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",

      # Instalar Docker
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",

      # Instalar Docker Compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",

      # Crear las carpetas necesarias
      "mkdir -p ~/data/storage",
      "mkdir -p ~/data/mysql_data",

      # Copiar el archivo docker-compose.yml desde local al droplet
      #"cp ~/data/docker-compose.yml ~/data/docker-compose.yml",
      "echo '${file("${path.module}/docker-compose.yml")}' > ~/data/docker-compose.yml",

      # Cambiar al directorio donde se encuentra el archivo docker-compose.yml
      "cd ~/data && sudo docker-compose up -d"
    ]

    # Conexión SSH
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_rsa")  # Ruta de tu clave privada SSH
      host        = "111.111.44.55"  # Dirección IP pública de tu droplet
    }
  }



}
