data "hcp_packer_image" "this" {
  bucket_name     = "docker-ubuntu-2204"
  channel         = "latest"
  cloud_provider  = "vsphere"
  region          = "Datacenter"
}

resource "tfe_agent_pool" "this" {
  name                = "gcve_agent_pool"
  organization_scoped = true
}

resource "tfe_agent_token" "this" {
  agent_pool_id = tfe_agent_pool.this.id
  description   = "agent token for vsphere environment"
}

data "nsxt_policy_ip_pool" "this" {
  display_name = "10 - gcve-foundations"
}
resource "nsxt_policy_ip_address_allocation" "this" {
  count        = var.agent_count
  display_name = "tfc-agent-${count.index}"
  pool_path    = data.nsxt_policy_ip_pool.this.path
}

module "vm" {
  count = var.agent_count

  source  = "app.terraform.io/tfo-apj-demos/virtual-machine/vsphere"
  version = "~> 1.3"

  hostname          = "tfc-agent-${count.index}"
  datacenter        = "Datacenter"
  cluster           = "cluster"
  primary_datastore = "vsanDatastore"
  folder_path       = "management"
  networks = {
    "seg-general" : "${nsxt_policy_ip_address_allocation.this[count.index].allocation_ip}/22"
  }
  dns_server_list = [
    "172.21.15.150"
  ]
  gateway         = "172.21.12.1"
  dns_suffix_list = ["hashicorp.local"]

  template = data.hcp_packer_image.this.cloud_image_id

  userdata = templatefile("${path.module}/templates/userdata.yaml.tmpl", {
    agent_token = tfe_agent_token.this.token
    agent_name  = "tfc-agent-${count.index}"
    krb5_conf = base64encode(templatefile("${path.module}/templates/krb5.conf.tmpl", {}))
  })
  tags = {
    "application" = "tfc-agent"
  }
}