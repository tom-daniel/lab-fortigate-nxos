provider "fortios" {
  hostname = "fortigate.lab.lab"
  username = var.fortigate_api_user
  token    = var.fortigate_api_key
  insecure = true
}

provider "nxos" {
  username = "admin"
  password = var.nxos_password
  devices  = concat(local.torswitches, local.edgeswitches)
}

