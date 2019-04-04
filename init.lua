long_name = "Player AI"
short_name = "player-ai"
for_module = "tome"
version = {1,5,10}
addon_version = {1,6,1}
weight = 100
author = { "Charidan (twilly0@gmail.com)" }
description = [[Adds a keybind to activate the new player AI. Set to Alt+F1 by default.
This player AI rests, auto-explores, and attacks enemies (using most talents when possible).
It will clear an entire floor or stop when it hits a configurable health threshold (default 25%) in the presence of enemies.

This AI has not been tested in the Sandworm Lair; use it there at your own risk.

Compatibility warning: This addon superwrites Player:act(), so if your addon also touches Player:act() change the load order so that the Player AI addon loads last.

CURRENT FEATURES:
 - Rests!
 - Autoexplores!
 - Attacks enemies!
 - Uses talents randomly! (No exceptions yet for talents like Meditation or Phase Door to use them intelligently)
 - - Note that this addon *does* obey talent auto-use settings, and should be compatible with addons which expand auto-use functionality. Every such addon I checked modifies Player:automaticTalents() and relies on the core Player:act() to call it, which the AI still does.

CURRENT BUGS:
 - It can get stuck in infinite explore loops, so I added a setting for max turns it can run in a row (default 1000) so it will eventually cede control back to you.
 - The AI still has trouble understanding water. It doesn't know about waterbreathing, and it doesn't recognize "bubbles" as air. So it's going to complain about suffocation constantly while it's underwater, but paradoxically seems to always move in the intelligent direction while doing so.
 - The AI sometimes falls through to its "wait a turn" case when it doesn't seem necessary. This will be awful to debug.

v1.6 PATCH NOTES:
 - Added framework support for configurations!
 - - There is a new tab in the Game Options menu for "Player AI" settings.
 - - Configurable percentage health thresholds for disabling the AI or fleeing in "hunt" state.
 - - Configurable timeout on "hunt" state.
 - - Just three settings for now, will definitely be more later.
 - Added a primitive "hunting" mode.
 - - If out-of-combat and attacked by an enemy it cannot see (including when it is blinded; the AI is dumb), it will check if the enemy position is known and rush them.
 - - If the attacker's position is unknown, the AI will randomwalk instead of standing still.
 - - Configurable health threshold to instead avoid the engagement and lose its pursuers so it can rest safely.
 
 v1.6.1 PATCH NOTES:
 - Added configuration for the AI runtime timeout. You can now adjust to match your patience with the AI getting stuck in loops.
 
Stuff I want implemented soon:
 - Smarter "hunting" state.
]]
tags = { 'keybind', 'options', 'playerai', 'auto-use', 'quality of life', 'utility' }
hooks = true
overload = true
superload = true
data = true
