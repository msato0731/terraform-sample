resource "tfe_agent_pool" "this" {
  name                = "sato-blog-test"
  organization        = var.hcp_tf_organization_name
  organization_scoped = true
}

resource "tfe_agent_token" "this" {
  agent_pool_id = tfe_agent_pool.this.id
  description   = "sato-blog-test"
}
