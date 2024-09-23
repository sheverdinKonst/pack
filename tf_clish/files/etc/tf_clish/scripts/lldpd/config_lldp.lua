#!/usr/bin/lua

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sheverdin
--- DateTime: 6/6/24 12:43 PM
---
---
--package.path = "/etc/tf_clish/lib_lua/?.lua;" .. package.path

local tf = require "tf_module"
--local port_utilities = require "port_utilities"

local Value_in = ""
local portList_old = {}
local portList_new = {}

local cmd_get_lldp_config = "ubus call uci get '{\"config\":\"lldpd\"}'"
local cmd_del_lldp_if = "uci del lldpd.config.interface"
local cmd_add_lldp_port = "uci add_list lldpd.config.interface="

local function set_enable_lldp(Value_in)
    local cmd = "uci set lldpd.config.enable_lldp=" .. Value_in
    tf.executeCommand(cmd)
    cmd = "uci set lldpd.config.force_lldp=" .. Value_in
    tf.executeCommand(cmd)
end

local function set_lldp_tx_interval(Value_in)
    local cmd = "uci set lldpd.config.lldp_tx_interval=" .. Value_in
    tf.executeCommand(cmd)
end

local function set_lldp_tx_hold(Value_in)
    local cmd = "uci set lldpd.config.lldp_tx_hold=" .. Value_in
    tf.executeCommand(cmd)
end

local function enable_lldp_Ports(status, portRange)
    local min_port = tonumber(portRange[1])
    local max_port = tonumber(portRange[2])

    for port = min_port, max_port do
        local cmd = cmd_add_lldp_port .. "lan" .. port
        tf.executeCommand(cmd)
    end

    if status == "if_not_empty" then
        for _, port in pairs(portList_old) do
            if port < min_port or port > max_port then
                local cmd = cmd_add_lldp_port .. "lan" .. port
                tf.executeCommand(cmd)
            end
        end
    end
end

local function disable_lldp_Ports(status, portRange)
    print("disable_lldp_Ports")
    local min_port = tonumber(portRange[1])
    local max_port = tonumber(portRange[2])
    if status == "if_not_empty" then
        for _, port in pairs(portList_old) do
            if port < min_port or port > max_port then
                local cmd = cmd_add_lldp_port .. "lan" .. port
                tf.executeCommand(cmd)
            end
        end
    end
end

local cmd_statePort =
{
    enable  = enable_lldp_Ports,
    disable = disable_lldp_Ports
}

local function set_ports()
    local portState = arg[3]
    local status = "if_not_empty"
    local portRange = tf.checkPortRange(arg[2])
    if portRange ~= nil and portRange[3] == "range" then
        local lldp_info = tf.collectJsonTable(cmd_get_lldp_config)
        if lldp_info["values"]["config"]["interface"] ~= nil then
            lldp_info = lldp_info["values"]["config"]["interface"]
            for i, portStr in pairs(lldp_info) do
                local port, _ = tf.getPort(portStr)
                portList_old[i] = tonumber(port)
            end
            tf.executeCommand(cmd_del_lldp_if)

        else
            status = "if_empty"
            print("Interface List is empty")
        end
        cmd_statePort[portState](status, portRange)
    else
        return 0
    end
end

local lldp_cmdList =
{
    { cmd = "enable_lldp",      func = set_enable_lldp },
    { cmd = "lldp_tx_interval", func = set_lldp_tx_interval },
    { cmd = "lldp_tx_hold",     func = set_lldp_tx_hold },
    { cmd = "ports",            func = set_ports },
}

local function run_config_lldp()
    local errorCode = 0
    errorCode = tf.validateParam(3, arg)
    if errorCode == 0 then
        for _, value in pairs(lldp_cmdList) do
            if arg[1] == value.cmd then
                value.func(arg[3])
            end
        end
    end
end

run_config_lldp()