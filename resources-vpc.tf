
resource "nxos_vpc_instance" "vpc-instance" {
  for_each    = toset([for torswitch in local.torswitches : torswitch.name])
  device      = each.key
  depends_on  = [nxos_feature_vpc.feature-vpc]
  admin_state = "enabled"
}

resource "nxos_vrf" "vpc-pka-vrf" {
  for_each    = toset([for torswitch in local.torswitches : torswitch.name])
  device      = each.key
  name        = var.vpc-pka-vrf-name
  description = "VPC PKA VRF"
}

resource "nxos_ipv4_vrf" "vpc-pka-ipv4-vrf" {
  for_each = toset([for torswitch in local.torswitches : torswitch.name])
  device   = each.key
  name     = var.vpc-pka-vrf-name
}

resource "nxos_physical_interface" "vpc-pka-interface" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = var.vpc-pka-interface
  layer        = "Layer3"
  description  = "VPC PKA INTERFACE"
}

resource "nxos_physical_interface_vrf" "vpc-pka-interface-vrf" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = var.vpc-pka-interface
  vrf_dn       = "sys/inst-VPC-PKA"
}

resource "nxos_ipv4_interface" "vpc-pka-interface-ipv4" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  vrf          = nxos_ipv4_vrf.vpc-pka-ipv4-vrf[each.key].name
  interface_id = var.vpc-pka-interface
}

resource "nxos_ipv4_interface_address" "tor1-vpc-pka-interface-address" {
  device       = "tor1"
  depends_on   = [nxos_vrf.vpc-pka-vrf, nxos_physical_interface.vpc-pka-interface, nxos_ipv4_interface.vpc-pka-interface-ipv4]
  vrf          = var.vpc-pka-vrf-name
  interface_id = var.vpc-pka-interface
  address      = "1.1.1.1/30"
}

resource "nxos_ipv4_interface_address" "tor2-vpc-pka-interface-address" {
  device       = "tor2"
  depends_on   = [nxos_vrf.vpc-pka-vrf, nxos_physical_interface.vpc-pka-interface, nxos_ipv4_interface.vpc-pka-interface-ipv4]
  vrf          = var.vpc-pka-vrf-name
  interface_id = var.vpc-pka-interface
  address      = "1.1.1.2/30"
}

resource "nxos_vpc_domain" "tor1-vpc-domain" {
  device          = "tor1"
  depends_on      = [nxos_feature_vpc.feature-vpc]
  admin_state     = "enabled"
  domain_id       = 100
  auto_recovery   = "enabled"
  role_priority   = 100
  system_priority = 100
}

resource "nxos_vpc_domain" "tor2-vpc-domain" {
  device          = "tor2"
  depends_on      = [nxos_feature_vpc.feature-vpc]
  admin_state     = "enabled"
  domain_id       = 100
  auto_recovery   = "enabled"
  role_priority   = 150
  system_priority = 150
}

resource "nxos_vpc_keepalive" "tor1-vpc-pka" {
  device               = "tor1"
  depends_on           = [nxos_vpc_domain.tor1-vpc-domain]
  destination_ip       = "1.1.1.2/30"
  source_ip            = "1.1.1.1"
  vrf                  = var.vpc-pka-vrf-name
  type_of_service_type = 0
}

resource "nxos_vpc_keepalive" "tor2-vpc-pka" {
  device               = "tor2"
  depends_on           = [nxos_vpc_domain.tor1-vpc-domain]
  destination_ip       = "1.1.1.1/30"
  source_ip            = "1.1.1.2"
  vrf                  = var.vpc-pka-vrf-name
  type_of_service_type = 0
}


resource "nxos_port_channel_interface" "vpc-peerlink-portchannel" {
  for_each          = toset([for torswitch in local.torswitches : torswitch.name])
  device            = each.key
  interface_id      = "po1"
  port_channel_mode = "active"
  admin_state       = "up"
  description       = "VPC PEERLINK"
  layer             = "Layer2"
  mode              = "trunk"
  trunk_vlans       = "1-4094"

}

resource "nxos_physical_interface" "vpc-peerlink-physical-interface-1" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = "eth1/20"
  admin_state  = "up"
  description  = "VPC PEERLINK"
  layer        = "Layer2"
  mode         = "trunk"
  trunk_vlans  = "1-4094"
}

resource "nxos_physical_interface" "vpc-peerlink-physical-interface-2" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = "eth1/21"
  admin_state  = "up"
  description  = "VPC PEERLINK"
  layer        = "Layer2"
  mode         = "trunk"
  trunk_vlans  = "1-4094"
}

resource "nxos_port_channel_interface_member" "vpc-peerlink-port-channel-interface-member-1" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = nxos_port_channel_interface.vpc-peerlink-portchannel[each.key].interface_id
  #interface_dn = nxos_physical_interface.vpc-peerlink-physical-interface-1[each.key].interface_dn
  interface_dn = "sys/intf/phys-[eth1/20]"
}

resource "nxos_port_channel_interface_member" "vpc-peerlink-port-channel-interface-member-2" {
  for_each     = toset([for torswitch in local.torswitches : torswitch.name])
  device       = each.key
  interface_id = nxos_port_channel_interface.vpc-peerlink-portchannel[each.key].interface_id
  #interface_dn = nxos_physical_interface.vpc-peerlink-physical-interface-2[each.key].interface_dn
  interface_dn = "sys/intf/phys-[eth1/21]"
}

resource "nxos_vpc_peerlink" "vpc-peerlink" {
  for_each        = toset([for torswitch in local.torswitches : torswitch.name])
  device          = each.key
  port_channel_id = nxos_port_channel_interface.vpc-peerlink-portchannel[each.key].interface_id
}
