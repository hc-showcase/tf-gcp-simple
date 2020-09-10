variable "project" {
  default = "mkaesz" 
}

provider "google" {
#  credentials = file("~/.config/gcloud/application_default_credentials.json")
  project     = var.project
}

data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_instance" "tfe" {
  name         = "tfe-0815"
  machine_type = "n1-standard-8"
  zone         = "europe-west3-a"
  hostname     = "blub.msk.pub"

  tags = ["tfe", "manual"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20200618"
      size  = 100
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

output "tfe" {
  value = google_compute_instance.tfe
}
