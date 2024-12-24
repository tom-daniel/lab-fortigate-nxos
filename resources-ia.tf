resource "nxos_rest" "vlan-100" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  dn         = "sys/bd/bd-[vlan-100]"
  class_name = "l2BD"
  content = {
    name     = "vlan100"
    fabEncap = "vlan-100"
  }
}


resource "fortios_system_interface" "interface-ia-a" {
  defaultgw     = "enable"
  ip            = "198.51.100.2 255.255.255.252"
  mode          = "static"
  name          = "ia-a"
  interface     = "port5"
  vlan_protocol = "8021q"
  vlanid        = 100
  vdom          = "root"
  description   = "Created by Terraform Provider for FortiOS"
  allowaccess   = "ping"
  vrf = 1
}

resource "fortios_system_interface" "interface-ia-b" {
  defaultgw     = "enable"
  ip            = "198.51.100.6 255.255.255.252"
  mode          = "static"
  name          = "ia-b"
  interface     = "port6"
  vlan_protocol = "8021q"
  vlanid        = 100
  vdom          = "root"
  description   = "Created by Terraform Provider for FortiOS"
  allowaccess   = "ping"
  vrf = 1
}

resource "fortios_system_zone" "ia-zone" {
  intrazone = "allow"
  name      = "ia-zone"
  interface {
    interface_name = fortios_system_interface.interface-ia-a.name
  }
  interface {
    interface_name = fortios_system_interface.interface-ia-b.name
  }
}

resource "fortios_router_prefixlist" "ia-prefix-list-allowed-out" {
  name = "ia-prefix-list-allowed-out"
  rule {
    action = "permit"
    prefix = "89.101.50.0 255.255.255.0"
  }
  rule {
    action = "deny"
    prefix = "0.0.0.0 0.0.0.0"
    le = "32" 
  }
}

resource "fortios_routerbgp_neighbor" "bgp-neighbor-ia-a" {
  ip = "198.51.100.1"
  activate = "enable"
  remote_as = 2567
  interface = fortios_system_interface.interface-ia-a.name
  prefix_list_out = fortios_router_prefixlist.ia-prefix-list-allowed-out.name
}

resource "fortios_routerbgp_neighbor" "bgp-neighbor-ia-b" {
  ip = "198.51.100.5"
  activate = "enable"
  remote_as = 2567
  interface = fortios_system_interface.interface-ia-b.name
  prefix_list_out = fortios_router_prefixlist.ia-prefix-list-allowed-out.name
}

resource "fortios_router_static" "null-route-public-range-1" {
  blackhole           = "enable"
  dst = "89.101.50.0 255.255.255.0"
  link_monitor_exempt = "disable"
  status              = "enable"
  vrf                 = 1
}

resource "fortios_routerbgp_network" "bgp-network-public-range-1" {
  prefix = "89.101.50.0 255.255.255.0"
}


resource "fortios_firewall_ippool" "abc-patpool-1" {
  name                = "abc-patpool-1"
  startip             = "89.101.50.0"
  endip             = "89.101.50.0"
  type                = "overload"
}

resource "fortios_router_static" "null-route-abc-patpool-1" {
  blackhole           = "enable"
  dst = "89.101.50.0 255.255.255.255"
  link_monitor_exempt = "disable"
  status              = "enable"
  vrf                 = 2
}

resource "fortios_routerbgp_network" "bgp-network-abc-patpool-1" {
  prefix = "89.101.50.0 255.255.255.255"
}
