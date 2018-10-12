
local meta = class("loginView",function ()
    return require("login.index").create().root
end)
local MAX_ROW,SUB_PANEL_HEIGHT = 10,60

local graphic = require ("utils.graphic")
function meta:ctor()
    self:registEventFun()
    local anim = self:getChild("DemoPlayer")
    self:getChild("btn","txt"):setString("ggggggggggggggggggggggg")

    self.listView = self:getChild("ListView")

end

function meta:registEventFun( ... )

	self:getChild("close"):addClickEventListener(function ( ... )
		graphic:DispatchEvent("hidePanel","login.indexView")
	end)

end

function meta:Show(args1,args2)
    self:setVisible(true)
    self:getChild("Particle_1"):setCascadeOpacityEnabled(true)
    self:getChild("Particle_1"):setOpacity(0)
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
    end,5)

    self:initUI(50)
    self:setScorllView()
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

function meta:setScorllView( ... )
    local scrollView = self:getChild("ScrollView")
    self.hon_list_view_node = require("basic.refine_list_view").new(scrollView)

    self.hon_list_view_node:Init(MAX_ROW, SUB_PANEL_HEIGHT, function ()
        local new_record = require("login.item.indexItem").create().box
        new_record:removeSelf(true)
        return new_record
    end)

    local list = {}
    for i = 1 , 100 do
        table.insert(list,i)
    end
    self.hon_list_view_node:Show( #list, function (cur_row, item_node)
        local info = list[cur_row]
        self:setItems(cur_row,item_node)
        item_node:setPositionX(scrollView:getContentSize().width / 2)
        -- item_node:AddClick(function ()
        --     achievement_logic:ReqAchievementReward(info.id)
        -- end)
    end)
end

function meta:setItems( cur_row,item_node )
    print("cur_row")
end

function meta:Hide()
    self:getChild("btn","txt"):setString("ssssssssssssssssssss")
    self:setVisible(false)
end

return meta
