output "namespace_name" {
  description = "Name of the created Kubernetes namespace"
  value       = kubernetes_namespace.notes_app.metadata[0].name
}

output "redis_service_name" {
  description = "Name of the Redis service"
  value       = kubernetes_service.nginx.metadata[0].name
}

output "redis_service_cluster_ip" {
  description = "Cluster IP of the Redis service"
  value       = kubernetes_service.nginx.spec[0].cluster_ip
}