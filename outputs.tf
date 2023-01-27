output "service_name" {
  description = "Service name for Chevereto deployment"
  value       = kubernetes_service.chevereto.metadata.0.name
}

output "service_port" {
  description = "Port exposed by the service"
  value       = kubernetes_service.chevereto.spec.0.port.0.name
}
