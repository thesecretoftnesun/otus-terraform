output "load_balancer_public_ip" {
  description = "Public IP address of load balancer"
  value = tolist(tolist(yandex_lb_network_load_balancer.wp_lb.listener).0.external_address_spec).0.address
}

output "database_host_fqdn" {
  description = "DB hostname"
  value = local.dbhosts
}

output "vm_linux_public_ip_address" {
  description = "Virtual machine IP"
  value = yandex_compute_instance.wp-app-1.network_interface[0].nat_ip_address
}

output "db_user" { 
  value = local.dbuser 
} 
 
output "db_password" { 
  value = local.dbpassword 
  sensitive = true  # Явно указываем, что вывод является конфиденциальным 
} 
 
output "db_host" { 
  value = local.dbhosts[0]  # Если у вас несколько хостов, можно взять первый 
} 
 
output "db_name" { 
  value = local.dbname 
} 
output "db_hosts" { 
  value = yandex_mdb_mysql_cluster.wp_mysql.host.*.fqdn 
}