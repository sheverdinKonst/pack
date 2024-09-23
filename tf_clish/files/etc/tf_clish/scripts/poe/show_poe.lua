#!/usr/bin/lua

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sheverdin.
--- DateTime: 6/21/24 9:23 AM
---

local poe = require "tf_poe_module"

local cmd_in = arg[1]

local function show_config()
    local poeConfigInfo = poe.getPoeConfig()
    local portsNum = poeConfigInfo.global.ports
    portsNum = tonumber(portsNum)
    local key = "port"
    for i = 1, portsNum do
        key = key .. i
        print(poe.portsEnum.port .. i)
        local portlist = poeConfigInfo[key]
        print(poe.portsEnum.poe_plus .. portlist.poe_plus)
        print(poe.portsEnum.priority .. portlist.priority)
        key = "port"
    end
end

local function show_status()
    local poeInfo = poe.getPoeStatusInfo()
    local portArr = poeInfo.ports
    print(poe.poe_enum.mcu .. poeInfo.mcu)
    print(poe.poe_enum.budget .. poeInfo.budget)
    print(poe.poe_enum.consumption .. poeInfo.consumption)

    local poeConfigInfo = poe.getPoeConfig()
    local portsNum = poeConfigInfo.global.ports
    portsNum = tonumber(portsNum)
    local key = "lan"
    for i = 1, portsNum do
        key = key .. i
        print(poe.portsEnum.port .. i)
        local portList = portArr[key]
        print(poe.portsEnum.status .. portList.status)
        if portList.consumption ~= nil then
            print(poe.portsEnum.consumption .. portList.consumption .. " [W]")
        end
        key = "lan"
    end
end

local cmd_poeList =
{
    config = { cmd = "config", func = show_config },
    status = { cmd = "status", func = show_status },
}

local function run_show_poe()
    local cmd_list = cmd_poeList[cmd_in]
    cmd_list.func()
end

run_show_poe()

