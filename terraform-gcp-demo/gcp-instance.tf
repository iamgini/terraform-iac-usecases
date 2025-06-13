provider "google" {
  credentials = file("~/.gcp/mg-devops-febabc6f0c0a.json")
  project = "mg-devops"
  region  = "asia-southeast1" # Singapore
  zone    = "asia-southeast1-a"
}

resource "google_compute_instance" "gcp_sandbox" {
  name         = "gcp-sandbox"
  machine_type = "n1-standard-1"
  zone    = "us-central1-c"
  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}