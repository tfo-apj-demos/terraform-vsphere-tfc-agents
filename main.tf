resource "tfe_agent_pool" "this" {
  name                = "vsphere_agent_pool"
  organization_scoped = false
}

resource "tfe_agent_token" "this" {
  agent_pool_id = tfe_agent_pool.this.id
  description   = "agent token for vsphere environment"
}

module "vm" {
  count = 3

  source  = "app.terraform.io/tfo-apj-demos/virtual-machine/vsphere"
  version = "~> 1.3"

  hostname          = "tfc-agent-${count.index}"
  datacenter        = var.datacenter
  cluster           = var.cluster
  primary_datastore = var.primary_datastore
  folder_path       = var.folder_path
  networks          = var.networks
  template          = var.vsphere_template_name

  userdata = templatefile("${path.module}/templates/userdata.yaml.tmpl", {
    agent_token = tfe_agent_token.this.token
    agent_name  = "tfc-agent-${count.index}"
  })
}