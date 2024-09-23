#!/usr/bin/lua

---
--- Generated by Luanalysis
--- Created by sheverdin.
--- DateTime: 2/15/24 1:24 PM


-- print("tfortis module Ver 1.0")

local tf_module = {}
local dkjson = require("dkjson")

require "lfs"
--tf_module.uci = require("luci.model.uci").cursor()

local errorList = {
    "error >>> Command not found",
    "error >>> Port range not found",
    "error >>> Value not found"
}

tf_module.portList = {
    portName = "lan",
    maxLanPorts = 8,
    spfPorts    = { 9, 10 }
}

tf_module.ubusList =
{
    cmd_ubus    = "ubus call uci ",
    cmd_changes = "changes ",
    cmd_revert  = "revert ",
    cmd_reload  = "reload_config ",
    cmd_get     = "get ",
    cmd_config  = "\"config\":\"",
    cmd_section = "\",\"section\":\"",
    cmd_option  = "\",\"option\":\"",
    cmd_prefix  = "\'{",
    cmd_suffix  = "\"}\'",
}

local function runCommand(command)
    local result = ""
    local handle = io.popen(command)
    if handle then
        result = handle:read("*a")
        handle:close()
    else
        print("runCommand:  file not found")
    end
    --print(result)
    return result
end

local function getJsonTable(ubusCmd)
    local ubusRes = runCommand(ubusCmd)
    local jsonData = dkjson.decode(ubusRes, 1)
    return jsonData
end

local function printList(pList)
    for k, v in pairs(pList) do
        if (k == nil) then
            print("key = nill")
        elseif type(k) == "table" then
            print("key is table")
        else
            io.write("key = ", tostring(k), "\n")
        end
        if (v == nil) then
            print("value = nill")
        elseif type(v) == "table" then
            print("value is table")
        else
            io.write("value = ", tostring(v), "\n")
        end
    end
end

function tf_module.printarray(pList)
    for i, j in pairs(pList) do
        print("i -------------  " .. i)
        if type(j) == "table" then
            for i1, j1 in pairs(j) do
                if type(j1) == "table" then
                    for i2, j2 in pairs(j1) do
                        print("\t\t 2-- " .. i2 .. "  " .. j2)
                    end
                else
                    print("\t 1--" .. i1 .. "  " .. j1)
                end
            end
        else
            print("0 -- " .. i .. "  " .. tostring(j))
        end
    end
end

function tf_module.printScalar(data, str)
    print(str .. " = " .. data)
end

function tf_module.printTypeandData(data, str)
    print("type " .. str .. " = " .. type(data) .. "  " .. str " = " .. data)
end

function tf_module.getIfList(cmd)
    local interfaceList = getJsonTable(cmd)
    interfaceList = interfaceList["interface"]
    local if_arr = {}
    for i, if_list in pairs(interfaceList) do
        local dev = if_list["device"]
        local res = string.find(dev, "switch")
        if res ~= nil and res == 1 then
            table.insert(if_arr, if_list["interface"])
        end
    end
    return if_arr
end

function tf_module.getUbusDataByName(name)
    local ubus_cmd = "ubus call hw_sensor getStatus '{\"param\":\"" .. name .. "\"}'"
    local jsonInfo = getJsonTable(ubus_cmd)
    return jsonInfo
end

function tf_module.executeCommand(command)
    local res, err = runCommand(command)
    return res, err
end

function tf_module.collectJsonTable(ubusCmd)
    local jsonTable = getJsonTable(ubusCmd)
    return jsonTable
end

function tf_module.decodeToJson(jsonStr)
    local jsonData = dkjson.decode(jsonStr, 1)
    return jsonData
end

function tf_module.getPortList(config, arg1, arg2)
    local configSwitch  = config[arg1]
    local portList      = configSwitch[arg2]
    -- printList(portList)
    return portList
end


function tf_module.validateParam(argc, argv)
    local errorCode = 0
    for i = 1, argc do
        if argv[i] == nil then
            io.write(errorList[i], "\n")
            errorCode = tonumber(i)
            print("error: Arg " .. i .. " not valid or not present")
        end
    end
    return errorCode;
end

function tf_module.changes(cmd_list)
    local changes_ubus_cmd = cmd_list.cmd_ubus .. cmd_list.cmd_changes
    local changes = getJsonTable(changes_ubus_cmd)
    local count = 1
    local configList = {}
    io.write("Changes: \n")
    for key, section in pairs(changes["changes"]) do
        io.write("\t>> ", key, ":\n")
        count = 1
        if section ~= nil and type(section) == "table" then
            table.insert(configList, key)
            for _, arr1 in pairs(section) do
                --print(count .. "  -----------------------------------")
                local changeMsg = "\t\t"
                changeMsg = changeMsg .. tostring(count) .. "\t"
                count = count + 1
                if arr1 ~= nil and type(arr1) == "table" then
                    for _, value in pairs(arr1) do
                        if string.sub(value, 1, 3) ~= "cfg" then
                            changeMsg = changeMsg .. value .. "     \t"
                        end
                    end
                    io.write(changeMsg, "\n")
                end
            end
        end
    end
    return configList
end

function tf_module.uci_delete(optionlist, start, stop)
    local error = 1
    for opt_index = start, stop  do
        print("del option = " .. optionlist[opt_index])
        tf_module.uci:delete("network", "switch", optionlist[opt_index])
        error = 0
    end
    return error
end

function tf_module.checkPortRange(range)

    local result = {}
    if (range == "all") then
        result[1] = 1
        result[2] = 10
        result[3] = "all"
    elseif (range == "switch") then
        result[1] = 0
        result[2] = 0
        result[3] = "switch"
    else
        for value in string.gmatch(range, "[^-]+") do
            value = tonumber(value)
            table.insert(result, value)
            result[3] = "range"
        end

        if result[2] == nil then
            result[2] = result[1]
            --result[3] = "range"
            result[3] = "once"
        end
        if result[1] > result[2] then
            result = nil
            io.write("error >> port range is wrong\n")
        end
    end
    return result
end

function tf_module.isPrintPortRange(portRange, port)
    local isPrint = 0
    if portRange[3] == "all" then
        isPrint = 1
    elseif portRange[3] == "range" then
        local portMin = tonumber(portRange[1])
        local portMax = tonumber(portRange[2])
        if port >= portMin and port <= portMax then
            isPrint = 1
        end
    end
    return isPrint
end

function tf_module.get_hour_minutes(time_str)

    local time_H_M = {}
    local count = 1

    for part in string.gmatch(time_str, "([^:]+)") do
        --print("count = " .. count)
        if count == 1 then
            local hour = tonumber(part)
            if hour < 0 or hour > 24 then
                part = nil
            end
        elseif count == 2 then
            local min = tonumber(part)
            if min < 0 or min > 60 then
                part = nil
            end
        end
        count = count + 1
        table.insert(time_H_M, part)
    end
    return time_H_M
end

function tf_module.saveChanges(isPrint, demon)
    runCommand("uci commit")
    runCommand("reload_config")
    if isPrint == 1 then
        io.write("new configuration saved\n")
    end

    if demon ~= nil then
        local cmd = "/etc/init.d/" .. demon .. " restart"
        --print("cmd = " .. cmd)
        runCommand(cmd)
    end
end

function tf_module.addBackSlash(str)
    local newStr = ""
    local status = "OK"
    for i = 1, #str do
        local char = string.sub(str, i, i)
        if char == '"' then
            newStr = newStr .. "\\"
        end
        newStr = newStr .. char
    end
    return newStr
end

function tf_module.getFilesInDirectory(dir)
    local filesList = {}
    for file in lfs.dir(dir) do
        if file ~= "." and file ~= ".." then
            filesList[file] = ""
        end
    end
    return filesList
end

function tf_module.capFirstLetter(inputString)
    if inputString == nil or inputString == "" then
        return inputString
    end
    local firstChar = string.sub(inputString, 1, 1)
    local capitalFirstChar = string.upper(firstChar)
    local restOfString = string.sub(inputString, 2)
    return capitalFirstChar .. restOfString
end

function tf_module.getPort(inputString)
    local numbers = ""
    local words = ""

    for word in inputString:gmatch("%d+") do
        local number = tonumber(word)
        if number then
            numbers = numbers .. number .. " "
        else
            words = words .. word .. " "
        end
    end

    return numbers, words
end

function tf_module.needToPrint(portStr, name)
    local isPrint = 0
    if (portStr[3] == "all") then
        isPrint = 1
    else
        if name:find("%.") then
            name = name:gsub("%.", "")  -- убираем точку из строки
        end
        local str, num = name:match("(%a+)(%d+)")
        local portNumber = tonumber(num)
        local portRangeMin = tonumber(portStr[1])
        local portRangeMax = tonumber(portStr[2])

        if str == "lan" then
            if portNumber >= portRangeMin and portNumber <= portRangeMax then
                isPrint = 1
            end
        end
    end
    return isPrint
end


local function removeSpaces(input)
    return string.gsub(input, "%s+", "")
end
local function validate_email(email)
    if email:match("^[%w%p]+@[%w%p]+%.%a%a%a?$") then
        --print("true")
        return true
    else
        --print("false")
        return false
    end
end

local function isValidIP(ip)
    local parts = { ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") }
    if #parts ~= 4 then
        return false
    end
    for _, part in ipairs(parts) do
        if tonumber(part) < 0 or tonumber(part) > 255 then
            return false
        end
    end
    return true
end

function tf_module.parse_emails(email_string)
    local emails = {}
    for email in email_string:gmatch("([^,]+)") do
        email = removeSpaces(email)
        if validate_email(email) then
            table.insert(emails, email)
        end
    end
    return emails
end

function tf_module.parse_ip(ipString)
    local ipTable = {}
    for ip in ipString:gmatch("[^,]+") do
        ip = removeSpaces(ip)
        if isValidIP(ip) then
            table.insert(ipTable, ip)
        end
    end
    return ipTable
end

return tf_module
