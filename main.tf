
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {

  token     = "xxxxx"
  cloud_id  = "b1gmshlj3qsdnpqthq19"
  folder_id = "b1gf810p932eanbjul9k"
}


######################################################---COMPUTE INSTACE (WEBSERVERS)---#######################


resource "yandex_compute_instance" "vm1" {
  name = "web-server-1"
  zone = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8b24tqvq7t2f8a1o1s"
      size     = 10     
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-1.id
    security_group_ids = [yandex_vpc_security_group.inner.id]
    ip_address         = "10.0.1.3"
    #nat       = true
  }


  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm2" {
  name = "web-server-2"
  zone = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8b24tqvq7t2f8a1o1s"
      size     = 10
    }    
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-2.id
    security_group_ids = [yandex_vpc_security_group.inner.id]
    ip_address         = "10.0.2.3"
    #nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}


#######################################################---COMPUTE INSTANCE (PROMETHEUS)---###################


resource "yandex_compute_instance" "vm3" {
  name = "prometheus-server"
  zone = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8b24tqvq7t2f8a1o1s"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.inner-services.id
    security_group_ids = [yandex_vpc_security_group.inner.id]
    ip_address         = "10.0.3.10"
    #nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

#resource "yandex_vpc_subnet" "subnet-prometheus" {
#name           = "subnetprometheus"
#zone           = "ru-central1-c"
#network_id     = yandex_vpc_network.network.id
#v4_cidr_blocks = ["192.168.150.0/24"]
#}


################################################---COMPUTE ISTANCE (GRAFANA)---##############################


resource "yandex_compute_instance" "vm4" {
  name = "grafana-server"
  zone = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8b24tqvq7t2f8a1o1s"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.inner.id, yandex_vpc_security_group.public-grafana.id]
    ip_address         = "10.0.10.11"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

#resource "yandex_vpc_subnet" "subnet-grafana" {
#name           = "subnetgrafana"
#zone           = "ru-central1-c"
#network_id     = yandex_vpc_network.network.id
#v4_cidr_blocks = ["192.168.65.0/24"]
#}


##########################################################---COMPUTE ISTANCE (ELASTIC)---###############


resource "yandex_compute_instance" "elastic" {
  name        = "vm-elastic"
  hostname    = "elastic"
  platform_id = "standard-v3"
  zone        = "ru-central1-c"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd85jf9kn9r40o1neolo"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.inner-services.id
    security_group_ids = [yandex_vpc_security_group.inner.id]
    ip_address         = "10.0.3.12"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}


##########################################################---COMPUTE ISTANCE (KIBANA)---###############


resource "yandex_compute_instance" "kibana" {
  name        = "vm-kibana"
  hostname    = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd85jf9kn9r40o1neolo"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.inner.id, yandex_vpc_security_group.public-kibana.id]
    ip_address         = "10.0.10.13"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}


##########################################################---COMPUTE ISTANCE (BASTION)---###############


resource "yandex_compute_instance" "bastion" {
  name        = "vm-bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd82v0f4ufbnvm3b9s08"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.inner.id, yandex_vpc_security_group.public-bastion.id]
    ip_address         = "10.0.10.5"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}


######################################################---NETWORK/SUBNET---#################################


resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "private_subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.1.0/28"]
  route_table_id = yandex_vpc_route_table.inner-to-nat.id
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "private_subnet2"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.2.0/28"]
  route_table_id = yandex_vpc_route_table.inner-to-nat.id
}

resource "yandex_vpc_subnet" "inner-services" {
  name           = "inner-services-subnet"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.3.0/27"]
  route_table_id = yandex_vpc_route_table.inner-to-nat.id
}

resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.10.0/27"]
}

resource "yandex_vpc_route_table" "inner-to-nat" {
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion.network_interface.0.ip_address
  }
}


####################################################---SECURITY-GROUP---#########################################


resource "yandex_vpc_security_group" "inner" {
  name       = "inner-rules"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "ANY"
    description    = "allow any connection from inner subnets"
    v4_cidr_blocks = ["10.0.1.0/28", "10.0.2.0/28", "10.0.3.0/27", "10.0.10.0/27"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-bastion" {
  name       = "public-bastion-rules"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "allow ssh connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-grafana" {
  name       = "public-grafana-rules"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "allow grafana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-kibana" {
  name       = "public-kibana-rules"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "allow kibana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-load-balancer" {
  name       = "public-load-balancer-rules"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol    = "ANY"
    description = "Health checks"
    #port              = 80
    v4_cidr_blocks    = ["198.18.235.0/24", "198.18.248.0/24"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


###############################################------###############################################


resource "yandex_alb_target_group" "atg" {
  name = "targetgroup"
  target {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = yandex_compute_instance.vm1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet-2.id
    ip_address = yandex_compute_instance.vm2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "bg" {
  name = "backendgroup"
  http_backend {
    name             = "httpbackend"
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.atg.id}"]
    load_balancing_config {
      panic_threshold = 90
    }

    healthcheck {
      timeout             = "5s"
      interval            = "1s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "httpr" {
  name = "httprouter"
}

resource "yandex_alb_virtual_host" "vh" {
  name           = "virtualhost"
  http_router_id = yandex_alb_http_router.httpr.id
  route {
    name = "route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.bg.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name               = "aloadbalancer"
  network_id         = yandex_vpc_network.network.id
  security_group_ids = [yandex_vpc_security_group.public-load-balancer.id, yandex_vpc_security_group.inner.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.inner-services.id
    }
    #location {
    #zone_id   = "ru-central1-a"
    #subnet_id = yandex_vpc_subnet.subnet-2.id
    #}
  }

  listener {
    name = "listeneer"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.httpr.id
      }
    }
  }
}


#####################################################---CREATE INVENTORY FILE FOR ANSIBLE *.INI ---###############


resource "local_file" "ansible-inventory" {
  content  = <<-EOT
    [bastion]
    ${yandex_compute_instance.bastion.network_interface.0.ip_address} public_ip=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} 

    [public_balancer]
    ${yandex_alb_load_balancer.alb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}

    [web1]
    ${yandex_compute_instance.vm1.network_interface.0.ip_address}
    [web2]
    ${yandex_compute_instance.vm2.network_interface.0.ip_address}

    [prometheus]
    ${yandex_compute_instance.vm3.network_interface.0.ip_address}

    [grafana]
    ${yandex_compute_instance.vm4.network_interface.0.ip_address} public_ip=${yandex_compute_instance.vm4.network_interface.0.nat_ip_address} 

    [elastic]
    ${yandex_compute_instance.elastic.network_interface.0.ip_address}

    [kibana]
    ${yandex_compute_instance.kibana.network_interface.0.ip_address} public_ip=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} 

    [web1:vars]
    domain="islamgaleev.com"

    [web2:vars]
    domain="islamgaleev.com"

    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -p 22 -W %h:%p -q qwerbo@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
    EOT
  filename = "./host.ini"
}
