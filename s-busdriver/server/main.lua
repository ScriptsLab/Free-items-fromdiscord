ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('s-busdriver:reward', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.REWARD_TYPE == "money" then
        xPlayer.addMoney(Config.REWARD)
    elseif Config.REWARD_TYPE == "item" then
        if exports.ox_inventory then
            exports.ox_inventory:AddItem(source, Config.REWARD_ITEM, Config.REWARD_ITEM_COUNT)
        else
            xPlayer.addInventoryItem(Config.REWARD_ITEM, Config.REWARD_ITEM_COUNT)
        end
    end
end)