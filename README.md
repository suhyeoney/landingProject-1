# landingProject
"First Landing Project - Engineer"

# 사용방법
* Jenkins Server 구축
* Packer
    * local machine에 packer 설치 후, packer dir 내에서 $ packer build 
    * $HOME/.aws/credentials 에 aws profile이 있어야 함
* Terraform
    * local machine에 terraform 설치 후, jenkinsServer.tf 파일의 ami, vpc_security_group_ids, key_name 을 수정
    * terraform dir 내에서 $ terraform init; terraform apply
    * $HOME/.aws/credentials 에 aws profile이 있어야 함