locals {
  dbuser = tolist(yandex_mdb_mysql_user.user.*.name)[0]
  dbpassword = tolist(yandex_mdb_mysql_user.user.*.password)[0]
  dbhosts = yandex_mdb_mysql_cluster.wp_mysql.host.*.fqdn
  dbname = tolist(yandex_mdb_mysql_database.db.*.name)[0]
}

resource "yandex_mdb_mysql_cluster" "wp_mysql" {
  name        = "wp-mysql"
  folder_id   = var.yc_folder
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.wp-network.id
  version     = "8.0"

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.wp-subnet-b.id
    assign_public_ip = true
  }
  host {
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.wp-subnet-d.id
    assign_public_ip = true
  }
}
 
resource "yandex_mdb_mysql_database" "db" {
    cluster_id = yandex_mdb_mysql_cluster.wp_mysql.id
    name  = "db"
}

resource "yandex_mdb_mysql_user" "user" {
    cluster_id = yandex_mdb_mysql_cluster.wp_mysql.id
    name     = "user"
    password = var.db_password
    authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    permission {
      database_name = "db"
      roles         = ["ALL"]
    }
}