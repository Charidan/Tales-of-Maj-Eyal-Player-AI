AISettings = {}

function AISettings.init()
    if config.settings.playerai_init_settings_ran then return end
    config.settings.playerai_init_settings_ran = true

    config.settings.playerai = config.settings.playerai or {}

    -- set defaults for the player ai
    if type(config.settings.playerai.health_threshold_stop) == 'nil' then config.settings.playerai.health_threshold_stop = 0.25 end
    if type(config.settings.playerai.health_threshold_avoid) == 'nil' then config.settings.playerai.health_threshold_avoid = 0.50 end
end

return AISettings