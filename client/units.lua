--================================--
--       POLICE TOOLS v1.0.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--          BLIP MANAGER          --
--================================--

PoliceBlips = {
    sentCallsign = false,
    active = {},
	__index = self
}

function PoliceBlips:updateAll(activeBlips)
    if not sentCallsign then
        sentCallsign = true
        local callsign = GetResourceKvpString("callsign")
        if callsign then
            PoliceBlips:setCallsign(callsign)
        end
    end
    for k, v in pairs(activeBlips) do
        self:update(k, v.coords.x, v.coords.y, v.coords.z, v.type, v.number)
    end
end

function PoliceBlips:update(playerID, x, y, z, type, number)
    if playerID == GetPlayerServerId(PlayerId()) then
        return
    end
    local color = Config.PoliceBlips.colors[type] or Config.PoliceBlips.colors[1]
    if self.active[playerID] == nil then
        self.active[playerID] = AddBlipForCoord(x, y, z)
        SetBlipScale(self.active[playerID], 0.8)
        SetBlipSprite(self.active[playerID], 57)
        SetBlipCategory(self.active[playerID], 1)
        SetBlipHiddenOnLegend(self.active[playerID], true)
        SetBlipShrink(self.active[playerID], true)
        SetBlipPriority(self.active[playerID], 10)
    else
        SetBlipCoords(self.active[playerID], x, y, z)
    end
    if number then
        ShowNumberOnBlip(self.active[playerID], number)
    end
    SetBlipColour(self.active[playerID], color)
end

function PoliceBlips:remove(playerID)
    if self.active[playerID] then
        RemoveBlip(self.active[playerID])
        self.active[playerID] = nil
    end
end

function PoliceBlips:removeAll()
    for k, v in pairs(self.active) do
        self:remove(k)
    end
end

function PoliceBlips:setCallsign(callsign)
    callsign = tostring(callsign)
    if callsign then
        TriggerServerEvent('police:setCallsign', callsign)
        SetResourceKvp("callsign", callsign)
    end
end

--================================--
--            CALLSIGN            --
--================================--

RegisterCommand(
    'callsign',
    function(source, args, rawCommand)
        local callsign = tostring(args[1])
        PoliceBlips:setCallsign(callsign)
    end,
    false
)

--================================--
--              SYNC              --
--================================--

RegisterNetEvent('police:removeBlip')
AddEventHandler(
    'police:removeBlip',
    function(playerID)
        PoliceBlips:remove(playerID)
    end
)

RegisterNetEvent('police:removeBlips')
AddEventHandler(
    'police:removeBlips',
    function()
        PoliceBlips:removeAll()
    end
)

RegisterNetEvent('police:updateBlips')
AddEventHandler(
    'police:updateBlips',
    function(blips)
        PoliceBlips:updateAll(blips)
    end
)