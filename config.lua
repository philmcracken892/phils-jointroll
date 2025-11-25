Config = {}

-- Debug mode (set to false for production)
Config.Debug = false


Config.RequiredItems = {
    { item = 'paper', amount = 1, label = 'Rolling Paper' },
    { item = 'tobacco', amount = 1, label = 'Tobacco' },
    { item = 'weed', amount = 1, label = 'Weed' }
}


Config.RewardItem = {
    item = 'joint',
    amount = 1,
    label = 'Joint'
}


Config.RollingTime = 5000 -- Time in ms to roll a joint (5 seconds)


Config.Animation = {
    dict = 'amb_work@world_human_write_notebook@male_a@idle_a',
    anim = 'idle_a',
    flag = 49
}





Config.Command = 'rolljoint'


Config.KeyBind = false
Config.KeyBindHash = 0x760A9C6F -- G key hash for RedM

--[[
    Common RedM Key Hashes:
    G = 0x760A9C6F
    E = 0xCEFD9220
    F = 0xB2F377E8
    H = 0x24978A28
    J = 0xF3830D8E
    K = 0xD9D0E1C0
    L = 0x80F28E95
    X = 0x8CC9CD42
    Z = 0x26E9DC00
]]

-- Notification settings (ox_lib)
Config.Notifications = {
    position = 'top-right',
    duration = 5000
}