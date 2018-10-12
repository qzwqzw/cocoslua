-- local Plus = require("zeromvc.core.Plus")
local commonBase = {}


------------------------------------------------------------------puls\
--priority设置优先级
function commonBase:scheduleUpdateWithPriorityLua(node, callback ,delaytime,priority)
    local frame = 0
    local time = os.time()
    frame = time
    priority = priority or 100000
    delaytime = delaytime or 1
    node:scheduleUpdateWithPriorityLua(function ( dt )
        time = time + dt
        if time >= frame + delaytime then
            frame = frame + delaytime
            callback()
        end
    end,priority)
end


return commonBase
