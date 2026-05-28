output "analytics_vm_internal_ip" {
  description = "Internal IP of analytics platform VM"
  value       = yandex_compute_instance.analytics.network_interface[0].ip_address
}

output "kafka_vm_internal_ip" {
  description = "Internal IP of Kafka event bus VM"
  value       = yandex_compute_instance.kafka.network_interface[0].ip_address
}

output "portal_vm_external_ip" {
  description = "External (NAT) IP of self-service portal VM"
  value       = yandex_compute_instance.portal.network_interface[0].nat_ip_address
}

output "portal_vm_internal_ip" {
  description = "Internal IP of self-service portal VM"
  value       = yandex_compute_instance.portal.network_interface[0].ip_address
}

output "vpc_network_id" {
  description = "VPC network ID"
  value       = yandex_vpc_network.main.id
}

output "private_subnet_id" {
  description = "Private routed subnet ID"
  value       = yandex_vpc_subnet.private_routed.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = yandex_vpc_subnet.public.id
}
