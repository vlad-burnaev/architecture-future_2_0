terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
  required_version = ">= 1.3"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# ─── Network ────────────────────────────────────────────────────────────────

resource "yandex_vpc_network" "main" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "private" {
  name           = "${var.network_name}-private"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.network_name}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

# NAT gateway — исходящий трафик из приватной подсети
resource "yandex_vpc_gateway" "nat" {
  name = "${var.network_name}-nat-gw"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private_rt" {
  name       = "${var.network_name}-private-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# Привязываем таблицу маршрутов к приватной подсети
resource "yandex_vpc_subnet" "private_routed" {
  name           = "${var.network_name}-private-routed"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.2.0/24"]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

# ─── Security groups ────────────────────────────────────────────────────────

resource "yandex_vpc_security_group" "analytics" {
  name       = "sg-analytics"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH"
  }
  ingress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["10.10.0.0/16"]
    description    = "Spark / Jupyter UI (internal)"
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kafka" {
  name       = "sg-kafka"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH"
  }
  ingress {
    protocol       = "TCP"
    port           = 9092
    v4_cidr_blocks = ["10.10.0.0/16"]
    description    = "Kafka broker (internal)"
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "portal" {
  name       = "sg-portal"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH"
  }
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTPS portal"
  }
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP redirect"
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ─── Disk images ────────────────────────────────────────────────────────────

data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

# ─── Analytics platform VM ──────────────────────────────────────────────────

resource "yandex_compute_disk" "analytics_data" {
  name = "${var.analytics_vm_name}-data"
  type = "network-ssd"
  zone = var.zone
  size = var.analytics_data_disk_size
}

resource "yandex_compute_instance" "analytics" {
  name        = var.analytics_vm_name
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = var.analytics_vm_cores
    memory = var.analytics_vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.analytics_disk_size
      type     = "network-ssd"
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.analytics_data.id
    mode    = "READ_WRITE"
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_routed.id
    security_group_ids = [yandex_vpc_security_group.analytics.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}

# ─── Kafka / event bus VM ───────────────────────────────────────────────────

resource "yandex_compute_disk" "kafka_data" {
  name = "${var.kafka_vm_name}-data"
  type = "network-ssd"
  zone = var.zone
  size = var.kafka_data_disk_size
}

resource "yandex_compute_instance" "kafka" {
  name        = var.kafka_vm_name
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = var.kafka_vm_cores
    memory = var.kafka_vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.kafka_disk_size
      type     = "network-ssd"
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.kafka_data.id
    mode    = "READ_WRITE"
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_routed.id
    security_group_ids = [yandex_vpc_security_group.kafka.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}

# ─── Self-service portal VM ─────────────────────────────────────────────────

resource "yandex_compute_instance" "portal" {
  name        = var.portal_vm_name
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = var.portal_vm_cores
    memory = var.portal_vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.portal_disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.portal.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}

# ─── Object Storage bucket (lakehouse raw layer) ────────────────────────────
# Требует статических ключей сервисного аккаунта (access_key / secret_key).
# Создаётся вручную через консоль Yandex Cloud или отдельным пайплайном.
# resource "yandex_storage_bucket" "lakehouse" { ... }
