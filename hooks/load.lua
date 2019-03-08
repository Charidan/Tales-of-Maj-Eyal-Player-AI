-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local PlayerAIOptions = require "mod.class.PlayerAIOptions"
local KeyBind = require "engine.KeyBind"
local Textzone = require "engine.ui.Textzone"
local GetQuantity = require "engine.dialogs.GetQuantity"

class:bindHook("ToME:run",
    function(self, data)
    	KeyBind:load("toggle-player-ai")
	    game.key:addBinds {
		    TOGGLE_PLAYER_AI = function()
		        local Player = require "mod.class.Player"
		        game.log("#GOLD#Player AI Toggle requested!")
			    Player.player_ai_start()
		    end
	    }
    end
)

class:bindHook("GameOptions:tabs",
    function(self, data)
	    data.tab("Player AI",
	        function()
	            self.list = PlayerAIOptions.createTab(self)
	        end
	    )
	end
)


















