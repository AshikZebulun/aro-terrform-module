output "console_url" {
  value = azurerm_redhat_openshift_cluster.cluster.console_url
  description = "The URL of the OpenShift Console."
}

output "api_url" {
  value = azurerm_redhat_openshift_cluster.cluster.api_server_profile[0].url
  description = "The URL of the OpenShift API server."
}

output "api_server_ip" {
  value = azurerm_redhat_openshift_cluster.cluster.api_server_profile[0].ip_address
  description = "The IP addresses of the OpenShift API server."
}

output "ingress_ip" {
  value = azurerm_redhat_openshift_cluster.cluster.ingress_profile[0].ip_address
  description = "The IP addresses of the OpenShift Ingress controller."
}