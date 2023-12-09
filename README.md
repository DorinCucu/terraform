Description:
This code is used for bosch assesment.

Tools used:
 - terraform
 - putty(plink, pscp)

Azure services/resources used:
- resource groups
- storage account 
- vnet
- subnet
- public_ip
- network interfaces
- linux vm
- random_password generator
- null_resources with local-exec and remote-exec

Inputs/outputs definitions:

Inputs:
- vm_count # how many vm machines to deploy
- vm_image # image used for the VMs
- vm_size #

Outputs:
 - vm passwords, with sensitive = true
 - ping_results

##IMPLEMENTATION

Manual steps:
1. Create a storage account with name "terraformstateproj" and  a container with the name: "terraform"
1. Create all_ping_results.txt
2. Create ssh key used for ssh into the VM: ssh-keygen -t rsa -b 2048 -f C:\Users\%username%\.ssh\vm_key
3. Transform openssh key into ppk(used for putty) with this cmd puttygen C:\Users\%username%\.ssh\vm_key  -o vm_key.ppk or manually using puttygen.exe

Run Commands:
terraform init/
terraform plan/
terraform apply/




