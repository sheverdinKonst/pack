---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sheverdin.
--- DateTime: 8/7/24 12:22 PM
---

local tf = require "tf_module"
local log_module = {}

local log_ubus_cmd_config = "ubus call uci get '{\"config\":\"log\"}'"

log_module.filter_paramList = {
    "name",
    "facility",
    "severity",
    "progname",
    "content",
}

log_module.action_paramList = {
    "name",
    "action",
    "log_email",
    "log_syslog",
}

log_module.rule_paramList = {
    "name",
    "filter",
    "action",
}



function log_module.getValue_str(valid_v)
    local num = #valid_v
    local str = "["
    if num == 1 then
        str = str .. "\"" .. valid_v[1] .. "\""
    elseif num > 1 then
        for j = 1, num - 1 do
            str = str .. "\"" .. valid_v[j] .. "\", "
        end
        str = str .. "\"" .. valid_v[num] .. "\""
    elseif num == 0 then
        str = str .. "\"\""
        print("list is empty")
    end
    return str
end

function log_module.print_filterListConfig(param, configList)
    print("Filter: ")
    for name, _ in pairs(configList) do
        local configList_i = configList[name]
        print("\t" .. name)
        if param == "all" then
            for _, value in pairs(log_module.filter_paramList) do
                if configList_i[value] ~= nil then
                    if type(configList_i[value]) ~= "table" then
                        print("\t\t" .. value .. ":\t " .. configList_i[value])
                    else
                        print("\t\t" .. value .. "value is table")
                    end
                end
            end
        end
    end
end

function log_module.print_actionListConfig(param, configList)
    print("Action: ")
    for name, _ in pairs(configList) do
        local configList_i = configList[name]
        print("\t" .. name)
        if param == "all" then
            for _, value in pairs(log_module.action_paramList) do

                if configList_i[value] ~= nil then
                    if type(configList_i[value]) ~= "table" then
                        print("\t\t" .. value .. ":\t" .. configList_i[value])
                    else
                        print("\t\t" .. value)
                        for _, element in pairs(configList_i[value]) do
                            print("\t\t\t" .. element)
                        end
                    end
                end
            end
        end
    end
end

function log_module.print_ruleListConfig(param, configList)
    print("Rule: ")
    for name, _ in pairs(configList) do
        print("\t" .. name)
        local configList_i = configList[name]
        if param == "all" then
            for _, value in pairs(log_module.rule_paramList) do
                if configList_i[value] ~= nil then
                    if type(configList_i[value]) ~= "table" then
                        print("\t\t" .. value .. ":\t" .. configList_i[value])
                    else
                        print("\t\t" .. value .. "value is table")
                    end
                end
            end
        end
    end
end

function log_module.getFilter_list(listConfig)
    --print("***********************  log_getFilterList")
    local log_jsonInfo = tf.collectJsonTable(log_ubus_cmd_config)
    log_jsonInfo = log_jsonInfo.values
    for _, dict in pairs(log_jsonInfo) do
        if dict[".type"] == "filter" then
            if dict["name"] ~= nil then
                local name = dict["name"]
                listConfig[name] = {}
                --print("dict[name] = " .. dict["name"])
                if dict[".name"] ~= nil then
                    --print("dict[facility] = " .. dict["facility"])
                    listConfig[name].section = dict[".name"]
                end
                if dict["facility"] ~= nil then
                    --print("dict[facility] = " .. dict["facility"])
                    listConfig[name].facility = dict["facility"]
                end
                if dict["severity"] ~= nil then
                    --print("dict[severity] = " .. dict["severity"])
                    listConfig[name].severity = dict["severity"]
                end
                if dict["progname"] ~= nil then
                    --print("dict[progname] = " .. dict["progname"])
                    listConfig[name].progname = dict["progname"]
                end
                if dict["content"] ~= nil then
                    --print("dict[content] = " .. dict["content"])
                    listConfig[name].content = dict["content"]
                end
            end
        end
    end
    --for key, value in pairs(filter_listConfig) do
    --    print(".... " .. key)
    --    if type(value) == "table" then
    --        for param, v in pairs(value) do
    --            print(param .. " = " .. v)
    --        end
    --    end
    --end
end

function log_module.getAction_list(listConfig)
    --print("-------------------- log_getAction_list: ")
    local log_jsonInfo = tf.collectJsonTable(log_ubus_cmd_config)
    log_jsonInfo = log_jsonInfo.values
    for _, dict in pairs(log_jsonInfo) do
        if dict[".type"] == "action" then
            if dict["name"] ~= nil then
                local name = dict["name"]
                listConfig[name] = {}
                --print("dict[name] = " .. dict["name"])
                if dict[".name"] ~= nil then
                    --print("dict[facility] = " .. dict["facility"])
                    listConfig[name].section = dict[".name"]
                end
                if dict["action"] ~= nil then
                    --print("dict[facility] = " .. dict["facility"])
                    listConfig[name].action = dict["action"]
                end
                if dict["log_email"] ~= nil then
                    --print("dict[severity] = " .. dict["severity"])
                    listConfig[name].log_email = dict["log_email"]
                end
                if dict["log_syslog"] ~= nil then
                    --print("dict[progname] = " .. dict["progname"])
                    listConfig[name].log_syslog = dict["log_syslog"]
                end
            end
        end
    end
    --for key, value in pairs(action_listConfig) do
    --    print(".... " .. key)
    --    if type(value) == "table" then
    --        for param, v in pairs(value) do
    --            if type(v) == "table" then
    --                for _, v1 in pairs(v) do
    --                    print("...... " .. v1)
    --                end
    --            else
    --                print(param .. " = " .. v)
    --            end
    --        end
    --
    --    end
    --end
end

function log_module.getRules_list(listConfig)
    print("***********************  log_getRules_list")
    local log_jsonInfo = tf.collectJsonTable(log_ubus_cmd_config)
    log_jsonInfo = log_jsonInfo.values
    for _, dict in pairs(log_jsonInfo) do
        if dict[".type"] == "rule" then
            if dict["name"] ~= nil then
                local name = dict["name"]
                listConfig[name] = {}
                --print("dict[name] = " .. dict["name"])
                if dict[".name"] ~= nil then
                    --print("dict[facility] = " .. dict["facility"])
                    listConfig[name].section = dict[".name"]
                end
                if dict["filter"] ~= nil then
                    --print("dict[facility] = " .. dict["facility"])
                    listConfig[name].filter = dict["filter"]
                end
                if dict["action"] ~= nil then
                    --print("dict[severity] = " .. dict["severity"])
                    listConfig[name].action = dict["action"]
                end
            end
        end
    end
    --for key, value in pairs(rule_listConfig) do
    --    print(".... " .. key)
    --    if type(value) == "table" then
    --        for param, v in pairs(value) do
    --            print(param .. " = " .. v)
    --        end
    --    end
    --end
end

function log_module.deleteSection(name, configList)
    local log_ubus_delete_pref = "ubus call uci delete '{\"config\":\"log\",\"section\":\""
    local log_ubus_delete_suf = "\"}'"
    local dict = configList[name]
    local section = dict["section"]
    local log_ubus_delete = log_ubus_delete_pref .. section .. log_ubus_delete_suf
    tf.executeCommand(log_ubus_delete)
end

return log_module

