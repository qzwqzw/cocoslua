-- local Plus = require("zeromvc.core.Plus")
local UITools = {}
UITools.version = "UITools 1.0"


------------------------------------------------------------------puls

local ListView = ccui.ListView
function ListView:upListViewPuls(parm)
    local _index
    local go
    local ed
    if self._direction==1 then
        _index=self:getInnerContainerPosition().y
        go=math.floor((self._max+_index-self._min)/self._itemHeight)
        ed=math.floor((self._max+_index)/self._itemHeight)+1
    else
        _index=self:getInnerContainerPosition().x
        go=math.floor(-_index/self._itemHeight)
        ed=math.floor((-_index+self._min)/self._itemHeight)+1
    end
    if go<1 then
        go=1
    end
    if ed>self._len then
        ed=self._len
    end
    local useItem

    if go ~= 1 and parm then
        return
    end
    if self._go~=go or self._ed~=ed then
        self._go=go
        self._ed=ed
        local thisItems={}
        for i=go,ed do
            if self._items[i]==nil then
                local len=#self.feelList
                -- print(len,i,ed)
                if len>0 then
                    useItem=self.feelList[len]
                    table.remove(self.feelList, len)

                    if tolua.isnull(useItem) then
                        useItem=self._getItemFn()
                    else
                        useItem:retain()
                        useItem:removeSelf()
                    end
                    self:getItem(i-1):addChild(useItem)
                    useItem:setData(self.data[i])
                    useItem:release()
                    self._isUpdata=false
                else
                    useItem=self._getItemFn()
                    self:getItem(i-1):addChild(useItem)
                    useItem:setData(self.data[i])
                end
            else
                useItem=self._items[i]
                self._items[i]=nil
            end
            thisItems[i]=useItem
        end
        for k,v in pairs(self._items) do
            if v~=nil then
                table.insert(self.feelList,v)
            end
        end
        self._items=thisItems
    end
end
function ListView:plus(itemSize,getItemFn,isTB)
    self:jumpToTop()
    self._getItemFn=getItemFn
    self._isTB=isTB
    self.isPlus=true;
    local default = ccui.Widget:create()
    default:setContentSize(itemSize.width,itemSize.height)
    self:setItemModel(default)
    self._max=0
    self._min=0
    self._itemHeight=0
    self._items={}
    self.feelList={} 
    local _minSize=self:getContentSize()
    self._direction=self:getDirection()
    if self._direction==1 then
        self._min=_minSize.height
        self._itemHeight=itemSize.height
    else
       self._min=_minSize.width
       self._itemHeight=itemSize.width
    end
    self:addScrollViewEventListener(function(sender, eventType)
        self:scrollHd(eventType)
    end)
end

function ListView:scrollHd(eventType)
    if eventType == 4 or eventType == 9  then
        self:upListViewPuls()
    end
end
-- function ListView:plusDiffItem(minSize,getItemFn) --minSize 最小item尺寸；
--     self._itemMinHeight=minSize.height;
--     self._getItemFn=getItemFn
--     local default = ccui.Widget:create()
--     default:setContentSize(minSize.width,minSize.height)
--     self:setItemModel(default)
--     self._items={}
--     self.feelList={} 
--     self:addScrollViewEventListener(function(sender, eventType)
--         self:scroll2Hd(eventType)
--     end)
-- end
-- function ListView:upDiffList(data)
--     if data~=nil then
--         self._len=#data
--         self.feelList={}
--         self:removeAllChildren()
--         local viewSize=self:getContentSize()
--         local itemExitNum=math.ceil(viewSize/self._itemMinHeight);
--         for i=1, itemExitNum do
--             self:pushBackDefaultItem()
--         end
--         -- self._max=self._len*self._itemHeight
--         self.data=data
--         self._items={}
--         -- self._go=0
--         -- self._ed=0
--         -- -- self._isUpdata=false
--         -- self.data=data
--         self:upListViewDiffPuls()
--     end
-- end

-- function ListView:scroll2Hd(eventType)
--     if eventType == 4 or eventType == 9  then
        
--     end
-- end

-- function ListView:upListViewDiffPuls()
--     local thisItems={}
--     for i,v in ipairs(self.data) do
--         local useItem
--         local itemHeight
--         if self._items[i]==nil then
--             if tolua.isnull(useItem) then
--                 useItem=self._getItemFn()
--                 useItem:setData();
--                 itemHeight=useItem:getContentSize().height;
--             else
--                 useItem:retain()
--                 useItem:removeSelf()
--             end
--         else
--             useItem=self._items[i]
--             self._items[i]=nil
--         end
--         thisItems[i]=useItem
--     end
--     self._items=thisItems;
    
-- end

function ListView:reList()
    self:upList(self.data)
end
function ListView:getPlusItem(index)
    local box=self:getItem(index)
    if box~=nil then
        return box:getChildren()[1]
    else
        return nil
    end
end
function ListView:getPlusIndex(item)
    return self:getIndex(item:getParent())
end

function ListView:getPlusItems()
    local items=self:getItems()
    local t={};
    for i,v in ipairs(items) do
        table.insert(t,v:getChildren()[1])
    end
    return t;
end
-- function ListView:reList()
--     self:upList(self.data)
-- end
function ListView:upList(data)
    if data~=nil then
        self._len=#data
        self.feelList={}

        self:removeAllChildren()
        for i=1, self._len do
            self:pushBackDefaultItem()
        end
        self._max=self._len*self._itemHeight
        self.data=data
        self._items={}
        self._go=0
        self._ed=0
        self.data=data
        -- if self._isUpdata == true then
            self:upListViewPuls(true)
        -- end
        self._isUpdata=true
    end
end

function ListView:scrollToItemVer(index, time)
    local per = 0
    local raddis = self._max - self._min
    local dis = (index-1) * self._itemHeight
    dis = dis < 0 and 0 or dis
    dis = dis > raddis and raddis or dis
    per = dis / raddis * 100
    delayCall(function()
        self:scrollToPercentVertical(per,time,true)
    end,1)
end
function ListView:scrollToItemHor(index, time)
    local per = 0
    local raddis = self._max - self._min
    local dis = (index-1) * self._itemHeight
    dis = dis < 0 and 0 or dis
    dis = dis > raddis and raddis or dis
    per = dis / raddis * 100
    delayCall(function()
        self:scrollToPercentHorizontal(per,time,true)
    end,1)
end
function ListView:scrollToItemVerForce(index) --强制滚动到第几项 
    local ci=self:getItem(index);   --index 从 0 开始
    if ci==nil then
        return
    end
    local ci_y=ci:getPositionY()+ci:getContentSize().height*0.5+self:getItemsMargin()*0.5;
    local _innerHeight=self:getInnerContainerSize().height;
    local vsizeHeight=self:getContentSize().height;
    local dis=(vsizeHeight-_innerHeight)+(_innerHeight-ci_y);
    local inner=self:getInnerContainer()
    inner:runAction(cc.MoveTo:create(0.5,{x=0,y=dis}))
end

function ListView:scrollToItemHorForce(index) --强制滚动到第几项 
    local ci=self:getItem(index);   --index 从 0 开始
    if ci==nil then
        return
    end
    local ci_x=ci:getPositionX()+ci:getContentSize().width*0.5+self:getItemsMargin()*0.5;
    local _innerWidth=self:getInnerContainerSize().width;
    local vsizeWidth=self:getContentSize().width;
    local dis=(vsizeWidth-_innerWidth)+(_innerWidth-ci_x);
    local inner=self:getInnerContainer()
    inner:runAction(cc.MoveTo:create(0.5,{x=-dis,y=0}))
end
----------------------------------------------------------------------------------------------确认使用
function UITools.getChild(node, ...)
    local par = { ... }
    local child = node
    -- dump(par,"par")
    for key, var in ipairs(par) do
        -- if child == nil then
        --     print("___",var);
        -- end
        child = child:getChildByName(var)
        if child == nil then
            break
        end
    end
    return child
end
function UITools.getCSB(path)
    local node = cc.CSLoader:createNode(path)
    node.getChild=UITools.getChild
    return node
end

function UITools.getLCSB(path)
    local node=cc.CSLoader:createNode(path)
    node.getChild=UITools.getChild
    node:setContentSize(display.width, display.height)
    ccui.Helper:doLayout(node)
    return node
end

function UITools.playForCSB(node,path,loop)
    local timeline = cc.CSLoader:createTimeline(path)
    node:runAction(timeline)
    timeline:gotoFrameAndPlay(loop~=false)
end

function UITools.shakeNode(node,val,time)
    local lsNode=cc.Node:create()
    node:addChild(lsNode)
    local x = node:getPositionX()
    local y = node:getPositionY()

    local index=0
    local function upFrame()
        index=index+1
        if index > time then
            lsNode:removeSelf()
        else
            node:move(x-val/2+math.random()*val,y-val/2+math.random()*val)
        end
    end
    lsNode:scheduleUpdateWithPriorityLua(upFrame, 0)
end

-- function UITools.getFCSB(path)
--     local csLoader = cc.CSLoader:createNode(path)
--     local timeline = cc.CSLoader:createTimeline(path)
--     csLoader:runAction(timeline)
--     timeline:gotoFrameAndPlay(0, true)
--     return csLoader
-- end
----------------------------------------------
-- fn 使用全局方法来格式化文本
-- args 参数
-- formatFn 格式化方法
-- text 文本
-- event 事件
-- 
local function childSetInfo(self,...)
    self.__fn(self,...);
end
local function childSetInfoForFn(self,...)
    local args={}
    for i,v in ipairs(self.__args) do
        table.insert(args,v)
    end
    for i,v in ipairs({...}) do
        table.insert(args,v)
    end
    self.__fn(self,self.__fn2(unpack(args)));
end
function UITools.formatCSBInfo(self,...)
    local args={...}
    for k,infos in pairs(self.__infoSubNodePool) do
        local v = args[k]
        local sub = infos[1]
        local formatInfo = infos[2]
        if sub then
            if formatInfo.text~=nil then
                sub:setInfo(v)
            else
                sub:setInfo(v or "")
            end
        end
    end
end
function UITools.formatCSBChild(self,body,formatInfo)
    local sub=UITools.getChild(body,unpack(formatInfo.path))
    if sub==nil then
        trace(formatInfo.path .."数据有误")
    else
        sub.__fn=formatInfo.formatFn or sub.setTitleText or sub.setString or sub.setVisible

        if formatInfo.fn~=nil then
            if type(formatInfo.fn)=="string" then
                formatInfo.fn=_G[formatInfo.fn]
            end
            if type(formatInfo.fn)=="function" then
                sub.__fn2=formatInfo.fn
                sub.__args=formatInfo.args or {formatInfo.text}
            end
            sub.setInfo=childSetInfoForFn
        else
            sub.setInfo=childSetInfo
        end
        
        if formatInfo.text~=nil then
            sub:setInfo(formatInfo.text)
        end
        if formatInfo.event~=nil then
            local function callback(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:event(formatInfo.event)
                end
            end
            sub:addTouchEventListener(callback)
        end
        if formatInfo.addInfo~=nil then
            if self.__infoSubNodePool==nil then
                self.__infoSubNodePool={}
                if self.setInfo==nil then
                    self.setInfo=UITools.formatCSBInfo
                end
            end
            table.insert(self.__infoSubNodePool,{sub,formatInfo})
            self.child[#self.__infoSubNodePool]=sub
        end
        if formatInfo.key~=nil then
            if self.child==nil then
                self.child={}
            end
            self.child[formatInfo.key]=sub
        end
    end
end

function UITools.formatCSB(target,node,formatTable)
    for i,v in ipairs(formatTable) do
        UITools.formatCSBChild(target,node,v)
    end
end

function UITools.switch(c)
    local swtbl = {
        casevar = c,
        caseof = function (self, code)
            local f;
            if (self.casevar) then
                f = code[self.casevar] or code.default
            else
                f = code.missing or code.default
            end
            if f then
                if type(f)=="function" then
                    return f(self.casevar,self)
                else
                error("case "..tostring(self.casevar).." not a function")
                end
            end
        end
    }
    return swtbl
end

function UITools.loadstring( str ) -- 读取字符串代码
    return assert(loadstring("return "..str))()
end
    -- local 
    -- local node

        -- {path={"closeBtn"},event="close"},
        -- {path={"title"},lang="ReadyUI title"},
        -- {path={"tou"},lang="ReadyUI title"},
        -- {path={"title1"},lang="ReadyUI title1"},
        -- {path={"title2"},lang="ReadyUI title2"},
        -- {path={"title3"},lang="ReadyUI title3"},
        -- {path={"b4"},lang="ReadyUI b4"},
        -- {path={"shuoming"},lang="ReadyUI shuoming"},
        -- {path={"infoBtn"},lang="ReadyUI infoBtn"},
        -- {path={"b2"},lang="ReadyUI b2"},
        -- {path={"b1"},lang="ReadyUI b1"},
        -- {path={"rank1"},addInfo="i"},
        -- {path={"jifen1"},addInfo="i"},
        -- {path={"name1"},addInfo="i"},
        -- {path={"rank"},addInfo="i"},
        -- {path={"jifen"},addInfo="i"},
        -- {path={"name"},addInfo="i"},
        -- {path={"n1"},addInfo="i"},
        -- {path={"n2"},addInfo="i"},
        -- {path={"n3"},addInfo="i"},
        -- {path={"f1"},addInfo="i"},
        -- {path={"f2"},addInfo="i"},
        -- {path={"f3"},addInfo="i"},

    


-- local function sizeRefer(node,fixedNode,offestWidth,offestHeight)
--     local size=fixedNode:getContentSize()
--     trace(size.width+offestWidth,size.height+offestHeight)
--     node:setContentSize(size.width+offestWidth,size.height+offestHeight)
-- end
-- UITools.sizeRefer=sizeRefer

----------------------------------------------------------------------------------------------确认使用

-- local function getPopups(txt, btn1, hd1, btn2, hd2)
--     local node = cc.Node:create()
--     node:addChild(getSwallowNode())
--     local function menuCallback1()
--         node:removeSelf()
--         hd1()
--     end

--     local ui = getStuNode("system.Popup")
--     node:addChild(ui.root)
--     ui.txt:setString(txt)
--     ui.btn1:setTitleText(btn1)
--     ui.btn1:addClickEventListener(menuCallback1)
--     if hd2 ~= nil then
--         local function menuCallback2()
--             node:removeSelf()
--             hd2()
--         end

--         ui.btn2:addClickEventListener(menuCallback2)
--         ui.btn2:setTitleText(btn2)
--     else
--         ui.btn2:setVisible(false)
--         ui.btn1:setPositionX(0)
--     end
--     node:setPosition(display.cx, display.cy)
--     return node
-- end


-- ----------------------------------------------------------------------------------------------
-- local function getPopupBgUI(width, height, color)
--     local box = getSwallowNode()
--     local _width = width or 540;
--     local _height = height or 300;
--     local _color = color or cc.c3b(255, 255, 255);
--     local bg = getRoundRect(_width, _height, 15, _color)
--     box:addChild(bg)
--     box:setPosition(display.cx, display.cy)
--     return box
-- end

-- -- local function getTxt(size)
-- --     local txt
-- --     local txtBox = cc.Node:create()
-- --     local nameBg = ccui.Scale9Sprite:create("txtBg.png")
-- --     nameBg:setAnchorPoint(0.5, 0.5)
-- --     local nameTxt = cc.Label:create()
-- --     nameTxt:setSystemFontSize(size)
-- --     nameTxt:setAnchorPoint(0.5, 0.5)
-- --     txtBox:addChild(nameBg)
-- --     txtBox:addChild(nameTxt)
-- --     function txtBox:setString(str)
-- --         nameTxt:setString(str)
-- --         local txtSize = nameTxt:getContentSize()
-- --         nameBg:setContentSize(cc.size(txtSize.width + 20, txtSize.height + 6))
-- --     end
-- --     return txtBox
-- -- end


-- ----------------------------------------- flash---------------------------------------------------------------------
-- local function getAction(name, callback)
--     local animation = cc.Animation:create()
--     local spriteFrameCache = cc.SpriteFrameCache:getInstance()
--     for i = 0, 9999 do
--         local spriteFrame = spriteFrameCache:getSpriteFrame(string.format(name .. "%04d", i))
--         if spriteFrame ~= nil then
--             animation:addSpriteFrame(spriteFrame)
--         else
--             break
--         end
--     end
--     animation:setDelayPerUnit(1 / 60)
--     local action
--     if callback == nil then
--         action = cc.Animate:create(animation)
--     else
--         action = cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(callback))
--     end
--     return action
-- end


-- local function getSkin(actionName)
--     local sprite = cc.Sprite:create()
--     local action = getAction(actionName)
--     function sprite:play(loop)
--         if loop then
--             self:runAction(cc.RepeatForever:create(action))
--         else
--             self:runAction(action)
--         end
--     end

--     return sprite
-- end

-- -------------------------------------------------------------------------------------------------------------- 公式
-- local function getStu(url, view)
--     local callBackProvider
--     if view ~= nil then
--         callBackProvider = function(luaFileName, node, callbackName)
--             local function stuCallback(sender, type)
--                 if view[callbackName] == nil then
--                     base.print(string.format("function %s:%s(sender,type) end", view.classname, callbackName))
--                 else
--                     view[callbackName](view, sender, type)
--                 end
--             end

--             return stuCallback
--         end
--     end

--     local node = require("stu." .. url).create(callBackProvider)
--     node.root:setContentSize(display.width, display.height)
--     ccui.Helper:doLayout(node.root)
--     return node
-- end

-- local function getStuNode(url)
--     return require("stu." .. url).create()
-- end

-- local function stuplay(node, animationName, loop)
--     node.root:runAction(node.animation);
--     node.animation:play(animationName, loop)
-- end

-- local function stuStop(node)
--     node.animation:stop()
--     node.root:stopAction(node.animation);
-- end

-- function stuflash(node)
--     node.play = stuplay
--     node.stop = stuStop
-- end

------------
--UITools 功能等待整理

local Node = cc.Node

function Node:getChild( ... )
    local childArr  = {...}
    local child = self
    for i,v in ipairs(childArr) do
        if type(v) == "string" then
            child = child:getChildByName(v)
        else
            return nil
        end
    end
    return child
end

-- function split( str ,pattern)
--     local arr = {}
--     local arr2 = ""
--     local index = 0
--     for w in string.gmatch(str,".") do
--         index = index + 1
--         if w == pattern then
--             table.insert(arr,arr2)
--             arr2 = ""
--         elseif string.len(str) <= index then
--             arr2 = arr2..w
--             table.insert(arr,arr2)
--             arr2 = ""
--         else
--             arr2 = arr2..w
--         end
--     end
--     return arr
-- end

local function delayCall(callback, delay,...)
        local args={...}
        local _scheduleId
        local  function _callback()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_scheduleId)
            callback(unpack(args))
        end
        _scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_callback, (delay or 0)/1000, false)
end
cc.exports.delayCall=delayCall

return UITools
