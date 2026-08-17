output "profile" {
  description = "Selected profile and the contract the networking platform must fulfill."
  value       = terraform_data.profile_contract.output
}
