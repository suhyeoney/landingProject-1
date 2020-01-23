provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0b9734b974d49e8a9"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-03565efa99637b5d1"]
  key_name = "jenkins_server"
}
