provider "null" {}

resource "null_resource" "install_python" {
  connection {
    type        = "ssh"
    timeout     = "5m"
    host        = "192.168.1.1"
    user        = "orangepi"
    password    = "orangepi"
  }

  provisioner "remote-exec" {
    inline = [
      # Actualiza el sistema e instala Python
      "echo '${var.sudo_password}' | sudo -S apt update -y",
      "echo '${var.sudo_password}' | sudo -S apt install -y git",
      "echo '${var.sudo_password}' | sudo -S apt install -y curl git make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev",
      "echo '${var.sudo_password}' | sudo -S apt-get install -y build-essential libffi-dev libc6-dev",
      "echo '${var.sudo_password}' | sudo -S apt install cmake -y",
      "curl https://pyenv.run | bash",
      "export PATH=\"$HOME/.pyenv/bin:$PATH\"",
      "eval \"$(pyenv init --path)\"",
      "eval \"$(pyenv init -)\"",
      "pyenv install 3.10.0",
      "pyenv global 3.10.0",
      "sudo apt-get install -y libhdf5-dev",


      # Instalación de Docker
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo usermod -aG docker ${var.usuario_pi}",
      "rm get-docker.sh",

      # Instalación de NVM (Node Version Manager)
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash",
      # Usamos 'bash -c' para asegurarnos de que el entorno correcto se aplique
      "source ~/.bashrc",
      "fnm use --install-if-missing 22",

      # Cargar y exportar NVM_DIR y luego instalar Node.js
      "bash -c 'export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\" && nvm install 22'",

      # Configuración de GitHub con el token de acceso
      "echo -e 'machine github.com\nlogin ${var.github_token}\npassword ${var.github_token}' > ~/.netrc",
      "chmod 600 ~/.netrc",

      # Clona el repositorio privado
      #"rm -rf /home/${var.usuario_pi}/'${var.repo1}'",
      "git clone '${var.repoGit1}' /home/${var.usuario_pi}/'${var.repo1}'",
      "git clone '${var.repoGit2}' /home/${var.usuario_pi}/'${var.repo2}'",


      # Acceso a la carpeta del repositorio e instalación de dependencias
      "bash -c 'cd /home/${var.usuario_pi}/'${var.repo1}' && export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\" && npm install'",


      # Acceso a la carpeta del repositorio e instalación de dependencias
      #"cd /home/${var.usuario_pi}/'${var.repo2}'",
      #"python3 -m venv venv",                             # Crea el entorno virtual en la carpeta actual
      #"bash -c 'source venv/bin/activate && pip install -r requirements.txt'"  # Activa y usa pip desde venv
      #"bash -c 'cd /home/${var.usuario_pi}/'${var.repo2}' && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt'"


     "cd /home/${var.usuario_pi}/'${var.repo2}'",
     "python3 -m venv venv",
     ". venv/bin/activate",
     #"./venv/bin/pip install --upgrade pip setuptools",
     "python -c 'import ctypes'",
     "./venv/bin/pip install -r requirements.txt"


    ]
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token"
}


variable "usuario_pi" {
  type        = string
  description = "usuario raspi"
}

variable "sudo_password" {
  description = "Password for sudo commands"
  type        = string
  sensitive   = false
}


variable "repo1" {
  type        = string
  description = "carpeta de clonacion proyecto"
}

variable "repo2" {
  type        = string
  description = "carpeta de clonacion proyecto"
}

variable "repoGit1" {
  type        = string
  description = "clonacion proyecto de git 1"
}

variable "repoGit2" {
  type        = string
  description = "clonacion proyecto de git 1"
}


