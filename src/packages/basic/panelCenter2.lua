-- /**
--  * Created by leo on 16/2/21.
--  */

local meta = {}

local panelCenter = {}
local panelCenter = {};

local panelUtil = require("util.panelUtil");
local clientEvent = require("basic.clientEvent");
local subSceneFactory = require("basic.subSceneFactory");

local cacheEventLib = {};

function panelCenter:init ()
    
end

function panelCenter:setMaskNodeHide ()
    self.maskNode.setBackGroundColorOpacity(0);
end

function panelCenter:setMaskNodeShow ()
    self.maskNode.setBackGroundColorOpacity(150);
end

function panelCenter:initGraphic (scene)
    
    self.subScenes = {};
    self.subPanels = {};
    
    self.newestSubPanelName = "";
    
    self.runningScene = scene;
    
    self.initEventDispatcherStack();
    
    self.maskNode = ccui.layout:create();
    self.maskNode:setContentSize(1136, 640);
    self.maskNode:setBackGroundColor(panelUtil.getColor4B(0x000000));
    self.maskNode:setBackGroundColorOpacity(150);
    self.maskNode:setBackGroundColorType(ccui.Layout.BG_COLOR_SOLID);
    self.maskNode:setTouchEnabled(true);
    self.maskNode:setVisible(false);
    self.runningScene:addChild(self.maskNode, COMMON_MASK_ZORDER);
    
    self.curCommonSubPanelZorder = WORLD_PANEL_ZORDER;
    self.curModalSubPanelZorder = MODAL_PANEL_ZORDER;
    
    self:registerEvent();
    require("logic.h5Optimize").init();
    
    self.panelOpenConfig = {};
    local configManager = require("shared.configManager");
    local bntCondData = configManager.getTable("btnCond");
    for key, v in bntCondData do
        if (not bntCondData[key]["needFinish"]) then
            
            if (bntCondData[key]["panelName"].length > 0) then
                
                if (not self.panelOpenConfig[bntCondData[key]["panelName"]]) then
                    self.panelOpenConfig[bntCondData[key]["panelName"]] = bntCondData[key];
                end
            end
        end
        
    end
    
end

function panelCenter:initEventDispatcherStack ()
    self.subPanelStack = {};
    
    self.curActiveSubScene = nil;
    self.nextSubScene = nil;
    
    self.originEventDispatcher = cc.director.getEventDispatcher();
    
    self.subPanelStackIndex = -1;
    
    self.subSceneStack = {};
    self.subSceneStackIndex = 0;
    
    self.eventDispatcherStack = {};
    self.eventDispatcherStackIndex = 0;
end

function panelCenter:pushEventDispatcher (eventDispatcher)
    self.eventDispatcherStackIndex = self.eventDispatcherStackIndex + 1;
    self.eventDispatcherStack[self.eventDispatcherStackIndex] = eventDispatcher;
    
    cc.director.setEventDispatcher(eventDispatcher);
end

function panelCenter:popEventDispatcher ()
    self.eventDispatcherStackIndex = self.eventDispatcherStackIndex - 1;
    local eventDispatcher = self.eventDispatcherStack[self.eventDispatcherStackIndex];
    
    cc.director.setEventDispatcher(eventDispatcher);
end

function panelCenter:getSubScene (name)
    local subScene = self.subScenes[name];
    
    if (not subScene) then
        
        local director = cc.director;
        local curEventDispatcher = cc.director.getEventDispatcher();
        
        director.setEventDispatcher(self.originEventDispatcher);
        
        subScene = subSceneFactory.create(name);
        
        self.subScenes[name] = subScene;
        
        self.runningScene.addChild(subScene.getRootNode(), SUB_SCENE_ZORDER);
        self.runningScene.sortAllChildren();
        subScene.getRootNode().setVisible(false);
        
        director.setEventDispatcher(curEventDispatcher);
    end
    
    return subScene;
end

function panelCenter:getSubPanel (name)
    return self.subPanels[name];
end

-- 判断panel是否显示
function panelCenter:getPanelIsVisible (name)
    if (self.getSubPanel(name) and self.getSubPanel(name).rootNode and self.getSubPanel(name).isVisible()) then
        return true;
    end
    
    return false;
end

-- -- 采取new出来的subpanel，不缓存
-- -- name为全局路径（如：subPanel.xiuLianTaiSubPanel）
function panelCenter:newSubPanel (name, json, parent)
    local splitNameSpace = name.split(".");
    local item = window;
    for i = 0, #splitNameSpace, 1 do
        item = item[splitNameSpace[i]];
        if (typeof (item) == "undefined") then
            break;
        end
    end
    
    local subPanel = nil;
    if (item) then
        subPanel = require(name);
        
        if (subPanel) then
            subPanel = subPanel.create();
        end
        
        if (not subPanel) then
            subPanel = require("basic.panel").create();
            subPanel.setName(name);
            subPanel.rootNode = cc.CSLoader.createNode(json, subPanel);
        end
        
        if (not subPanel) then
            cc.warn("can not find sub panel class ", name);
            return nil;
        end
        
        subPanel.init();
        subPanel.setName(name);
        
        parent:addChild(subPanel.rootNode);
        
        return subPanel;
    end
    
    function panelCenter:getAndCreateSubPanel (name)
        local parent;
        
        if (not self.curActiveSubScene) then
            parent = self.runningScene;
            if (not parent) then
                parent = cc.director.getRunningScene();
            else
                parent = self.curActiveSubScene.rootNode;
            end
        end
        
        local subPanel = self.subPanels[name];
        
        if (not subPanel) then
            local splitNameSpace = name.split(".");
            local item = window["ui"];
            for i = 0, #splitNameSpace do
                item = item[splitNameSpace[i]];
            end
            
            if (item) then
                local newName = "ui." + name;
                subPanel = require(newName);
            end
            
            if (not subPanel) then
                subPanel = require("basic.panel").create();
                subPanel.setName(name);
                subPanel.rootNode = cc.CSLoader.createNode("ui/" + name + ".json", subPanel);
            end
            
            if (not subPanel) then
                cc.warn("can not find sub panel class ", name);
                return;
            end
            
            if (subPanel.customOrder) then
                parent = self.runningScene;
            end
            
            subPanel.setName(name);
            
            local director = cc.director;
            local curEventDispatcher = cc.director.getEventDispatcher();
            director.setEventDispatcher(self.originEventDispatcher);
            
            if (subPanel.isModal) then
                subPanel.init();
                parent.addChild(subPanel.getRootNode(), MODAL_PANEL_ZORDER);
                
            elseif (subPanel.customOrder) then
                subPanel.init();
                self.runningScene.addChild(subPanel.getRootNode(), subPanel.customOrder);
            else
                subPanel.init();
                parent.addChild(subPanel.getRootNode(), WORLD_PANEL_ZORDER);
            end
            
            director.setEventDispatcher(curEventDispatcher);
            
            subPanel.getRootNode().setVisible(false);
            self.subPanels[name] = subPanel;
        else
            if (subPanel.customOrder) then
                parent = self.runningScene;
            end
            
            if (subPanel.getRootNode().getParent() ~= parent) then
                -- subPanel.getRootNode().removeFromParent(false);
                -- delete self.subPanels[name];
                -- return self.getAndCreateSubPanel(name);
                
                subPanel.getRootNode().retain();
                subPanel.getRootNode().removeFromParent(false);
                cc.eventManager.pauseTarget(subPanel.getRootNode(), true);
                if (subPanel.isModal) then
                    parent.addChild(subPanel.getRootNode(), MODAL_PANEL_ZORDER);
                else if (subPanel.customOrder) then
                        subPanel.init();
                        parent.addChild(subPanel.getRootNode(), subPanel.customOrder);
                    else
                        parent.addChild(subPanel.getRootNode(), WORLD_PANEL_ZORDER);
                    end
                    
                    cc.eventManager.resumeTarget(subPanel.getRootNode(), true);
                    
                    subPanel.getRootNode().release();
                end
                
            end
            
            return subPanel;
        end
    end
    
    function panelCenter:finishChangeSubScene ()
        if (self.curActiveSubScene) then
            self.curActiveSubScene.hide(self.nextSubScene.getName());
            self.curActiveSubScene.getRootNode().setPosition(0, 0);
        end
        
        if (self.getPanelIsVisible("battlePanel")) then
            clientEvent.dispatchEvent("hideSubPanel", "battlePanel");
        end
        
        if (self.getPanelIsVisible("h5BattlePanel")) then
            clientEvent.dispatchEvent("hideSubPanel", "h5BattlePanel");
        end
        
        -- 如果第一次进入游戏 等场景判断后才执行这个判断
        if (require("logic.gameArea").isInitMapScene) then
            if (self.nextSubScene.getName() == "newJiangHuSubScene") then
                require("logic.gameArea").isInHangUpMap = true;
            else
                require("logic.gameArea").isInHangUpMap = false;
            end
            
            self.curActiveSubScene = self.nextSubScene;
            self.nextSubScene = nil;
            
            self.subPanelStack = {};
            self.subPanelStackIndex = -1;
            cc.eventManager.setEnabled(true);
        end
        
    end
    
    function panelCenter:dispatchCacheEvent (eventName, argName)
        -- 用于SubScene之间的事件交互
        if (cacheEventLib[eventName]) then
            local eventLib = cacheEventLib[eventName];
            local avalibleEvent = {};
            local key;
            for key = 0, #eventLib do
                if (eventLib[key].judgeFunc(argName)) then
                    avalibleEvent.push(eventLib[key]);
                    -- delete eventLib[key];
                    eventLib.splice(key, 1);
                    key = key - 1;
                end
                
            end
            
            for key, v in avalibleEvent do
                if (not avalibleEvent[key].args) then
                    avalibleEvent[key].args = {};
                end
                
                avalibleEvent[key].args.unshift(avalibleEvent[key].eventName);
                clientEvent.dispatchEvent.apply(clientEvent, avalibleEvent[key].args);
            end
        end
    end
    
    function panelCenter:registerEvent ()
        
        clientEvent.registerEvent("showSubScene", function(subSceneName)
            self.hideAllSubPanel();
            cc.log("show_world_subScene:" + subSceneName);
            
            local subScene = self.getSubScene(subSceneName);
            if (subScene.isVisible()) then
                return;
            end
            
            self.nextSubScene = subScene;
            
            if (self.curActiveSubScene) then
                if (subScene.isRememberFromScene()) then
                    self.pushSubScene(self.curActiveSubScene);
                else
                    self.subSceneStackIndex = 0;
                end
                
                self.finishChangeSubScene();
                
                local args = {};
                for i = 1, arguments do
                    args.push(arguments[i]);
                end
                
                subScene.show.apply(subScene, args);
                
                self.dispatchCacheEvent("showSubScene", subSceneName);
                
            end
        end)
        
        clientEvent.registerEvent("replaceSubScene", function(subSceneName)
            self.hideAllSubPanel();
            if (self.curActiveSubScene) then
                self.curActiveSubScene.hide();
                -- 不能cleanup，否则挂在这个subScene下的所有panel事件都会消失，
                -- self.curActiveSubScene.rootNode.removeFromParent(true);
                -- delete self.subScenes[self.curActiveSubScene.getName()];
                
                self.curActiveSubScene = nil;
            end
            
            local subScene = self.getSubScene(subSceneName);
            if (subScene.isVisible()) then
                return;
            end
            
            self.nextSubScene = subScene;
            self.finishChangeSubScene();
            
            local args = {};
            for i = 1, arguments do
                args.push(arguments[i]);
            end
            
            subScene.show.apply(subScene, args);
            
            self.dispatchCacheEvent("replaceSubScene", subSceneName);
        end)
        
        clientEvent.registerEvent("hideSubScene", function ()
            self.hideAllSubPanel();
            local lastSubScene = self.popSubScene();
            
            if (self.curActiveSubScene) then
                self.curActiveSubScene.hide(lastSubScene and lastSubScene.getName() or "main_sub_scene");
                if (not cc.sys.isNative) then
                    self.curActiveSubScene.rootNode.removeFromParent(true);
                    -- delete self.subScenes[self.curActiveSubScene.getName()];
                    table.remove(self.subScenes, self.curActiveSubScene.getName())
                end
                self.curActiveSubScene = nil;
            end
            
            self.subPanelStack = {};
            self.subPanelStackIndex = -1;
            
            if (lastSubScene) then
                self.curActiveSubScene = lastSubScene;
                lastSubScene.show();
            else
                -- 不显示任何子场景
                cc.error("no sub scene hide");
            end
            
        end);
        
        clientEvent.registerEvent("switchSubPanel", function(panelName)
            local panel = self.getAndCreateSubPanel(panelName);
            if (not panel) then
                cc.error("can't find " + panelName);
                return;
            end
            
            if (panel.isVisible()) then
                clientEvent.dispatchEvent("hideSubPanel", panelName);
            else
                clientEvent.dispatchEvent("showSubPanel", panelName);
            end
        end);
        clientEvent.registerEvent("showSubPanel", function(panelName)
            local user = require("logic.user");
            cc.log("show_subPanel:" + panelName);
            
            if (kf.isRelease and self.panelOpenConfig[panelName]) then
                local storyArr = require("logic.event").getFinishStory();
                local panelConfig = self.panelOpenConfig[panelName];
                if (panelConfig["needLevel"] and
                    require("logic.user").userGameInfo["level"] < panelConfig["needLevel"] and
                storyArr.indexOf(panelConfig["needFinish"]) == -1) then
                clientEvent.dispatchEvent("showSubPanel", "tiShiKuangPanel", require("util.lang").get("levelNoEnough"));
                return;
            end
            
            if (panelName == "menPaiManagePanel") then
                if (not user.userFaction or not user.userFaction["factionId"]) then
                    clientEvent.dispatchEvent("showSubPanel", "tiShiKuangPanel", require("util.lang").get("haveNotJoinMenPai"));
                    return;
                end
            end
            
            local panel = self.getAndCreateSubPanel(panelName);
            if (not panel) then
                cc.error("can't find " + panelName);
                return;
            end
            
            self.newestSubPanelName = panelName;
            
            if (panel.isVisible()) then
                clientEvent.dispatchEvent("hideSubPanel", panelName);
            end
            
            local i = 0;
            local subPanel;
            if (panel.isModal) then
                local index = -1;
                for i = 1, #self.subPanelStackIndex do
                    subPanel = self.subPanelStack[i];
                    if (subPanel.getName() == panel.getName()) then
                        index = i;
                        break;
                    end
                end
                
                if (index ~= -1) then
                    self.subPanelStack.splice(index, 1);
                    self.subPanelStackIndex = self.subPanelStackIndex - 1;
                    -- for (i = index; i < self.subPanelStackIndex do
                    -- subPanel = self.subPanelStack[i];
                    -- subPanel.rootNode.setLocalZOrder(subPanel.rootNode.getLocalZOrder());
                    -- end
                    
                    self.curModalSubPanelZorder = self.curModalSubPanelZorder + 1;
                    
                    self.pushSubPanel(panel);
                    
                    -- 判断是否淡入出现
                    local noNeedPanel = {"huaShanLunJianPanel"}; -- 不需要淡入的panel
                    panel.rootNode.setLocalZOrder(self.curModalSubPanelZorder);
                end
                
                if (noNeedPanel.indexOf(panel.getName()) == -1) then
                    panel.rootNode.setOpacity(0);
                    -- 进行淡入
                    if (panel and panel.rootNode)then
                        local action = cc.fadeIn(0.4);
                        if (panel.rootNode.bindRenderTexture) then
                            -- 有的界面是个画布
                            -- local idv = setInterval(function ()
                            --     if (not panel or panel.rootNode.getOpacity() > 254 or
                            --     os.time() - panel.idvStartTime > 10000)
                            --     clearInterval(panel.idv);
                            --     panel.idv = nil;
                            -- }
                            local idv = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (...) --
                                if (not panel or panel.rootNode.getOpacity() > 254 or
                                os.time() - panel.idvStartTime > 10000) then
                                if idv then
                                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(idv) --關閉執行
                                    idv = nil
                                end
                                panel.idv = nil;
                            end
                            require("util.renderHelp").createVirtualTexture(panel.rootNode,
                                panel.rootNode.bindRenderTexture.absPos,
                            panel.rootNode.bindRenderTexture.customSize);
                        end, 1, false)
                        
                        panel.idv = idv;
                        panel.idvStartTime = os.time(); -- 时间过长也要删除 防止没删
                    end
                    
                    panel.rootNode.runAction(action);
                elseif (panel.idv) then
                    -- clearInterval(panel.idv);
                    -- panel.idv = nil;
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(panel.idv) --關閉執行
                    panel.idv = nil
                end
                -- .bind(self), 10);
            else
                if (panel.customOrder) then
                    panel.rootNode.setLocalZOrder(panel.customOrder);
                else
                    self.curCommonSubPanelZorder = self.curCommonSubPanelZorder + 1;
                    panel.rootNode.setLocalZOrder(self.curCommonSubPanelZorder);
                end
                
            end
            
            -- pass arguments to panel.show except panelName
            local args = {};
            for i = 1, arguments.length do
                args[args.length] = arguments[i];
            end
            
            panel.show.apply(panel, args);
            
            self.dispatchCacheEvent("showSubPanel", panelName);
            
            local sceneManager = require("basic.sceneManager");
            if ((sceneManager.getCurrentSceneName() == "jianghu" or
            sceneManager.getCurrentSceneName() == "battle")) then
            local guide = require("logic.guide");
            for idx = 0, #guide.aryGamePanels do
                if (guide.aryGamePanels[idx] == panelName) then
                    guide.aryGamePanels.splice(idx, 1);
                end
                
                if (panelName ~= "jianghuHoldPanel") then-- 江湖场景这个特殊处理下
                    guide.aryGamePanels.push(panelName);
                else
                    guide.aryGamePanels.splice(0, 0, panelName);
                end
                
                if (panelName ~= "newbieGuide") then
                    guide.enterGuide();
                end
                
            end
            
            require("debug.fileSync").recordPanelArgs(panelName, args);
            
            -- 判断是否h5
            if (not cc.sys.isNative) then
                require("logic.h5Optimize").h5ShowSubPanel(panelName);
            end
            
        end)
        
        clientEvent.registerEvent("hideSubPanel", function(panelName)
            local panel = self.getAndCreateSubPanel(panelName);
            if (not panel or (not panel.isVisible() and not panel.isModal)) then
                return;
            end
            
            local i;
            -- 隐藏遮罩层;
            local subPanel;
            repeat
                if (panel.isModal) then
                    subPanel = self.subPanelStack[self.subPanelStackIndex];
                    if (not subPanel and self.subPanelStack.length > 0) then
                        self.subPanelStackIndex = self.subPanelStack.length - 1;
                        subPanel = self.subPanelStack[self.subPanelStackIndex];
                        if (not kf.isOnlineVersion) then
                            debug();
                        end
                        
                    end
                    
                    if (not subPanel) then
                        break;
                    end
                    
                    if (subPanel.getName() ~= panelName) then
                        local index = -1;
                        for i = 0, #self.subPanelStackIndex do
                            subPanel = self.subPanelStack[i];
                            if (subPanel.getName() == panel.getName()) then
                                index = i;
                                break;
                            end
                            
                            if (index >= 0) then
                                self.subPanelStack.splice(index, 1);
                                self.subPanelStackIndex = self.subPanelStackIndex - 1;
                                self.curModalSubPanelZorder = self.curModalSubPanelZorder - 1;
                            end
                            
                            break;
                        end
                        
                    end
                    
                    self.popSubPanel();
                    subPanel = self.subPanelStack[self.subPanelStackIndex];
                    self.curModalSubPanelZorder = self.curModalSubPanelZorder - 1;
                    
                    if (subPanel) then
                        self.showMaskNode(subPanel);
                    else
                        self.maskNode.setVisible(false);
                    end
                    
                else
                    -- self.curCommonSubPanelZorder = self.curCommonSubPanelZorder - 1;
                end
                
            until(0);
            
            local sceneManager = require("basic.sceneManager");
            
            if (self.subPanelStack.length <= 0 and sceneManager.getCurrentSceneName() == "jianghu") then
                self.hideSubSceneUIRoot(true);
            end
            
            -- pass all arguments to prompt_panel except panel name
            local args = {};
            for i = 1, arguments.length do
                args[args.length] = arguments[i];
            end
            
            panel.hide.apply(panel, args);
            
            self.dispatchCacheEvent("hideSubPanel", panelName);
            
            if ((sceneManager.getCurrentSceneName() == "jianghu" or
            sceneManager.getCurrentSceneName() == "battle")) then
            local guide = require("logic.guide");
            for idx = 0, #guide.aryGamePanels do
                if (guide.aryGamePanels[idx] == panelName) then
                    guide.aryGamePanels.splice(idx, 1);
                end
                if (panelName ~= "newbieGuide") then
                    guide.enterGuide();
                end
            end
            
        end)
    end
    
    -- 性能优化用
    function panelCenter:hideSubSceneUIRoot (bool)
        if (not bool) then
            bool = false;
        else
            bool = true;
        end
        
        local jianghuHoldPanel panelCenter:getSubPanel("jianghuHoldPanel");
        if (jianghuHoldPanel and jianghuHoldPanel.getRootNode() and jianghuHoldPanel.getRootNode().isVisible()) then
            jianghuHoldPanel.showAndHideSubPanels(bool);
        end
        
        -- 在挂机界面 直接隐藏地图
        if (require("logic.gameArea").isInHangUpMap and self.curActiveSubScene and
        self.curActiveSubScene.mainBgSubPanel and self.curActiveSubScene.mainBgSubPanel.rootNode) then
        if (bool) then
            self.curActiveSubScene.mainBgSubPanel.rootNode.setVisible(true);
        else
            self.curActiveSubScene.mainBgSubPanel.rootNode.setVisible(false);
        end
    end
    
    function panelCenter:pushSubScene (subScene)
        self.subSceneStackIndex = self.subSceneStackIndex + 1;
        self.subSceneStack[self.subSceneStackIndex] = subScene;
    end
    
    function panelCenter:popSubScene ()
        if (self.subSceneStackIndex <= 0) then
            return nil;
        end
        
        local subScene = self.subSceneStack[self.subSceneStackIndex];
        self.subSceneStackIndex = self.subSceneStackIndex - 1;
        self.subSceneStack.length = self.subSceneStack.length - 1;
        return subScene;
    end
    
    function panelCenter:pushSubPanel (subPanel)
        self.subPanelStackIndex = self.subPanelStackIndex + 1;
        self.subPanelStack[self.subPanelStackIndex] = subPanel;
        
        self.showMaskNode(subPanel);
    end
    
    function panelCenter:showMaskNode (subPanel)
        self.maskNode.retain();
        self.maskNode.removeFromParent(false);
        subPanel.getRootNode().getParent().addChild(self.maskNode, self.curModalSubPanelZorder - 1);
        self.maskNode.release();
        self.maskNode.setVisible(true);
        
        -- 为了修复点击事件层级关系不一致问题而加，典型案例。在战斗结束后一直狂点屏幕，结算界面无法点击
        setTimeout(function ()
            self.maskNode.setTouchEnabled(false);
            self.maskNode.setTouchEnabled(true);
        end, 100);
    end
    
    function panelCenter:popSubPanel ()
        local subPanel = self.subPanelStack.splice(self.subPanelStackIndex, 1)[0];
        self.subPanelStackIndex = self.subPanelStackIndex - 1;
        
        return subPanel;
    end
    
    function panelCenter:getSubPanelStack ()
        return self.subPanelStack;
    end
    
    function panelCenter:hideAllSubPanel ()
        local subPanelStack = self.subPanelStack;
        for idx = self.subPanelStackIndex, 1, -1 do
            clientEvent.dispatchEvent("hideSubPanel", subPanelStack[idx]["__name"]);
        end
        
        self.subPanelStackIndex = -1;
    end
    
    -- /**
    -- * 获取最新的subpanel的名称，主要部分界面在初始化的时候需要了解当前最新的subPanel是谁
    -- * */
    function panelCenter:getNewestPanel ()
        return self.newestSubPanelName;
    end
    
    function panelCenter:getCurSubScene ()
        return self.curActiveSubScene;
    end
    
    -- 晃panel rootNode:panel的rootNode, time:s
    function panelCenter:shakePanel (rootNode, time)
        local perTime = time / 4;
        rootNode.runAction(cc.sequence(
            cc.delayTime(0.07),
            cc.scaleTo(perTime, 1.01, 1.01),
            cc.jumpBy(perTime, cc.p(0, 0), 5, 12),
            cc.scaleTo(perTime, 0.99, 0.99),
        cc.scaleTo(perTime, 1, 1)));
    end
    
    function panelCenter:cacheClientEvent (clientEventName, judgeFuncArgs, eventName, args)
        if (not cacheEventLib[clientEventName]) then
            cacheEventLib[clientEventName] = {};
        end
        
        if (type(judgeFuncArgs) == "string") then
            local obj = {eventName = eventName, args = args, judgeFunc = function(name)
                return name == judgeFuncArgs;
            end}
            table.insert(cacheEventLib, clientEventName, obj)
        else
            local obj = {eventName = eventName, args = args, judgeFunc = judgeFuncArgs}
            table.insert(cacheEventLib, clientEventName, obj)
        end
    end
    
    return panelCenter;
    
