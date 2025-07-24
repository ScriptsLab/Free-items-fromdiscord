local ped = nil
local ESX = exports["es_extended"]:getSharedObject()
lib = exports.ox_lib

print("Busdriver script start")

Citizen.CreateThread(function()
    print("Thread started")
    local pedModel = `a_m_m_business_01`
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    local coords = Config.PEDKORDY
    ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    exports['ox_target']:addLocalEntity(ped, {
        {
            label = 'Rozpocznij pracę',
            icon = 'fa-solid fa-bus',
            onSelect = function(data)
                exports.ox_lib:notify({
                    title = 'Gratulacje',
                    description = 'Rozpocząłeś pracę',
                    type = 'success'
                })

                local playerPed = PlayerPedId()
                local busModel = `bus`
                RequestModel(busModel)
                while not HasModelLoaded(busModel) do
                    Wait(10)
                end

                local spawnCoords = Config.MIEJSCEAUTA
                local bus = CreateVehicle(
                    busModel,
                    spawnCoords.x, spawnCoords.y, spawnCoords.z,
                    spawnCoords.w, 
                    true, false
                )
                SetVehicleOnGroundProperly(bus)
                TaskWarpPedIntoVehicle(playerPed, bus, -1)

                StartBusJob() 
            end
        }
    })
    print("Ped powinien się pojawić na kordach:", coords)
end)

local currentRoute = {}
local currentStop = 1
local blips = {}
local onJob = false

function StartBusJob()

    currentRoute = {}
    local stops = {}
    for i=1, #Config.STOPS do stops[i]=i end
    for i=1, Config.STOPS_COUNT do
        local idx = math.random(#stops)
        table.insert(currentRoute, Config.STOPS[stops[idx]])
        table.remove(stops, idx)
    end
    currentStop = 1
    onJob = true
    CreateNextStopBlip()
    GoToNextStop()
end

function CreateNextStopBlip()
    for _, b in ipairs(blips) do RemoveBlip(b) end
    blips = {}
    if currentRoute[currentStop] then
        local blip = AddBlipForCoord(currentRoute[currentStop].x, currentRoute[currentStop].y, currentRoute[currentStop].z)
        SetBlipSprite(blip, 513)
        SetBlipColour(blip, 3)
        SetBlipScale(blip, 0.8)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Przystanek autobusowy")
        EndTextCommandSetBlipName(blip)
        table.insert(blips, blip)
       
        SetNewWaypoint(currentRoute[currentStop].x, currentRoute[currentStop].y)
    end
end

function GoToNextStop()
    if not currentRoute[currentStop] then
        EndBusJob()
        return
    end
    CreateNextStopBlip()
    Citizen.CreateThread(function()
        while onJob do
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local stop = currentRoute[currentStop]
            if #(coords - vector3(stop.x, stop.y, stop.z)) < 8.0 then
                exports.ox_lib:notify({
                    title = "Przystanek",
                    description = "Pasażerowie wsiadają/wysiadają...",
                    type = "info"
                })
                Wait(5000)
                exports.ox_lib:notify({
                    title = "Przystanek",
                    description = "Możesz jechać dalej!",
                    type = "success"
                })
                FreezeEntityPosition(GetVehiclePedIsIn(playerPed, false), false)
                currentStop = currentStop + 1
                GoToNextStop()
                break
            end
            Wait(500)
        end
    end)
end

function EndBusJob()
    onJob = false
    for _, b in ipairs(blips) do RemoveBlip(b) end
    blips = {}

    TriggerServerEvent('s-busdriver:reward')
    exports.ox_lib:notify({title="Kurs zakończony", description="Otrzymałeś nagrodę!", type="success"})
end
