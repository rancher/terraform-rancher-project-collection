# Create rancher cluster sync
resource "rancher2_cluster_sync" "cluster_sync" {
  cluster_id = data.rancher2_cluster.cluster.id
  wait_catalogs = local.project_info.wait_for_catalogs
}

# Provision rancher project
resource "rancher2_project" "project" {
  cluster_id = rancher2_cluster_sync.cluster_sync.cluster_id
  name       = local.project_info.name
  dynamic "resource_quota" {
    for_each = { for k, v in local.project_info.resource_quota : k => v }
    content {
      project_limit {
        limits_cpu               = lookup(resource_quota.value.project_limit, "limits_cpu", null)
        limits_memory            = lookup(resource_quota.value.project_limit, "limits_memory", null)
        requests_storage         = lookup(resource_quota.value.project_limit, "requests_storage", null)
        config_maps              = lookup(resource_quota.value.project_limit, "config_maps", null)
        persistent_volume_claims = lookup(resource_quota.value.project_limit, "persistent_volume_claims", null)
        pods                     = lookup(resource_quota.value.project_limit, "pods", null)
        replication_controllers  = lookup(resource_quota.value.project_limit, "replication_controllers", null)
        requests_cpu             = lookup(resource_quota.value.project_limit, "requests_cpu", null)
        requests_memory          = lookup(resource_quota.value.project_limit, "requests_memory", null)
        secrets                  = lookup(resource_quota.value.project_limit, "secrets", null)
        services                 = lookup(resource_quota.value.project_limit, "services", null)
        services_load_balancers  = lookup(resource_quota.value.project_limit, "services_load_balancers", null)
        services_node_ports      = lookup(resource_quota.value.project_limit, "services_node_ports", null)
      }
      namespace_default_limit {
        limits_cpu               = lookup(resource_quota.value.namespace_default_limit, "limits_cpu", null)
        limits_memory            = lookup(resource_quota.value.namespace_default_limit, "limits_memory", null)
        requests_storage         = lookup(resource_quota.value.namespace_default_limit, "requests_storage", null)
        config_maps              = lookup(resource_quota.value.namespace_default_limit, "config_maps", null)
        persistent_volume_claims = lookup(resource_quota.value.namespace_default_limit, "persistent_volume_claims", null)
        pods                     = lookup(resource_quota.value.namespace_default_limit, "pods", null)
        replication_controllers  = lookup(resource_quota.value.namespace_default_limit, "replication_controllers", null)
        requests_cpu             = lookup(resource_quota.value.namespace_default_limit, "requests_cpu", null)
        requests_memory          = lookup(resource_quota.value.namespace_default_limit, "requests_memory", null)
        secrets                  = lookup(resource_quota.value.namespace_default_limit, "secrets", null)
        services                 = lookup(resource_quota.value.namespace_default_limit, "services", null)
        services_load_balancers  = lookup(resource_quota.value.namespace_default_limit, "services_load_balancers", null)
        services_node_ports      = lookup(resource_quota.value.namespace_default_limit, "services_node_ports", null)
      }
    }
  }
}

# Provision rancher project role template bindings
resource "rancher2_project_role_template_binding" "project_role_template_bindings" {
  for_each           = { for k, v in local.project_info.role_bindings : v.name => v }
  name               = each.key
  project_id         = rancher2_project.project.id
  role_template_id   = each.value.data.role_template_id
  group_principal_id = try(each.value.data.group_principal_id, null)
  group_id           = try(each.value.data.group_id, null)
  user_id            = try(each.value.data.user_id, null)
  user_principal_id  = try(each.value.data.user_principal_id, null)
}

# Provision rancher project namespaces
resource "rancher2_namespace" "namespaces" {
  for_each   = { for k, v in local.namespace_list : v.name => v }
  name       = each.key
  project_id = rancher2_project.project.id
  dynamic "resource_quota" {
    for_each = { for k, v in each.value.resource_quota : k => v }
    content {
      limit {
        limits_cpu               = lookup(resource_quota.value.limit, "limits_cpu", null)
        limits_memory            = lookup(resource_quota.value.limit, "limits_memory", null)
        requests_storage         = lookup(resource_quota.value.limit, "requests_storage", null)
        config_maps              = lookup(resource_quota.value.limit, "config_maps", null)
        persistent_volume_claims = lookup(resource_quota.value.limit, "persistent_volume_claims", null)
        pods                     = lookup(resource_quota.value.limit, "pods", null)
        replication_controllers  = lookup(resource_quota.value.limit, "replication_controllers", null)
        requests_cpu             = lookup(resource_quota.value.limit, "requests_cpu", null)
        requests_memory          = lookup(resource_quota.value.limit, "requests_memory", null)
        secrets                  = lookup(resource_quota.value.limit, "secrets", null)
        services                 = lookup(resource_quota.value.limit, "services", null)
        services_load_balancers  = lookup(resource_quota.value.limit, "services_load_balancers", null)
        services_node_ports      = lookup(resource_quota.value.limit, "services_node_ports", null)
      }
    }
  }
}

# Provision rancher project config maps
resource "rancher2_config_map_v2" "config_maps" {
  for_each   = { for k, v in local.config_map_list : v.name => v }
  cluster_id = rancher2_project.project.cluster_id
  name       = each.key
  namespace  = rancher2_namespace.namespaces[each.value.namespace].name
  data       = each.value.data
}

# Provision rancher project secrets
resource "rancher2_secret_v2" "secrets" {
  for_each   = { for k, v in local.secret_list : v.name => v }
  cluster_id = rancher2_project.project.cluster_id
  name       = each.key
  namespace  = rancher2_namespace.namespaces[each.value.namespace].name
  type       = each.value.type != "" ? each.value.type : null
  data       = each.value.data
}

# Provision rancher project apps
resource "rancher2_app_v2" "apps" {
  for_each      = { for k, v in local.app_list : v.name => v }
  cluster_id    = rancher2_project.project.cluster_id
  project_id    = rancher2_project.project.id
  name          = each.key
  namespace     = rancher2_namespace.namespaces[each.value.namespace].name
  repo_name     = each.value.repo_name
  chart_name    = each.value.chart_name
  chart_version = each.value.chart_version
  values        = each.value.values
}


  