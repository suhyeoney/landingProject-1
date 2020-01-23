provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-016351c2ca998ee89"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-03565efa99637b5d1"]
  key_name = "jenkins_server"
}
