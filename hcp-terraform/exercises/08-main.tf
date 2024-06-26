# Copyright (c) HashiCorp, Inc.

terraform {
  required_providers {
    tfe = {
      version = "~> 0.38.0"
    }
  }
}

/**** **** **** **** **** **** **** **** **** **** **** ****
Obtain name of the target organization from the particpant.
**** **** **** **** **** **** **** **** **** **** **** ****/

data "tfe_organization" "org" {
  name = var.tf_organization
}

/**** **** **** **** **** **** **** **** **** **** **** ****
 
 * DEPRECATED *
 
 Configure workspace with local execution mode so that plans 
 and applies occur on this workstation. And, HCP Terraform 
 is only used to store and synchronize state. 

 * DEPRECATED *

**** **** **** **** **** **** **** **** **** **** **** ****/

# resource "tfe_workspace" "hashicat" {
#   name           = var.tf_workspace
#   organization   = data.tfe_organization.org.name
#   tag_names      = var.tf_workspace_tags
#   execution_mode = "local"
# }

/**** **** **** **** **** **** **** **** **** **** **** ****

 * DEPRECATED *

 Configure workspace with REMOTE execution mode so that plans 
 and applies occur on HCP Terraform's infrastructure. 
 HCP Terraform exectures code and stores state. 

* DEPRECATED *

**** **** **** **** **** **** **** **** **** **** **** ****/

# resource "tfe_workspace" "hashicat" {
#   name           = var.tf_workspace
#   organization   = data.tfe_organization.org.name
#   tag_names      = var.tf_workspace_tags
#   execution_mode = "remote"
# }

/**** **** **** **** **** **** **** **** **** **** **** ****
 Configure workspace with REMOTE execution mode so that plans 
 and applies occur on HCP Terraform's infrastructure. 
 HCP Terraform exectures code and stores state. 
**** **** **** **** **** **** **** **** **** **** **** ****/

resource "tfe_workspace" "hashicat" {
  name         = var.tf_workspace
  organization = data.tfe_organization.org.name
  tag_names    = var.tf_workspace_tags
  auto_apply   = true

  vcs_repo {
    identifier     = "${var.github_owner}/${var.github_repo}"
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

/**** **** **** **** **** **** **** **** **** **** **** ****
 Configure organization-wide variables with Variables sets
**** **** **** **** **** **** **** **** **** **** **** ****/

resource "tfe_variable_set" "hashicat" {
  name         = "Cloud Credentials"
  description  = "Dedicated Principal Account for Terraform Deployments"
  organization = data.tfe_organization.org.name
}

/**** **** **** **** **** **** **** **** **** **** **** ****
 Assing the Variables set to the hashicat workspace
**** **** **** **** **** **** **** **** **** **** **** ****/

resource "tfe_workspace_variable_set" "hashicat" {
  variable_set_id = tfe_variable_set.hashicat.id
  workspace_id    = tfe_workspace.hashicat.id
}

