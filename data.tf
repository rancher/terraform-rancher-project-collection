data "rancher2_cluster" "cluster" {
  name = local.project_info.cluster_name
}