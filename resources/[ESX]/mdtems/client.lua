local ESX      = nil
local PlayerData = {}
local holdingTablet = true

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

function hintToDisplay(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local disablechatmdt = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if disablechatmdt then
            DisableControlAction(0, 245, true)
            DisableControlAction(0, 309, true)
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterCommand('mdt',function()
    if (ESX.PlayerData.job.name == 'ambulance') then
        if (holdingTablet==true) then
            TriggerEvent("tabletmdttemporal:ems")
            holdingTablet=false
            ESX.TriggerServerCallback('mdtems:fetch', function(d)
                disablechatmdt = true
                Citizen.Wait(2000)
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "open",
                    array  = d
                })
            end, data, 'start')
        elseif (holdingTablet==false) then
            DeleteEntity(tab)
            ClearPedTasks(PlayerPedId())
            holdingTablet=true
        end
    end
end)

RegisterNetEvent("tabletmdttemporal:ems")
AddEventHandler("tabletmdttemporal:ems", function()
    local ped = GetPlayerPed(-1)

    if not IsEntityDead(ped) then
        if not IsEntityPlayingAnim(ped, "amb@world_human_seat_wall_tablet@female@idle_a", "idle_c", 3) then
            RequestAnimDict("amb@world_human_seat_wall_tablet@female@idle_a")
            while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@idle_a") do
                Citizen.Wait(100)
            end
            TaskPlayAnim(ped, "amb@world_human_seat_wall_tablet@female@idle_a", "idle_c", 8.0, -8, -1, 49, 0, 0, 0, 0)
            tab = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)        ----0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)   
            AttachEntityToEntity(tab, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 18905), 0.12, 0.05, 0.13, -10.5, 180.0, 180.0, true, true, false, true, 1, true)        
             Citizen.Wait(2000)
            SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
        end
    end
end)

RegisterNUICallback('escape', function(data, cb)
    local ped = GetPlayerPed(-1) 
    disablechatmdt = false

    EnableControlAction(0, 245, true)
    EnableControlAction(0, 309, true)
    DeleteEntity(tab, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 18905), 0.12, 0.05, 0.13, -10.5, 180.0, 180.0, true, true, false, true, 1, true)
    ClearPedTasksImmediately(ped)    
    Citizen.Wait(1000)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('fetch', function(data, cb)
    ESX.TriggerServerCallback('mdtems:fetch', function( d )
        cb(d)
    end, data, data.type)
end)

RegisterNUICallback('search', function(data, cb)
    ESX.TriggerServerCallback('mdtems:search', function( d )
        cb(d)
    end, data)
end)

RegisterNUICallback('add', function(data, cb)
    ESX.TriggerServerCallback('mdtems:add', function( d )
        cb(d)
    end, data)
end)

RegisterNUICallback('update', function(data, cb)
    ESX.TriggerServerCallback('mdtems:update', function( d )
        cb(d)
    end, data)
end)

RegisterNUICallback('remove', function(data, cb)
    ESX.TriggerServerCallback('mdtems:remove', function( d )
        cb(d)
    end, data)
end)

RegisterCommand('fixmdt',function()
    cerrarmdtems()
end)

