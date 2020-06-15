local json = require('json')
local data = {}
local defaultData = {}
local path = system.pathForFile('databox.json', system.DocumentsDirectory)

local function shallowcopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(k) == 'string' then
            if type(v) == 'number' or type(v) == 'string' or type(v) == 'boolean' then
                copy[k] = v
            else
                print('databox: Values of type "' .. type(v) .. '" are not supported.')
            end
        end
    end
    return copy
end

local function saveData()
    local file = io.open(path, 'w')
    if file then
        file:write(json.encode(data))
        io.close(file)
    end
end

local function loadData()
    local file = io.open(path, 'r')
    if file then
        data = json.decode(file:read('*a'))
        io.close(file)
    else
        data = shallowcopy(defaultData)
        saveData()
    end
end

local function patchIfNewDefaultData()
    local isPatched = false
    for k, v in pairs(defaultData) do
        if data[k] == nil then
            data[k] = v
            isPatched = true
        end
    end
    if isPatched then
        saveData()
    end
end

local mt = {
    __index = function(t, k)
        return data[k]
    end,
    __newindex = function(t, k, value)
        data[k] = value
        saveData()
    end,
    __call = function(t, value)
        if type(value) == 'table' then
            defaultData = shallowcopy(value)
        end
        loadData()
        patchIfNewDefaultData()
    end
}

local _M = {}
setmetatable(_M, mt)
return _M