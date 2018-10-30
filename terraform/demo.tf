resource "aws_vpc" "ansiblepulldemo_vpc" {
  cidr_block = "10.240.0.0/24"
  enable_dns_hostnames = true

  tags {
    Trigramme = "${var.aws_trigram}"
    Name = "VPC ansible-pull demo"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.ansiblepulldemo_vpc.id}"
  cidr_block = "10.240.0.0/24"
  availability_zone = "eu-west-1a"

  tags {
    Name = "ansiblepulldemo-subnet1"
    Trigramme = "${var.aws_trigram}"
  }
}

resource "aws_internet_gateway" "ansiblepulldemo_igw" {
  vpc_id = "${aws_vpc.ansiblepulldemo_vpc.id}"

  tags {
    Trigramme = "${var.aws_trigram}"
    Name = "ansiblepulldemo internet gateway"
  }
}

resource "aws_default_route_table" "ansiblepulldemo_vpc_route_table" {
  default_route_table_id = "${aws_vpc.ansiblepulldemo_vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ansiblepulldemo_igw.id}"
  }

  route {
    cidr_block = "10.200.0.0/24"
    instance_id = "${aws_instance.puller-web.id}"
  }

  tags {
    Trigramme = "${var.aws_trigram}"
    Name = "ansible-pull demo route table"
  }
}

resource "aws_security_group" "ansible-pull-demo-almost-openbar" {
  name        = "ansible-pull-demo-allow-internal"
  description = "allows internal communication across all protocols"
  vpc_id      = "${aws_vpc.ansiblepulldemo_vpc.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Trigramme = "${var.aws_trigram}"
    Name = "ansiblepulldemo-security-group-internal"
  }
}

# Render a part using a `template_file`
data "template_file" "script-web" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars {
    node_type = "web"
    env = "${var.env}"
    git_repository = "${var.git_repository}"
    secret = "${var.web_role_secret}"
  }
}

data "template_file" "script-db" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars {
    node_type = "db"
    env = "${var.env}"
    git_repository = "${var.git_repository}"
    secret = "${var.db_role_secret}"
  }
}

resource "aws_instance" "puller-web" {
  ami           = "ami-4d46d534"
  instance_type = "t2.micro"
  key_name = "${var.aws_keypair}"

  vpc_security_group_ids = ["${aws_security_group.ansible-pull-demo-almost-openbar.id}"]
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "${data.template_file.script-web.rendered}"
      

  subnet_id = "${aws_subnet.main.id}"

  tags {
    Trigramme = "${var.aws_trigram}"
    Topic = "ansiblepulldemo"
    Name = "puller-web"
  }
}

resource "aws_instance" "puller-db" {
  ami           = "ami-4d46d534"
  instance_type = "t2.micro"
  key_name = "${var.aws_keypair}"

  vpc_security_group_ids = ["${aws_security_group.ansible-pull-demo-almost-openbar.id}"]
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "${data.template_file.script-db.rendered}"
      

  subnet_id = "${aws_subnet.main.id}"

  tags {
    Trigramme = "${var.aws_trigram}"
    Topic = "ansiblepulldemo"
    Name = "puller-db"
  }
}

resource "aws_instance" "remotevm" {
  ami           = "ami-4d46d534"
  instance_type = "t2.micro"
  key_name = "${var.aws_keypair}"

  vpc_security_group_ids = ["${aws_security_group.ansible-pull-demo-almost-openbar.id}"]
  associate_public_ip_address = true
  source_dest_check = false     

  subnet_id = "${aws_subnet.main.id}"

  tags {
    Trigramme = "${var.aws_trigram}"
    Topic = "ansiblepulldemo"
    Name = "remotevm"
  }
}

output "puller-web" {
    value = "${aws_instance.puller-web.public_dns}"
}
output "puller-db" {
    value = "${aws_instance.puller-db.public_dns}"
}

output "remotevm" {
    value = "${aws_instance.remotevm.public_dns}"
}