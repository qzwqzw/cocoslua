
local meta = class("loginView",function ()
    return require("login.index").create().root
end)
local MAX_ROW,SUB_PANEL_HEIGHT = 10,60

local graphic = require ("utils.graphic")
function meta:ctor()
    local anim = self:getChild("DemoPlayer")
    self:getChild("btn","txt"):setString("ggggggggggggggggggggggg")

    self.listView = self:getChild("ListView")
    self:setScorllView()
    self:registEventFun()
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
         local list = {}
        for i = 1 , 5 do
            table.insert(list,i)
        end
        self:upListScorview(list)
    end,5)

    local list = {}
    for i = 1 , 100 do
        table.insert(list,i)
    end

    self:upListScorview(list)

    self:initUI(50)

    self:nodegird()
    -- print("sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss",tolua.type(parent))

    -- createTileDemoLayer()
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
    print("cur_row",cur_row,tolua.type(item_node))
end

function meta:Hide()
    self:getChild("btn","txt"):setString("ssssssssssssssssssss")
    self:setVisible(false)
end


-- local function createTileDemoLayer(title, subtitle)
--     Helper.index = 1
--     Helper.createFunctionTable = {
--         TMXIsoZorder,
--         TMXOrthoZorder,
--         TMXIsoVertexZ,
--         TMXOrthoVertexZ,
--         TMXOrthoTest,
--         TMXOrthoTest2,
--         TMXOrthoTest3,
--         TMXOrthoTest4,
--         TMXIsoTest,
--         TMXIsoTest1,
--         TMXIsoTest2,
--         TMXUncompressedTest,
--      -- TMXHexTest,
--         TMXReadWriteTest,
--         TMXTilesetTest,
--         TMXOrthoObjectsTest,
--         TMXIsoObjectsTest,
--         TMXResizeTest,
--         TMXIsoMoveLayer,
--         TMXOrthoMoveLayer,
--         TMXOrthoFlipTest,
--         TMXOrthoFlipRunTimeTest,
--         TMXOrthoFromXMLTest,
--         TMXOrthoXMLFormatTest,
--      -- TileMapTest,
--      -- TileMapEditTest,
--         TMXBug987,
--         TMXBug787,
--      -- TMXGIDObjectsTestNew,
--     }
--     self:addChild(TMXIsoZorder())
--     -- self:addChild(CreateBackMenuItem())
--     local layer = cc.Layer:create()
--     Helper.initWithLayer(layer)
--     local titleStr = title == nil and "No title" or title
--     local subTitleStr = subtitle  == nil and "drag the screen" or subtitle
--     Helper.titleLabel:setString(titleStr)
--     Helper.subtitleLabel:setString(subTitleStr)

--     local function onTouchesMoved(touches, event )
--         local diff = touches[1]:getDelta()
--         local node = layer:getChildByTag(kTagTileMap)
--         local currentPosX, currentPosY= node:getPosition()
--         node:setPosition(cc.p(currentPosX + diff.x, currentPosY + diff.y))
--     end

--     local listener = cc.EventListenerTouchAllAtOnce:create()
--     listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
--     local eventDispatcher = layer:getEventDispatcher()
--     eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

--     return layer
-- end

-- local function TMXIsoZorder()
--     local m_tamara = nil
--     local ret = createTileDemoLayer("TMX Iso Zorder", "Sprite should hide behind the trees")
--     local map = ccexp.TMXTiledMap:create("TileMaps/iso-test-zorder.tmx")
--     ret:addChild(map, 0, kTagTileMap)

--     local s = map:getContentSize()
--     cclog("ContentSize: %f, %f", s.width,s.height)
--     map:setPosition(cc.p(-s.width/2,0))

--     m_tamara = cc.Sprite:create("particle_texture.png")
--     map:addChild(m_tamara, table.getn(map:getChildren()))
--     m_tamara:retain()
--     local mapWidth = map:getMapSize().width * map:getTileSize().width
--     m_tamara:setPosition(CC_POINT_PIXELS_TO_POINTS(cc.p( mapWidth/2,0)))
--     m_tamara:setAnchorPoint(cc.p(0.5,0))

--     local  move = cc.MoveBy:create(10, cc.p(300,250))
--     local  back = move:reverse()
--     local  seq = cc.Sequence:create(move, back)
--     m_tamara:runAction( cc.RepeatForever:create(seq) )

--     local function repositionSprite(dt)
--         local p = cc.p(m_tamara:getPosition())
--         p = CC_POINT_POINTS_TO_PIXELS(p)
--         local map = ret:getChildByTag(kTagTileMap)

--         -- there are only 4 layers. (grass and 3 trees layers)
--         -- if tamara < 48, z=4
--         -- if tamara < 96, z=3
--         -- if tamara < 144,z=2

--         local newZ = 4 - (p.y / 48)
--         newZ = math.max(newZ,0)

--         map:reorderChild(m_tamara, newZ)
--     end

--     local schedulerEntry = nil
--     local function onNodeEvent(event)
--         if event == "enter" then
--             schedulerEntry = scheduler:scheduleScriptFunc(repositionSprite, 0, false)
--         elseif event == "exit" then
--             if m_tamara ~= nil then
--                 m_tamara:release()
--             end
--             scheduler:unscheduleScriptEntry(schedulerEntry)
--         end
--     end

--     ret:registerScriptHandler(onNodeEvent)

--     return ret
-- end
return meta
