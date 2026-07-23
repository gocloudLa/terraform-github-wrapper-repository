locals {

  metadata = {
    environment  = "Laboratory"
    project      = "Example"
    github_owner = "example-org"

    key = {
      company = "dmc"
      env     = "lab"
      project = "example"
      layer   = "project"
    }
  }

  common_name_prefix = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_name = join("-", [
    local.common_name_prefix,
    local.metadata.key.project
  ])

}
