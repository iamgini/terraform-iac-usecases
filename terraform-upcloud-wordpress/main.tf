terraform {
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 2.0"
    }
  }
}

provider "upcloud" {}


resource "upcloud_storage" "debian-2cpu-4gb-au-syd1_Device_1" {
  size  = 80
  tier  = "maxiops"
  title = "debian-2cpu-4gb-au-syd1 Device 1"
  zone  = "au-syd1"
}

resource "upcloud_network" "WP-NW" {
  name   = "WP-NW"
  zone   = "au-syd1"
  router = upcloud_router.RO.id

  ip_network {
    address            = "10.0.0.0/24"
    dhcp               = true
    dhcp_default_route = true
    family             = "IPv4"
    gateway            = "10.0.0.1"
  }
}

resource "upcloud_server" "wp-101" {
  firewall = false
  hostname = "wp-101"
  metadata = true
  title    = "wp-101"
  zone     = "au-syd1"
  plan     = "2xCPU-4GB"

 login {
    user = "root"
    keys = [
      var.public_key,
    ]
    create_password   = false
    password_delivery = "none"
  }

  network_interface {
    ip_address_family = "IPv4"
    type              = "public"
  }

  network_interface {
    ip_address_family = "IPv4"
    type              = "utility"
  }

  network_interface {
    ip_address_family = "IPv6"
    type              = "public"
  }

  network_interface {
    ip_address_family = "IPv4"
    type              = "private"
    network           = upcloud_network.WP-NW.id
  }

  storage_devices {
    address = "virtio"
    storage = upcloud_storage.debian-2cpu-4gb-au-syd1_Device_1.id
    type    = "disk"
  }
}

resource "upcloud_router" "RO" {
  name = "RO"
}

resource "upcloud_managed_database_mysql" "wpdb" {
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "05:00:00"
  name                    = "wpdb"
  plan                    = "1x1xCPU-2GB-25GB"
  powered                 = true
  title                   = "mysql-1x1xcpu-2gb-25gb-au-syd1"
  zone                    = "au-syd1"

  properties {
    automatic_utility_network_ip_filter = true
    backup_hour                         = 1
    backup_minute                       = 48
    ip_filter                           = ["10.0.0.0/24", "0.0.0.0/0"]
    sql_mode                            = "ANSI,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,STRICT_ALL_TABLES"
    sql_require_primary_key             = true
    version                             = "8"
  }
}

resource "upcloud_managed_database_user" "wpdemositedbuser" {
  service  = upcloud_managed_database_mysql.wpdb.id
  username = "wpdemositedbuser"
}

resource "upcloud_managed_database_logical_database" "wpdemosite" {
  name    = "wpdemosite"
  service = upcloud_managed_database_mysql.wpdb.id
}