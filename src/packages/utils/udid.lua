local CONVERT = { "2", "3", "4", "5", "6", "7", "8", "9",
                  "A", "B", "C", "D", "E", "F", "G", "H", "J",
                  "K", "L", "M", "N", "P", "Q", "R", "S", "T",
                  "U", "V", "W", "X", "Y", "Z"}

local MAPPING = {
                ["2"] = 1,["3"] = 2,["4"] = 3, ["5"] = 4, ["6"] =5, ["7"] = 6,
                ["8"] = 7, ["9"] = 8,["A"] = 9, ["B"] = 10, ["C"] = 11,
                ["D"] = 12, ["E"] = 13, ["F"] =14,["G"]= 15, ["H"]=16, ["J"]=17,
                ["K"] = 18, ["L"] = 19, ["M"] = 20, ["N"] = 21, ["P"] = 22, ["Q"] = 23,
                ["R"] = 24, ["S"] = 25, ["T"] = 26,
                ["U"] = 27, ["V"] = 28, ["W"] = 29, ["X"] = 30, ["Y"] = 31, ["Z"] = 32
}

local uuid = {}

-- 生成标示
function uuid.ConvertLetterId(number_id)
    number_id = tonumber(number_id) or 0
    local unin_id = ""
    local len = #CONVERT
    while number_id > 0 do
        local dec = (number_id % len) + 1
        number_id = math.floor(number_id / len)
        dec = CONVERT[dec]
        unin_id = dec .. unin_id
    end
    return unin_id
end

function uuid.ConvertNumberId(letter_id)
    local len = string.len(letter_id)
    local size = #CONVERT

    local number_id = 0
    local index = len
    for i=1,len do
        local a = string.sub(letter_id,i,i)
        local num = MAPPING[a] - 1
        index = index - 1
        local factorial = math.pow(size, index)--size ^ index -- lua 5.3不支持math.pow了
        number_id = number_id + factorial * num
    end
    return math.floor(number_id)
end

return uuid
