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

local aiTurnCount = 0
local function aiStop(msg)
    _M.ai_active = false
    _M.player_ai_resting = false
    aiTurnCount = 0
    if msg then game.log(msg) else game.log("#LIGHT_RED#AI Stopping!") end
end

local function getDirNum(src, dst)
    local dx = dst.x - src.x
    if dx ~= 0 then dx = dx/dx end
    local dy = dst.y - src.y
    if dy ~= 0 then dy = dy/dy end
    return util.coordToDir(dx, dy)
end

local function spotHostiles(self, actors_only)
	local seen = {}
	if not self.x then return seen end

	-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
	core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, self.sight or 10, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then
			seen[#seen + 1] = {x=x,y=y,actor=actor, entity=actor, name=actor.name}
		end
	end, nil)

	if not actors_only then
		-- Check for projectiles in line of sight
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, self.sight or 10, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local proj = game.level.map(x, y, game.level.map.PROJECTILE)
			if not proj or not game.level.map.seens(x, y) then return end

			-- trust ourselves but not our friends
			if proj.src and self == proj.src then return end
			local sx, sy = proj.start_x, proj.start_y
			local tx, ty

			-- Bresenham is too so check if we're anywhere near the mathematical line of flight
			if type(proj.project) == "table" then
				tx, ty = proj.project.def.x, proj.project.def.y
			elseif proj.homing then
				tx, ty = proj.homing.target.x, proj.homing.target.y
			end
			if tx and ty then
				local dist_to_line = math.abs((self.x - sx) * (ty - sy) - (self.y - sy) * (tx - sx)) / core.fov.distance(sx, sy, tx, ty)
				local our_way = ((self.x - x) * (tx - x) + (self.y - y) * (ty - y)) > 0
				if our_way and dist_to_line < 1.0 then
					seen[#seen+1] = {x=x, y=y, projectile=proj, entity=proj, name=(proj.getName and proj:getName()) or proj.name}
				end
			end
		end, nil)
	end
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

local function getAvailableTalents()
    local avail = {}
    -- TODO maybe check range for each enemy in range? player has unknowable target!
	-- local tx, ty = game.player:aiSeeTargetPos(game.player.ai_target.actor)
	--local target_dist = core.fov.distance(game.player.x, game.player.y, tx, ty)
	for tid, _ in pairs(game.player.talents) do
		local t = game.player:getTalentFromId(tid)
		-- For dumb AI assume we need range and LOS
		-- No special check for bolts, etc.
		local total_range = (game.player:getTalentRange(t) or 0) + (game.player:getTalentRadius(t) or 0)
		local tg = {type=util.getval(t.direct_hit, game.player, t) and "hit" or "bolt", range=total_range}
		if t.mode == "activated" and not t.no_npc_use and not t.no_dumb_use and
		   not game.player:isTalentCoolingDown(t) and game.player:preUseTalent(t, true, true) --and
		   --(not game.player:getTalentRequiresTarget(t) or game.player:canProject(tg, tx, ty))
		   then
			avail[#avail+1] = tid
			print(game.player.name, game.player.uid, "dumb ai talents can use", t.name, tid)
		elseif t.mode == "sustained" and not t.no_npc_use and not t.no_dumb_use and not game.player:isTalentCoolingDown(t) and
		   not game.player:isTalentActive(t.id) and
		   game.player:preUseTalent(t, true, true)
		   then
			avail[#avail+1] = tid
			print(game.player.name, game.player.uid, "dumb ai talents can activate", t.name, tid)
		end
	end
	return avail
end

local function checkLowHealth()
    local enemy = getNearestHostile()
    if enemy ~= nil and game.player.life < game.player.max_life/4 then
        local dir = game.level.map:compassDirection(enemy.x - game.player.x, enemy.y - game.player.y)
        local name = enemy.name
		return true, ("#RED#AI cancelled for low health while hostile spotted to the %s (%s%s)"):format(dir or "???", name, game.level.map:isOnScreen(enemy.x, enemy.y) and "" or " - offscreen")
    end
end

local function player_ai_rest() end

local function player_ai_after_rest() 
--TODO rework so we don't check for hostiles twice
    local ret, msg = checkLowHealth()
    if ret then return game.log(msg) end
    
    -- activate sustained talents
    local talents = getAvailableTalents()
    if talents == nil or #talents == 0 then game.log("#RED#no talents") end
    for i,tid in pairs(talents) do
        game.log("i = "..tostring(i).."    tid = "..tostring(tid))
        local t = game.player:getTalentFromId(tid)
        game.log("t = "..tostring(t))
        if tid == nil then game.log("#RED#tid is nil?") end
        if t.mode == "sustained" then
            game.player:useTalent(tid)
        end
    end
        
    local target = getNearestHostile()
    if target == nil
    then
        --If we stopped autoexploring on a level exit, stop the AI
        local terrain = game.level.map(game.player.x, game.player.y, Map.TERRAIN)
        if game.player:autoExplore() and terrain.change_level then
            aiStop("#LIGHT_RED#AI stopping: level change found")
        end
    else
        local move_success = false
        
        local a = Astar.new(game.level.map, game.player)
        local path = a:calc(game.player.x, game.player.y, target.x, target.y)
        
        if not path then
            --game.log("#RED#Path not found, trying beeline")
            local dir = getDirNum(game.player, target)
            move_success = game.player:attackOrMoveDir(dir)
        else
            --game.log("#GREEN#move via path")
            local moved = game.player:move(path[1].x, path[1].y)
            if not moved then
                --game.log("#RED#Normal movement failed, trying beeline")
                local enemies = spotHostiles(game.player)
                for index,enemy in pairs(enemies) do
                    local dir = getDirNum(game.player, target)
                    if game.player:attackOrMoveDir(dir) then
                         move_success = true
                        break
                    end
                end
            else
                move_success = true
            end
        end
        if not move_success then
            game.log("#GOLD#Waiting a turn!")
            game.player:attackOrMoveDir(5)
        end
    end
end

local function player_ai_rest()
    _M.player_ai_resting = true
    game.player:restInit(nil,nil,nil,nil,player_ai_after_rest)
end

local function player_ai_act()
    local ret, msg = checkLowHealth()
    if ret then 
        aiStop(msg)
        return
    end
    
    _M.player_ai_resting = true
    game.player:restInit(nil,nil,nil,nil,player_ai_rest)
end

function _M:player_ai_start()
    if _M.ai_active == true then
        return aiStop("#GOLD#Disabling Player AI!")
    end
    if game.zone.wilderness then
        return aiStop("#RED#Player AI cannot be used in the wilderness!")
    end
    _M.ai_active = true
    --dialog = Dialog:simplePopup("AI active!", "The AI is clearing the floor for you. Press any key to regain control...", function()
    --    aiStop()
    --end, false, true)
    
    player_ai_act()
end

local old_act = _M.act
function _M:act()
    local ret = old_act(game.player)
    if (not game.player.running) and (not game.player.resting) and _M.ai_active then
        if game.zone.wilderness then
            aiStop("#RED#Player AI cancelled by wilderness zone!")
            return ret
        end
        aiTurnCount = aiTurnCount + 1
        player_ai_act()
        local did_ai = true
    end
    if aiTurnCount > 1000 then
        aiStop("#LIGHT_RED#AI Disabled. AI acted for 1000 turns. Did it get stuck?")
    end
    --if (not did_ai) and (not game.player.player_ai_resting) and (not game.player.running) and (not game.player.resting) then aiStop() end
    return ret
end

return _M