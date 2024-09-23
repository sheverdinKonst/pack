
local lldp_utils = {}

lldp_utils.id_e =
{
    type    = "type",
    value   = "value",
}

lldp_utils.capability_e =
{
    type    = "type",
    enabled   = "enabled",
}

lldp_utils.chassis_e = {
    id              = "id",
    name            = "name",
    descr           = "descr",
    mgmt_ip         = "mgmt-ip",
    mgmt_iface      = "mgmt-iface",
    capability      = "capability",
    id_t            = lldp_utils.id_e,
    capability_t    = lldp_utils.capability_e
}

return lldp_utils





