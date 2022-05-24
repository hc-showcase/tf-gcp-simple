variable "server_port" {
   description = "The server port"
   type        = number
}

provider "google" {
  project     = "msk-pub"
}

resource "google_compute_network" "example_network" {
  name                    = "example-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_instance" "vm" {
  name         = "vm0815"
  machine_type = "n1-standard-2"
  zone         = "europe-west3-a"
  hostname     = "vm0815.msk.pub"

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2110-impish-v20220505"
      size  = 10
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = google_compute_network.example_network.name

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<EOT
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p ${var.server_port} &
EOT

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_firewall" "default" {
  name    = "firewall"
  network = google_compute_network.example_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["${var.server_port}"]
  }

  target_tags = ["web"]
}

resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket" "bucket" {
  name = "static-content-bucket-msk-0815"
  location = "EU"
}

output "vm" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
  sensitive = true
}
