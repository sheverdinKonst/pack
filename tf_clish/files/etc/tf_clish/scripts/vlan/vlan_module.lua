
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sheverdin.
--- DateTime: 6/17/24 2:33 PM
---
---
---

local vlan_module = {}
package.path = "/etc/tf_clish/scripts/vlan/?.lua;" .. package.path

local tf            = require "tf_module"
local vlan_utils    = require "vlan_utils"
local uci           = require("luci.model.uci").cursor()

vlan_module.cmd_vlan_list =
{
    cmd_netIfInfo     = "ubus call network.interface dump",
    cmd_netInfo       = "ubus call uci get '{\"config\":\"network\"}'",
    cmd_deviceInfo_1  = "ubus call uci get '{\"config\":\"network\", \"section\":\"",
    cmd_deviceInfo_2  = "\",\"option\":\"device\"}'"
}

function vlan_module.showVlanInfo(vlan_arr, id)
    local vlan = {}
    if id == "all" then
        for _, vlanList in pairs(vlan_arr) do
            vlan_utils.printVlanParm(vlanList)
        end
    elseif (tonumber(id) ~= 0) then
        if vlan_arr[id] ~= nil then
            vlan = vlan_arr[id]
            vlan_utils.printVlanParm(vlan)
        else
            print("error: Vlan " .. id .. " does not exist, chose *show all vlan* to inspect existing Vlan")
        end
    end
end

function vlan_module.getBridgeVlanList(netData)
    local vlan_arr = {}
    local num = ""
    for key, list in pairs(netData) do
        if list[".type"] ~= nil and list[".type"] == "bridge-vlan" then
            local vlanList = {}
            vlanList.id = vlan_utils.setVlanParam(list[".name"])
            vlanList.num = vlan_utils.setVlanParam(list["vlan"])
            vlanList.device = vlan_utils.setVlanParam(list["device"])
            vlanList.state = vlan_utils.setVlanParam(list["state"])
            vlanList.descr = vlan_utils.setVlanParam(list["descr"])
            vlanList.ports = vlan_utils.setPorts(list["ports"])
            num = vlanList.num
            vlan_arr[num] = vlanList
        end
    end
    return vlan_arr
end

function vlan_module.getMngmntVlan(cmd, vlanArr, if_name)
    local devInfo = tf.collectJsonTable(cmd)
    local mngtVlan = {}
    for i in devInfo["value"]:gmatch("[^.]+") do
        table.insert(mngtVlan, i)
    end
    if mngtVlan[1] == "switch" then
        local num = mngtVlan[2]
        vlanArr[num].mngtVlan = "yes"
        vlanArr[num].ifname = if_name
    end
    return vlanArr
end

function vlan_module.add_untagged(vlanArr, vlan_id, portRange, cmd)
    --print("vlan_add_untagged")
    local portRangeMin = tonumber(portRange[1])
    local portRangeMax = tonumber(portRange[2])

    local busy_vlanPortList = {}
    local add_vlanPortList = {}
    local add_count = 0
    local vlan_index = ""

    vlan_index = tostring(vlan_id)

    local vlan_list = {}
    vlan_list = vlanArr[vlan_index]
    if vlan_list == nil then
        print("Vlan  *" .. vlan_index .. "* not presented")
        -- TODO create function to add new Vlan
    else
        table.insert(busy_vlanPortList, vlan_index, vlan_utils.saveVlan(vlan_list))
        --busy_vlanPortList[vlan_index] = vlan_utils.saveVlan(vlan_list)
    end

    local port_index = ""
    for i = portRangeMin, portRangeMax do
        port_index = tostring(i)
        local status = "free"
        for id, vlanList in pairs(vlanArr) do
            if vlanList.ports == nil then
                --print("info: there are no ports assigned on this Vlan *" .. vlan_index .. "*")
            else
                if vlanList.ports ~= nil then
                    for num, state in pairs(vlanList.ports) do
                        if i == num then
                            if cmd == "add" then
                                status = "busy"
                            elseif cmd == "edit" then
                                if id ~= tostring(vlan_id) then
                                    print("info: Port *" .. num .. "*  busy in  Vlan *" .. vlanList.num .. "*")
                                    status = "busy"
                                end
                            end
                        end
                    end
                end
            end
        end

        if status == "free" then

            if busy_vlanPortList == nil then
                if cmd == "add" then
                    local portList = {}
                    portList[i] = "U"
                    add_count = add_count + 1
                    busy_vlanPortList = {}
                    busy_vlanPortList[vlan_id] = portList
                end
            else
                for id, portList in pairs(busy_vlanPortList) do
                    if cmd == "add" then
                        if portList[i] == nil then
                            portList[i] = "U"
                            add_count = add_count + 1
                        end
                    elseif cmd == "edit" then
                        if portList[i] ~= nil then
                            portList[i] = "U"
                            add_count = add_count + 1
                        else
                            print("info: Port " .. i .. " not set -- first, use the add command")
                        end
                    end
                end
            end
        end
    end

    if add_count > 0 then
        --print("total added " .. add_count .. ":")
        tf.printarray(add_vlanPortList)
        vlan_utils.uciSetVlanParam(vlanArr, busy_vlanPortList)
    else
        print("error: All ports are busy in another VLAN")
    end

end

function vlan_module.add_tagged(vlanArr, vlanRange, portRange, cmd)
    --print("vlan_add_tagged")

    local portRangeMin = tonumber(portRange[1])
    local portRangeMax = tonumber(portRange[2])
    local vlanRangeMin = tonumber(vlanRange[1])
    local vlanRangeMax = tonumber(vlanRange[2])

    --local vlan = vlanArr[tostring(vlan_id)]
    --local cmd = "uci del network." .. vlan.id .. "ports"
    --tf.executeCommand(cmd)

    local busy_vlanPortList = {}
    local add_vlanPortList = {}

    local add_count = 0
    local vlan_index = ""

    for i = vlanRangeMin, vlanRangeMax do
        vlan_index = tostring(i)

        local vlan_list = {}
        vlan_list = vlanArr[vlan_index]
        if vlan_list == nil then
            print("Vlan  *" .. vlan_index .. "* not presented")
            -- TODO create function to add new Vlan
        else
            table.insert(busy_vlanPortList, vlan_index, vlan_utils.saveVlan(vlan_list))
            --busy_vlanPortList[vlan_index] = vlan_utils.saveVlan(vlan_list)
        end
    end

    --print("SAVED :")
    --tf.printarray(busy_vlanPortList)

    for i = portRangeMin, portRangeMax do
        local status = "free"
        for id, vlanList in pairs(vlanArr) do
            if vlanList.ports == nil then
                --print("info: there are no ports assigned on this Vlan *" .. vlan_index .. "*")
            else
                for portNum, state in pairs(vlanList.ports) do
                    if cmd == "add" then
                        if i == portNum and state == "U" then
                            print("info: Port *" .. portNum .. "* \"U\"  busy in Vlan *" .. vlanList.num .. "*")
                            status = "busy"
                        end
                    elseif cmd == "edit" then
                        if tonumber(id) < vlanRangeMin or tonumber(id) > vlanRangeMax then
                            if i == portNum and state == "U" then
                                print("info: >>> Port *" .. portNum .. "* \"U\"  busy in  Vlan*" .. vlanList.num .. "*")
                                status = "busy"
                            end
                        end
                    end
                end
            end
        end

        if status == "free" then
            for vlan_id, portList in pairs(busy_vlanPortList) do
                if portList == nil then
                    print("error: portList is empty " .. " vlan_id = " .. vlan_id)
                end
                if cmd == "add" then
                    if portList[i] == nil then
                        portList[i] = "T"
                        add_count = add_count + 1
                        add_vlanPortList[i] = "T"
                    elseif portList[i] ~= nil then
                        print("info: Port  " .. i .. " busy --  state = " .. portList[i])
                    end
                elseif cmd == "edit" then
                    if portList[i] ~= nil then
                        portList[i] = "T"
                        add_count = add_count + 1
                        add_vlanPortList[i] = "T"
                    elseif portList[i] == nil then
                        print("info: Port " .. i .. " not set -- first, use the add command")
                    end
                end
            end
        end
    end

    if add_count > 0 then
        --print("total added " .. add_count .. ":")
        --print("Finally busy_vlanPortList:")
        --tf.printarray(busy_vlanPortList)
        vlan_utils.uciSetVlanParam(vlanArr, busy_vlanPortList)
    else
        print("error: All ports are busy in another VLAN")
    end
end

function vlan_module.add_notMemberPorts(vlanArr, vlanRange, portRange)
    local portRangeMin = tonumber(portRange[1])
    local portRangeMax = tonumber(portRange[2])
    local vlanRangeMin = tonumber(vlanRange[1])
    local vlanRangeMax = tonumber(vlanRange[2])

    --local cmd = "uci del network." .. vlan.id .. "ports"
    --tf.executeCommand(cmd)

    local busy_vlanPortList = {}
    local vlan_index = ""
    local remove_count = 0

    for i = vlanRangeMin, vlanRangeMax do
        vlan_index = tostring(i)

        local vlan_list = {}
        vlan_list = vlanArr[vlan_index]
        if vlan_list == nil then
            print("Vlan  *" .. vlan_index .. "* not presented")
            -- TODO create function to add new Vlan
        else
            table.insert(busy_vlanPortList, vlan_index, vlan_utils.saveVlan(vlan_list))
            --busy_vlanPortList[vlan_index] = vlan_utils.saveVlan(vlan_list)
        end
    end

    for i = portRangeMin, portRangeMax do
        for vlan_id, portList in pairs(busy_vlanPortList) do
            if portList[i] ~= nil then
                --print("remove port " .. i .. "from vlan " .. vlan_id)
                portList[i] = nil
                remove_count = remove_count + 1
            end
        end
    end

    if remove_count > 0 then
        --print("Finally removed list:")
        vlan_utils.uciSetVlanParam(vlanArr, busy_vlanPortList)
        print("\nwarning:\n \t\tThis operation may result in LOSS OF COMMUNICATION with the switch")
        print("\t\tBefore saving the changes, make sure they are correct !!!")
    end
end

function vlan_module.set_param(id, cmd_in, str)
    local cmd = "uci set network." .. id .. "." .. cmd_in .. "=" .. str
    tf.executeCommand(cmd)
end

function vlan_module.delete(id)
    --print("delete")
    local cmd = "uci del network." .. id
    --print("cmd = " .. cmd)
    tf.executeCommand(cmd)
end

function vlan_module.addVlan(id)
    local cmd = ""
    local uci_set_cmd = "uci set network"
    local uci_add_cmd = "uci add network "

    cmd = uci_add_cmd .. "bridge-vlan"
    local res_br_vlan = tf.executeCommand(cmd)
    local endIndex = string.len(res_br_vlan)
    res_br_vlan = string.sub(res_br_vlan, 1, endIndex - 2)
    --print(" ============================================= ")
    if res_br_vlan ~= nil and type(res_br_vlan) == "string" and res_br_vlan ~= "" then
        --print("res = " .. res_br_vlan)
        cmd = uci_set_cmd .. "." .. "@bridge-vlan[-1]" .. ".device=switch"
        --print("cmd = " .. cmd)
        tf.executeCommand(cmd)
        cmd = uci_set_cmd .. "." .. "@bridge-vlan[-1]" .. ".vlan=" .. id
        --print("cmd = " .. cmd)
        tf.executeCommand(cmd)
        cmd = uci_set_cmd .. "." .. "@bridge-vlan[-1]" .. ".state=enable"
        --print("cmd = " .. cmd)

    else
        return "not set"
    end

    --print(" ******************************************************** ")
    cmd = ""
    cmd = uci_add_cmd .. "device"
    local res_device = tf.executeCommand(cmd)
    endIndex = string.len(res_device)
    res_device = string.sub(res_device, 1, endIndex - 2)
    if res_device ~= nil and type(res_device) == "string" and res_device ~= "" then
        --print("res = " .. res_device)
        cmd = uci_set_cmd .. "." .. "@device[-1]" .. ".name=switch." .. id
        --print("cmd = " .. cmd)
        tf.executeCommand(cmd)
        cmd = uci_set_cmd .. "." .. "@device[-1]" .. ".type=8021q"
        --print("cmd = " .. cmd)
        tf.executeCommand(cmd)
        cmd = uci_set_cmd .. "." .. "@device[-1]" .. ".ifname=switch"
        --print("cmd = " .. cmd)
        tf.executeCommand(cmd)
        cmd = uci_set_cmd .. "." .. "@device[-1]" .. ".vid=" .. id
        --print("cmd = " .. cmd)
        tf.executeCommand(cmd)
        cmd = uci_set_cmd .. "." .. "@device[-1]" .. ".macaddr=" .. "C0:11:A6:00:00:00"
        --print("cmd = " .. cmd)
        tf.executeCommand(cmd)
    else
        return "not set"
    end
    return "OK"
end


function vlan_module.uci_addVlan(id)
    local value = ""
    value = "vlan" .. id
    local bridge_id = "ubus call uci add '{\"config\":\"network\",\"type\":\"bridge-vlan\", \"name\":\"" .. value .. "\"}'"
    --print("bridge_id = " .. bridge_id)
    tf.executeCommand(bridge_id)

    --print("set br vlan  param :")
    uci:set("network", value, ".name", value)
    uci:set("network", value, "device", "switch")
    uci:set("network", value, "vlan", id)
    uci:set("network", value, "state", "enable")

    value = "switch" .. id
    local device_id = "ubus call uci add '{\"config\":\"network\", \"type\":\"device\", \"name\":\"" .. value .. "\"}'"
    --print("device_id = " .. device_id)
    tf.executeCommand(device_id)
    --print("set device param :")
    uci:set("network", value, "name", "switch." .. id)
    uci:set("network", value, "type", "8021q")
    uci:set("network", value, "ifname", "switch")
    uci:set("network", value, "vid", id)
    uci:set("network", value, "macaddr", "C0:11:A6:00:00:00")

    return "OK"
end

function vlan_module.mngt_vlan(vlanList, vlan_id, ifName)
    if vlanList.ports == nil then
        print("warning: Vlan *" .. vlan_id .. "* Can not to change to \"Management interface\" " .. ifName .. "\n" ..
            "Ports list is empty")
    else
        if (vlanList.mngtVlan == "yes") and vlanList.ifname == ifName then
            print("info: this Vlan is current \"Management interface:\" *" .. ifName .. "*")
        else
            local devName = "switch." .. vlan_id
            local res = uci:set("network", ifName, "device", devName)
            if res == true then
                print("info: Vlan *" .. vlan_id .. "* set to \"Management interface\" " .. ifName)
            elseif res == false then
                print("error: Can not to change \"Management Vlan\"")
            end
        end
    end
end

return vlan_module

