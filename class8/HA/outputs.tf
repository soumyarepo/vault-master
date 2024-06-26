output "public_ips_lb" {
  value = azurerm_public_ip.public_ip_lb.ip_address
}

output "public_ips_vm" {
  value = [for ip in azurerm_public_ip.public_ip_vm : ip.ip_address]
}