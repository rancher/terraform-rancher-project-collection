# Required variables
variable "rancher2" {
  type = object({
    api_url = string
    insecure = bool
    token_key = string
  })
  description = "Rancher2 config, api_url, insecure and token_key are required"
}
variable "project" {
  type = object({
    cluster_id = string
    name = string
    project_limit = map(string)
    namespace_default_limit = map(string)
    role_bindings = map(map(string))
  })
  description = "Rancher2 project to be created"
}

# Optional variables
variable "config_maps" {
  type = map(object({
    namespace = string
    data = map(string)
  }))
  default = {}
  description = "Add config maps to be created within a project namespace"
}
variable "disable_prefix" {
  type = bool
  default = false
  description = "By default, all project resources names will have the prefix `<project_name>-`. Set this to true to disable it."
}
variable "namespaces" {
  type = map(object({
    limit = map(string)
  }))
  default = {}
  description = "Add namespaces to be created within the project"
}
variable "secrets" {
  type = map(object({
    namespace = string 
    type = string 
    data = map(string)
  }))
  default = {}
  description = "Add secrets to be created within a project namespace"
}
variable "apps" {
  type = map(object({
    namespace = string
    repo_name = string
    chart_name = string
    chart_version = string
    values = string
  }))
  default = {}
  description = "Add apps to be created within a project namespace"
}