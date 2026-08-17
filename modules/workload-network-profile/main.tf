locals {
  profile_requirements = {
    isolated = "No platform network attachment; workload owns ingress and egress."
    corp     = "Attach through the separately operated corporate hub network."
    online   = "Attach through the separately operated online hub network."
  }
}

resource "terraform_data" "profile_contract" {
  input = {
    profile     = var.profile
    requirement = local.profile_requirements[var.profile]
  }
}
