# Required variables
variable "project" {
  type = object({
    cluster_name            = string
    name                    = string
    project_limit           = map(string)
    namespace_default_limit = map(string)
    role_bindings           = map(map(string))
  })
  description = "Rancher2 project to be created"
}

# Optional variables
variable "config_maps" {
  type = map(object({
    namespace = string
    data      = map(string)
  }))
  default     = {}
  description = "Add config maps to be created within a project namespace"
}
variable "disable_prefix" {
  type        = bool
  default     = false
  description = "By default, all project resources names will have the prefix `<project_name>-`. Set this to true to disable it."
}
variable "wait_for_catalogs" {
  type        = bool
  default     = true
  description = "By default, project will wait until all catalogs are downloaded. Set this to false to disable it."
}
variable "namespaces" {
  type = map(object({
    limit = map(string)
  }))
  default     = {}
  description = "Add namespaces to be created within the project"
}
variable "secrets" {
  type = map(object({
    namespace = string
    type      = string
    data      = map(string)
  }))
  default     = {}
  description = "Add secrets to be created within a project namespace"
}
variable "apps" {
  type = map(object({
    namespace     = string
    repo_name     = string
    chart_name    = string
    chart_version = string
    values        = string
  }))
  default     = {}
  description = "Add apps to be created within a project namespace"
}