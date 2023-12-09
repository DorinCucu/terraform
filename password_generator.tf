resource "random_password" "vm_password" {
  count  = var.vm_count
  length = 16
}

output "password" {
  value     = random_password.vm_password[*].result
  sensitive = true
}