resource "fortios_system_interface" "interface-abc-a" {
  defaultgw     = "enable"
  ip            = "10.200.0.2 255.255.255.252"
  mode          = "static"
  name          = "abc-a"
  interface     = "port5"
  vlan_protocol = "8021q"
  vlanid        = 2000
  vdom          = "root"
  description   = "Created by Terraform Provider for FortiOS"
  allowaccess   = "ping"
  vrf = 2
}

resource "fortios_system_interface" "interface-abc-b" {
  defaultgw     = "enable"
  ip            = "10.200.0.130 255.255.255.252"
  mode          = "static"
  name          = "abc-b"
  interface     = "port6"
  vlan_protocol = "8021q"
  vlanid        = 2000
  vdom          = "root"
  description   = "Created by Terraform Provider for FortiOS"
  allowaccess   = "ping"
  vrf = 2
}

resource "fortios_system_zone" "abc-zone" {
  intrazone = "allow"
  name      = "abc-zone"
  interface {
    interface_name = fortios_system_interface.interface-abc-a.name
  }
  interface {
    interface_name = fortios_system_interface.interface-abc-b.name
  }
}

resource "fortios_router_prefixlist" "abc-prefix-list-allowed-in" {
  name = "abc-prefix-list-allowed-in"
  rule {
    action = "permit"
    prefix = "172.30.100.0 255.255.255.0"
    le = "32" 
  }
}

resource "fortios_router_prefixlist" "abc-prefix-list-allowed-out" {
  name = "abc-prefix-list-allowed-out"
  rule {
    action = "deny"
    prefix = "0.0.0.0 0.0.0.0"
    le = "32" 
  }
}