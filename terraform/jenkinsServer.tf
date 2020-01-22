provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_instance" "jenkins_server" {
  ami           = "landingProject-JenkinsServer"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-03565efa99637b5d1"]
}
