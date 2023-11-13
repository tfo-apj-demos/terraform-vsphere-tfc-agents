data "hcp_packer_image" "this" {
  bucket_name     = "base-ubuntu-2204"
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

module "vm" {
  count = 3

  source  = "app.terraform.io/tfo-apj-demos/virtual-machine/vsphere"
  version = "~> 1.3"

  hostname          = "tfc-agent-${count.index}"
  datacenter        = "Datacenter"
  cluster           = "cluster"
  primary_datastore = "vsanDatastore"
  folder_path       = "demo workloads"
  networks = {
    "seg-general" : "dhcp"
  }
  template = data.hcp_packer_image.this.cloud_image_id

  userdata = templatefile("${path.module}/templates/userdata.yaml.tmpl", {
    agent_token = tfe_agent_token.this.token
    agent_name  = "tfc-agent-${count.index}"
  })
}