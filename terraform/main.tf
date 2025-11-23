provider "kubernetes" {
  config_path = "~/.kube/config"
}
# Backend Deployment
resource "kubernetes_deployment" "backend" {
  metadata { # FIX 1: The required metadata block
    name = "backend"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name  = "backend"
          image = "coffee-backend"
          image_pull_policy = "Never"
          port { # FIX 2: Correct block syntax (no '=')
            container_port = 5000
          }
          env { # FIX 3: Correct block syntax (no '=')
            name  = "REDIS_HOST"
            value = "redis"
          }
        }
      }
    }
  }
}

# Backend Service
resource "kubernetes_service" "backend_service" {
  metadata {
    name = "backend" # <--- This is the fix!
  }  
  spec{
    selector =  {
        app = "backend"
    }
    port{
        protocol = "TCP"
        port = 80      
        target_port = 5000
    }
    type = "ClusterIP"
  }
}

# Frontend Deployment
resource "kubernetes_deployment" "frontend_deployment" {
  metadata {
    name = "frontend"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          name  = "frontend"
          image = "coffee-frontend" 
          image_pull_policy = "Never"
          port {
            container_port = 80
          }
          # No env block here, as the frontend doesn't need to find Redis!
        }
      }
    }
  }
}

# Frontend Service

resource "kubernetes_service" "frontend_service" {
  metadata {
    name = "frontend"
  }
  spec {
    selector = {
      app = "frontend"
    }
    # We need to expose this to the outside world!
    type = "NodePort"
    port {
      port = 80
      target_port = 80
    }
  }
}
resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          name  = "redis"
          image = "redis:alpine"
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis_service" {
  metadata {
    name = "redis"
  }
  spec {
    selector = {
      app = "redis"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}