local RSGCore = exports['rsg-core']:GetCoreObject()
local isRolling = false
local isHigh = false
local highThread = nil
local PlayerInventory = {}


local function DebugPrint(msg)
    if Config.Debug then
        print('^2[rsg-joints]^7 ' .. msg)
    end
end


local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end


local function GetItemCount(itemName)
    if PlayerInventory and PlayerInventory[itemName] then
        return PlayerInventory[itemName]
    end
    return 0
end


local function RefreshInventory()
    local inventory = lib.callback.await('rsg-joints:server:getInventory', false)
    if inventory then
        PlayerInventory = inventory
    end
    
end


local function HasRequiredItemsClient()
    for _, v in pairs(Config.RequiredItems) do
        local count = GetItemCount(v.item)
        if count < v.amount then
            return false, v.label
        end
    end
    return true, nil
end


local function GetInventoryStatus()
    local items = {}
    for _, v in pairs(Config.RequiredItems) do
        local count = GetItemCount(v.item)
        items[#items + 1] = {
            label = v.label,
            has = count,
            need = v.amount,
            complete = count >= v.amount
        }
    end
    return items
end


local function OpenRollingMenu()
    if isRolling then
        lib.notify({
            title = 'Joint Rolling',
            description = 'You are already rolling!',
            type = 'error',
            position = Config.Notifications.position,
            duration = Config.Notifications.duration
        })
        return
    end

    
    RefreshInventory()
    Wait(100)

    local hasItems, missingItem = HasRequiredItemsClient()
    local inventoryStatus = GetInventoryStatus()
    
   
    local statusText = ''
    for i, item in ipairs(inventoryStatus) do
        local icon = item.complete and '✅' or '❌'
        statusText = statusText .. icon .. ' ' .. item.label .. ': ' .. item.has .. '/' .. item.need
        if i < #inventoryStatus then
            statusText = statusText .. '\n'
        end
    end

    lib.registerContext({
        id = 'joint_rolling_menu',
        title = '🌿 Joint Rolling',
        options = {
            {
                title = '📦 Your Inventory',
                description = statusText,
                icon = 'box-open',
                disabled = true
            },
            {
                title = hasItems and '🚬 Roll a Joint' or '🚬 Roll a Joint (Missing Items)',
                description = hasItems and 'You have everything needed!' or 'Gather all required items first',
                icon = 'cannabis',
                iconColor = hasItems and '#4CAF50' or '#F44336',
                disabled = not hasItems,
                onSelect = function()
                    StartRollingJoint()
                end
            },
            {
                title = '📖 How to Roll',
                description = 'You need rolling paper, tobacco, and weed',
                icon = 'question-circle',
                disabled = true
            },
            {
                title = '❌ Close Menu',
                description = 'Close this menu',
                icon = 'times-circle',
                iconColor = '#F44336',
                onSelect = function()
                    lib.notify({
                        title = 'Joint Rolling',
                        description = 'Menu closed',
                        type = 'inform',
                        position = Config.Notifications.position,
                        duration = 2000
                    })
                end
            }
        }
    })

    lib.showContext('joint_rolling_menu')
end


function StartRollingJoint()
    if isRolling then return end

  
    local canRoll = lib.callback.await('rsg-joints:server:canRoll', false)
    
    if not canRoll then
        lib.notify({
            title = 'Joint Rolling',
            description = 'You don\'t have the required items!',
            type = 'error',
            position = Config.Notifications.position,
            duration = Config.Notifications.duration
        })
        return
    end

    isRolling = true
    local ped = PlayerPedId()

    
    LoadAnimDict(Config.Animation.dict)
    TaskPlayAnim(ped, Config.Animation.dict, Config.Animation.anim, 8.0, -8.0, -1, Config.Animation.flag, 0, false, false, false)

    
    local success = lib.progressBar({
        duration = Config.RollingTime,
        label = 'Rolling a joint...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })

   
    ClearPedTasks(ped)

    if success then
        
        TriggerServerEvent('rsg-joints:server:rollJoint')
        DebugPrint('Joint rolled successfully')
        
        
        Wait(500)
        RefreshInventory()
    else
        lib.notify({
            title = 'Joint Rolling',
            description = 'Rolling cancelled!',
            type = 'error',
            position = Config.Notifications.position,
            duration = Config.Notifications.duration
        })
    end

    isRolling = false
end




-- ================================================
-- EVENTS
-- ================================================


RegisterNetEvent('rsg-joints:client:openMenu', function()
    OpenRollingMenu()
end)


RegisterNetEvent('rsg-joints:client:applyEffects', function()
    ApplyHighEffects()
end)


RegisterNetEvent('rsg-joints:client:useJoint', function()
    SmokeJoint()
end)


RegisterNetEvent('rsg-joints:client:notify', function(title, message, ntype)
    lib.notify({
        title = title,
        description = message,
        type = ntype,
        position = Config.Notifications.position,
        duration = Config.Notifications.duration
    })
end)

-- ================================================
-- COMMANDS
-- ================================================


RegisterCommand(Config.Command, function()
    OpenRollingMenu()
end, false)



if Config.KeyBind then
    CreateThread(function()
        while true do
            Wait(0)
            
            
            if IsControlJustReleased(0, Config.KeyBindHash) then
               
                if not IsPauseMenuActive() and not isRolling then
                    OpenRollingMenu()
                end
            end
        end
    end)
end



AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    RemoveHighEffects()
end)


AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local ped = PlayerPedId()
        
        if victim == ped and IsEntityDead(ped) then
            RemoveHighEffects()
        end
    end
end)


RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    RefreshInventory()
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    Wait(2000)
    RefreshInventory()
end)

