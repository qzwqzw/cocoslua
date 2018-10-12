local text_loader = require "manager.text_loader"
local audio_manager = require "manager.audio_manager"
local defines = require "manager.defines"

local bit = require "bit"
local bit_rshift = bit.rshift
local bit_band = bit.band

local meta = {}

function meta:NewPanel(class_name, class_path)
    local origin = class(class_name, function ()
        return require("modules.common.base_panel").new(class_path)
    end)

    function origin:ctor(...)
        if self["OnInit"] then
            self:OnInit(...)
        end
        if self["RegisterEvent"] then
            self:RegisterEvent()
        end
    end
    origin["panel_name"] = class_name
    return origin
end

--保留两位小数
function meta:KeepTwoDecimalPlace(unit, value)
    local temp = value / unit

    return math.floor(temp * 100) / 100
end

--单位换算
function meta:ConvertUnit(value, add_minus_sign)
    local unit = ""
    -- if value < defines["UNIT"]["K"] then

    -- elseif value < defines["UNIT"]["M"] then
    --     --千
    --     value = self:KeepTwoDecimalPlace(defines["UNIT"]["K"], value)
    --     unit = "K"

    -- elseif value < defines["UNIT"]["B"] then
    --     --百万
    --     value = self:KeepTwoDecimalPlace(defines["UNIT"]["M"], value)
    --     unit = "M"

    -- else
    --     --十亿
    --     value = self:KeepTwoDecimalPlace(defines["UNIT"]["B"], value)
    --     unit = "B"

    -- end

    -- if add_minus_sign then
    --     value = "-" .. value
    -- else
    --     value = tostring(value)
    -- end

    -- value = value .. unit

    return value
end

-- 设置资源
function meta:SetResource(widget, value)
    self:SetText(widget, self:ConvertUnit(value))
end

-- 16进制转颜色数量
function meta:GetColor4B(color, alpha_value)
    local color_4b = {a = 0, r = 0, g = 0, b = 0}
    color_4b.a = alpha_value or 255
    color_4b.r = bit_band(bit_rshift(color, 16), 0xff)
    color_4b.g = bit_band(bit_rshift(color, 8), 0xff)
    color_4b.b = bit_band(color, 0xff)
    return color_4b
end

-- 16进制颜色数量
function meta:GetColor3B(color)
    local color_3b = {r = 0, g = 0, b = 0}
    color_3b.r = bit_band(bit_rshift(color, 16), 0xff)
    color_3b.g = bit_band(bit_rshift(color, 8), 0xff)
    color_3b.b = bit_band(color, 0xff)
    return color_3b
end

-- 加载UI
function meta:LoadCocosUI(path)
    print("LoadCocosUI:",path)
    local ui_root = cc.CSLoader:createNode(path)
    self:SetCocosSetting(ui_root, path)
    self:BindTimeLine(ui_root, path)

    return ui_root
end

-- 设置UI配置
function meta:SetCocosSetting(ui_root, path)
    local setting = text_loader:GetEditerSetting(path)
    local pre_path = {}
    for _, item_config in pairs(setting) do
        local key = item_config.field
        local path_level = string.split(key, ".")

        local find_count = 0
        local oper_object = ui_root
        for level, name in pairs(path_level) do
            local pre_config = pre_path[level]
            -- 如果上一次配置层级关系和本次相同就设置否则的话就从上一级目录查找
            if pre_config and pre_config.name == name then
                oper_object = pre_config.object
            else
                if not oper_object then
                    oper_object = nil
                    break
                end
                oper_object = oper_object:getChildByName(name)
                -- 层级对象记录
                pre_path[level] = {}
                pre_path[level]["name"] = name
                pre_path[level]["object"] = oper_object
                for i = level + 1, #path_level do
                    if pre_path[i] ~= nil then
                        pre_path[i] = nil
                    end

                end

                find_count = find_count + 1
            end
        end
        if oper_object then
            if item_config.text then
                self:SetText(oper_object, item_config.text)
            end

            if item_config.pimage then
                self:SetImage(oper_object, item_config.pimage, ccui.TextureResType.plistType)
            end
            if item_config.image then
                self:SetImage(oper_object, item_config.pimage, ccui.TextureResType.localType)
            end
            local font = item_config.font
            local size = item_config.size
            if item_config.size then
                oper_object:setFontSize(item_config.size)
            end
            local node = item_config.node
            -- print("查找对象成功 "..key.."查找次数:"..find_count)
        end
    end
end

-- 拓展UI
function meta:ExpandUI(ui_root, node_name, lua_file, anim_file)
    local node = ui_root:getChildByName(node_name)
    if not node then
        print("node_name = "..node_name.." is null")
    end
    return require(lua_file).new(node, anim_file)
end

-- 绑定时间轴
function meta:BindTimeLine(target, path)
    local timeline = cc.CSLoader:createTimeline(path)
    target.timeline = timeline
    target:runAction(timeline)


    -- 播放动画
    function target:PlayAnimation(anim_name, is_loop, last_callback, is_lock_touch)
        if self.cur_animation and self.cur_animation.anim_name and not self.cur_animation.is_loop then
            if self.callback_id then
                target:stopAction(self.callback_id)
                self.callback_id = nil
            end
        end

        is_loop = is_loop or false
        local timeline = self.timeline
        timeline:play(anim_name, is_loop)
        local decompress_pkg = require "entry.decompress_pkg"
        if not decompress_pkg:CheckIfNeedDecompress() then
            local guide_logic = require "logic.guide"
            guide_logic:CheckOrderCompalte(string.format("cc_ani_beg_%s_%s", (string.match(path, "%/([%w_]+)%.") or ""), anim_name))
        end
        local speed = timeline:getTimeSpeed()
        local start_frame = timeline:getStartFrame()
        local end_frame = timeline:getEndFrame()
        local frame_num = end_frame - start_frame
        local duration = 1.0 /(speed * 60.0) * frame_num
        if not is_loop then
            local event_dispatcher = cc.Director:getInstance():getEventDispatcher()
            event_dispatcher:setEnabled(not is_lock_touch)
            local block = cc.CallFunc:create(function()
                self.cur_animation = nil
                if not decompress_pkg:CheckIfNeedDecompress() then
                    local guide_logic = require "logic.guide"
                    guide_logic:CheckOrderCompalte(string.format("cc_ani_end_%s_%s", (string.match(path, "%/([%w_]+)%.") or ""), anim_name))
                end
                if last_callback then
                    last_callback()
                end
                event_dispatcher:setEnabled(true)
            end)
            self.callback_id = target:runAction(cc.Sequence:create(cc.DelayTime:create(duration), block))
        end

        self.cur_animation = {}
        self.cur_animation.anim_name = anim_name
        self.cur_animation.is_loop = is_loop
        return duration
    end

    -- 是否动画中
    function target:IsPlayAnimation()
        return self.cur_animation ~= nil
    end

    local stopAllActions = target["stopAllActions"]
    function target:stopAllActions()
        stopAllActions(self)
        local timeline = cc.CSLoader:createTimeline(path)
        self.timeline = timeline
        self:runAction(timeline)
    end

    local event_call_func
    function target:SetFrameEventCallFunc(callback)
        event_call_func = callback
    end
        
    timeline:setFrameEventCallFunc(function (frame)
        local frame_node = frame:getNode()
        if frame_node:isVisible() == false then
            return
        end

        local event_name = frame:getEvent()
        local event_map = {}
        local list = string.split(event_name, "|")
        for i = 1, #list, 2 do
            event_map[list[i]] = list[i+1] or nil
        end

        local sound_value = event_map["sound"]
        local shake_value = event_map["shake"]

        if sound_value then
            audio_manager:PlayEffect(sound_value)
        elseif shake_value then
            local float_value = event_map["float"]
            local int_value = event_map["int"]
            if shake_value == "screen" then
                graphic:DispatchEvent("effect_screen_shake", float_value, int_value)
            end
        elseif event_name == "max_display" then
            local parent = frame_node:getParent()
            local parent_size = parent:getContentSize()
            local visibleSize = cc.Director:getInstance():getVisibleSize() -- 屏幕分辨率大小
            frame_node:setContentSize(visibleSize)
            frame_node:setAnchorPoint(cc.p(0.5, 0.5))
            frame_node:setPosition(cc.p(parent_size.width / 2, parent_size.height / 2))
        else
            if event_call_func then
                event_call_func(frame)
            end
        end
    end)
end

--添加点击事件
function meta:AddClick(widget, callback, ...)
    if not widget then
        print("meta:AddClick widget is null", debug.traceback())
        return
    end
    widget:setTouchEnabled(true)
    local extension_data = widget:getComponent("ComExtensionData")
    local user_data = ""
    if extension_data then
        user_data = extension_data:getCustomProperty()
    end

    local event_map = {}
    local list = string.split(user_data, "|")
    for i = 1, #list, 2 do
        event_map[list[i]] = list[i+1] or nil
    end

    local click_time = os.time() - 1
    local params = ...
    widget:addTouchEventListener(function(widget, event_type)
        if event_type == ccui.TouchEventType.began then
            local sound_value = event_map["sound"]
            if sound_value then
                audio_manager:PlayEffect(sound_value)
            end
        elseif event_type == ccui.TouchEventType.ended then
            local offset_time = os.time() - click_time
            if offset_time > 0.6 then -- 有效点击事件时间
                click_time = os.time()
                callback(widget, params)
            end
        end
    end)
end

--获取子节点
--没有循环查找，可以优化
function meta:SeekChildByName(widget, name, isFind)
    if widget == nil then
        return nil
    end
    local node = widget:getChildByName(name)
    if node then
        return node
    end
    return nil
end

-- 设置文本内容根据key
function meta:SetTextByKey(widget, key, ...)
    if not key then
        return
    end
    local message = text_loader:GetText(key,...)
    self:SetText(widget, message)
end

--设置文本内容，兼容text,button
function meta:SetText(widget, text)
    text = text or ""
    if not widget then
        print("SetText widget is null", debug.traceback())
        return
    end
    if type(text) == "number" then
        text = tostring(text)
    end
    if type(widget["setString"]) == "function" then
        text = string.gsub(text, "\\n", "\n")
        widget:setString(tostring(text))


        local extension_data = widget:getComponent("ComExtensionData")
        local user_data = ""
        if extension_data then
            user_data = extension_data:getCustomProperty()
        end

        local event_map = {}
        local list = string.split(user_data, "|")
        for i = 1, #list, 2 do
            event_map[list[i]] = list[i+1] or nil
        end

        local over_flow = event_map["overflow"]
        if over_flow then
            local label = widget:getVirtualRenderer()
            label:setOverflow(cc.LabelOverflow[over_flow])
        end

    elseif type(widget["setTitleText"]) == "function" then
        widget:setTitleText(text)
    elseif type(widget["setText"]) == "function" then
        widget:setText(text)
    end
end

function meta:ReplaceProgressTimer(sprite)
    if sprite == nil then
        return nil
    end

    local progress = cc.ProgressTimer:create(sprite)
    local old_x, old_y = sprite:getPosition()
    progress:setPosition({x = old_x, y = old_y})
    local parent = sprite:getParent()
    parent:removeChild(sprite)
    parent:addChild(progress)
    return progress
end

-- 替换EditBox
function meta:ReplaceEditBox(textfield)
    local size = textfield:getContentSize()  
    local pos_x, pos_y = textfield:getPosition()
    local anchor = textfield:getAnchorPoint()
    local place_holder = textfield:getPlaceHolder()
    local txt_color = textfield:getTextColor()
    local font_size = textfield:getFontSize()
    local font_name = textfield:getFontName()
    local max_length = textfield:getMaxLength()
    local is_password = textfield:isPasswordEnabled()

    local edit_box = ccui.EditBox:create(size, ccui.Scale9Sprite:create(""))
    edit_box:setPosition(pos_x, pos_y)
    edit_box:setAnchorPoint(anchor)
    
    edit_box:setPlaceholderFont(font_name, font_size)
    edit_box:setPlaceholderFontColor(self:GetColor3B(0x74b2ce))

    edit_box:setFont(font_name, font_size)
    edit_box:setFontColor(self:GetColor3B(0x74b2ce))

    edit_box:setMaxLength(max_length)
    edit_box:setContentSize(size)
    if is_password then
        edit_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    end


    local parent = textfield:getParent()
    parent:addChild(edit_box)
    -- textfield:removeFromParent()
    textfield:setVisible(false)

    function edit_box:didNotSelectSelf()
    end

    function edit_box:setString(str)
        self:setText(str)
    end

    function edit_box:getString()
        return self:getText()
    end

    return edit_box
end

function meta:SetImageEx(widget,path,Type)
    if Type == nil then 
        self:SetImage(widget, path,ccui.TextureResType.plistType)
    else
        self:SetImage(widget, path,ccui.TextureResType.localType)
    end
end
-- 设置图片
function meta:SetImage(widget, path, ptype)
    if widget == nil then
        return
    end
    if type(widget["setTexture"]) == "function" then
        local texture2d = nil
        if ptype == ccui.TextureResType.plistType then
            local spriteframe_cache = cc.SpriteFrameCache:getInstance()
            local sprite_frame = spriteframe_cache:getSpriteFrame(path)
            widget:setSpriteFrame(sprite_frame)
        else
            local texture_cache = cc.Director:getInstance():getTextureCache()
            texture2d = texture_cache:addImage(path)
            widget:setTexture(texture2d)

        end
    elseif type(widget["loadTexture"]) == "function" then
        if ptype == nil then
            widget:loadTexture(path, ccui.TextureResType.localType)
        else
            widget:loadTexture(path, ptype)
        end
    elseif type(widget["loadTextures"]) == "function" then
        if ptype == nil then
            widget:loadTextures(path, nil, nil, ccui.TextureResType.localType)
        else
            widget:loadTextures(path, nil, nil, ptype)
        end
    end
end

-- 向左移动消失
function meta:RunLeftAnimationToHide(panel)
    local old_x, old_y = panel:getPosition()
    panel:setPosition({x = 0, y = 0})

    local act_move = cc.MoveBy:create(0.2, cc.p(-display.width, 0))
    local act_func = cc.CallFunc:create(function ()
        --panel:setVisible(false)
        panel:Hide()
    end)
    panel:runAction(cc.Sequence:create(act_move, act_func))
end

-- 向左移动出现
function meta:RunLeftAnimationToShow(panel)
    local old_x, old_y = panel:getPosition()
    panel:setPosition({x = display.width, y = 0})
    --panel:setVisible(true)
    panel:Show()

    local act_move = cc.MoveBy:create(0.2, cc.p(-display.width, 0))
    panel:runAction(act_move)
end

-- 向右移动消失
function meta:RunRightAnimationToHide(panel)
    local old_x, old_y = panel:getPosition()
    panel:setPosition({x = 0, y = 0})

    local act_move = cc.MoveBy:create(0.2, cc.p(display.width, 0))
    local act_func = cc.CallFunc:create(function ()
        --panel:setVisible(false)
        panel:Hide()
    end)
    panel:runAction(cc.Sequence:create(act_move, act_func))
end

-- 向右移动出现
function meta:RunRightAnimationToShow(panel)
    local old_x, old_y = panel:getPosition()
    panel:setPosition({x = -display.width, y = 0})
    --panel:setVisible(true)
    panel:Show()

    local act_move = cc.MoveBy:create(0.2, cc.p(display.width, 0))
    panel:runAction(act_move)
end

-- demo的手牌常驻内存不要清空掉
local demo_hand_card = nil
function meta:GetDemoHandCard(uid)
    if not demo_hand_card then
        demo_hand_card = require("modules.common.card_hand_item").new()
        demo_hand_card:retain()
    end
    demo_hand_card.SetScale = function (scale)
        local tt = demo_hand_card:getScale()
        if tt ~= scale then
            demo_hand_card:setPosition(0, 0)
            local rect = meta:GetNodeRect(demo_hand_card)

        end
    end
    if uid then
        demo_hand_card:SetCardId(uid)
    end
    return demo_hand_card
end

function meta:GetNodeRect(src_node)
    local scale = src_node:getScale()
    scale = 0.43
    -- print("scale = "..scale)
    -- 检查node边界
    local function clacRect(node)
        local children = node:getChildren()
        local min_x = 0
        local min_y = 0
        local max_x = 0
        local max_y = 0
        for k,v in pairs(children) do
            local rect = v:getBoundingBox()
            rect.width = rect.width * scale
            rect.height = rect.height * scale
            local p = node:convertToWorldSpace({x = rect.x, y = rect.y})
            p.x = p.x
            p.y = p.y
            if p.x < min_x then
                min_x = p.x
            end
            if p.y < min_y then
                min_y = p.y
            end
            if max_x < (p.x + rect.width) then
                max_x = p.x + rect.width
            end

            if max_y < (p.y + rect.height) then
                max_y = p.y + rect.height
            end
            local n_min_x, n_min_y, n_max_x, n_max_y = clacRect(v)
            if n_min_x < min_x then
                min_x = n_min_x
            end
            if n_min_y < min_y then
                min_y = n_min_y
            end
            if max_x < n_max_x then
                max_x = n_max_x
            end

            if max_y < n_max_y then
                max_y = n_max_y
            end

        end
        return min_x, min_y, max_x, max_y
    end
    local min_x, min_y, max_x, max_y = clacRect(src_node)

    local rect = {}
    rect.x = min_x
    rect.y = min_y
    rect.width = (max_x - min_x)
    rect.height = (max_y - min_y)
    return rect
end

-- src_node 缓冲到texture——chace的方案
function meta:NodeToTextureCache(src_node, renderTexture)
    if not renderTexture then
        local rect = meta:GetNodeRect(src_node)
        renderTexture = cc.RenderTexture:create(rect.width, rect.height)
    end
    renderTexture:beginWithClear(0.0, 0.0, 0.0, 0.0);
    src_node:visit()
    renderTexture:endToLua()
    return renderTexture
end

--截取中英混合的UTF8字符串，endIndex可缺省
function meta:SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = self:SubStringGetTotalIndex(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = self:SubStringGetTotalIndex(str) + endIndex + 1
    end

    if endIndex == nil then
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex))
    else
        local new_str = string.sub(str, self:SubStringGetTrueIndex(str, startIndex), self:SubStringGetTrueIndex(str, endIndex + 1) - 1)
        if string.len(str) > self:SubStringGetTrueIndex(str, endIndex + 1) - 1 then
            new_str = new_str.."..."
        end
        return new_str
    end
end

--获取中英混合UTF8字符串的真实字符数量
function meta:SubStringGetTotalIndex(str)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until(lastCount == 0)
    return curIndex - 1
end

function meta:SubStringGetTrueIndex(str, index)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until(curIndex >= index)
    return i - lastCount
end

--返回当前字符实际占用的字符数
function meta:SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<223 then
        byteCount = 2
    elseif curByte>=224 and curByte<239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount
end

function meta:FixedAllResolutionRatio(panel)
    local visibleSize = cc.Director:getInstance():getVisibleSize() -- 屏幕分辨率大小
    panel:setAnchorPoint(cc.p(0.5, 0.5))
    panel:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
end


-- Begin : added by rw at 2017-4-27 for 将图片切成 ”shader“ 的形状 
-- 所有带 头像的node 需要按照 下面的结构,icon,shader名称 不可更改
--[[
    head[
        -icon: ImageView //  
        -shader: ImageView
    ]
]]

local clip_vert = [[
    attribute vec4 a_position; 
    attribute vec2 a_texCoord; 
    attribute vec4 a_color; 
    #ifdef GL_ES  
    varying lowp vec4 v_fragmentColor;
    varying mediump vec2 v_texCoord;
    #else                      
    varying vec4 v_fragmentColor; 
    varying vec2 v_texCoord;  
    #endif    
    void main() 
    {
        gl_Position = CC_PMatrix * a_position; 
        v_fragmentColor = a_color;
        v_texCoord = a_texCoord;
    }
]]

local clip_frag = [[
    #ifdef GL_ES 
    precision mediump float; 
    #endif 
    varying vec4 v_fragmentColor; 
    varying vec2 v_texCoord; 
    void main(void) 
    { 
        vec4 c = texture2D(CC_Texture0, v_texCoord); 
        //vec4 shader = texture2D(CC_Texture1, v_texCoord); 
        gl_FragColor = c;
        //gl_FragColor.a = shader.a ;
        float x = (v_texCoord.x - 0.5 );
        float y = (v_texCoord.y - 0.5);
        float distSq = x * x + y * y;
        if (distSq > 0.25)
        {
            gl_FragColor.a = 0.0;
        }
        gl_FragColor = gl_FragColor * v_fragmentColor.a;
    }
]]

local function applyShader(icon,textureID)
    
    local _gLProgramCache = cc.GLProgramCache:getInstance()
    local glprogram = _gLProgramCache:getGLProgram("clip_circle");  
    if glprogram == nil then  
        --glprogram = _glProgram:createWithFilenames(vert,frag); 
        glprogram = cc.GLProgram:createWithByteArrays(clip_vert,clip_frag);   
        glprogram:link();  
        glprogram:updateUniforms();  
        _gLProgramCache:addGLProgram(glprogram,"clip_circle");  
    end  
      
    local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glprogram);  
    
    --glProgramState:setUniformTexture("CC_Texture1", textureID);  
    --glProgramState:applyUniforms();

    icon:setGLProgramState(glProgramState)
end

function meta:ClipHead(headNode)
    local stencil = headNode:getChildByName("shader")
    local target = headNode:getChildByName("icon")
    local target_original_position = cc.p(target:getPosition())
    local scale = target:getScale()
    local size = target:getContentSize()
    target:setVisible(false)

    local target_new = cc.Sprite:create()
    target_new:setName("newIcon")
    target_new:setContentSize(size)
    target_new:setScale(scale)
    
    if stencil then
        stencil:setVisible(false)
    end

    --头像原始位置
    local stencil_sprite = cc.Sprite:create("ui/ui_icon/headicon/head_shader.png") 
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setName("clippingNode")
    clippingNode:setAlphaThreshold(0.05)
    clippingNode:setStencil(stencil_sprite)
    clippingNode:addChild(target_new)
    target_new:setPosition({x=0,y=0})
    target_new.__originSize = stencil_sprite:getContentSize()
    headNode:addChild(clippingNode)

    clippingNode:setPosition(target_original_position)

    --target 99x99 path: image path 
    headNode.icon = target_new
    
    return target_new
end
-- End

--Begin : added by rw at 2017-4-28 for set texture not matter widget is a UIView or Sprite 
function meta:SetTextureEX(target, path)
    local originSize = target.__originSize or target:getContentSize()
    target:setTexture(path)
    local size = target:getContentSize()
    local scale = 1
    if size.width > size.height then 
        scale = (originSize.width)/size.height
    else
        scale = (originSize.height )/size.width
    end
    target:setScale(scale)
end

--Begin : added by rw at 2017-4-28 for set head image easily, 不管是网络图片地址，还是本地头像地址  
function meta:setHeadEx(icon,id,url,callback)

    --内部回调 设置失败的时候 还原成默认头像
    local function setHeadCallback(...)
        local result = select(1, ...)
        print("setHeadEx 设置头像 回调 ",result)
        if result == "failed" then
            -- self:SetDefualtHead(icon)
        end
        if callback ~= nil then
            callback(...)
        end
    end
    if id == nil then 
        self:SetDefualtHead(icon)
        return 
    end
    if id < 0 or id > 1000000 then 
        print("setHeadEx:" , id , url)
       if url and url ~= "" then 
            -- 为防止读取时间过长显示空白，先设为默认
            self:SetDefualtHead(icon)

            local url_imageHelpr = require "manager.url_imageHelper"
            url_imageHelpr.showNetImage(url,icon ,setHeadCallback)
        else
            --show default image 
            self:SetDefualtHead(icon)
            if callback ~= nil then
                callback()
            end
        end
        
        --url,uiImg,identifier,callback
        --self:setTexture(icon,,stencil:getContentSize() )
    else
        --print("setHead (local)" , id )
        local resource = require "manager.resource"
        local icon_path,localType = resource:GetUserHandIcon(id)
        print("setHeadEx:" , id , icon_path)
        self:SetTextureEX(icon,icon_path)
		if callback ~= nil then
			callback()
		end
        
    end
end
function meta:setHeadEx2(node,id,url,callback)
    local icon = node.icon
    if icon == nil then 
        print("icon is nil")
        icon = self:ClipHead(node)
    end 

    --内部回调 设置失败的时候 还原成默认头像
    local function setHeadCallback(...)
        local result = select(1, ...)
        print("设置头像 回调 ",result)
        if result == "failed" then
            -- self:SetDefualtHead(icon)
        end
        if callback ~= nil then
            callback(node)
        end
    end
    if id == nil then 
        self:SetDefualtHead(icon)
        return 
    end
    if id < 0 or id > 1000000 then 
        print("setHead" , id , url)
        if url and url ~= "" then 
            -- 为防止读取时间过长显示空白，先设为默认
            self:SetDefualtHead(icon)

            local url_imageHelpr = require "manager.url_imageHelper"
            url_imageHelpr.showNetImage(url,icon ,setHeadCallback)
        else
            --show default image 
            self:SetDefualtHead(icon)
            if callback ~= nil then
                callback(node)
            end            
        end
        
        --url,uiImg,identifier,callback
        --self:setTexture(icon,,stencil:getContentSize() )
    else
        --print("setHead (local)" , id )
        local resource = require "manager.resource"
        self:SetTextureEX(icon,resource:GetUserHandIcon(id))
        --self:SetTextureEX(icon,url)
        if callback ~= nil then
            callback(node)
        end        
    end
end
function meta:setHead(node,id,url,callback)
    local icon = node.icon
    if icon == nil then 
        print("icon is nil")
        icon = self:ClipHead(node)
    end 

    --内部回调 设置失败的时候 还原成默认头像
    local function setHeadCallback(...)
        local result = select(1, ...)
        print("设置头像 回调 ",result)
        if result == "failed" then
            -- self:SetDefualtHead(icon)
        end
        if callback ~= nil then
            callback(...)
        end
    end
    if id == nil then 
        self:SetDefualtHead(icon)
        return 
    end
    if id < 0 or id > 1000000 then 
        print("setHead" , id , url)
        if url and url ~= "" then 
            -- 为防止读取时间过长显示空白，先设为默认
            self:SetDefualtHead(icon)

            local url_imageHelpr = require "manager.url_imageHelper"
            url_imageHelpr.showNetImage(url,icon ,setHeadCallback)
        else
            --show default image 
            self:SetDefualtHead(icon)
        end
        
        --url,uiImg,identifier,callback
        --self:setTexture(icon,,stencil:getContentSize() )
    else
        --print("setHead (local)" , id )
        local resource = require "manager.resource"
        self:SetTextureEX(icon,resource:GetUserHandIcon(id))
    end
end
--End


function meta:SetDefualtHead(node)
    self:SetTextureEX(node,"ui/ui_icon/headicon/visitor.png")
end


function cc.Node:FetchChildren()
    local children = self:getChildren();
    for k , v in pairs(children) do 
        self[v:getName()] = v;
        v:FetchChildren()
    end
end

function cc.Node:Find(str)
    local findarr = str:split("/")
    local node = self;
    for i = 1, #findarr do 
        local findNode =  node:getChildByName(findarr[i])
        if findNode == nil then 
            return nil
        else
            node = findNode
        end
    end
    return node;
end


function meta:ProcessChildren(root,node)
    if node:getDescription() == "Button" then 
        local parent = node:getParent()
        local fun_name = string.format("on_%s_%s_clicked", parent:getName(), node:getName())
        if root[fun_name] then
            self:AddClick(node,function() 
                root[fun_name](root,node)
            end)
        else
            print(string.format("[%s]function meta:%s() missing" ,root.__cname , fun_name ))
        end
    end
    local children = node:getChildren();
    for k , v in pairs(children) do 
        node[v:getName()] = v;
        self:ProcessChildren(root,v)
    end
end

function meta:RegisterAllEvents(root)
    self:ProcessChildren(root,root)
end






function meta:addKeyboard(delegate)
    local dispatcher = cc.Director:getInstance():getEventDispatcher();
    local keyListener = cc.EventListenerKeyboard:create()  
    keyListener:registerScriptHandler(function(key) 
        if (delegate.onKeyPressed == nil) then 
            print(string.format("%s:onKeyPressed not implement",delegate.__cname or "delegate"))
        else
            delegate:onKeyPressed(key)
        end
    end,cc.Handler.EVENT_KEYBOARD_PRESSED)
    
    keyListener:registerScriptHandler(function(key) 
        if (delegate.onKeyReleased == nil) then 
            print(string.format("%s:onKeyReleased not implement",delegate.__cname or "delegate"))
        else
           delegate:onKeyReleased(key)
        end
    end,cc.Handler.EVENT_KEYBOARD_RELEASED)  
    
    delegate.keyListener = keyListener;
    dispatcher:addEventListenerWithFixedPriority(keyListener,1)  
end



return meta
