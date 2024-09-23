#!/usr/bin/lua

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sheverdin.
--- DateTime: 8/12/24 10:35 AM
---

local tf = require "tf_module"

local smtp_ubus_config  = "ubus call uci get '{\"config\":\"smtp\"}'"
local smpt_ubus_cmd_add = "ubus call uci set '{\"config\":\"smtp\",\"type\":\"smtp\", \"section\":\""

local function run_smpt_config()
    print("arg1 = " .. arg[1])
    print("arg2 = " .. arg[2])
    local section = ""
    local log_ubus_set_value = "\"values\":{"
    local smtp_jsonInfo = tf.collectJsonTable(smtp_ubus_config)
    smtp_jsonInfo = smtp_jsonInfo.values
    if smtp_jsonInfo ~= nil then
        for _, smtp_dict in pairs(smtp_jsonInfo) do
            section = smtp_dict[".name"]
            local smpt_ubus_cmd_add_section = smpt_ubus_cmd_add .. section .. "\", "
            if arg[1] == "state" then
                local log_ubus_set_value_1 = log_ubus_set_value .. "\"enabled\":\"" .. arg[2] .. "\"}}'"
                local cmd = smpt_ubus_cmd_add_section .. log_ubus_set_value_1
                --print("cmd = " .. cmd)
                tf.executeCommand(cmd)
            elseif arg[1] == "port" then
                if tonumber(arg[2]) then
                    local log_ubus_set_value_1 = log_ubus_set_value .. "\"port\":\"" .. arg[2] .. "\"}}'"
                    local cmd = smpt_ubus_cmd_add_section .. log_ubus_set_value_1
                    --print("cmd = " .. cmd)
                    tf.executeCommand(cmd)
                else
                    print("error: port must be positive number")
                end
            elseif arg[1] == "host" then
                local log_ubus_set_value_1 = log_ubus_set_value .. "\"host\":\"" .. arg[2] .. "\"}}'"
                local cmd = smpt_ubus_cmd_add_section .. log_ubus_set_value_1
                --print("cmd = " .. cmd)
                tf.executeCommand(cmd)
            elseif arg[1] == "subject" then
                local log_ubus_set_value_1 = log_ubus_set_value .. "\"subject\":\"" .. arg[2] .. "\"}}'"
                local cmd = smpt_ubus_cmd_add_section .. log_ubus_set_value_1
                --print("cmd = " .. cmd)
                tf.executeCommand(cmd)

            elseif arg[1] == "user" and arg[3] == "password" then
                local log_ubus_set_value_1 = log_ubus_set_value .. "\"user\":\"" .. arg[2] .. "\", "
                log_ubus_set_value_1 = log_ubus_set_value_1 .. "\"password\":\"" .. arg[4] .. "\"}}'"
                local cmd = smpt_ubus_cmd_add_section .. log_ubus_set_value_1
                print("cmd = " .. cmd)
                tf.executeCommand(cmd)
            elseif arg[1] == "to" then
                local valid_emails = tf.parse_emails(arg[2])
                local emailListLen = #valid_emails
                if emailListLen > 3 then
                    emailListLen = 3
                end
                local log_ubus_set_value_1 = log_ubus_set_value

                for i = 1, emailListLen do
                    if i < emailListLen then
                        log_ubus_set_value_1 = log_ubus_set_value_1 .. "\"to" .. i .. "\":\"" .. valid_emails[i] .. "\", "
                    elseif i == emailListLen then
                        log_ubus_set_value_1 = log_ubus_set_value_1 .. "\"to" .. i .. "\":\"" .. valid_emails[i] .. "\""
                    end
                end
                log_ubus_set_value_1 = log_ubus_set_value_1 .. "}}'"

                local cmd = smpt_ubus_cmd_add_section .. log_ubus_set_value_1
                print("cmd = " .. cmd)
                tf.executeCommand(cmd)

            elseif arg[1] == "tls" then
                local log_ubus_set_value_1 = log_ubus_set_value .. "\"tls\":\"" .. arg[2] .. "\"}}'"
                local cmd = smpt_ubus_cmd_add_section .. log_ubus_set_value_1
                --print("cmd = " .. cmd)
                tf.executeCommand(cmd)
            end
        end
    end
end

run_smpt_config()
