#!/usr/bin/lua
--
-- Created by sheverdin.
-- DateTime: 2/14/24 12:06 PM
--

package.path = "/etc/tf_clish/scripts/stp/?.lua;" .. package.path

local tf = require "tf_module"

local uci = require("luci.model.uci").cursor()
local stp = require "stp_module"

local function config_portPriority(port)
    -- print("function config_portPriority()")
    -- print("value = " .. arg[3] .. " port = " .. port)
    local value = tonumber(arg[3])
    if value >= 0 and value <= 15 then
        uci:set("mstpd", port, "treeprio", tostring(arg[3]))
    else
        io.write("error >> Priority value not corrected\n")
    end
end

local function config_portPathcost(port)
    -- print("function config_portPathcost()")
    -- print("value = " .. arg[3] .. " port = " .. port)
    local value = tonumber(arg[3])
    if value >= 0 or value <= 200000000 then
        uci:set("mstpd", port, "pathcost", tostring(arg[3]))
    else
        io.write("error >> Path cost value maust be in range  0 - 200000000\n")
    end
end

local function config_portAdmin_edge(port)
    -- print("function config_portAdmin_edge()")
    -- print("value = " .. arg[3] .. " port = " .. port)
    if arg[3] == "yes" or arg[3] == "no" then
        uci:set("mstpd", port, "adminedge", tostring(arg[3]))
    else
        io.write("error >> Admin edge value not corrected\n")
    end
end

local function config_port_Auto_edge(port)
    -- print("function config_port_Auto_edge()")
    -- print("value = " .. arg[3] .. " port = " .. port)
    if arg[3] == "yes" or arg[3] == "no" then
        uci:set("mstpd", port, "autoedge", tostring(arg[3]))
    else
        io.write("error >> Auto_edge value not corrected\n")
    end
end

local function config_portBpdu_filter(port)
    -- print("function config_portBpdu_filter()")
    -- print("value = " .. arg[3] .. " port = " .. port)

    if arg[3] == "yes" or arg[3] == "no" then
        uci:set("mstpd", port, "bpdufilter", tostring(arg[3]))
    else
        io.write("error >> BPDU filter value not corrected\n")
    end
end

local function config_portBpdu_guard(port)
    -- print("function config_portBpdu_guard()")
    -- print("value = " .. arg[3] .. " port = " .. port)
    local value = tonumber(arg[3])
    if value >= 6 and value <= 40 then
        uci:set("mstpd", port, "bpduguard", tostring(arg[2]))
    else
        io.write("error >> BPDU guard value not corrected\n")
    end
end

local cmdPortList =
{
    {cmd = "treeprio",      func = config_portPriority },
    {cmd = "pathcost",      func = config_portPathcost },
    {cmd = "adminedge",     func = config_portAdmin_edge },
    {cmd = "autoedge",      func = config_port_Auto_edge },
    {cmd = "bpdufilter",    func = config_portBpdu_filter },
    {cmd = "bpduguard",     func = config_portBpdu_guard },
}

local function run_config_stp_port()
    local errorCode = 0

    errorCode = tf.validateParam(3, arg)
    if errorCode == 0 then
        local portRange = tf.checkPortRange(arg[1])

        if portRange ~= nil then
            local minPort = tonumber(portRange[1])
            local maxPort = tonumber(portRange[2])
            local netConfig = tf.collectJsonTable(stp.cmdList.get_netConfig)
            local portList = tf.getPortList(netConfig["values"], "switch", "ports")

            --print("arg[2] = " .. arg[2])
            for _, portStr in pairs(portList) do
                local port, _ = tf.getPort(portStr)
                local portNum = tonumber(port)
                if (portNum >= minPort and portNum <= maxPort) then
                    for _, value in pairs(cmdPortList) do
                        --print("value.cmd = " .. value.cmd)
                        if arg[2] == value.cmd then
                            value.func(portStr)
                        end
                    end
                end
            end
        else
            io.write("error >> port range is wrong\n")
        end
    end
end

run_config_stp_port()
