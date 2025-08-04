output "chartmuseum_auth_pass" {
  value = nonsensitive(random_password.chartmuseum.result)
}
