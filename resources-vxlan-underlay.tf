resource "nxos_feature_ospf" "feature-ospf" {
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_ospf" "global-ospf" {
  depends_on = [ nxos_feature_ospf.feature-ospf]
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_ospf_instance" "underlay-ospf-instance" {
  depends_on = [ nxos_ospf.global-ospf]
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  admin_state = "enabled"
  name        = "UNDERLAY"
}

resource "nxos_ospf_vrf" "underlay-ospf-vrf" {
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  instance_name            = nxos_ospf_instance.underlay-ospf-instance[each.key].name
  name                     = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  admin_state              = "enabled"
}

resource "nxos_loopback_interface" "underlay-loopback" {
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  interface_id = "lo0"
  admin_state  = "up"
  description  = "UNDERLAY LOOPBACK"
}

resource "nxos_ipv4_vrf" "ipv4-default-vrf" {
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  name = "default"
}

resource "nxos_ipv4_interface" "underlay-loopback-ipv4-interface" {
  depends_on = [ nxos_loopback_interface.underlay-loopback ]
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = "lo0"
}

resource "nxos_ipv4_interface_address" "underlay-loopback-ipv4-interface" {
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = nxos_ipv4_interface.underlay-loopback-ipv4-interface[each.key].interface_id
# Increment the IP address for each device
  address      = "${cidrhost("10.255.0.0/24", local.device_indices[each.key] + 1)}/32"
}

resource "nxos_ospf_interface" "ospf-interface-loopback" {
  for_each    = toset([for switch in local.spineandleafswitches : switch.name])
  device      = each.key
  instance_name         = nxos_ospf_instance.underlay-ospf-instance[each.key].name
  vrf_name              = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id          = nxos_ipv4_interface.underlay-loopback-ipv4-interface[each.key].interface_id
  area                  = "0.0.0.0"
}

resource "nxos_physical_interface" "leaf-underlay-uplink-1" {
  for_each    = toset([for switch in local.leafswitches : switch.name])
  device      = each.key
  interface_id             = "eth1/22"
  admin_state              = "up"
  description              = "LINK TO SPINE 1"
  layer                    = "Layer3"
  mtu                      = "9192"
  medium                   = "p2p"
}

resource "nxos_ipv4_interface" "leaf-underlay-uplink-1-ipv4-interface" {
  depends_on = [ nxos_ipv4_interface_address.underlay-loopback-ipv4-interface ]
  for_each    = toset([for switch in local.leafswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = nxos_physical_interface.leaf-underlay-uplink-1[each.key].interface_id
  unnumbered = "lo0"
}

resource "nxos_ospf_interface" "leaf-underlay-uplink-1-ospf-interface" {
  for_each    = toset([for switch in local.leafswitches : switch.name])
  device      = each.key
  instance_name         = "UNDERLAY"
  vrf_name              = "default"
  interface_id          = nxos_physical_interface.leaf-underlay-uplink-1[each.key].interface_id
  area                  = "0.0.0.0"
  network_type          = "p2p"
}

resource "nxos_physical_interface" "leaf-underlay-uplink-2" {
  for_each    = toset([for switch in local.leafswitches : switch.name])
  device      = each.key
  interface_id             = "eth1/23"
  admin_state              = "up"
  description              = "LINK TO SPINE 2"
  layer                    = "Layer3"
  mtu                      = "9192"
  medium                   = "p2p"
}

resource "nxos_ipv4_interface" "leaf-underlay-uplink-2-ipv4-interface" {
  depends_on = [ nxos_ipv4_interface_address.underlay-loopback-ipv4-interface ]
  for_each    = toset([for switch in local.leafswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = nxos_physical_interface.leaf-underlay-uplink-2[each.key].interface_id
  unnumbered = "lo0"
}

resource "nxos_ospf_interface" "leaf-underlay-uplink-2-ospf-interface" {
  for_each    = toset([for switch in local.leafswitches : switch.name])
  device      = each.key
  instance_name         = "UNDERLAY"
  vrf_name              = "default"
  interface_id          = nxos_physical_interface.leaf-underlay-uplink-2[each.key].interface_id
  area                  = "0.0.0.0"
  network_type          = "p2p"
}




resource "nxos_physical_interface" "spine-underlay-downlink-1" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  interface_id             = "eth1/1"
  admin_state              = "up"
  description              = "LINK TO LEAF 1"
  layer                    = "Layer3"
  mtu                      = "9192"
  medium                   = "p2p"
}

resource "nxos_ipv4_interface" "spine-underlay-downlink-1-ipv4-interface" {
  depends_on = [ nxos_ipv4_interface_address.underlay-loopback-ipv4-interface ]
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = nxos_physical_interface.spine-underlay-downlink-1[each.key].interface_id
  unnumbered = "lo0"
}

resource "nxos_ospf_interface" "spine-underlay-uplink-1-ospf-interface" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  instance_name         = "UNDERLAY"
  vrf_name              = "default"
  interface_id          = nxos_physical_interface.spine-underlay-downlink-1[each.key].interface_id
  area                  = "0.0.0.0"
  network_type          = "p2p"
}




resource "nxos_physical_interface" "spine-underlay-downlink-2" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  interface_id             = "eth1/2"
  admin_state              = "up"
  description              = "LINK TO LEAF 2"
  layer                    = "Layer3"
  mtu                      = "9192"
  medium                   = "p2p"
}

resource "nxos_ipv4_interface" "spine-underlay-downlink-2-ipv4-interface" {
  depends_on = [ nxos_ipv4_interface_address.underlay-loopback-ipv4-interface ]
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = nxos_physical_interface.spine-underlay-downlink-2[each.key].interface_id
  unnumbered = "lo0"
}

resource "nxos_ospf_interface" "spine-underlay-uplink-2-ospf-interface" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  instance_name         = "UNDERLAY"
  vrf_name              = "default"
  interface_id          = nxos_physical_interface.spine-underlay-downlink-2[each.key].interface_id
  area                  = "0.0.0.0"
  network_type          = "p2p"
}



resource "nxos_physical_interface" "spine-underlay-downlink-3" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  interface_id             = "eth1/3"
  admin_state              = "up"
  description              = "LINK TO LEAF 3"
  layer                    = "Layer3"
  mtu                      = "9192"
  medium                   = "p2p"
}

resource "nxos_ipv4_interface" "spine-underlay-downlink-3-ipv4-interface" {
  depends_on = [ nxos_ipv4_interface_address.underlay-loopback-ipv4-interface ]
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = nxos_physical_interface.spine-underlay-downlink-3[each.key].interface_id
  unnumbered = "lo0"
}

resource "nxos_ospf_interface" "spine-underlay-uplink-3-ospf-interface" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  instance_name         = "UNDERLAY"
  vrf_name              = "default"
  interface_id          = nxos_physical_interface.spine-underlay-downlink-3[each.key].interface_id
  area                  = "0.0.0.0"
  network_type          = "p2p"
}



resource "nxos_physical_interface" "spine-underlay-downlink-4" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  interface_id             = "eth1/4"
  admin_state              = "up"
  description              = "LINK TO LEAF 4"
  layer                    = "Layer3"
  mtu                      = "9192"
  medium                   = "p2p"
}

resource "nxos_ipv4_interface" "spine-underlay-downlink-4-ipv4-interface" {
  depends_on = [ nxos_ipv4_interface_address.underlay-loopback-ipv4-interface ]
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  vrf          = nxos_ipv4_vrf.ipv4-default-vrf[each.key].name
  interface_id = nxos_physical_interface.spine-underlay-downlink-4[each.key].interface_id
  unnumbered = "lo0"
}

resource "nxos_ospf_interface" "spine-underlay-uplink-4-ospf-interface" {
  for_each    = toset([for switch in local.spineswitches : switch.name])
  device      = each.key
  instance_name         = "UNDERLAY"
  vrf_name              = "default"
  interface_id          = nxos_physical_interface.spine-underlay-downlink-4[each.key].interface_id
  area                  = "0.0.0.0"
  network_type          = "p2p"
}




