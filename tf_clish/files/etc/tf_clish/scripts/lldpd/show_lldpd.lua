#!/usr/bin/lua

package.path = "/etc/tf_clish/scripts/lldpd/?.lua;" .. package.path

local tf          = require "tf_module"
local utils       = require "lldp_utils"
local neighbors   = require "lldp_neighbors"
local statistics  = require "lldp_statistics"
local interface   = require "lldp_interfaces"
local chassis     = require "lldp_chassis"

local portRange = { 0, 0 }
local lldpdInfo = {}
local lldpConfig = {}

local interfaces_e = {}

-- local lldp_mian = {
--     interfaces = interfaces_e,
--     statistics = statistics.statistics_e,
--     neighbors  = neighbors.neighbors_e,
--     chassis    = utils.chassis_e
-- }

local cmdList = {
    lldpd_status = "ubus call lldpd getStatus",
    lldpd_config = "ubus call uci get '{\"config\":\"lldpd\"}'"
}

local function Interfaces(isPrint)
    print(" > > > Interfaces: ")
    local i_portCount = 0

    for _, lldp in pairs(lldpdInfo.interfaces.lldp) do
        for _, lldp_interface_arr in pairs(lldp) do
            for _, lldp_interface in pairs(lldp_interface_arr) do
                if (lldp_interface ~= nil) then
                    print()
                    if portRange[3] == "range" or portRange[3] == "once" then
                        isPrint = tf.needToPrint(portRange, lldp_interface.name)
                    elseif portRange[3] == "all" then
                        isPrint = 1
                    end
                    if isPrint == 1 then
                        i_portCount = interface.parsingInterfaces(lldp_interface)
                    end
                end
            end
        end
    end

    if i_portCount == 0 then
        print("According to your conditions, no PORT have been found for Interface statistics")
    end
end

local function Statistics(isPrint)
    print(" > > Statistics: ")
    local s_portCount = 0
    for i, lldp in pairs(lldpdInfo.statistics.lldp) do
        for key, lldp_statistics_arr in pairs(lldp) do
            for param, lldp_statistics in pairs(lldp_statistics_arr) do
                if (lldp_statistics ~= nil) then
                    if portRange[3] == "all" then
                        s_portCount = statistics.parsingStatistics(lldp_statistics)
                    else
                        isPrint = tf.needToPrint(portRange, lldp_statistics.name)
                        if (isPrint == 1) then
                            s_portCount = statistics.parsingStatistics(lldp_statistics)
                        end
                    end
                end
            end
        end
    end
    if s_portCount == 0 then
        print("According to your conditions, Statistics are not presented")
    end
end

local function Neighbors(isPrint)
    print(" > > Neighbors: ")
    local n_portCount = 0

    for i, lldp in pairs(lldpdInfo.neighbors.lldp) do
        for key, lldp_neighbors_arr in pairs(lldp) do
            for param, lldp_neighbors in pairs(lldp_neighbors_arr) do
                if (lldp_neighbors ~= nil) then
                    if portRange[3] == "all" then
                        n_portCount = chassis.parsingChassis(lldp_neighbors)
                    else
                        isPrint = tf.needToPrint(portRange, lldp_neighbors.name)
                        if (isPrint == 1) then
                            n_portCount = chassis.parsingChassis(lldp_neighbors)
                        end
                    end
                end
            end
        end
    end

    if n_portCount == 0 then
        print("\tNo remote Neighbors have been found")
    end
end

local function Chassis()
    print("> > > Chassis")

    for i, local_chassis_arr in pairs(lldpdInfo.chassis["local-chassis"]) do
        for i1, local_chassis_struct in pairs(local_chassis_arr) do
            if (local_chassis_struct ~= nil) then
                chassis.parsingChassis(local_chassis_struct)
            end
        end
    end
end

local function run_show_lldp()
    local portRange_in = arg[1]
    local cmd_in = ""
    if (portRange_in ~= nil) then
        cmd_in = arg[2]
    else
        cmd_in = arg[1]
    end

    if (cmd_in == nil) then
        print("Command is wrong")
    end

    portRange = tf.checkPortRange(portRange_in)

    if (portRange ~= nil) then
        lldpdInfo = tf.collectJsonTable(cmdList.lldpd_status)
        lldpConfig = tf.collectJsonTable(cmdList.lldpd_config)
        lldpConfig = lldpConfig.values.config

        local lldpConfig_if = {}
        local isPrint = 0
        if lldpConfig.interface == nil then
            print("lldpConfig.interface is NULL")
            isPrint = 1
        end

        if cmd_in == "local" then
            Chassis(isPrint)
        elseif cmd_in == "remote" then
            Neighbors(isPrint)
        elseif cmd_in == "statistics" then
            Statistics(isPrint)
        elseif cmd_in == "interfaces" then
            Interfaces(isPrint)
        else
            print("\t >>> Command is wrong <<<")
        end
    else
        print("error: >> port range is wrong <<")
    end
end

run_show_lldp()



