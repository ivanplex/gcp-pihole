output "vpn_public_addr" {
  value       = google_compute_address.static.address
  description = "The public IP address of the VPN server."
}