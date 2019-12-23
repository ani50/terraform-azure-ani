provider "azurerm" {
  version = "~> 1.0"
}

variable "resource_group_name" {
    default = "terraform-test"
}

module "network" {
    source              = "Azure/network/azurerm"
    location            = "westus"
    resource_group_name = "${var.resource_group_name}"
  }

module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${var.resource_group_name}"
  location            = "westus"
  prefix              = "terraform-test"
  lb_port             = {
                          http  = ["80", "Tcp", "80"]
                          https = ["443", "Tcp", "443"]
                          #ssh   = ["22", "Tcp", "22"]
                        }
}

module "computegroup" {
    source              = "Azure/computegroup/azurerm"
    resource_group_name = "${var.resource_group_name}"
    location            = "westus"
    vm_size             = "Standard_A0"
    admin_username      = "azureuser"
    admin_password      = "ComplexPassword"
    ssh_key             = "~/.ssh/id_rsa.pub"
    nb_instance         = 2
    vm_os_simple        = "UbuntuServer"
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
    load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"
    cmd_extension       = "sudo apt-get -y install nginx"
    tags                = {
                            environment = "dev"
                            costcenter  = "it"
                          }
}

output "vmss_id"{
  value = "${module.computegroup.vmss_id}"
}
