variable "rpi_ip" {
  description = "Dirección IP fija para la Raspberry Pi"
  type        = string
}

variable "rpi_netmask" {
  description = "Máscara de red para la IP fija"
  default     = "24"
}

variable "rpi_gateway" {
  description = "Puerta de enlace predeterminada"
  type        = string
}

variable "rpi_dns" {
  description = "Servidor DNS"
  default     = "8.8.8.8"
}

variable "ssh_user" {
  description = "Usuario SSH para la Raspberry Pi"
  default     = "pi"
}

variable "ssh_private_key" {
  description = "Ruta al archivo de clave privada SSH"
  default     = "~/.ssh/id_rsa"
}

variable "compose_dir" {
  description = "Ruta donde se guardará el archivo docker-compose.yml"
  default     = "/home/pi/mysql-server"
}
