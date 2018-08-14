
variable "name" {
  type = "string"
  default = "dev-instance"
}
variable "password" {
  type = "string"
  default = "Test1234!"
}

/*provider "aws" {
  access_key = ""
  secret_key = ""
  region     = ""
}

resource "aws_instance" "appserver" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
*/

provider "alicloud" {}

data "alicloud_instance_types" "2c4g" {
  cpu_core_count = 2
  memory_size = 4
}

# Create security group
resource "alicloud_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id = "vpc-0xiqymnb1meza9huffo1z"
}
resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.default.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "appserver" {
  image_id          = "ubuntu_16_0402_64_20G_alibase_20180409.vhd"
  #internet_charge_type  = "PayByBandwidth"
  instance_type        = "${data.alicloud_instance_types.2c4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.default.id}"]
  instance_name        = "${var.name}"
  vswitch_id = "vsw-0xi7dh595fc0gocx8wexe"
  internet_max_bandwidth_out = 100
  password = "${var.password}"
  #allocate_public_ip = true
  user_data = "${file("cloudconfig")}"
provisioner "remote-exec" {
  inline = [
    "until [ -f /var/lib/cloud/instance/boot-finished ]\ndo\nsleep 5\ndone",
    "git clone https://github.com/2wistedSerpent/normWork.git",
    "service docker start",
    "cd normWork",
    "docker build -t testapplication .",
    "docker run -p 80:80 testapplication"
  ]

   connection {
     host = "${alicloud_instance.appserver.public_ip}"
     password = "${var.password}"
   }
 }
}
output "ip" {
  value = "${alicloud_instance.appserver.public_ip}"
}
