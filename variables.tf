variable "vm_count" {
  description = "Number of VM instances to create"
  type        = number
}

variable "vm_size" {
  description = "Size of the VM instances"
  type        = string
}

variable "vm_image" {
  description = "Image ID for the VM instances"
  type        = string
}
