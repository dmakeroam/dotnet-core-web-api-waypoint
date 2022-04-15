project = "hashicorp-demo"

variable "environment" {
  type = string
}

variable "registryUserName" {
  type = string
  default = dynamic("vault", {
    path = "kv/data/container/registry"
    key  = "/data/username"
  })
  sensitive = true
}

variable "registryPassword" {
  type = string
  default = dynamic("vault", {
    path = "kv/data/container/registry"
    key  = "/data/password"
  })
  sensitive = true
}

variable "containerImageTag" {
  type = string
}

app "dotnetcore-webapi" {

  labels = {
    "service" = "dotnetcore-webapi",
    "environment" = var.environment
  }

  build {
    use "docker" {}
    registry {
      use "docker" {
        image = "kubeopstester/dotnetcore-webapi"
        tag   = var.containerImageTag
        auth {
          username = var.registryUserName
          password = var.registryPassword
        }
      }
    }
  }

  config {
    env = {
      ASPNETCORE_URLS = "http://*:8090"
      ASPNETCORE_ENVIRONMENT = var.environment
    }
  }

  deploy {
    use "kubernetes" {
      namespace    = "default"
      probe_path   = "/health"
      service_port = 8090
      cpu {
        request = "200m"
        limit = "300m"
      }
      memory {
        request = "512M"
        limit = "600M"
      }
    }
  }

  release {
    use "kubernetes" {
      load_balancer = true
      port          = 8090
    }
  }
}