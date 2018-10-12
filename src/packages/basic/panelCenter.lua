-- /**
--  * Created by leo on 2017/11/12.
--  */

-- /**
--  * Created by leo on 16/2/21.
--  */
local meta = {}

local clientEvent = require("utils.graphic");

local panelCenter = {}

local ZORDER = {
    SUB_SCENE_ZORDER = 0,
    BATTLE_ROOM_ZORDER = 3,
    SUB_PANEL_ZORDER = 4,
    COMMON_MASK_ZORDER = 900000,
    WORLD_PANEL_ZORDER = 1000000,
    WORLD_ANIMATION_ZORDER = 1100000,
    MODAL_PANEL_ZORDER = 1200000,
    GLOBAL_FLOATING_PANEL_ZORDER = 1400000,
    LOADING_PANEL_ZORDER = 1500000,
    ALERT_PANEL_ZORDER = 1600000
}

function meta:init ()
    
end

function meta:setMaskNodeHide ()
    self.maskNode:setBackGroundColorOpacity(0);
end

function meta:setMaskNodeShow ()
    self.maskNode:setBackGroundColorOpacity(150);
end

function meta:addClickMaskEvent (maskNode)
    -- maskNode.on('touchstart', function(event)
    --     event:stopPropagation();
    -- end);
    
    -- maskNode.on('touchend', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('touchmove', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('touchcancel', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('mousedown', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('mouseenter', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('mousemove', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('mouseleave', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('touchend', function(event)
    --     event:stopPropagation();
    -- end)
    
    -- maskNode.on('mousewheel', function(event)
    --     event:stopPropagation();
    -- end)
end

function meta:initGraphic (scene, maskNode, uiRoot)
    self.subScenes = {}
    self.subPanels = {}
    self.args = {}
    
    self.newestSubPanelName = "";
    
    self.runningScene = scene;
    
    self:initEventDispatcherStack();
    
    self.curActiveSubScene = nil;
    self.maskNode = maskNode;
    self.maskNode:setVisible(false);
    self.maskNode.width = display.width;
    self.maskNode.height = display.height;
    
    self:addClickMaskEvent(self.maskNode);
    
    self.curCommonSubPanelZorder = ZORDER.WORLD_PANEL_ZORDER;
    self.curModalSubPanelZorder = ZORDER.MODAL_PANEL_ZORDER;
    
    self:registerEvent();
end

function meta:getWinSize ()
    if (self.curActiveSubScene) then
        return self.curActiveSubScene:getContentSize();
    end
    
    return self.runningScene:getContentSize();
end

function meta:initEventDispatcherStack ()
    self.subPanelStack = {};
    
    self.curActiveSubScene = nil;
    self.nextSubScene = nil;
    
    self.subPanelStackIndex = -1;
    
    self.subSceneStack = {};
    self.subSceneStackIndex = 0;
    
    self.eventDispatcherStack = {};
    self.eventDispatcherStackIndex = 0;
end

function meta:pushEventDispatcher (eventDispatcher)
    self.eventDispatcherStackIndex = self.eventDispatcherStackIndex + 1;
    self.eventDispatcherStack[self.eventDispatcherStackIndex] = eventDispatcher;
    
    cc.director:setEventDispatcher(eventDispatcher);
end

function meta:popEventDispatcher ()
    self.eventDispatcherStackIndex = self.eventDispatcherStackIndex - 1;
    local eventDispatcher = self.eventDispatcherStack[self.eventDispatcherStackIndex];
    
    cc.director:setEventDispatcher(eventDispatcher);
end

function meta:getSubScene (name)
    local subScene = self.subScenes[name];
    
    if (not subScene) then
        local director = cc.director;
        local curEventDispatcher = cc.director:getEventDispatcher();
        
        director:setEventDispatcher(self.originEventDispatcher);
        
        subScene = subSceneFactory.create(name);
        
        self.subScenes[name] = subScene;
        
        self.runningScene:addChild(subScene, ZORDER.SUB_SCENE_ZORDER);
        self.runningScene:sortAllChildren();
        subScene:setVisible(false);
        
        director:setEventDispatcher(curEventDispatcher);
    end
    
    return subScene;
end

function meta:getSubPanel (name)
    return self.subPanels[name];
end

-- 判断panel是否显示
function meta:getPanelIsVisible (name)
    if (self.getSubPanel(name) and self.getSubPanel(name) and self.getSubPanel(name).active) then
        return true;
    end
    
    return false;
end

function meta:getAndCreateSubPanel (name, cb)
    local parent;
    
    if (not self.curActiveSubScene) then
        parent = self.runningScene;
        if (not parent) then
            parent = cc.Director:getInstance():getRunningScene();
        end
    else
        parent = self.curActiveSubScene;
    end

    -- for i,v in ipairs(parent:getChildren()) do
    --     print(v:getName())
    -- end
    
    local function loadOverCallFunc (subPanel)
        if (not subPanel) then
            cc.error("can not find sub panel class ", name);
            return;
        end
        -- subPanel.setName(name.replace(/\--g, "."));
        local strName = string.split(name,".")
        subPanel:setName(strName[#strName])
        -- if (panelComponent.customOrder)
        --     parent = self.runningScene;
        -- }
        
        if (subPanel:getParent() ~= parent) then
            -- subPanel.parent = parent;
            parent:addChild(subPanel)
            parent:setLocalZOrder(ZORDER.MODAL_PANEL_ZORDER);
            -- if (panelComponent.isModal) then
            --     parent:setLocalZOrder(ZORDER.MODAL_PANEL_ZORDER);
            -- elseif (panelComponent.customOrder) then
            --     parent:setLocalZOrder(panelComponent.customOrder);
            -- else
            --     parent:setLocalZOrder(ZORDER.WORLD_PANEL_ZORDER);
            -- end
        end
        
        subPanel:setVisible(false);
        
        cb(subPanel);
    end
    
    local subPanel = false

    local strName = string.split(name,".")
    strName = (strName[#strName])

    if self.subPanels[strName] then
        subPanel = self.subPanels[strName]
    end
    if (not subPanel) then
        local pathName = name;
        -- local paths = {};
        -- if (cc.loader._resources.getAllPaths) then
        --     -- creator 1.6.2的写法
        --     paths = cc.loader._resources.getAllPaths();
        -- else
        --     paths = Object.keys(cc.loader._resources._pathToUuid);
        -- end
        -- for i = 0, #paths, 1 do
        --     local aliasPath = paths[i];
        --     local aliasArr = aliasPath.split("/");
        --     if (aliasArr[aliasArr.length - 1] == name) then
        --         pathName = aliasPath;
        --         break;
        --     end
        -- end
        local subPanel = require(pathName).create()
        if not subPanel then
            print("subPanel创建失败######################")
        else
            self.subPanels[strName] = subPanel;
            loadOverCallFunc(subPanel);
        end
    else
 
        local subPanel = self.subPanels[strName];
        loadOverCallFunc(subPanel);
    end
end

function meta:finishChangeSubScene ()
    if (self.curActiveSubScene) then
        self.curActiveSubScene:hide(self.nextSubScene.getName());
        self.curActiveSubScene:setPosition(0, 0);
    end
    
    self.curActiveSubScene = self.nextSubScene;
    self.nextSubScene = nil;
    
    self.subPanelStack = {};
    self.subPanelStackIndex = -1;
    cc.eventManager:setEnabled(true);
end

function meta:registerEvent ()
    clientEvent:RegisterEvent("showSubScene", function(...)
        self.args = {...}
        subSceneName = self.args[1]
        self.hideAllSubPanel();
        cc.log("show_world_subScene:" .. subSceneName);
        
        local subScene = self.getSubScene(subSceneName);
        if (subScene:isVisible()) then
            return;
        end
        
        self.nextSubScene = subScene;
        
        if (self.curActiveSubScene) then
            if (subScene.isRememberFromScene()) then
                self.pushSubScene(self.curActiveSubScene);
            else
                self.subSceneStackIndex = 0;
            end
        end
        
        self.finishChangeSubScene();
        
        local args = {};
        for i = 2, #self.args do
            -- args.push(self.args[i]);
            table.insert(args, self.args[i])
        end
        
        -- subScene.show.apply(subScene, args);
        subScene:Show(args)
    end)
    
    clientEvent:RegisterEvent("showPanel", function(panelName,...)
        self.args = {...}
        local i;
        
        self:getAndCreateSubPanel(panelName, function(panel)
            if (not panel) then
                cc.error("can't find " .. panelName);
                return;
            end
            
            print("******showPanel:",panelName);
            
            self.newestSubPanelName = panelName;
            
            if (panel:isVisible()) then
                clientEvent:dispatchEvent("hidePanel", panelName);
            end
            
            i = 0;
            local subPanel;
            local panelComponent = panel
            if (panelComponent.isModal) then
                local index = -1;
                for i = 0, #self.subPanelStackIndex do
                    subPanel = self.subPanelStack[i];
                    if (subPanel:getName() == panel:getName()) then
                        index = i;
                        break;
                    end
                    
                end
                
                if (index ~= -1) then
                    self.subPanelStack.splice(index, 1);
                    self.subPanelStackIndex = self.subPanelStackIndex - 1;
                    -- for (i = index; i < self.subPanelStackIndex; i++)
                    --     subPanel = self.subPanelStack[i];
                    --     subPanel:setLocalZOrder(subPanel.getLocalZOrder());
                    -- }
                end
                
                self.curModalSubPanelZorder = self.curModalSubPanelZorder + 1;
                
                self:pushSubPanel(panel);
                panel:setLocalZOrder(self.curModalSubPanelZorder);
            elseif (panelComponent.customOrder) then
                panel:setLocalZOrder(panelComponent.customOrder);
            else
                self.curCommonSubPanelZorder = self.curCommonSubPanelZorder + 1;
                panel:setLocalZOrder(self.curCommonSubPanelZorder);
            end
            
            if (panelComponent.Show) then
                panel:Show(unpack(self.args))
            end
        end)
    end)
    
    clientEvent:RegisterEvent("hidePanel", function(panelName,...)
        self.args = {...}
        -- local panelName = self.args[1]
        
        self:getAndCreateSubPanel(panelName, function(panel)
            local panelComponent = panel

            if not panel  then
                return
            end
            
            local i
            -- 隐藏遮罩层;
            local subPanel
            
            repeat
                if (panelComponent.isModal) then
                    subPanel = self.subPanelStack[self.subPanelStackIndex]
                    if (not subPanel and self.subPanelStack.length > 0) then
                        self.subPanelStackIndex = self.subPanelStack.length - 1
                        subPanel = self.subPanelStack[self.subPanelStackIndex]
                    end
                    
                    if (not subPanel) then
                        break
                    end
                    
                    if (subPanel.getName() ~= panelName) then
                        local index = -1
                        for i = 0, #self.subPanelStackIndex do
                            subPanel = self.subPanelStack[i];
                            if (subPanel.getName() == panel.getName()) then
                                index = i
                                break
                            end
                        end
                        
                        if (index >= 0) then
                            self.subPanelStack.splice(index, 1)
                            self.subPanelStackIndex = self.subPanelStackIndex - 1
                            self.curModalSubPanelZorder = self.curModalSubPanelZorder - 1
                        end
                        
                        break
                    end
                    
                    self.popSubPanel()
                    subPanel = self.subPanelStack[self.subPanelStackIndex]
                    self.curModalSubPanelZorder = self.curModalSubPanelZorder - 1
                    
                    if (subPanel) then
                        self.showMaskNode(subPanel)
                    else
                        self.maskNode:setVisible(false)
                    end
                    
                end
            until(0)

            if (panelComponent.hide) then
                panel:Hide(unpack(self.args))
                panel:unscheduleUpdate()
                print("******hidePanel:",panelName)
                -- local paneln = string.split(panelName,".")
                -- paneln = paneln[#paneln]
                -- if self.subPanels[paneln] then
                --     self.subPanels[paneln]:removeFromParent()
                --     self.subPanels[paneln] = nil
                -- end
            end
        end)
    end)
end

function meta:pushSubPanel (subPanel)
    self.subPanelStackIndex = self.subPanelStackIndex + 1;
    self.subPanelStack[self.subPanelStackIndex] = subPanel;
    
    self.showMaskNode(subPanel);
end

function meta:showMaskNode (subPanel)
    self.maskNode.parent = subPanel:getParent();
    self.maskNode:setLocalZOrder(self.curModalSubPanelZorder - 1);
    self.maskNode:setVisible(true);
end

function meta:popSubPanel ()
    local subPanel = self.subPanelStack.splice(self.subPanelStackIndex, 1)[0];
    self.subPanelStackIndex = self.subPanelStackIndex - 1;
    
    return subPanel;
end

function meta:getSubPanelStack ()
    return self.subPanelStack;
end

function meta:hideAllSubPanel ()
    local subPanelStack = self.subPanelStack;
    for idx = self.subPanelStackIndex, 1, -1 do
        clientEvent:dispatchEvent("hidePanel", subPanelStack[idx]["__name"]);
    end
    
    self.subPanelStackIndex = -1;
end

-- /**
--  * 获取最新的subpanel的名称，主要部分界面在初始化的时候需要了解当前最新的subPanel是谁
--  * */
function meta:getNewestPanel ()
    return self.newestSubPanelName;
end

function meta:getCurSubScene ()
    return self.curActiveSubScene;
end

-- 晃panel rootNode:panel的rootNode, time:s
function meta:shakePanel (rootNode, time)
    local perTime = time / 4;
    rootNode.runAction(cc.sequence(
        cc.delayTime(0.07),
        cc.scaleTo(perTime, 1.01, 1.01),
        cc.jumpBy(perTime, cc.p(0, 0), 5, 12),
        cc.scaleTo(perTime, 0.99, 0.99),
    cc.scaleTo(perTime, 1, 1)));
end

return meta;

