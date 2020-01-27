variable "image_id" {
    type = string
}

variable "key_name" {
    type = string
}

variable "public_key_path" {
    type    = string
    default = "~/.ssh/id_rsa.pub"
}