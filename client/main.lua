onPlayerDeath = false

AddEventHandler('esx:onPlayerDeath', function()
    local playerId = PlayerPedId()
    local coords = GetEntityCoords(playerId)
    TriggerServerEvent('esx:updateLastPosition', coords)
    onPlayerDeath = true
end)

Citizen.CreateThread(function()
    while true do
        if onPlayerDeath then
            local playerId = PlayerPedId()
            if GetEntityHealth(playerId) > 0 then
                onPlayerDeath = false
            else
                local coords = GetEntityCoords(playerId)
                local onGround, ground = GetGroundZFor_3dCoord(coords['x'], coords['y'], coords['z'], false)
                local _, groundIgnore = GetGroundZFor_3dCoord(coords['x'], coords['y'], coords['z'], true)
                local distanceZ = groundIgnore - ground
                if distanceZ >= 3 then
                    local distance = 0
                    local position = nil
                    for _,val in pairs(Config.position) do
                        local distanceBetween = GetDistanceBetweenCoords(coords, val)
                        if distance == 0 or distance > distanceBetween then
                            distance = distanceBetween
                            position = val
                        end
                    end
                    if distance > 5 then
                        SetEntityCoords(playerId, position['x'], position['y'], position['z'], false, false, false, true)
                        Citizen.Wait(10 * 1000)
                        TriggerServerEvent('esx:updateLastPosition', position)
                    else
                        if not onGround then
                            SetEntityCoords(playerId, position['x'], position['y'], position['z'], false, false, false, true)
                        end
                        Citizen.Wait(10 * 1000)
                    end
                end
            end
        end
        Citizen.Wait(10 * 1000)
    end
end)
