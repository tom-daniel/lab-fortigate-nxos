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
  trunk_vlans  = "100,2000-2100"

}

resource "nxos_physical_interface" "wan-uplink-1" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = "eth1/3"
  admin_state  = "up"
  description  = "WAN"
  mode         = "trunk"
  trunk_vlans  = "100,2000-2100"

}


resource "fortios_router_bgp" "fortigate-bgp" {
  depends_on = [ fortios_system_interface.interface-abc-a, fortios_system_interface.interface-abc-b ]
  router_id = "10.30.12.3"
  as = 50
  neighbor_group {
    name = "abc-a"
    activate = "enable"
    remote_as = 100
    prefix_list_in = fortios_router_prefixlist.abc-prefix-list-allowed-in.name
    prefix_list_out = fortios_router_prefixlist.abc-prefix-list-allowed-out.name
    interface = fortios_system_interface.interface-abc-a.name
    update_source = fortios_system_interface.interface-abc-a.name
  }

  neighbor_group {
    name = "abc-b"
    activate = "enable"
    remote_as = 100
    prefix_list_in = fortios_router_prefixlist.abc-prefix-list-allowed-in.name
    prefix_list_out = fortios_router_prefixlist.abc-prefix-list-allowed-out.name
    interface = fortios_system_interface.interface-abc-b.name
    update_source = fortios_system_interface.interface-abc-b.name
  }

  neighbor_range {
    prefix = "10.200.0.0/25"
    neighbor_group = "abc-a"
  }

  neighbor_range {
    prefix = "10.200.0.128/25"
    neighbor_group = "abc-b"
  }

  #vrf leakingConfig for old fortigates
  vrf_leak {
    vrf = 1
    target {
      vrf = 2
      route_map = fortios_router_routemap.route-map-leak-001-to-002.name
      interface = fortios_system_interface.v-001-002-0.name
    }
  }

    vrf_leak {
    vrf = 2
    target {
      vrf = 1
      route_map = fortios_router_routemap.route-map-leak-002-to-001.name
      interface = fortios_system_interface.v-001-002-1.name
    }
  }

  #vrf leakingConfig for new fortigates
  #vrf {
  #  vrf = 1
  #  leak_target {
  #    vrf = 2
  #    route_map = fortios_router_routemap.route-map-leak-001-to-002.name
  #    interface = fortios_system_interface.v-001-002-0.name
  #  }
  #}
}


