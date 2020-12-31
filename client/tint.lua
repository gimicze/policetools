--================================--
--       POLICE TOOLS v1.1.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

local windowTints = {
    "Stock", -- Stock
    "None", -- None
    "Pure Black", -- Pure Black
    "Dark Smoke", -- Dark Smoke
    "Light Smoke", -- Light Smoke
    "Stock", -- Stock
    "Limo", -- Limo
    "Green" -- Green
}

--================================--
--           FUNCTIONS            --
--================================--

function CheckNearestVehicleWindowTint()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = GetNearestVehicle(table.unpack(coords))
    
    if vehicle then
        local tint = GetVehicleWindowTint(vehicle) + 2
        local message = Config.Tint.allowed[tint] and ("Window tint within range. (%s)"):format(windowTints[tint]) or ("Window tint exceeds allowed range. (%s)"):format(windowTints[tint])
        sendMessage(message, "Tint Meter")
        return tint
    else
        sendMessage("No vehicle nearby.", "Tint Meter")
        return false
    end
end

--================================--
--            COMMANDS            --
--================================--

RegisterCommand(
    'tint',
    function(source, args, rawCommand)
        CheckNearestVehicleWindowTint()
    end,
    false
)