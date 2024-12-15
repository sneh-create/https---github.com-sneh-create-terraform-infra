output "vmpubips" {
  value = azurerm_public_ip.testpubid.*.ip_address
}
