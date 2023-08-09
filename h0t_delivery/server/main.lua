RegisterNetEvent('wh-job:caution:take')
AddEventHandler('wh-job:caution:take', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= Config.CautionVehicleSpawn then
        xPlayer.removeMoney(Config.CautionVehicleSpawn)
        TriggerClientEvent('wh-job:client:spawnVehicle', source, Config.VanModel)
    else
        TriggerClientEvent('wh-job:client:noCaution', source)
    end
end)
RegisterNetEvent('wh-job:caution:back')
AddEventHandler('wh-job:caution:back', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(Config.CautionVehicleSpawn)
end)
RegisterNetEvent('wh-job:finish')
AddEventHandler('wh-job:finish', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(Config.FinishWorkPayAmount)
end)