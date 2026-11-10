output "red_driver" {
  value = data.docker_network.bridge.driver
}

# TODO 3 resuelto: map nombre => url recorriendo module.sitio
output "urls" {
  value = { for k, m in module.sitio : m.nombre => m.url }
}
