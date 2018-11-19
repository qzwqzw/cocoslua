
local csvInfo = require "utils.csvInfo"
local meta = class("loginView", function ()
    return require("login.loginPanel").create().root
end)

local graphic = require ("utils.graphic")

function meta:ctor()
    print("显示界面")
    self:registEventFun()
end

function meta:registEventFun(...)
    self:getChildByName("Button_1"):addClickEventListener(function (...)
        graphic:DispatchEvent("showPanel", "login.indexView")
    end)
end

function meta:Show(args1, args2)
    self:setVisible(true)
    local a = {12, 3, 5}
    local b = {4}
    local c = table.concat(a, "")
    -- c = "One \23 Two"
    -- dump(args1)
    local widget = ccui.Widget:create()
    local txt = ccui.Text:create()
    -- txt:setString("sssssssssssssssssssssssssssss")
    txt:setPosition(cc.p(100, 100))
    widget:addChild(txt)
    self:addChild(widget)
    local data1 =  csvInfo.tablelist["skin"][2]
     -- dump(data1.skills)
    -- local str =  assert(loadstring(data1.skills))
    -- str = str()
    str =  UITools.loadstring( data1.skills)  --- 执行字符串代码
    dump(str)
end

function meta:Hide()
    self:setVisible(false)
end

return meta
