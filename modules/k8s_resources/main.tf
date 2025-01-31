terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "notes_app" {
  metadata {
    name = "notes-app"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "notes-app-redis"
    namespace = kubernetes_namespace.notes_app.metadata[0].name
    labels = {
      app = "notes-app-redis"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-app-redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-app-redis"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 15
            period_seconds       = 20
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds       = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "notes-app-redis-service"
    namespace = kubernetes_namespace.notes_app.metadata[0].name
    labels = {
      app = "notes-app-redis"
    }
  }

  spec {
    selector = {
      app = "notes-app-redis"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}