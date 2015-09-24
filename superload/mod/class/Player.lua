-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
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
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

-- Modifications by Charidan

local Astar = require "engine.Astar"
local Dialog = require "engine.ui.Dialog"
local Map = require "engine.Map"
local PlayerRest = require "engine.interface.PlayerRest"
local PlayerExplore = require "mod.class.interface.PlayerExplore"

local _M = loadPrevious(...)

_M.ai_active = false

local function aiStop()
    _M.ai_active = false
end

local function spotHostiles(self, ...)
	local esp_explore = select(1, ...)
	local seen = {}
	if not self.x then return seen end

	-- Check for visible monsters.
	core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, self.sight or 10, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then
			seen[#seen + 1] = {x=x,y=y,actor=actor}
      --game.log("distance: "..core.fov.distance(x, y, self.x, self.y))
		end
	end, nil)
	
	return seen
end

local function getNearestHostile()
    local seen = spotHostiles(game.player)
    
    target = nil
    for index,enemy in pairs(seen) do
        if target == nil
        then
            target = enemy
        end
    end
    return target
end

local function checkLowHealth()
    local enemy = getNearestHostile()
    if enemy ~= nil and game.player.life < game.player.max_life/4 then
-- TODO: 
        -- use healing talents
        aiStop()
        local dir = game.level.map:compassDirection(enemy.x - game.player.x, enemy.y - game.player.y)
        game.log("#LIGHT_RED#(checkLowHealth) Low Health! Incoming cancel message!")
		return true, ("#RED#AI cancelled for low health while hostile spotted to the %s (%s%s)"):format(dir or "???", enemy.name, game.level.map:isOnScreen(enemy.x, enemy.y) and "" or " - offscreen")
    end
    game.log("#LIGHT_GREEN#(checkLowHealth) Health fine OR no enemy")
end

local function player_ai_rest() end

local function player_ai_after_rest()
    game.log("#GREEN#Start of Player AI After Rest! #GOLD#Player AI is: %s", _M.ai_active and "#LIGHT_GREEN#enabled" or "#LIGHT_RED#disabled")
    
--TODO rework so we don't check for hostiles twice
    local ret, msg = checkLowHealth()
    if ret then return game.log(msg) end
        
    local target = getNearestHostile()
    if target == nil
    then
        game.log("#RED#No Target! Auto-Exploring!")
        --If we stopped autoexploring on a level exit, stop the AI
        local terrain = game.level.map(game.player.x, game.player.y, Map.TERRAIN)
        if game.player:autoExplore() and terrain.change_level then
            aiStop()
        end
    else
        game.log("#RED#Target found! Approaching!")
        local a = Astar.new(game.level.map, game.player)
        local path = a:calc(game.player.x, game.player.y, target.x, target.y)
        if not path then
            game.log("#RED#Path not found, trying beeline")
            game.log("#GOLD#player x = #GREEND#%d #GOLD#player y = #GREEND#%d #GOLD#target x = #GREEND#%d #GOLD#target y = %d",game.player.x, game.player.y, target.x, target.y)
            --game.player:moveDir(util.coordToDir(game.player.x, game.player.y, target.x, target.y))
        else
            local moved = game.player:move(path[1].x, path[1].y)
            if not moved then
                game.log("#RED#Normal movement failed, trying beeline")
                game.log("#GOLD#player x = #GREEND#%d #GOLD#player y = #GREEND#%d #GOLD#target x = #GREEND#%d #GOLD#target y = %d",game.player.x, game.player.y, target.x, target.y)
                --game.player:moveDir(util.coordToDir(game.player.x, game.player.y, target.x, target.y))
            end
        end
    end
    
    game.log("#GREEN#End of Player AI After Rest! #GOLD#Player AI is: %s", _M.ai_active and "#LIGHT_GREEN#enabled" or "#LIGHT_RED#disabled")
end

local function player_ai_rest()
    game.log("#GOLD#Player AI Rest! #GOLD#Player AI is: %s", _M.ai_active and "#LIGHT_GREEN#enabled" or "#LIGHT_RED#disabled")
    game.player:restInit(nil,nil,nil,nil,player_ai_after_rest)
    game.log("#GREEN#End of Player AI Rest!")
end

local function player_ai_act()
    local ret, msg = checkLowHealth()
    if ret then 
        game.log("#LIGHT_RED#(ai_act) Low Health! Incoming cancel message!")
        aiStop()
        return game.log(msg)
    end
    
    game.player:restInit(nil,nil,nil,nil,player_ai_rest)
end

function _M:player_ai_start()
    game.log("#GOLD#Player AI Start! #GOLD#Player AI is: %s", _M.ai_active and "#LIGHT_GREEN#enabled" or "#LIGHT_RED#disabled")
    _M.ai_active = true
    --dialog = Dialog:simplePopup("AI active!", "The AI is clearing the floor for you. Press any key to regain control...", function()
    --    aiStop()
    --end, false, true)
    
    player_ai_act()
end

local old_act = _M.act
function _M:act()
    old_act(game.player)
    if (not game.pause) and (not game.player.resting) and _M.ai_active then
        player_ai_act()
    end
end

return _M