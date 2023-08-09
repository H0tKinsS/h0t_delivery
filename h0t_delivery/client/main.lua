--==================================
--== ESX Delivery Job By H0tKinsS ==
--==================================
local Status = {
    DELIVERY_IDLE = 0,
    DELIVERY_PACKAGE_PICKUP = 1,
    VEHICLE_SPAWN = 2,
    DELIVERY_RIDE_DESTINATION = 3,
    DELIVERY_PACKAGE_DROPOFF = 4,
    DELIVERY_RETURN_BACK = 5
}
--==================================
--== Variables, please dont touch ==
--==================================

local CurrentBlip               = nil
local CurrentStatus             = Status.DELIVERY_PACKAGE_PICKUP
local CurrentHelpSubtitle       = nil
local CurrentVehicle            = nil
local CurrentVehicleMaxHealth   = nil
local DeliveryLocation          = nil
local CurrentDeliveryRoute      = {}
local CurrentAttachments        = false
local CurrentLoad               = 0
local CurrentWork               = false
local ShowLoadingBar            = false

--==================================
--== Functions                    ==
--==================================
function CloakRoomOutfitChange(type)
    if type == "wear_work" then
        Citizen.CreateThread(function()
            ESX.Progressbar("Przebieranie", 1500,{
                FreezePlayer = true,  
                onFinish = function()
                    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                        if skin.sex == 0 then
                            TriggerEvent('skinchanger:loadClothes', skin, ESX.PlayerData.job.skin_male)
                        else
                            TriggerEvent('skinchanger:loadClothes', skin,ESX.PlayerData.job.skin_female)
                        end
                    end)
                    CurrentStatus = Status.DELIVERY_PACKAGE_PICKUP
                    CurrentWork = true
                    ESX.ShowNotification(_U('cloakroom_wear_work_notify'))
            end})
        end)
    end
    if type == "wear_citizen" then
        Citizen.CreateThread(function()
            ESX.Progressbar("Przebieranie", 1500,{
                FreezePlayer = true,  
                onFinish = function()
                    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                        TriggerEvent('skinchanger:loadSkin', skin)
                    end)
                    finishWork(false)
                    CurrentStatus = Status.DELIVERY_IDLE
                    CurrentWork = false
                    ESX.ShowNotification(_U('cloakroom_wear_citizen_notify'))
            end})
        end)
    end
end

function OpenCloakroom()
    local elements
    if not CurrentWork then
        elements = {
            {unselectable = true, icon = "fas fa-shirt", title = _U('cloakroom')},
            {icon = "fas fa-shirt", title = _U('cloakroom_wear_work'), value = 'wear_work'},
        }
    else
        elements = {
            {unselectable = true, icon = "fas fa-shirt", title = _U('cloakroom')},
            {icon = "fas fa-shirt", title = _U('cloakroom_wear_citizen'), value = 'wear_citizen'},
        }
    end
    ESX.OpenContext("right", elements, function(menu,element)
        ESX.CloseContext()
        CloakRoomOutfitChange(element.value)
    end, function(menu)

    end)
end

function DeleteVehicle()
    if CurrentVehicle == nil then return end
    if not IsPedInAnyVehicle(PlayerPedId()) then return end
    if DoesEntityExist(CurrentVehicle) and IsPedInVehicle(PlayerPedId(), CurrentVehicle) then
        ESX.Game.DeleteVehicle(CurrentVehicle)
        ESX.ShowNotification(_U('caution_receive_back'))
        TriggerServerEvent('wh-job:caution:back')
    end
end
RegisterNetEvent('wh-job:client:noCaution')
AddEventHandler('wh-job:client:noCaution', function()
    ESX.ShowNotification(_U('no_caution_pay'))
end)
RegisterNetEvent('wh-job:client:spawnVehicle')
AddEventHandler('wh-job:client:spawnVehicle', function(model)
    math.randomseed(GetGameTimer())
    local rnd
    local spawnPos

    local amount = 0
    local maxAmount = 10
    
    repeat
        if amount >= maxAmount then 
            ESX.ShowNotification(_U('spawn_no_free_space'))
            return
        end
        rnd = math.random(1, #Config.Zones.VehicleSpawn)
        spawnPos = Config.Zones.VehicleSpawn[rnd]
        amount = amount + 1
    until IsPositionOccupied(spawnPos[1],spawnPos[2],spawnPos[3], 8 ,false, true) == false
--[[         CurrentVehicle = CreateVehicle(model, spawnPos[1],spawnPos[2],spawnPos[3],spawnPos[4], true, true)
    SetVehicleExtra(CurrentVehicle, 2, false)
    SetVehicleLivery(CurrentVehicle, 0)
    SetVehicleColours(CurrentVehicle, 0, 0)
    SetVehicleNumberPlateText(CurrentVehicle, "GOPO"..randomPlateNumber)
    CurrentVehiclePlate = GetVehicleNumberPlateText(CurrentVehicle)
    TaskWarpPedIntoVehicle(PlayerPedId(), CurrentVehicle, -1) ]]

    ESX.Game.SpawnVehicle(model, vector3(spawnPos[1],spawnPos[2],spawnPos[3]),spawnPos[4], function(vehicle)
        CurrentVehicleMaxHealth = GetVehicleEngineHealth(vehicle)
        local randomPlateNumber = math.random(1, 9999)
        SetVehicleNumberPlateText(vehicle, _U('vehicle_plate_text')..randomPlateNumber)   
        CurrentVehicle = vehicle
    end)
    Citizen.Wait(10)
    TaskWarpPedIntoVehicle(GetPlayerPed(-1), CurrentVehicle, -1)

    ESX.ShowNotification(_U('caution_pay'))
end)

function SpawnVehicle()
end


function CreateRoute()
    if CurrentLoad <= 0 then
        removeCurrentBlip()
        CurrentStatus = Status.DELIVERY_RETURN_BACK
        return
    end
    math.randomseed(GetGameTimer())
    local route = {}
    local rnd
    if CurrentDeliveryRoute ~= nil then
        repeat
            rnd = math.random(1, #Config.Zones.DeliveryRoute)
            route = {
                x = Config.Zones.DeliveryRoute[rnd].Ride[1],
                y = Config.Zones.DeliveryRoute[rnd].Ride[2],
                z = Config.Zones.DeliveryRoute[rnd].Ride[3],
                dropoffX = Config.Zones.DeliveryRoute[rnd].Drop[1],
                dropoffY = Config.Zones.DeliveryRoute[rnd].Drop[2],
                dropoffZ = Config.Zones.DeliveryRoute[rnd].Drop[3],
            }
        until not AreRoutesEqual(route, CurrentDeliveryRoute)
    else 
        rnd = math.random(1, #Config.Zones.DeliveryRoute)
        route = {
            x = Config.Zones.DeliveryRoute[rnd].Ride[1],
            y = Config.Zones.DeliveryRoute[rnd].Ride[2],
            z = Config.Zones.DeliveryRoute[rnd].Ride[3],
            dropoffX = Config.Zones.DeliveryRoute[rnd].Drop[1],
            dropoffY = Config.Zones.DeliveryRoute[rnd].Drop[2],
            dropoffZ = Config.Zones.DeliveryRoute[rnd].Drop[3],
        }
    end
    CurrentDeliveryRoute = route
    CurrentStatus = Status.DELIVERY_RIDE_DESTINATION
    removeCurrentBlip()
    
    CurrentBlip = CreateBlipAt(route.x,route.y,route.z)
end
function AreRoutesEqual(route1, route2)
    return route1.x == route2.x and route1.y == route2.y and route1.z == route2.z
        and route1.dropoffX == route2.dropoffX and route1.dropoffY == route2.dropoffY and route1.dropoffZ == route2.dropoffZ
end

function finishWork(safeReturn)
    removeCurrentBlip()
    CurrentHelpSubtitle       = nil
    DeliveryLocation          = nil
    CurrentDeliveryRoute      = {}
    CurrentLoad               = 0
    if safeReturn then
        ESX.ShowNotification(_U('finish_work_pay'))
        TriggerServerEvent('wh-job:finish')
        CurrentStatus             = Status.DELIVERY_PACKAGE_PICKUP
    else 
        CurrentWork = false
        CurrentStatus             = Status.DELIVERY_IDLE
    end
end

function openVehicleDoor()
    Citizen.CreateThread(function()
        TaskTurnPedToFaceEntity(PlayerPedId(), CurrentVehicle, -1)
        Wait(1000)
        SetVehicleDoorOpen(CurrentVehicle, 2, false, false)
        SetVehicleDoorOpen(CurrentVehicle, 3, false, false)
        ESX.Progressbar("Rozładunek", 3000,{
            FreezePlayer = true, 
            animation ={
                type = "anim",
                dict = "amb@prop_human_bum_bin@idle_a", 
                lib ="idle_a"
            }, 
            onFinish = function()
                CurrentAttachments = true  
                CurrentStatus = Status.DELIVERY_PACKAGE_DROPOFF
                SetVehicleDoorShut(CurrentVehicle, 2, false)
                SetVehicleDoorShut(CurrentVehicle, 3, false)
                ClearPedSecondaryTask(PlayerPedId())
                ClearPedTasksImmediately(PlayerPedId())
        end})
    end)
end

function removeCurrentBlip()
    if CurrentBlip ~= nil then
        RemoveBlip(CurrentBlip)
        CurrentBlip = nil
    end
end

function packageDelivery()
    Citizen.CreateThread(function()
        ESX.Progressbar("Rozładunek", 3000,{
            FreezePlayer = true,
            animation = {
              type = "Scenario",
              Scenario = "PROP_HUMAN_PARKING_METER"
            },
            onFinish = function()
                CurrentLoad = CurrentLoad - 1
                CurrentAttachments = false
                CreateRoute()
        end})
    end)
end

--==================================
--== Main logic and handlers      ==
--==================================

-- Display Help Subtitle Text
function MainLogic()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'delivery' and CurrentWork then

        if CurrentStatus == Status.DELIVERY_IDLE then
            CurrentHelpSubtitle = nil
        end
        local pedPos = GetEntityCoords(PlayerPedId())
        removeCurrentBlip()
        if IsPedDeadOrDying(PlayerPedId()) then
            finishWork(false)
            return
        end

        if CurrentStatus == Status.DELIVERY_PACKAGE_PICKUP then
            if GetDistanceBetweenCoords(pedPos, Config.Zones.PackagePickup.x, Config.Zones.PackagePickup.y, Config.Zones.PackagePickup.z, true) <= 2.6 then
                CurrentHelpSubtitle = nil
            else
                CurrentHelpSubtitle = _U('pickup_deliveries')
                CurrentBlip = CreateBlipAt(Config.Zones.PackagePickup.x,Config.Zones.PackagePickup.y,Config.Zones.PackagePickup.z)
            end
        end
        if CurrentStatus == Status.DELIVERY_RIDE_DESTINATION then
            CurrentHelpSubtitle = _U('destination_drive')
            CurrentBlip = CreateBlipAt(CurrentDeliveryRoute.x, CurrentDeliveryRoute.y, CurrentDeliveryRoute.z)
        end
        if CurrentStatus == Status.VEHICLE_REMOVE_PACKAGE then
            CurrentHelpSubtitle = _U('vehicle_remove_package')
            CurrentBlip = CreateBlipAt(CurrentDeliveryRoute.x, CurrentDeliveryRoute.y, CurrentDeliveryRoute.z)
        end
        if CurrentStatus == Status.DELIVERY_PACKAGE_DROPOFF then
            CurrentHelpSubtitle = _U('destination_delivery_hand')
            CurrentBlip = CreateBlipAt(CurrentDeliveryRoute.dropoffX, CurrentDeliveryRoute.dropoffY, CurrentDeliveryRoute.dropoffZ)
        end
        if CurrentStatus == Status.DELIVERY_RETURN_BACK then
            CurrentHelpSubtitle = _U('destination_return_back')
            CurrentBlip = CreateBlipAt(Config.Zones.DeliveryReturn.x, Config.Zones.DeliveryReturn.y, Config.Zones.DeliveryReturn.z)
        end
        
        if CurrentHelpSubtitle ~= nil then
            DrawHelpSubtitle(0.5, 0.95, CurrentHelpSubtitle, 0.5)
        end
    end
end

-- Display and manage Markers and interaction
function MarkerLogic()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'delivery' then 

        local pedPos = GetEntityCoords(PlayerPedId())

        -- CloakRoom

        DrawMarker(20, Config.Zones.CloakRoom.x, Config.Zones.CloakRoom.y, Config.Zones.CloakRoom.z, 0, 0, 0, 0, 180.0, 0, 1.5, 1.5, 1.6, 249, 38, 114, 150, true, true)
--        if GetDistanceBetweenCoords(pedPos, Config.Zones.CloakRoom.x, Config.Zones.CloakRoom.y, Config.Zones.CloakRoom.z, true) <= 1.5 then
        if #(pedPos - vector3(Config.Zones.CloakRoom.x, Config.Zones.CloakRoom.y, Config.Zones.CloakRoom.z)) <=1.5 and not IsPedInAnyVehicle(PlayerPedId()) then
            ESX.ShowHelpNotification(_U('cloakroom_notify'))
            if IsControlJustPressed(0, 38) then
                OpenCloakroom()
            end
        end
        if CurrentWork then
            if IsPedInVehicle(PlayerPedId(), CurrentVehicle) then
                DrawMarker(1, Config.Zones.VehicleDeleter.x, Config.Zones.VehicleDeleter.y, Config.Zones.VehicleDeleter.z-1, 0, 0, 0, 0, 0, 0, 5.1, 5.1, 1.2, 255, 0, 0, 150, false, false)
                if #(pedPos - vector3(Config.Zones.VehicleDeleter.x, Config.Zones.VehicleDeleter.y, Config.Zones.VehicleDeleter.z)) <= 3.1 then
                    ESX.ShowHelpNotification(_('vehicle_deleter_notify'))
                    if IsControlJustPressed(0, 38) then
                        DeleteVehicle()
                    end
                end
            end
            DrawMarker(36, Config.Zones.VehicleSpawner.x, Config.Zones.VehicleSpawner.y, Config.Zones.VehicleSpawner.z, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.6, 249, 38, 114, 150, true, true)
            if #(pedPos - vector3(Config.Zones.VehicleSpawner.x, Config.Zones.VehicleSpawner.y, Config.Zones.VehicleSpawner.z)) <= 1.5  and not IsPedInAnyVehicle(PlayerPedId())then
                ESX.ShowHelpNotification(_U('vehicle_spawner_notiy'))
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('wh-job:caution:take')
                end
            end
            if CurrentStatus == Status.DELIVERY_PACKAGE_PICKUP then
                DrawMarker(1, Config.Zones.PackagePickup.x, Config.Zones.PackagePickup.y, Config.Zones.PackagePickup.z-1, 0, 0, 0, 0, 0, 0, 5.1, 5.1, 1.1, 249, 38, 114, 150, false, false)
            end
            if CurrentStatus == Status.DELIVERY_RIDE_DESTINATION and CurrentDeliveryRoute ~= nil then
                if #(pedPos - vector3(CurrentDeliveryRoute.x, CurrentDeliveryRoute.y, CurrentDeliveryRoute.z)) <= Config.RideDestinationSize then
                    CurrentStatus = Status.VEHICLE_REMOVE_PACKAGE
                end
            end
            if CurrentStatus == Status.VEHICLE_REMOVE_PACKAGE then
                if not IsPedInAnyVehicle(PlayerPedId()) and CurrentAttachments == false then
                    if CurrentVehicle ~= nil and #(pedPos - vector3(CurrentDeliveryRoute.dropoffX, CurrentDeliveryRoute.dropoffY, CurrentDeliveryRoute.dropoffZ)) <=50 then
                        local vehPos = GetEntityCoords(CurrentVehicle)
                        local vehPosForward = GetEntityForwardVector(CurrentVehicle)
                        vehPos = vehPos - (vehPosForward * 4.5)
                        local vehHeight = vehPos.z + 0.4
                        DrawMarker(20, vehPos.x, vehPos.y, vehHeight, 0, 0, 0, 180.0, 0, 0, 2.0, 2.0, 2.0, 102, 217, 239, 150, true, true)
                        if #(pedPos - vector3(vehPos.x, vehPos.y, vehHeight)) <= 1.5 then
                            ESX.ShowHelpNotification(_U('vehicle_package_pick'))
                            if IsControlJustPressed(0, 38) then
                                openVehicleDoor()
                            end
                        end
                    end
                end
            end
            if CurrentStatus == Status.DELIVERY_PACKAGE_DROPOFF and CurrentDeliveryRoute ~= nil then
                DrawMarker(20, CurrentDeliveryRoute.dropoffX, CurrentDeliveryRoute.dropoffY, CurrentDeliveryRoute.dropoffZ, 0, 0, 0, 0, 180.0, 0, 1.5, 1.5, 1.6, 249, 38, 114, 150, true, true)
                
                if CurrentAttachments == true then
                    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "walk", 8.0, 8.0, -1, 51)
                end
                if #(pedPos - vector3(CurrentDeliveryRoute.dropoffX, CurrentDeliveryRoute.dropoffY, CurrentDeliveryRoute.dropoffZ)) <= 1.5 then
                    ESX.ShowHelpNotification(_U('delivery_hand_notify'))
                    if IsControlJustPressed(0, 38) and IsPedInAnyVehicle(PlayerPedId()) == false and CurrentAttachments == true then
                        packageDelivery()
                    end
                end
            end
            if CurrentStatus == Status.DELIVERY_RETURN_BACK then
                DrawMarker(1, Config.Zones.DeliveryReturn.x, Config.Zones.DeliveryReturn.y, Config.Zones.DeliveryReturn.z-2, 0, 0, 0, 0, 0, 0, 3.1, 3.1, 2.1, 249, 38, 114, 150, false, false)
                if #(pedPos - vector3(Config.Zones.DeliveryReturn.x, Config.Zones.DeliveryReturn.y, Config.Zones.DeliveryReturn.z)) <= 1.7 then
                    finishWork(true)
                end
            end
        end
    end
end
function LoadAndUnloadLogic()
    local pedPos = GetEntityCoords(PlayerPedId())
    if CurrentStatus == Status.DELIVERY_PACKAGE_PICKUP then
        if #(pedPos - vector3(Config.Zones.PackagePickup.x, Config.Zones.PackagePickup.y, Config.Zones.PackagePickup.z)) <= 3.1 then
            CurrentLoad = CurrentLoad + 1
            if CurrentLoad >= Config.MaxPackages then
                CurrentStatus = Status.DELIVERY_RIDE_DESTINATION
                CreateRoute()
                CurrentLoad = Config.MaxPackages
            end
        end
    end
end
-- Utils

function CreateBlipAt(x, y, z, text)
	
	local tmpBlip = AddBlipForCoord(x, y, z)
	
	SetBlipSprite(tmpBlip, 1)
	SetBlipColour(tmpBlip, 66)
	SetBlipAsShortRange(tmpBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
	SetBlipAsMissionCreatorBlip(tmpBlip, true)
	
	return tmpBlip
end
function _(str, ...)  -- Translate string

    if Config.Locales[Config.Locale] ~= nil then
  
      if Config.Locales[Config.Locale] ~= nil then
        return string.format(Config.Locales[Config.Locale][str], ...)
      else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exists'
      end
  
    else
      return 'Locale [' .. Config.Locale .. '] does not exists'
    end
  
  end
  
  function _U(str, ...) -- Translate string first char uppercase
    return tostring(_(str, ...):gsub("^%l", string.upper))
  end

function DrawHelpSubtitle(x, y, text, scale)
    SetTextFont(0)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
	SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetTextJustification(
        0 --[[ integer ]]
    )
    DrawText(x, y)
end

function SubtitleLogic()
end

--==================================
--== Threads ==
--==================================
Citizen.CreateThread(function()
	blip = AddBlipForCoord(Config.Zones.Base.x, Config.Zones.Base.y, Config.Zones.Base.z)
	SetBlipSprite(blip, Config.Zones.Base.markerId)
	SetBlipColour(blip, 5)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('blip_name'))
	EndTextCommandSetBlipName(blip)
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        MainLogic()
    end
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        MarkerLogic()
    end
end)
Citizen.CreateThread(function()
    local sleep = 1
    while true do
        Citizen.Wait(sleep)
        SetNuiFocus(false, false)
        if CurrentWork then
            sleep = 1
            SendNUIMessage({
                type = "loadStatusUpdate",
                percentage = (CurrentLoad/Config.MaxPackages) * 100,
                load = CurrentLoad..'/'..Config.MaxPackages
            })
        else
            SendNUIMessage({
                type = "close",
            })
            sleep = 100
        end
        if CurrentStatus ~= Status.DELIVERY_PACKAGE_PICKUP and CurrentWork then
            sleep = 300
        end
    end
end)
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
Citizen.CreateThread(function()
    while true do
        LoadAndUnloadLogic()
        Citizen.Wait(1000*Config.LoadTimePerPackage)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)