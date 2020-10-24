// Configure the Google Cloud provider
provider "google" {
 credentials = file("gcp_vpn_proj_cred.json")
 project     = "whitebox-infrastructure"
 region      = "asia-east2"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
  // network_tier = "STANDARD"
}

resource "google_compute_firewall" "allow-openvpn" {
  name          = "allow-openvpn"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vpn"]

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }
}

// A single Compute Engine instance
resource "google_compute_instance" "default" {
 name         = "vpn-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "asia-east2-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update && apt-get upgrade -y"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
     nat_ip = google_compute_address.static.address
   }
 }
 tags = ["vpn"]
}
