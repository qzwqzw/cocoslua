
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("src/packages/")
require "config"
require "cocos.init"
cc.exports.UITools =  require "ui.UITools"
cc.exports.commonBase = require "basic.commonBase"
local csvInfo = require "utils.csvInfo"
csvInfo:Init()

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
