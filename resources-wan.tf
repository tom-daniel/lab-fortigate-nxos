resource "nxos_rest" "vlan-2000" {
  dn         = "sys/bd/bd-[vlan-2000]"
  class_name = "l2BD"
  content = {
    name     = "vlan2000"
    fabEncap = "vlan-2000"
  }
}


resource "nxos_physical_interface" "wan-downlink-1" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = "eth1/1"
  admin_state  = "up"
  description  = "FortiGate WAN"
  mode         = "trunk"
  trunk_vlans  = "2000-2100"

}

resource "nxos_physical_interface" "wan-uplink-1" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = "eth1/3"
  admin_state  = "up"
  description  = "WAN"
  mode         = "trunk"
  trunk_vlans  = "2000-2100"

}


resource "fortios_system_interface" "interface-vlan-2000" {
  defaultgw     = "enable"
  ip            = "10.200.0.2 255.255.255.252"
  mode          = "static"
  name          = "vlan2000"
  interface     = "port5"
  vlan_protocol = "8021q"
  vlanid        = 2000
  vdom          = "root"
  description   = "Created by Terraform Provider for FortiOS"
  allowaccess   = "ping"
}