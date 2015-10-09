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
This player AI rests, auto-explores, and attacks enemies.
It will clear an entire floor or stop when it hits 1/4 health in the presence of enemies.
Future versions may add configurable exit conditions and talent use.

This AI has undefined behavior in the Sandworm Lair, use it there at your own risk.

Note for Developers: This addon superwrites Player:act(), so if your addon also touches Player:act() change the load order so that the Player AI addon loads last.

CURRENT FEATURES:
 - Rests!
 - Autoexplores!
 - Uses talents! (No exceptions yet for talents like Meditation or Phase Door to use them intelligently)
 - Attacks enemies!

CURRENT BUGS:
 - The AI assumes it is safe when attacked from unseen enemies, including when it is blinded in combat
 - The AI sometimes suffocates itself
 - The AI sometimes falls through to its "wait a turn" case when it doesn't seem necessary

v1.2 PATCH NOTES:
 - Complete backend rewrite of the action and decision code
 - Addition of AI states so it stops trying to rest and autoexplore in combat
 - Implemented Talents
 
Stuff I want in the next version:
 - A "hunting" AI state to react to damage taken while out of combat
 - This should fix the suffocation issue, and let it respond to unseen attackers
]]
tags = { 'keybind', 'options', 'playerai' }
hooks = true
overload = true
superload = true
data = true
