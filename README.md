# Rancher2 terraform module for project

Rancher2 terraform module for deploying a project and its resources. This terraform module is using the [Rancher2](https://registry.terraform.io/providers/rancher/rancher2/latest) terraform provider to create and manage `apps`, `config maps`, `namespaces`, `project role bindings` and `secrets`

Module will do following tasks:
- Connect to Rancher2 server
- Create Rancher2 project and its resources:
  - apps
  - config maps
  - namespaces
  - project role bindings
  - secrets

## Variables

### Input

This module accept the following variables as input:

```
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
  type = list(string)
  default = []
  description = "Add namespaces to be created within the project"
}
variable "secrets" {
  type = map(object({
    namespace = string  # namespace should be added first at variable namespaces
    type = string 
    data = map(string)
  }))
  default = {}
  description = "Add secrets to be created within a project namespace"
}
variable "apps" {
  type = map(object({
    namespace = string  # namespace should be added first at variable namespaces
    repo_name = string
    chart_name = string
    chart_version = string
    values = string
  }))
  default = {}
  description = "Add apps to be created within a project namespace"
}
```

### Output

This module use the following variables as ouput:

```
output "rancher2_project" {
  value = rancher2_project.project
}

output "rancher2_project_role_template_bindings" {
  value = rancher2_project_role_template_binding.project_role_template_bindings
  sensitive = true
}

output "rancher2_namespaces" {
  value = rancher2_namespace.namespaces
  sensitive = true
}

output "rancher2_config_maps" {
  value = rancher2_config_map_v2.config_maps
  sensitive = true
}

output "rancher2_secrets" {
  value = rancher2_secret_v2.secrets
  sensitive = true
}

output "rancher2_apps" {
  value = rancher2_app_v2.apps
  sensitive = true
}
```

## How to use

This tf module can be used standalone or combined with other tf modules.

Requirements for use standalone:
* Rancher2 server up and running
* Rancher2 url and access token
* Input project info with required variables
* Input project additional resources info with optional variables

Add the following to your tf file:

```
module "rancher2-project" {
  source = "github.com/rawmind0/terraform-rancher2-project"

  # Required variables
  rancher2 = {
    api_url = <RANCHER_URL>
    insecure = true
    token_key = <RANCHER_TOKEN>
  }
  project = {
    cluster_id = "local"
    disable_prefix = true
    name = "test"
    project_limit = {
      limits_cpu = "2"
      limits_memory = "2Gi"
      requests_storage = "10Gi"
    }
    namespace_default_limit = {
      limits_cpu = "1"
      limits_memory = "1Gi"
      requests_storage = "10Gi"
    }
    role_bindings = {
      admin = {
        role_template_id = "admin"
        user_principal_id = "local://<user>"
      }
    }
  }
  # Optional variables
  namespaces = {
    myapp: {
      limit = {
        limits_cpu = "2"
        limits_memory = "2Gi"
        requests_storage = "10Gi"
      }
    }
    grafana = {
      limit = null
    }
  }
  config_maps = {
    myapp-config = {
      namespace = "myapp"  # namespace should be added first at variable namespaces
      data = {
        "v1.json" = "[{\"foo\": \"var\"}]"
        "v2.json" = file("config/myapp/v2.json")
      }
    }
  }
  secrets = {
    myapp-admin = {
      namespace = "myapp"  # namespace should be added first at variable namespaces
      type = null
      data = {
        "admin-user" = "myapp_user"
        "admin-password" = "myapp_pass"
      }
    }
  }
  apps = {
    myapp = {
      namespace = "myapp"  # namespace should be added first at variable namespaces
      repo_name = "myapp_repo"
      chart_name = "myapp_chart"
      chart_version = "myapp_version"
      values = file("config/grafana.yaml")
    }
  }
}
```

# License

Copyright (c) 2014-2021 [Rancher Labs, Inc.](http://rancher.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
