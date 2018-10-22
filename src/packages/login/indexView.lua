
local meta = class("loginView",function ()
    return require("login.index").create().root
end)
local MAX_ROW,SUB_PANEL_HEIGHT = 8,60

local graphic = require ("utils.graphic")
function meta:ctor()
    local anim = self:getChild("DemoPlayer")
    self:getChild("btn","txt"):setString("ggggggggggggggggggggggg")

    self.listView = self:getChild("ListView")
    self:registEventFun()
    -- self:setScorllView()
end

function meta:setScorllView( ... )
    local scrollView = self:getChild("ScrollView")
    scrollView:removeAllChildren()
    self.hon_list_view_node = require("basic.refine_list_view").new(scrollView)

    self.hon_list_view_node:Init(MAX_ROW, SUB_PANEL_HEIGHT, function ()
        local new_record = require("login.item.indexItem").create().box
        new_record:removeSelf(true)
        return new_record
    end)

end

function meta:registEventFun( ... )

	self:getChild("close"):addClickEventListener(function ( ... )
		graphic:DispatchEvent("hidePanel","login.indexView")
	end)

end

function meta:Show(args1,args2)
    self:setVisible(true)
    -- self:getChild("Particle_1"):setCascadeOpacityEnabled(true)
    -- self:getChild("Particle_1"):setOpacity(0)
    -- dump(getmetatable( self:getChild("Particle_1")))
    -- local str = "sadasd.sdas"
    -- local Arr = string.split(str,".")
    -- dump(Arr)
    local arr1 = {1,2,3}
    local arr2 = {id = 9,"ss", src = 10,11}
    table.insertto(arr1,arr2)
    -- dump(arr1)

    commonBase:scheduleUpdateWithPriorityLua(self,function ( ... )
        -- local arr = {1,2,3,4,5,3,4,5,3,4,5,3,4,5}

        --  self.listView:upList(arr)
         -- self:initUI(7)
        --  local list = {}
        -- for i = 1 , 200 do
        --     table.insert(list,i)
        -- end
        -- -- self.hon_list_view_node:CleanItemInfo()
        -- -- self.hon_list_view_node:RemoveAllItem()
        -- self:upListScorview(list)
    end,5)

    self.scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (...) --
        self.list = {}
        for i = 1 , 50 do
            table.insert(self.list,i)
        end
        -- self.hon_list_view_node:CleanItemInfo()
        -- self.hon_list_view_node:RemoveAllItem()
        -- self:setScorllView()
        -- self:getChild("ScrollView"):updateItemData()
        self:upListScorview(self.list)

        if self.scheduleId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId) --關閉執行
            self.scheduleId = nil
        end
    end, 3, false)

    self.list = {}
    for i = 1 , 100 do
        table.insert(self.list,i)
    end

    self:setScorllView()
    self:upListScorview(self.list)
    -- self:getChild("ScrollView"):scrollToVertical(50,2)

    -- self:nodegird()
    -- print("sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss",tolua.type(parent))

    -- createTileDemoLayer()
    self.getnode = function ( self )
        print(self)
    end

    self.getnode(self)
    self:initUI(50)

    -- local web = ccexp.WebView:create()
    if device.platform ~= "windows" then
        local webView = ccui.WebView:create()
        self:addChild(webView)
        webView:setScalesPageToFit(true)
        webView:loadURL("www.baidu.com")
        webView:setPosition(cc.p(350, 500))
        webView:setContentSize(cc.size(750,1334))
        webView:setVisible(true)

        layout = ccui.LayoutComponent:bindLayoutComponent(webView)
        layout:setPositionPercentX(0.4933)
        layout:setPositionPercentY(0.2239)
        layout:setPercentWidth(0.1042)
        layout:setPercentHeight(0.0313)
        layout:setSize({width = 100.0000, height = 20.0000})
        layout:setLeftMargin(423.6015)
        layout:setRightMargin(436.3985)
        layout:setTopMargin(486.7240)
        layout:setBottomMargin(133.2760)
        self:addChild(webView)
    end

end

function meta:nodegird( ... )
    local layer = cc.Layer:create()
    local NodeGrid = cc.NodeGrid:create()
    local to1 = cc.FadeOutBLTiles:create(2, cc.size(24,40))
    local back = to1:reverse()
    cc.Director:getInstance():setDepthTest(false)

    -- self.sssssNode = cc.Sprite:create("beijing/beijing249.png")
    local gradNode = self:getChild("gradNode")
    gradNode:removeSelf()
    -- local parent = self:getParent()
    -- self:removeSelf()

    NodeGrid:addChild(gradNode)
    NodeGrid:setPosition(cc.p(0,0))
    NodeGrid:runAction(cc.RepeatForever:create(to1))
    layer:addChild(NodeGrid)
    layer:setName("layer")
    self:addChild(layer)


    self:getChild("layer"):setVisible(false)
end

function meta:initUI(num )
    local arr = {}
    for i = 1 , num do
        table.insert(arr,i)
    end

    local function getItem(v)
        local stu = require("login.item.indexItem").create()
        local item = stu.box
        item:removeSelf(true)
        item.setData = function (_item, v)
            self:setItem(item, v)
        end
        return item
    end
        
    local TestItem = require("login.item.indexItem").create()
    self.listView:plus(TestItem.box:getContentSize(), getItem)

    self.listView:upList(arr)
end

function meta:setItem( item, v )
    -- print("ssssssssssssssssss",v)
    item:getChild("txt"):setString(v)
end

function meta:upListScorview( list )
    local scrollView = self:getChild("ScrollView")
     self.hon_list_view_node:Show( #self.list, function (cur_row, item_node)
        local info = self.list[cur_row]
        self:setItems(cur_row,item_node,info)
        item_node:setPositionX(scrollView:getContentSize().width / 2)
        -- item_node:AddClick(function ()
        --     achievement_logic:ReqAchievementReward(info.id)
        -- end)
    end)
end

function meta:setItems( cur_row,item_node ,info)
    item_node:setVisible(true)
    print("cur_row",info,tolua.type(item_node))
    item_node:getChild("txt"):setString(info)
end

function meta:Hide()
    self:getChild("btn","txt"):setString("ssssssssssssssssssss")
    self:setVisible(false)
     if self.scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId) --關閉執行
        self.scheduleId = nil
    end
end

return meta
