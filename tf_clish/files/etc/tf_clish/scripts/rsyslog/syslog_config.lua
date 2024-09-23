#!/usr/bin/lua

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sheverdin.
--- DateTime: 9/8/24 15:50 PM
---
local tf = require "tf_module"

local cmd_get_rsyslog_config = "ubus call uci get '{\"config\":\"syslog\"}'"

local log_paramList = {
    "state",
    "proto",
    "port",
}

local logConfig_listArg = {}

local function log_getparam(argList, paramList)
    --print("-------------- log_getparam")
    local i = 1
    local j = 1
    while arg[i] ~= nil do
        if arg[i] == paramList[j] then
            --print("paramList[j]  = " .. paramList[j])
            --print("arg[" .. i .. "]" .. arg[i])
            if arg[i + 1] ~= "" and arg[i + 1] ~= nil then
                argList[paramList[j]] = arg[i + 1]
            end
        end
        i = i + 2
        j = j + 1
    end

    --print("-------------------- log_getparam: ")
    --for key, value in pairs(argList) do
    --    print("key = " .. key .. " value = " .. value)
    --end
end

local function log_edit()
    local syslog_info = tf.collectJsonTable(cmd_get_rsyslog_config)
    syslog_info = syslog_info.values
    local log_ubus_set_section = ""
    local log_ubus_set_value_list = {}
    local count = 0
    for key, syslogSection in pairs(syslog_info) do
        log_ubus_set_section = syslogSection[".name"]
        if logConfig_listArg.state ~= "" and logConfig_listArg.state ~= nil then
            count = count + 1
            log_ubus_set_value_list[count] = "\"enabled\":\"" .. logConfig_listArg.state .. "\""
        end

        if logConfig_listArg.proto ~= "" and logConfig_listArg.proto ~= nil then
            count = count + 1
            log_ubus_set_value_list[count] = "\"log_proto\":\"" .. logConfig_listArg.proto .. "\""
        end

        if logConfig_listArg.port ~= "" and logConfig_listArg.port ~= nil then
            count = count + 1
            log_ubus_set_value_list[count] = "\"log_port\":\"" .. logConfig_listArg.port .. "\""
        end
    end

    local log_ubus_set_1 = "ubus call uci set '{\"config\":\"syslog\",\"type\":\"syslog\",\"section\":\""
    local log_ubus_set_2 = "\","

    local log_ubus_set_value = "\"values\":{"
    local log_ubus_set_value_1 = ""

    local log_ubus_cmd = log_ubus_set_1 .. log_ubus_set_section .. log_ubus_set_2 .. log_ubus_set_value

    if count == 0 then
        print("error: parameters list is empty")
        return 1
    elseif count == 1 then
        log_ubus_set_value_1 = log_ubus_set_value_1 .. log_ubus_set_value_list[1]
    elseif count > 1 then
        for j = 1, count - 1 do
            log_ubus_set_value_1 = log_ubus_set_value_1 .. log_ubus_set_value_list[j] .. ", "
        end
        log_ubus_set_value_1 = log_ubus_set_value_1 .. log_ubus_set_value_list[count]
    end
    log_ubus_cmd = log_ubus_cmd .. log_ubus_set_value_1 .. "}}'"
    print("log_ubus_cmd = " .. log_ubus_cmd)
    tf.executeCommand(log_ubus_cmd)
end

local function run_config_log()
    log_getparam(logConfig_listArg, log_paramList)
    log_edit()
end

run_config_log()
