#!/usr/bin/lua

---
--- Created by sheverdin.
--- DateTime: 2/29/24 10:59 AM
---

local tf = require "tf_module"

local  mngmtDevice= {
    interface = "interface",
    l3_device = "l3_device"
}

local function main_getNetDeviceInfo()
    local cmd_getMngmntDeviceInfo = "ubus call network.interface dump"
    local jsonData = tf.collectJsonTable(cmd_getMngmntDeviceInfo)
    if jsonData ~= nil then
        if type(jsonData[mngmtDevice.interface]) == "table" then
            for k, value in pairs(jsonData.interface) do
                if value[mngmtDevice.interface] == arg[1]  then
                    print(value[mngmtDevice.l3_device])
                end
            end
        else
            print("")
        end
    end
end

main_getNetDeviceInfo()





