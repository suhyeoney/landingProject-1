variable "my_region" {
    type    = string
    default = "ap-northeast-2"
}


variable "image_id_app" {
    type = string
}

variable "image_id_web" {
    type = string
}

variable "key_name" {
    type = string
}

variable "public_key_path" {
    type    = string
    default = "~/.ssh/id_rsa.pub"
}

variable "db_password" {
    type    = string
}

variable "db_port" {
    type    = string
}

variable "db_username" {
    type    = string
}
