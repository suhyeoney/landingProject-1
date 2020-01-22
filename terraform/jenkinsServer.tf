provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-00379ec40a3e30f87"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-03565efa99637b5d1"]

  provisioner "file" {
    source      = "init.sh"
    destination = "init.sh"
  }

  provisioner "local-exec" {
    command = "sh init.sh"
  }
}
