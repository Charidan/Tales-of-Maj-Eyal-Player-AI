local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"
local Tabs = require "engine.ui.Tabs"
local GraphicMode = require("mod.dialogs.GraphicMode")
local FontPackage = require "engine.FontPackage"

local PlayerAIOptions = {}

function PlayerAIOptions.createTab(self)
    local list = {}

    local zone = Textzone.new{
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
    
    return list
end

return PlayerAIOptions