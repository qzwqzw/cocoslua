local csv = require "utils.csv"

local meta = {}


-- 转换文本信息
local function TranslationText(text_config, key, row)
    key = tostring(key)
    row = row or {}
    local config_list = text_config[key] or {}
    for _, table in pairs(config_list) do
        local field = table["field"]
        local value = table["text"]
        row[field] = value
    end
    return row
end

local csvNameArr = {"all_achievement_config","skin"}

function meta:Init()
    csv.Init("res/")
    self.tablelist = {}
    for i,v in ipairs(csvNameArr) do
        local list = csv.Load(v)
        self.tablelist[v] = list
    end

end

return meta
