project = "hashicorp-demo"

variable "registryUsername" {
  type = string
}

variable "registryPassword" {
  type = string
}

app "dotnetcore-webapi" {

  labels = {
    "service" = "dotnetcore-webapi",
    "environment" = "Development"
  }

  build {
    use "docker" {}
    registry {
      use "docker" {
        image = "kubeopstester/dotnetcore-webapi"
        tag   = "1.0.1"
        auth {
          username = var.registryUsername
          password = var.registryPassword
        }
      }
    }
  }

  config {
    env = {
      ASPNETCORE_URLS = "http://*:8090"
      ASPNETCORE_ENVIRONMENT = "Development"
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