variable "headless_build" {
  type =  bool
  default = true
}

variable "memory_amount" {
  type =  string
  default = "2048"
}

variable "rsa_key_location" {
  type = string
    # On MacOS use this Source Path, assuming your user is named: palad
  # default = "/Users/palad/.ssh/id_rsa_itmo-453-github-deploy"
  # On Windows use this syntax, assuming your user is named: palad
  # default = "C:\Users\palad\.ssh\id_rsa_itmo-453-github-deploy"
  # On Linux use this syntax, assuming your user is named: controller
  default = "/home/ebudiono/.ssh/id_rsa_itmo-453-github-deploy"
  #default = "C:\\Users\\enriq\\.ssh\\id_rsa_itmo-453-class-github-deploy"

}

variable "build_artifact_location" {
  type = string
  #default = "../build"
  # This is the default path on the build-server to place the .box files for download via a webserver
  default = "/datadisk2/boxes/ebudi-"
}