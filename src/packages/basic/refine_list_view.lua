-- 这个控件是优化版本的list_view,
-- 他继承于scroll_view, 在滚动的过程中，依靠重载界面来完成
local meta = class("refine_page_view",function (node)
    return node
end)

local DIR = {
    UP = "up",
    DOWN = "down",
    LEFT = "left",
    RIGHT = "right",
}

-- 初始化控件信息
function meta:Init(max_row, item_height, create_item_func)
    self.sub_item_panel = {}
    self.size = self:getContentSize()
    self.item_height = item_height
    self.cur_row = 1
    self.max_row = max_row

    local inner_container = self:getInnerContainer()
    for i = max_row, 1, -1  do
        local item = create_item_func()
        local anchor = item:getAnchorPoint()
        item:setPositionX( self.size.width * anchor.x )
        item:setPositionY( i * item_height + anchor.y * item_height - item_height)
        item:setVisible(false)
        self.sub_item_panel[i] = item
        inner_container:addChild(item)
    end
    self.item_touch_enter = true --默认点击响应事件
    self:addEventListener(function(widget, event_type)
        if event_type == 4 or event_type == 9 then
            self:OnScrolling()
        end
    end)
end

function meta:RemoveAllItem()

    if not self.sub_item_panel then
        return
    end

    for k,v in pairs(self.sub_item_panel) do
        v:removeFromParent()
    end
    self.sub_item_panel = {}
end

-- 滚动事件
function meta:OnScrolling()
    if self.pre_inner_y == nil then 
        return 
    end
    local cur_y = self:getInnerContainer():getPositionY()
    if self.move then --如果在点击时移动
        self.item_touch_enter = false
    end

    if self.pre_inner_y < cur_y then
        self.scroll_dir = DIR.DOWN
    else
        self.scroll_dir = DIR.UP
    end
    self.pre_inner_y = cur_y

    if cur_y >= 0 then
        cur_y = 0
        return
    end

    if self.total_row < self.max_row then
        return
    end

    local inner_height = self.inner_size.height
    -- 上边界
    local boundary_up_y =  self.size.height - cur_y - self.item_height
    -- 下边界
    local boundary_down_y = cur_y
    -- 获取顶部item
    local top_item_y = self.sub_item_panel[1]:getPositionY()
    -- 获取底部item
    local bottom_item_y = -self.sub_item_panel[self.max_row]:getPositionY()

    if self.scrollcallback then
        self.scrollcallback(self)
    end

    -- 向下滚动，底部item，超过边界，
    if self.scroll_dir == DIR.DOWN and bottom_item_y < boundary_down_y then
        if self.cur_row >= self.total_row then
            return
        end
        local top_item = self.sub_item_panel[1]
        table.remove(self.sub_item_panel, 1)
        self.sub_item_panel[self.max_row] = top_item
        self.cur_row = self.cur_row + 1
        self:SetItemInfo(self.max_row, self.cur_row + self.max_row - 1)
        return
    end

    -- 向上滚动，
    if self.scroll_dir == DIR.UP and top_item_y < boundary_up_y then
        if self.cur_row <= 1 then
            return
        end
        local bottom_item = self.sub_item_panel[self.max_row]
        self.sub_item_panel[self.max_row] = nil
        table.insert(self.sub_item_panel, 1, bottom_item)
        self.cur_row = self.cur_row - 1
        if self.cur_row < 1 then
            self.cur_row = 1
        end
        self:SetItemInfo(1, self.cur_row)
        return
    end
end

function meta:SetScrollCallback(callback)
    self.scrollcallback = callback
end

-- 设置Item内容
function meta:SetItemInfo(index, cur_row)
    local inner_height = self.inner_size.height
    local item_height = self.item_height
    local item = self.sub_item_panel[index]
    local anchor = item:getAnchorPoint()
    local y = inner_height - cur_row * item_height
    item:setPositionY(y)
    if cur_row < 1 or cur_row > self.total_row then
        item:setVisible(false)
    else
        item:setVisible(true)
    end
    local update_func = self.update_func
    if update_func then
        update_func(cur_row, item)
    end
end

function meta:CleanItemInfo()

    if not self.sub_item_panel then
        return
    end
    for _, item in pairs(self.sub_item_panel) do
        item:setVisible(false)
    end
end

-- 设置第一行显示
-- @cur_row 真实行数
function meta:SetHeadRow(cur_row)
    print("################",cur_row)
    self.cur_row = cur_row
    local inner_height = self.inner_size.height
    local index = 1
    local item_height = self.item_height
    for i = 1, math.min(self.total_row, self.max_row) do
        self:SetItemInfo(index, cur_row + i - 1)
        index = index + 1
    end


    self:jumpToPercentVertical((cur_row - 1)/self.total_row)


    -- 设置显示窗口
    local cur_yy = inner_height - (cur_row * item_height - item_height)
    self.pre_inner_y = self.size.height - cur_yy
    self:getInnerContainer():setPositionY(self.pre_inner_y)
end

-- 显示邮件列表
function meta:Show(total_row, update_func)

    self:CleanItemInfo()

    self.inner_size = { width = 0, height = 0}
    self.inner_size.width = self.size.width
    self.inner_size.height = math.max(self.size.height, total_row * self.item_height)
    self.total_row = total_row
    self.update_func = update_func

    for i = self.max_row, 1, -1  do
        local item = self.sub_item_panel[i]
        if item then
            item:setVisible(false)
        end
    end

    if self.total_row > 4 then
        self:setTouchEnabled(true)
    else
        self:setTouchEnabled(false)
    end

    if self.cur_row ~= 1 and self.cur_row + self.max_row < self.total_row  then
        self:SetHeadRow(self.cur_row)
    elseif self.cur_row + self.max_row >= self.total_row  and self.total_row - self.max_row + 1 > 0 then
        self:SetHeadRow(self.total_row - self.max_row + 1)
    else
        self:SetHeadRow(1)
    end

    self:getInnerContainer():setContentSize(self.inner_size)
end

function meta:SetItemTouchEnter(_bool) --是否响应cell点击事件
    self.item_touch_enter = _bool
end

function meta:GetItemTouchEnter() --是否响应cell点击事件
    return self.item_touch_enter 
end

function meta:GetCanMove() --是否点击了cell
    return self.move 
end

function meta:SetCanMove(_bool) --是否点击了cell
    self.move = _bool
end

function meta:SetContentSize(size)
    self.size = size
    self:setContentSize(size)
end

function meta:scrollToVertical(index,time)  --
    time = time/100
    local per = index/self.total_row
    self:scrollToPercentVertical(per * 100,math.abs(index - self.cur_row ) * time,true)
end

function meta:updateItemData( )
    for i,item in ipairs(self.sub_item_panel) do
        local update_func = self.update_func
        if update_func then
            update_func(self.cur_row + i - 1, item)
        end
    end
end

return meta
