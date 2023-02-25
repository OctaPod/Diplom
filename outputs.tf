#output "private_web-server1" {
#value = yandex_compute_instance.vm1.network_interface.0.ip_address
#}
#output "public_web-server1" {
#value = yandex_compute_instance.vm1.network_interface.0.nat_ip_address
#}
#output "private_web-server2" {
#value = yandex_compute_instance.vm2.network_interface.0.ip_address
#}
output "public_web-server2" {
  value = yandex_compute_instance.vm2.network_interface.0.nat_ip_address
}
output "private_prometheus-server" {
  value = yandex_compute_instance.vm3.network_interface.0.ip_address
}
output "public_prometheus-server" {
  value = yandex_compute_instance.vm3.network_interface.0.nat_ip_address
}
output "private_grafana-server" {
  value = yandex_compute_instance.vm4.network_interface.0.ip_address
}
output "public_grafana-server" {
  value = yandex_compute_instance.vm4.network_interface.0.nat_ip_address
}
output "public_ip_address_alb" {
  value = yandex_alb_load_balancer.alb.listener.0.endpoint.0.address.0.external_ipv4_address
}
output "external_ip_addres_bastion-ssh" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}