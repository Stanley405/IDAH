local disPlayerNames = 5
local playerDistances = {}
local displayToggle = false
local lastToggleTime = 0

local function DrawText3D(position, text, r, g, b, offset) 
    local onScreen, _x, _y = World3dToScreen2d(position.x, position.y, position.z + 1 + offset)
    local dist = #(GetGameplayCamCoords() - position)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.5 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

Citizen.CreateThread(function()
    Wait(500)
    while true do
        local isInsertPressed = IsControlPressed(0, 121)
        local isControlPressed = IsControlPressed(0, 177)

        if isControlPressed and isInsertPressed then
            if not lastToggleTime then lastToggleTime = GetGameTimer() end -- Initialize last toggle time

            if GetGameTimer() - lastToggleTime > 1500 then -- Check if they've been held for more than 1.5 seconds
                displayToggle = not displayToggle
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)  -- Play a sound on toggle
                lastToggleTime = GetGameTimer()
            end
        else
            lastToggleTime = nil
        end

        local shouldDisplay = displayToggle or isInsertPressed

        if shouldDisplay then
            for _, id in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(id)
                if playerDistances[id] and playerDistances[id] < disPlayerNames then
                    local targetPedCords = GetEntityCoords(targetPed)
                    local serverId = GetPlayerServerId(id)
                    local playerName = GetPlayerName(id)

                    if NetworkIsPlayerTalking(id) then
                        DrawText3D(targetPedCords, serverId, 251, 177, 51, 0.235)
                        DrawText3D(targetPedCords, playerName, 251, 177, 51, 0.13)
                    else
                        DrawText3D(targetPedCords, serverId, 255, 255, 255, 0.235)
                        DrawText3D(targetPedCords, playerName, 255, 255, 255, 0.13)
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, id in ipairs(GetActivePlayers()) do
            local targetPed = GetPlayerPed(id)
            local distance = #(playerCoords - GetEntityCoords(targetPed))
            playerDistances[id] = distance
        end
        Wait(1000)
    end
end)
