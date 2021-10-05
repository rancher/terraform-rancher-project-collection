locals {
  tags = {
    terraform        = "true"
    terraform_code   = "https://github.com/rancher/terraform-rancher2-project"
    terraform_module = "terraform-rancher2-project"
  }

  project_info = {
    cluster_id = var.project.cluster_id
    disable_prefix = var.disable_prefix
    name = var.project.name
    role_bindings = try(flatten([for role_k,role_v in var.project.role_bindings: {
      name = !var.project.disable_prefix ? "${var.project.name}-${role_k}" : role_k
      data = {for conf_k, conf_v in role_v : conf_k => conf_v}
    }]), null)
    resource_quota = var.project.project_limit != null && var.project.namespace_default_limit != null ? length(var.project.project_limit) > 0 && length(var.project.namespace_default_limit) > 0 ? [{
        project_limit = try(var.project.project_limit, null)
        namespace_default_limit = try(var.project.namespace_default_limit, null)
    }] : null : null
  }

  app_list = flatten([for app_k,app_v in var.apps: [{
    name = !local.project_info.disable_prefix ? "${local.project_info.name}-${app_k}" : app_k
    namespace = !local.project_info.disable_prefix ? "${local.project_info.name}-${app_v.namespace}" : app_v.namespace
    repo_name = app_v.repo_name
    chart_name = app_v.chart_name
    chart_version = app_v.chart_version
    values = app_v.values == trimprefix(app_v.values, "#FILE#") ? app_v.values : file(trimprefix(app_v.values, "#FILE#"))
  }]])

  config_map_list = flatten([for conf_k, conf_v in var.config_maps : {
    name = !local.project_info.disable_prefix ? "${local.project_info.name}-${conf_k}" : "${conf_k}"
    namespace = !local.project_info.disable_prefix ? "${local.project_info.name}-${conf_v.namespace}" : conf_v.namespace
    data = {for k, v in conf_v.data : k => v == trimprefix(v, "#FILE#") ? v : file(trimprefix(v, "#FILE#"))}
  }])

  namespace_list = flatten([for k, v in var.namespaces : {
    name = !local.project_info.disable_prefix ? "${local.project_info.name}-${k}" : "${k}"
    resource_quota = v.limit != null ? length(v.limit) > 0 ? [{
      limit = try(v.limit, null)
    }] : null : null
  }])
  
  secret_list = flatten([for sec_k, sec_v in var.secrets : {
    name = !local.project_info.disable_prefix ? "${local.project_info.name}-${sec_k}" : "${sec_k}"
    namespace = !local.project_info.disable_prefix ? "${local.project_info.name}-${sec_v.namespace}" : sec_v.namespace
    type = sec_v.type
    data = {for k, v in sec_v.data : k => v == trimprefix(v, "#FILE#") ? v : file(trimprefix(v, "#FILE#"))}
  }])
}
