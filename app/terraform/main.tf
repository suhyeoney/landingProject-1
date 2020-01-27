provider "aws" {
    profile = "default"
}

resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
    route_table_id          = "${aws_vpc.default.main_route_table_id}"
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "deafult" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "10.0.64.0/18"
    map_public_ip_on_launch = true
}

# need to add one more subnet for RDS

resource "aws_security_group" "elb" {
    name        = "app_lb_security_group"
    description = "load balancer used for the application"
    vpc_id      = "${aws_vpc.default.id}"

    # HTTP access from everywhere http port 80
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1" # -1 specifies every kind of connection including tpc, udp, etc.
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "default" {
    name        = "default security group"
    description = "default security group for SSH and HTTP inbound and unlimited outbound"
    vpc_id      = "${aws_vpc.default.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_elb" "web" {
    name            = "elastic load balancer for the web app"

    subnets         = ["${aws_subnet.deafult.id}"]
    security_groups = ["${aws_security_group.elb.id}"]
    instances       = ["${aws_instance.web.id}"]

    listener {
        instance_port       = 80
        instance_protocol   = "http"
        lb_port             = 80
        lb_protocol         = "http"
    }
}

resource "aws_key_pair" "auth" {
    key_name    = "${var.key_name}"
    public_key  = "${file(var.public_key_path)}"
}

resource "aws_instance" "web" {
    connection {
        user    = "ubuntu"
        host    = "${self.publilc_ip}"
    }

    instance_type           = "t2.micro"
    ami                     = "${var.image_id}"
    key_name                = "${aws_key_pair.auth.id}"

    vpc_security_group_ids  = ["${aws_security_group.default}"]
    subnet_id               = "${aws_subnet.deafult.id}"

    provisioner "local-exec" {
        # dependencies and so on to add here
        command =<<EOT
        sudo apt update
        sudo apt install git -y
        EOT
    }
}

