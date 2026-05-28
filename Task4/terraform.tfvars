# Замените значения на реальные перед запуском
cloud_id  = "sprint-11"
folder_id = "b1g9olb7cafchlmql5s9"
zone      = "ru-central1-a"

network_name = "future20-network"

# Analytics platform (lakehouse + Spark)
analytics_vm_name        = "analytics-platform"
analytics_vm_cores       = 2
analytics_vm_memory      = 4
analytics_disk_size      = 20
analytics_data_disk_size = 20

# Kafka event bus
kafka_vm_name        = "event-bus"
kafka_vm_cores       = 2
kafka_vm_memory      = 4
kafka_disk_size      = 20
kafka_data_disk_size = 20

# Self-service portal (Superset / Metabase)
portal_vm_name    = "selfservice-portal"
portal_vm_cores   = 2
portal_vm_memory  = 2
portal_disk_size  = 20

image_family        = "ubuntu-2204-lts"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
