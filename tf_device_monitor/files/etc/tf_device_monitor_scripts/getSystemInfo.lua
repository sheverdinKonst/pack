#!/usr/bin/lua

---
--- Generated by Luanalysis
--- Created by sheverdin.
--- DateTime: 3/1/24 12:26 PM
---

local tf = require "tf_module"

local systemInfo = {
    hostname    = "hostname",
    description = "description",
    notes       = "notes",
    location    = "location"
}

local function main_getSystemInfo()
    local  cmd_getSystemInfo =  tf.ubusList.cmd_ubus ..  tf.ubusList.cmd_get ..  tf.ubusList.cmd_prefix .. tf.ubusList.cmd_config ..
            "system" .. tf.ubusList.cmd_section .. "system" .. tf.ubusList.cmd_suffix

    local jsonData = tf.collectJsonTable(cmd_getSystemInfo)
    if jsonData ~= nil then
        if type(jsonData.values) == "table" then
            local location      = jsonData.values[systemInfo.location]
            local description   = jsonData.values[systemInfo.description]
            print(location)
            print(description)
        else
            print("")
        end
    end
end

main_getSystemInfo()
