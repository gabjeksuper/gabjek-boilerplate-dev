
Config = {}

Config.Locale = "en"
Config.Debug = false
Config.PanelKey = "F6"

Config.UseOxLib = true
Config.UseOxTarget = true
Config.UseOxMySQL = false
Config.UseOxInventory = true

Config.Limits = {
    MoneyPerAction = 10000,
    ItemCountMax = 10
}

Config.RateLimits = {
    route = { max = 15, window = 10 },
    announce = { max = 5, window = 30 }
}

Config.Teleports = {
    legion = { x = 215.76, y = -810.12, z = 30.73, h = 160.0 },
    sandy  = { x = 1732.07, y = 3295.59, z = 41.22, h = 105.0 },
    paleto = { x = -133.29, y = 6315.56, z = 31.49, h = 220.0 }
}
