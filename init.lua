-- ToME - Tales of Maj'Eyal:
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
--
-- Addon by Charidan

long_name = "Player AI"
short_name = "player-ai"
for_module = "tome"
version = {1,3,1}
weight = 100
author = { "Charidan (twilly0@gmail.com)" }
description = [[Adds a keybind to activate the new player AI. Set to Alt+F1 by default.
This player AI rests, auto-explores, and then attacks enemies.
It will clear an entire floor or stop when it hits 1/4 health in the presence of enemies.
Future versions may add configurable exit conditions and talent use.

This AI has undefined behavior in the Sandworm Lair, use it there at your own risk.

Note for Developers: This addon superwrites Player:act(), so if your addon also touches Player:act() change the load order so that the Player AI addon loads last.

PATCH NOTES:
 - Much fewer "hang" situations where the AI stops acting, but resumes control the next turn. A few persist, seemingly related to either enemies in previously unseen tiles or trying to path through walls.
 - AI disables itself on the worldmap to prevent unstoppable exploration
 - Added a 1000 turn limit to AI execution in case it gets stuck in a loop somehow.
]]
tags = { 'keybind', 'options', 'playerai' }
hooks = true
overload = true
superload = true
data = true
