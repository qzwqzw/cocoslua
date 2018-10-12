--------------------------------------------------------------
-- This file was automatically generated by Cocos Studio.
-- Do not make changes to this file.
-- All changes will be lost.
--------------------------------------------------------------

local luaExtend = require "LuaExtend"

-- using for layout to decrease count of local variables
local layout = nil
local localLuaFile = nil
local innerCSD = nil
local innerProject = nil
local localFrame = nil

local Result = {}
------------------------------------------------------------
-- function call description
-- create function caller should provide a function to 
-- get a callback function in creating scene process.
-- the returned callback function will be registered to 
-- the callback event of the control.
-- the function provider is as below :
-- Callback callBackProvider(luaFileName, node, callbackName)
-- parameter description:
-- luaFileName  : a string, lua file name
-- node         : a Node, event source
-- callbackName : a string, callback function name
-- the return value is a callback function
------------------------------------------------------------
function Result.create(callBackProvider)

local result={}
setmetatable(result, luaExtend)

--Create Node
local Node=cc.Node:create()
Node:setName("Node")

--Create Image_2
local Image_2 = ccui.ImageView:create()
Image_2:ignoreContentAdaptWithSize(false)
Image_2:loadTexture("beijing/beijing44.png",0)
Image_2:setLayoutComponentEnabled(true)
Image_2:setName("Image_2")
Image_2:setTag(8)
Image_2:setCascadeColorEnabled(true)
Image_2:setCascadeOpacityEnabled(true)
Image_2:setAnchorPoint(0.0000, 0.0000)
Image_2:setPosition(-1.1456, -1.5303)
layout = ccui.LayoutComponent:bindLayoutComponent(Image_2)
layout:setSize({width = 750.0000, height = 1334.0000})
layout:setLeftMargin(-1.1456)
layout:setRightMargin(-748.8544)
layout:setTopMargin(-1332.4700)
layout:setBottomMargin(-1.5303)
Node:addChild(Image_2)

--Create Button_1
local Button_1 = ccui.Button:create()
Button_1:ignoreContentAdaptWithSize(false)
Button_1:loadTextureNormal("academy/button/4.png",0)
Button_1:setTitleFontSize(14)
Button_1:setTitleText("开始")
Button_1:setTitleColor({r = 65, g = 65, b = 70})
Button_1:setScale9Enabled(true)
Button_1:setCapInsets({x = 15, y = 11, width = 128, height = 34})
Button_1:setLayoutComponentEnabled(true)
Button_1:setName("Button_1")
Button_1:setTag(5)
Button_1:setCascadeColorEnabled(true)
Button_1:setCascadeOpacityEnabled(true)
Button_1:setPosition(377.0555, 126.9447)
layout = ccui.LayoutComponent:bindLayoutComponent(Button_1)
layout:setSize({width = 158.0000, height = 56.0000})
layout:setLeftMargin(298.0555)
layout:setRightMargin(-456.0555)
layout:setTopMargin(-154.9447)
layout:setBottomMargin(98.9447)
Node:addChild(Button_1)

--Create Animation
result['animation'] = ccs.ActionTimeline:create()
  
result['animation']:setDuration(0)
result['animation']:setTimeSpeed(1.0000)
--Create Animation List

result['root'] = Node
return result;
end

return Result
