locals {
  torswitches = [
    {
      name = "tor1"
      url  = "https://10.30.12.7"
    },
    {
      name = "tor2"
      url  = "https://10.30.12.4"
    },
  ]
  spineswitches = [
    {
      name = "spine1"
      url  = "https://10.30.12.8"
    },
    {
      name = "spine2"
      url  = "https://10.30.12.9"
    },
  ]
  leafswitches = [
    {
      name = "tor1"
      url  = "https://10.30.12.7"
    },
    {
      name = "tor2"
      url  = "https://10.30.12.4"
    },
    #{
    #  name = "tor3"
    #  url  = "https://10.30.12.7"
    #},
    #{
    #  name = "tor4"
    #  url  = "https://10.30.12.4"
    #},
  ]
  spineandleafswitches = [
    {
      name = "spine1"
      url  = "https://10.30.12.8"
    },
    {
      name = "spine2"
      url  = "https://10.30.12.9"
    },
    {
      name = "tor1"
      url  = "https://10.30.12.7"
    },
    {
      name = "tor2"
      url  = "https://10.30.12.4"
    },
    #{
    #  name = "tor3"
    #  url  = "https://10.30.12.7"
    #},
    #{
    #  name = "tor4"
    #  url  = "https://10.30.12.4"
    #},
  ]
  edgeswitches = [
    #{
    #  name = "edge1"
    #  url  = "https://10.1.1.1"
    #},
    #{
    #  name = "edge2"
    #  url  = "https://10.1.1.2"
    #},
  ]
}


locals {
  # Create a mapping of device names to their indices
  device_indices = { for idx, switch in local.spineandleafswitches : switch.name => idx }
}