
local ViewBase = class("ViewBase", cc.Node)
-- ViewBase.RESOURCE_FILENAME="MenuScene.csb"

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:createSprite( ... )
    local Image_1 = ccui.ImageView:create()
    Image_1:ignoreContentAdaptWithSize(false)
    Image_1:loadTexture("HelloWorld.png",0)
    Image_1:setScale9Enabled(true)
    Image_1:setCapInsets({x = 9, y = 9, width = 945, height = 624})
    Image_1:setLayoutComponentEnabled(true)
    Image_1:setName("Image_1")
    Image_1:setTag(6)
    Image_1:setCascadeColorEnabled(true)
    Image_1:setCascadeOpacityEnabled(true)
    Image_1:setPosition(-1.7852, 0.2485)
    Image_1:setOpacity(204)
    Image_1:setColor({r = 0, g = 0, b = 0})
    local layout = ccui.LayoutComponent:bindLayoutComponent(Image_1)
    layout:setSize({width = 750.0000, height = 1340.0000})
    layout:setLeftMargin(-376.7852)
    layout:setRightMargin(-373.2148)
    layout:setTopMargin(-670.2485)
    layout:setBottomMargin(-669.7515)
    return Image_1
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    -- scene:addChild(self)
    local ccsdata = require("MainScene").create()
    scene:addChild(ccsdata.root)

    display.runScene(scene, transition, time, more)

    local graphic = require ("utils.graphic")
    graphic:Init()

    -- graphic:RegisterEvent("goodBoy",function ( parm )
    --     print(parm)
    --     -- local MainPanel = cc.CSLoader:createNode("MainScene.csb")
    -- end)

    local panelCenter = require ("basic.panelCenter")
    panelCenter:initGraphic(scene,self:createSprite(),cc.Node:create())
    -- panelCenter:registerEvent()

    -- graphic:DispatchEvent("goodBoy","1111111111111111")
    graphic:DispatchEvent("showPanel","login.loginView",1,2)
    -- self.scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (...) --
    --     graphic:DispatchEvent("hidePanel","login.loginView")

    --     if self.scheduleId then
    --         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId) --關閉執行
    --         self.scheduleId = nil
    --     end
    -- end, 3, false)

    return self
end

return ViewBase
