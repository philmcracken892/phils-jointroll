local RSGCore = exports['rsg-core']:GetCoreObject()

-- Debug function
local function DebugPrint(msg)
    if Config.Debug then
        print('^2[rsg-joints]^7 ' .. msg)
    end
end


local function HasRequiredItems(Player)
    for _, v in pairs(Config.RequiredItems) do
        local item = Player.Functions.GetItemByName(v.item)
        if not item or item.amount < v.amount then
            return false
        end
    end
    return true
end


local function RemoveRequiredItems(Player, src)
    for _, v in pairs(Config.RequiredItems) do
        Player.Functions.RemoveItem(v.item, v.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[v.item], 'remove', v.amount)
    end
end


lib.callback.register('rsg-joints:server:getInventory', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return {} end
    
    local inventory = {}
    
    
    for _, v in pairs(Config.RequiredItems) do
        local item = Player.Functions.GetItemByName(v.item)
        inventory[v.item] = item and item.amount or 0
    end
    
   
    local joint = Player.Functions.GetItemByName(Config.RewardItem.item)
    inventory[Config.RewardItem.item] = joint and joint.amount or 0
    
    DebugPrint('Inventory callback for player ' .. source)
    return inventory
end)


lib.callback.register('rsg-joints:server:canRoll', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    return HasRequiredItems(Player)
end)


lib.callback.register('rsg-joints:server:hasJoint', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local joint = Player.Functions.GetItemByName(Config.RewardItem.item)
    return joint and joint.amount >= 1
end)


RegisterNetEvent('rsg-joints:server:rollJoint', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
   
    if not HasRequiredItems(Player) then
        TriggerClientEvent('rsg-joints:client:notify', src, 'Joint Rolling', 'You don\'t have the required items!', 'error')
        DebugPrint('Player ' .. src .. ' tried to roll without items')
        return
    end
    
    
    RemoveRequiredItems(Player, src)
    
    
    local success = Player.Functions.AddItem(Config.RewardItem.item, Config.RewardItem.amount)
    
    if success then
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.RewardItem.item], 'add', Config.RewardItem.amount)
        TriggerClientEvent('rsg-joints:client:notify', src, 'Joint Rolling', 'You rolled a joint!', 'success')
        DebugPrint('Player ' .. src .. ' rolled a joint')
    else
       
        for _, v in pairs(Config.RequiredItems) do
            Player.Functions.AddItem(v.item, v.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[v.item], 'add', v.amount)
        end
        TriggerClientEvent('rsg-joints:client:notify', src, 'Joint Rolling', 'Your inventory is full!', 'error')
    end
end)


RSGCore.Functions.CreateUseableItem('paper', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    TriggerClientEvent('rsg-joints:client:openMenu', source)
    DebugPrint('Player ' .. source .. ' used paper - opening menu')
end)


RSGCore.Functions.CreateUseableItem('tobacco', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    TriggerClientEvent('rsg-joints:client:openMenu', source)
    DebugPrint('Player ' .. source .. ' used tobacco - opening menu')
end)


RSGCore.Functions.CreateUseableItem('weed', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    TriggerClientEvent('rsg-joints:client:openMenu', source)
    DebugPrint('Player ' .. source .. ' used weed - opening menu')
end)
