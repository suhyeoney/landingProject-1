provider "aws" {
    profile = "default"
}

resource "aws_vpc" "default" {
    cidr_block          = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

// AWS VPC divided into 4 subnets: 1 Public subnet, 3 Private subnets for server(Web), app(WAS), db(RDS) respectively

resource "aws_subnet" "public_subnet" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "10.0.0.0/18"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_web" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "10.0.64.0/18"
}

resource "aws_subnet" "private_subnet_was" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "10.0.128.0/18"
}

resource "aws_subnet" "private_subnet_db" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "10.0.192.0/18"
}

// ********************************************************

// AWS Public route table configuration for public subnets

resource "aws_route" "internet_access" {
    route_table_id          = "${aws_vpc.default.main_route_table_id}"
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table_association" "public_association" {
    subnet_id       = "${aws_subnet.public_subnet.id}"
    route_table_id  = "${aws_vpc.default.main_route_table_id}"
}

// ********************************************************

// AWS Private route table configuration for private subnets

resource "aws_eip" "elastic_ip" {
    vpc         = true
    depends_on  = ["${aws_internet_gateway.default}"]
}

resource "aws_nat_gateway" "nat" {
    allocation_id   = "${aws_eip.elastic_ip.id}"
    subnet_id       = "${aws_subnet.public_subnet.id}"
    depends_on      = ["${aws_internet_gateway.default}"]
}

resource "aws_route_table" "private" {
    vpc_id  = "${aws_vpc.default.id}"

    route {
        cidr_block      = "0.0.0.0/0"
        nat_gateway_id  = "${aws_nat_gateway.nat.id}"
    }

resource "aws_route_table_association" "private_association_app" {
    subnet_id       = "${aws_subnet.private_subnet_was.id}"
    route_table_id  = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_association_server" {
    subnet_id       = "${aws_subnet.private_subnet_web.id}"
    route_table_id  = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_association_db" {
    subnet_id       = "${aws_subnet.private_subnet_db.id}"
    route_table_id  = "${aws_route_table.private.id}"
}

// ********************************************************

// AWS Secuity groups: elb for HTTP inbound, default for HTTP && SSH inbound, private for SSH inbound from public subnet(bastion)

resource "aws_security_group" "elb" {
    name        = "app_lb_security_group"
    description = "load balancer used for the application"
    vpc_id      = "${aws_vpc.default.id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
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

resource "aws_security_group" "private" {
    name        = "security group for private instances"
    description = "security group for private instances which can be only handled by bastion instance"
    vpc_id      = "${aws_vpc.default.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${aws_subnet.public_subnet.cidr_block}"]
    }

    egress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${aws_subnet.private_subnet_web.cidr_block}", "${aws_subnet.private_subnet_was.cidr_block}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// ********************************************************

// AWS Elastic Load Balancers: web for Web EC2, app for WAS EC2

resource "aws_elb" "web" {
    name            = "ELB for Web EC2"

    subnets         = ["${aws_subnet.public_subnet.id}"]
    security_groups = ["${aws_security_group.elb.id}"]
    instances       = ["${aws_instance.web.id}"]

    listener {
        // HTTP request IN/OUT
        instance_port       = 80
        instance_protocol   = "http"
        lb_port             = 80
        lb_protocol         = "http"
    }
}

resource "aws_elb" "app" {
    name            = "ELB for WAS EC2"

    subnets         = ["${aws_subnet.private_subnet_was}"]
    security_groups = ["${aws_security_group.elb.id}"]
    instances       = ["${aws_instance.app.id}"]

    listener {
        // HTTP request IN/OUT
        instance_port       = 80
        instance_protocol   = "http"
        lb_port             = 80
        lb_protocol         = "http"
    }
}

// ********************************************************

// AWS EC2 instances: web for Web EC2 in private_subnet_app subnet, app for WAS EC2 in private_subnet_app_subnet

// Need to generate a bastion instance as well

resource "aws_instance" "bastion" {
    instance_type           = "t2.micro"
    ami                     = "${lookup()}"
    key_name                = "${var.key_name}"

    vpc_security_group_ids  = ["${aws_security_group.default.id}"]
    subnet_id               = "${aws_subnet.public_subnet.id}"
}

resource "aws_instance" "web" {
    instance_type           = "t2.micro"
    ami                     = "${var.image_id_web}"
    key_name                = "${var.key_name}"

    vpc_security_group_ids  = ["${aws_security_group.private}"]
    subnet_id               = "${aws_subnet.private_subnet_web.id}"

    provisioner "local-exec" {
        command =<<EOT
        sudo apt update
        sudo apt install git -y
        EOT
    }
}

resource "aws_instance" "app" {
    instance_type           = "t2.micro"
    ami                     = "${var.image_id_app}"
    key_name                = "${var.key_name}"

    vpc_security_group_ids  = ["${aws_security_group.private}"]
    subnet_id               = "${aws_subnet.private_subnet_app.id}"

    provisioner "local-exec" {
        command =<<EOT
        EOT
    }
}

resource "aws_db_instance" "default" {
    allocated_storage   = 10
    storage_type        = "gp"
}

