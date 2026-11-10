terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.6"
    }
  }

  backend "pg" {}
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

module "sitio" {
  for_each = local.sitios
  source   = "./modules/sitio_web"

  nombre  = "${each.key}-g${var.grupo}-${local.entorno}"
  puerto  = each.value
  mensaje = "${title(each.key)} - ${upper(local.entorno)} - grupo ${var.grupo}"
  imagen  = local.amb.imagen # TODO 2 resuelto: imagen del ambiente
}
