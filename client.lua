ESX = exports["es_extended"]:getSharedObject()

local playerJob = nil
local createdBlips = {}

RegisterNetEvent('esx:setJob', function(job)
    playerJob = job.name
    updateBlips() 
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local IsLoaded = ESX.IsPlayerLoaded()

        if IsLoaded then

            playerJob = ESX.PlayerData.job and ESX.PlayerData.job.name

            updateBlips()

            sleep = 5000
        end

        Wait(sleep)
    end
end)

function updateBlips()
    for _, blipData in ipairs(Config.Blips) do
        if not blipData.disabled then
            if Config.UseJob and blipData.UseJob then
                if playerJob == Config.Job then
                    createBlip(blipData)
                else
                    removeBlip(blipData)
                end
            elseif not Config.UseJob then
                createBlip(blipData)
            end
        end
    end
end

function createBlip(blipData)
    if not createdBlips[blipData.name] then
        local blip = AddBlipForCoord(blipData.coords)
        SetBlipSprite(blip, blipData.sprite)
        SetBlipColour(blip, blipData.color)
        SetBlipScale(blip, blipData.scale)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.name)
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, blipData.shortrange)
        
        createdBlips[blipData.name] = blip 
    end
end

function removeBlip(blipData)
    if createdBlips[blipData.name] then
        RemoveBlip(createdBlips[blipData.name])
        createdBlips[blipData.name] = nil 
    end
end

local function createPed(pedData)
    lib.requestModel(pedData.model, 10000)

    local ped = CreatePed(4, pedData.model, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.coords.w, false, true)

    SetEntityInvincible(ped, pedData.invincible)
    SetBlockingOfNonTemporaryEvents(ped, pedData.blockEvents)
    FreezeEntityPosition(ped, pedData.frozen)

    exports.ox_target:addLocalEntity(ped, {
        label = pedData.target.label,
        icon = pedData.target.icon,
        distance = pedData.target.distance,
        onSelect = pedData.target.onSelect
    })

    SetModelAsNoLongerNeeded(pedData.model)
end

if Config.UseLicense then
createPed(Config.Ped)
end

createPed(Config.PilotPedGarage)

function spawnAirplane(airplane)
    lib.requestModel(airplane.model, 10000)

    local modelHash = GetHashKey(airplane.model)

    while not HasModelLoaded(modelHash) do
        Wait(500)
    end

    local coords = airplane.coords
    local heading = airplane.heading

    local airplaneVehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)

    GiveKeys(airplaneVehicle)

    if airplane.useTaskWarp then
        local playerPed = PlayerPedId()
        TaskWarpPedIntoVehicle(playerPed, airplaneVehicle, -1)
    end

    SetModelAsNoLongerNeeded(modelHash)
end

local point = lib.points.new({
    coords = Config.AirplaneSpawn.ParkCoords, 
    distance = Config.PointDistance,
})

function point:onExit()
    lib.hideTextUI()
end

function point:nearby()
    local TextUI = false

    if self.currentDistance >= Config.PointDistance then
        return
    end

    if IsPedInAnyVehicle(cache.ped, false) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        local vehicleModel = GetEntityModel(vehicle)

        local isAirplane = false
        for _, airplane in ipairs(Config.AirplaneSpawn) do
            if vehicleModel == GetHashKey(airplane.model) then
                isAirplane = true
                break
            end
        end

        if isAirplane then
            if not TextUI then
                lib.showTextUI('[E] - Save Vehicle', {
                    icon = 'fa-solid fa-square-parking',
                    position = "left-center",
                })
                TextUI = true

                if IsControlJustReleased(0, 38) then
                    isAirplane = false
                    lib.hideTextUI()
                    parkVehicle(garageName)
                end
            end
        end
    end
end

function parkVehicle(garageName)
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    local plate = GetVehicleNumberPlateText(vehicle)

    RemoveKeys(vehicle)
    
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function RemoveKeys(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not plate then return end

    if GetResourceState('wasabi_carlock') == 'started' then
        exports.wasabi_carlock:RemoveKey(plate)
    end

    if GetResourceState('okokGarage') == 'started' then
        TriggerServerEvent("okokGarage:RemoveKeys", plate, PlayerId())
    end

    if GetResourceState('qb-vehiclekeys') == 'started' then
        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
    end

    if GetResourceState('qs-vehiclekeys') == 'started' then
        exports['qs-vehiclekeys']:RemoveKeys(plate, model)
    end

    if GetResourceState('cd_garage') == 'started' then
        TriggerServerEvent('cd_garage:RemovePersistentVehicles', plate)
    end

    if GetResourceState('vehicles_keys') == 'started' then
        TriggerServerEvent("vehicles_keys:selfRemoveKeys", plate)
    end

    if GetResourceState('Renewed-Vehiclekeys') == 'started' then
        exports['Renewed-Vehiclekeys']:removeKey(plate)
    end
end

function GiveKeys(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not plate then return end

    if GetResourceState('wasabi_carlock') == 'started' then
        exports.wasabi_carlock:GiveKey(plate)
    end

    if GetResourceState('okokGarage') == 'started' then
        TriggerServerEvent("okokGarage:GiveKeys", plate)
    end

    if GetResourceState('qb-vehiclekeys') == 'started' then
        TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)
    end

    if GetResourceState('qs-vehiclekeys') == 'started' then
        exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
    end

    if GetResourceState('cd_garage') == 'started' then
        TriggerEvent('cd_garage:AddKeys', plate)
    end

    if GetResourceState('vehicles_keys') == 'started' then
        TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate)
    end

    if GetResourceState('t1ger_keys') == 'started' then
        TriggerServerEvent('t1ger_keys:updateOwnedKeys', plate, true)
    end

    if GetResourceState('Renewed-Vehiclekeys') == 'started' then
        exports['Renewed-Vehiclekeys']:addKey(plate)
    end
end
