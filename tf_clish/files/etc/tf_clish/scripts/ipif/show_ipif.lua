#!/usr/bin/lua

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sheverdin.
--- DateTime: 6/21/24 11:51 AM
---

local tf = require "tf_module"

local if_enum = {
    device  = "\tdevice:        \t",
    proto   = "\tipv4 method:   \t",
    ipaddr  = "\tip address:    \t",
    netmask = "\tnetmask        \t",
    gateway = "\tgateway        \t",
    dns     = "\tdns:           \t",
}

local cmd_show_if = "ubus call uci get '{\"config\":\"network\", \"type\":\"interface\"}'"

local function run_show_ipif()
    local ipifInfo = tf.collectJsonTable(cmd_show_if)
    ipifInfo = ipifInfo.values


    for key, value in pairs(ipifInfo) do
        print("Interface:\t" .. key)
        if value.device ~= nil then
            print(if_enum.device .. value.device)
        end
        if value.proto ~= nil then
            print(if_enum.proto .. value.proto)
        end
        if value.ipaddr ~= nil then
            print(if_enum.ipaddr .. value.ipaddr)
        end
        if value.netmask ~= nil then
            print(if_enum.netmask .. value.netmask)
        end
        if value.gateway ~= nil then
            print(if_enum.gateway .. value.gateway)
        end
        if value.dns ~= nil then
            print(if_enum.dns .. value.dns)
        end
    end
end

run_show_ipif()

