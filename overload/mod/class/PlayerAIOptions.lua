local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"
local Tabs = require "engine.ui.Tabs"
local GraphicMode = require("mod.dialogs.GraphicMode")
local FontPackage = require "engine.FontPackage"

local PlayerAIOptions = {}

-- HACK TO MAKE A MAX_INT
local MAX_INT = 2
while true do
    local nextstep = MAX_INT*2
    if (math.floor(nextstep) == nextstep) and (nextstep-1 ~= nextstep) then
        MAX_INT = nextstep
    else
        break
    end
end
-- END HACK

function PlayerAIOptions.createTab(self)
    local list = {}

    -- maximum runtime (turns)
    local zone = Textzone.new{
        width=self.c_desc.w, height=self.c_desc.h,
        text=string.toTString"Maximum number of turns the AI can run consecutively. The AI can get stuck in loops and is difficult to cancel manually, so adjust this value to match your patience with it."
    }
    list[#list+1] = {
        zone=zone, name=string.toTString"#GOLD##{bold}#Maximum AI runtime#WHITE##{normal}#",
        status=function(item)
            return tostring(config.settings.tome.playerai_max_runtime)
	    end,
	    fct=function(item)
    		game:registerDialog(GetQuantity.new("Enter maximum AI runtime in turns", "",
    		    config.settings.tome.playerai_max_runtime, MAX_INT,
    		    function(qty)
    			    game:saveSettings("tome.playerai_max_runtime", ("tome.playerai_max_runtime = %d\n"):format(qty))
    			    config.settings.tome.playerai_max_runtime = qty
    			    self.c_list:drawItem(item)
    		    end
    		))
    	end
    }

    -- health threshold disable
    zone = Textzone.new{
        width=self.c_desc.w, height=self.c_desc.h,
        text=string.toTString"If character health drops below this percentage, the AI will disable itself and notify you that health is low."
    }
    list[#list+1] = {
        zone=zone, name=string.toTString"#GOLD##{bold}#Disable-AI health threshold#WHITE##{normal}#",
        status=function(item)
            return tostring(config.settings.tome.playerai_health_threshold_stop*100)
	    end,
	    fct=function(item)
    		game:registerDialog(GetQuantity.new("Enter disable-AI health threshold", "From 0% to 100%",
    		    config.settings.tome.playerai_health_threshold_stop*100, 100,
    		    function(qty)
    			    game:saveSettings("tome.playerai_health_threshold_stop", ("tome.playerai_health_threshold_stop = %f\n"):format(qty/100.0))
    			    config.settings.tome.playerai_health_threshold_stop = qty/100.0
    			    self.c_list:drawItem(item)
    		    end
    		))
    	end
    }
    
    -- use hunt state
    zone = Textzone.new{
        width=self.c_desc.w, height=self.c_desc.h,
        text=string.toTString"Experimental AI state to respond to attacks from unseen enemies. Use at your own risk, the AI often gets itself killed with this still."
    }
    list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Use experimental HUNT state#WHITE##{normal}#", status=function(item)
        return tostring(config.settings.tome.playerai_use_hunt  and "enabled" or "disabled")
    end, fct=function(item)
        config.settings.tome.playerai_use_hunt = not config.settings.tome.playerai_use_hunt
        self.c_list:drawItem(item)
    end,}
    
    -- health threshold hunt avoid
    zone = Textzone.new{
        width=self.c_desc.w, height=self.c_desc.h,
        text=string.toTString"If character health drops below this percentage, the AI will attempt to flee attacks from unseen enemies and find a safe place to rest."
    }
    list[#list+1] = {
        zone=zone, name=string.toTString"#GOLD##{bold}#Avoid-combat health threshold#WHITE##{normal}#",
        status=function(item)
            return tostring(config.settings.tome.playerai_health_threshold_avoid*100)
	    end,
	    fct=function(item)
    		game:registerDialog(GetQuantity.new("Enter avoid-combat health threshold", "From 0% to 100%",
    		    config.settings.tome.playerai_health_threshold_avoid*100, 100,
    		    function(qty)
    			    game:saveSettings("tome.playerai_health_threshold_avoid", ("tome.playerai_health_threshold_avoid = %f\n"):format(qty/100.0))
    			    config.settings.tome.playerai_health_threshold_avoid = qty/100.0
    			    self.c_list:drawItem(item)
    		    end
    		))
    	end
    }

    -- hunt avoid timeout
    zone = Textzone.new{
        width=self.c_desc.w, height=self.c_desc.h,
        text=string.toTString"If the AI is out-of-combat and attacked by unseen enemies, it will enter \"hunting\" state. This value is the number of turns the AI continues to hunt (or flee) after the last time it was hit before returning to rest state."
    }
    list[#list+1] = {
        zone=zone, name=string.toTString"#GOLD##{bold}#Hunt state timeout#WHITE##{normal}#",
        status=function(item)
            return tostring(config.settings.tome.playerai_hunt_timeout)
	    end,
	    fct=function(item)
    		game:registerDialog(GetQuantity.new("Enter hunt state timeout", "Number of turns",
    		    config.settings.tome.playerai_hunt_timeout, nil,
    		    function(qty)
    			    game:saveSettings("tome.playerai_hunt_timeout", ("tome.playerai_hunt_timeout = %d\n"):format(qty))
    			    config.settings.tome.playerai_hunt_timeout = qty
    			    self.c_list:drawItem(item)
    		    end
    		))
    	end
    }

    -- actor rank to stop on
    zone = Textzone.new{
        width=self.c_desc.w, height=self.c_desc.h,
        text=string.toTString"AI wil stop on sighting monsters of this rank.\n\n0 = Don't stop (disable this feature)\n10 = Critter\n20 = Normal\n30 = Elite\n32 = Rare\n35 = Unique\n40 = Boss\n50 = Elite Boss\n100 = God\n\nThe savvy player will know that these numbers are 10 times too big. This is because ToME settings do not allow decimals, but ranks 3.2 and 3.5 exist in unmodded ToME."
    }
    list[#list+1] = {
        zone=zone, name=string.toTString"#GOLD##{bold}#Stop on rank#WHITE##{normal}#",
        status=function(item)
            return tostring(config.settings.tome.playerai_stop_rank)
	    end,
	    fct=function(item)
    		game:registerDialog(GetQuantity.new("Enter (decimal) rank to stop on. 10 = normal, 50 = elite boss, 100 = god", "rank number 0-100",
    		    config.settings.tome.playerai_stop_rank, nil,
    		    function(qty)
    			    game:saveSettings("tome.playerai_stop_rank", ("tome.playerai_stop_rank = %d\n"):format(qty))
    			    config.settings.tome.playerai_stop_rank = qty
    			    self.c_list:drawItem(item)
    		    end
    		))
    	end
    }

    return list
end

return PlayerAIOptions