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