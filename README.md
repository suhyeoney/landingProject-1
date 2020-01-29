# LandingProject
"First Landing Project - SRE"

# 사용방법
* Jenkins Server 구축

    * 주의: $HOME/.aws/credentials 에 aws profile이 있어야 함

    * Packer
        * local machine에 packer 설치 후, packer dir 내에서 $ packer build 
        * $ ./jsonParser (Go bin) 실행시 ../terraform에 필요한 파일이 생성된다.
    
    * Terraform
        * local machine에 terraform 설치 후, jenkinsServer.tf 파일의 vpc_security_group_ids, key_name 을 개인에 맞게 수정
        * terraform dir 내에서 $ terraform init; terraform apply

* App Infra 구축
    * Packer
	* To be added
    * Terraform
	* terraform.tfvars.json 내의 Parameter를 개인에 맞게 수정 후, $ terraform init, terraform apply
