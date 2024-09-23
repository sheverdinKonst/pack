#!/usr/bin/lua

package.path = "/etc/tf_clish/lib_lua/?.lua;" .. package.path

local tf    = require "tf_module"
local vlan  = require "vlan_utils"

local function run_show_vlan()
    local vlanId = arg[1]
    local netInfo = tf.collectJsonTable(vlan.cmd_list.cmd_netInfo)
    local vlanArr = vlan.getBridgeVlanList(netInfo["values"])

    if (vlanArr == nil) then
        print("error: config bridge-vlan")
    end

    local ifList = tf.getIfList(vlan.cmd_list.cmd_netIfInfo)

    --tf.printarray(vlanArr)

    for _, if_name in pairs(ifList) do
        local cmd = vlan.cmd_list.cmd_deviceInfo_1 .. if_name .. vlan.cmd_list.cmd_deviceInfo_2
        vlanArr = vlan.getMngmntVlan(cmd, vlanArr, if_name)
    end
    --tf.printarray(vlanArr)

    vlan.showVlanInfo(vlanArr, vlanId)
end

run_show_vlan()
