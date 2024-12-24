resource "nxos_system" "nxos-system-settings" {
  for_each = toset([for torswitch in local.torswitches : torswitch.name])
  device   = each.key
  name     = each.value
}

resource "nxos_feature_vpc" "feature-vpc" {
  for_each    = toset([for torswitch in local.torswitches : torswitch.name])
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_lacp" "feature-lacp" {
  for_each    = toset([for torswitch in local.torswitches : torswitch.name])
  device      = each.key
  admin_state = "enabled"
}


resource "nxos_save_config" "wr" {
  for_each = toset([for torswitch in local.torswitches : torswitch.name])
  device   = each.key
}

resource "fortios_system_settings" "fortigate-system-settings" {
  allow_subnet_overlap = "enable"
}