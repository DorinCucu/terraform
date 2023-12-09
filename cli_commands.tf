resource "null_resource" "delay" {
  depends_on = [azurerm_public_ip.vm_ips, azurerm_linux_virtual_machine.vm]

  provisioner "local-exec" {
    command = <<-EOF
      echo "Sleeping for 60 seconds to wait for IPs to be available"
      Start-Sleep -Seconds 60
    EOF

    interpreter = ["PowerShell", "-Command"]
  }
}

resource "null_resource" "fetch_host_key" {
  count      = var.vm_count
  depends_on = [null_resource.delay]
  provisioner "local-exec" {
    command = "ssh-keyscan -t ed25519 ${azurerm_public_ip.vm_ips[(count.index + 1) % var.vm_count].ip_address} > ${local.ssh_path}temp_${count.index}_known_hosts"
  }
}
resource "null_resource" "write_host_key" {
  depends_on = [null_resource.fetch_host_key]

  provisioner "local-exec" {
    command     = <<-EOF
      Get-Content ${local.ssh_path}temp_* | Set-Content ${local.ssh_path}known_hosts
    EOF
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "null_resource" "ping" {
  depends_on = [null_resource.write_host_key]
  count      = var.vm_count

  provisioner "remote-exec" {
    inline = [
      "source_vm_index=${count.index}",
      "destination_vm_index=${count.index + 1 % var.vm_count}",
      "destination_vm_ip=${azurerm_network_interface.vm_nics[(count.index + 1) % var.vm_count].private_ip_address}",
      "ping_result=$(ping -c 1 $destination_vm_ip && echo 'Success' || echo 'Failure')",
      "echo \"Ping from VM ${count.index} to VM $destination_vm_index: $ping_result\" >> ping_results_VM${count.index}.txt",
    ]

    connection {
      type     = "ssh"
      host     = azurerm_public_ip.vm_ips[(count.index + 1) % var.vm_count].ip_address
      user     = local.vm_user
      password = random_password.vm_password[(count.index + 1) % var.vm_count].result
    }
  }
}
resource "null_resource" "cache_ssh" {
  count      = var.vm_count
  depends_on = [null_resource.ping]
  provisioner "local-exec" {
    command     = <<-EOF
      "echo y | plink -i ${local.ssh_path}vm_key ${local.vm_user}@${azurerm_public_ip.vm_ips[(count.index + 1) % var.vm_count].ip_address}"
    EOF
    interpreter = ["PowerShell", "-Command"]
  }
}
resource "null_resource" "extract_results" {
  count      = var.vm_count
  depends_on = [null_resource.cache_ssh]
  provisioner "local-exec" {
    command = "pscp -i ${local.ssh_path}vm_key ${local.vm_user}@${azurerm_public_ip.vm_ips[(count.index + 1) % var.vm_count].ip_address}:ping_results_VM${count.index}.txt ${local.project_path}"
  }
}


resource "null_resource" "concatenate_files" {
  depends_on = [null_resource.extract_results]

  provisioner "local-exec" {
    command     = <<-EOF
      Get-Content ${local.project_path}ping_results_*.txt | Set-Content ${local.project_path}all_ping_results.txt
    EOF
    interpreter = ["PowerShell", "-Command"]
  }
}

output "ping_results" {
  depends_on = [null_resource.concatenate_files]
  value = file("all_ping_results.txt")
}
