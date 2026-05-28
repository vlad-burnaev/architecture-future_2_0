variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "future20-network"
}

# Analytics platform VM
variable "analytics_vm_name" {
  description = "Analytics platform VM name"
  type        = string
  default     = "analytics-platform"
}

variable "analytics_vm_cores" {
  description = "vCPU count for analytics VM"
  type        = number
  default     = 4
}

variable "analytics_vm_memory" {
  description = "RAM in GB for analytics VM"
  type        = number
  default     = 16
}

variable "analytics_disk_size" {
  description = "Boot disk size in GB for analytics VM"
  type        = number
  default     = 100
}

variable "analytics_data_disk_size" {
  description = "Data disk size in GB for analytics VM (lakehouse storage)"
  type        = number
  default     = 500
}

# Kafka / event bus VM
variable "kafka_vm_name" {
  description = "Kafka broker VM name"
  type        = string
  default     = "event-bus"
}

variable "kafka_vm_cores" {
  description = "vCPU count for Kafka VM"
  type        = number
  default     = 2
}

variable "kafka_vm_memory" {
  description = "RAM in GB for Kafka VM"
  type        = number
  default     = 8
}

variable "kafka_disk_size" {
  description = "Boot disk size in GB for Kafka VM"
  type        = number
  default     = 50
}

variable "kafka_data_disk_size" {
  description = "Data disk size in GB for Kafka VM (message log)"
  type        = number
  default     = 200
}

# Self-service portal VM
variable "portal_vm_name" {
  description = "Self-service portal VM name"
  type        = string
  default     = "selfservice-portal"
}

variable "portal_vm_cores" {
  description = "vCPU count for portal VM"
  type        = number
  default     = 2
}

variable "portal_vm_memory" {
  description = "RAM in GB for portal VM"
  type        = number
  default     = 4
}

variable "portal_disk_size" {
  description = "Boot disk size in GB for portal VM"
  type        = number
  default     = 30
}

variable "image_family" {
  description = "OS image family"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
