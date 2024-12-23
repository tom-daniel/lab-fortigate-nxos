resource "nxos_rest" "vlan-2000" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
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
}


resource "fortios_router_bgp" "fortigate-bgp" {
  depends_on = [ fortios_system_interface.interface-abc-a, fortios_system_interface.interface-abc-b ]
  router_id = "10.30.12.3"
  as = 50
  neighbor_group {
    name = "abc-a"
    activate = "enable"
    #interface = "abc-a"
    remote_as = 100
  }

  neighbor_group {
    name = "abc-b"
    activate = "enable"
    #interface = "abc-b"
    remote_as = 100
  }

  neighbor_range {
    prefix = "10.200.0.0/25"
    neighbor_group = "abc-a"
  }

  neighbor_range {
    prefix = "10.200.0.128/25"
    neighbor_group = "abc-b"
  }
}