--print("Loading PlayerAI settings")

--config.settings.playerai = config.settings.playerai or {}
config.settings.playerai = {}

-- set defaults for the player ai
if type(config.settings.playerai.health_threshold) == 'nil' then config.settings.playerai.health_threshold_stop = 0.25 end
if type(config.settings.playerai.health_threshold) == 'nil' then config.settings.playerai.health_threshold_flee = 0.50 end