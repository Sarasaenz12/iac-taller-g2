output "url" {
  value = "http://localhost:${var.puerto}"
}

# TODO 4 resuelto
output "contenedor" {
  value = docker_container.web.name
}

# TODO 5 resuelto
output "red_driver" {
  value = data.docker_network.bridge.driver
}