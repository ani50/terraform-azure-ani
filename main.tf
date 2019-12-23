module "consul" {
    source = "github.com/hashicorp/consul/terraform/aws"
    servers = 3
}
