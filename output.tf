# Outputs

output "rancher2_project" {
  value = rancher2_project.project
}

output "rancher2_project_role_template_bindings" {
  value     = rancher2_project_role_template_binding.project_role_template_bindings
  sensitive = true
}

output "rancher2_namespaces" {
  value     = rancher2_namespace.namespaces
  sensitive = true
}

output "rancher2_config_maps" {
  value     = rancher2_config_map_v2.config_maps
  sensitive = true
}

output "rancher2_secrets" {
  value     = rancher2_secret_v2.secrets
  sensitive = true
}

output "rancher2_apps" {
  value     = rancher2_app_v2.apps
  sensitive = true
}
