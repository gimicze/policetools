--================================--
--       POLICE TOOLS v1.1.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--          BLIP MANAGER          --
--================================--

UnitsRadar = {
    sentCallsign = false,
    active = {},
	__index = self
}

function UnitsRadar:updateAll(activeBlips)
    if not self.sentCallsign then
        self.sentCallsign = true
        self:sendCallsign()
    end
    for k, v in pairs(activeBlips) do
        self:update(k, v.coords.x, v.coords.y, v.coords.z, v.type, v.number)
    end
end

function UnitsRadar:update(playerID, x, y, z, type, number)
    if playerID == GetPlayerServerId(PlayerId()) then
        return
    end
    local color = Config.UnitsRadar.colors[type] or Config.UnitsRadar.colors[1]
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

function UnitsRadar:remove(playerID)
    if self.active[playerID] then
        RemoveBlip(self.active[playerID])
        self.active[playerID] = nil
    end
end

function UnitsRadar:removeAll()
    self.sentCallsign = false
    for k, v in pairs(self.active) do
        self:remove(k)
    end
end

function UnitsRadar:setCallsign(callsign)
    callsign = tostring(callsign)
    if callsign then
        TriggerServerEvent('police:setUnitCallsign', callsign)

        local letter = callsign:sub(1,1)
        local number = tonumber(callsign:sub(3))

        if number and Config.UnitsRadar.callsigns[letter] then
            SetResourceKvp("callsign", callsign)
        end
    end
end

function UnitsRadar:sendCallsign()
    local callsign = GetResourceKvpString("callsign")
    if callsign then
        UnitsRadar:setCallsign(callsign)
    end
end

--================================--
--            COMMANDS            --
--================================--

RegisterCommand(
    'callsign',
    function(source, args, rawCommand)
        local callsign = tostring(args[1])
        UnitsRadar:setCallsign(callsign)
    end,
    false
)

RegisterCommand(
    'cs',
    function(source, args, rawCommand)
        local callsign = tostring(args[1])
        UnitsRadar:setCallsign(callsign)
    end,
    false
)

TriggerEvent('chat:addSuggestion', '/callsign', 'Changes your callsign shown on the map', {
	{
		name = "callsign",
		help = "Your callsign (e.g. L-1)"
	}
})

TriggerEvent('chat:addSuggestion', '/cs', 'Changes your callsign shown on the map', {
	{
		name = "callsign",
		help = "Your callsign (e.g. L-1)"
	}
})

--================================--
--             BIGMAP             --
--================================--

local stopBigmap = nil

RegisterCommand(
    '+bigmap',
    function()
        SetBigmapActive(true, false)
    end,
    false
)

RegisterCommand(
    '-bigmap',
    function()
        SetBigmapActive(false, false)
    end,
    false
)

RegisterKeyMapping('+bigmap', 'Expand / shrink minimap', 'keyboard', Config.UnitsRadar.bigmapKey)

--================================--
--              SYNC              --
--================================--

RegisterNetEvent('police:removeUnit')
AddEventHandler(
    'police:removeUnit',
    function(playerID, unsubscribe)
        UnitsRadar:remove(playerID)
    end
)

RegisterNetEvent('police:removeBlips')
AddEventHandler(
    'police:removeBlips',
    function()
        UnitsRadar:removeAll()
    end
)

RegisterNetEvent('police:updateBlips')
AddEventHandler(
    'police:updateBlips',
    function(blips)
        UnitsRadar:updateAll(blips)
    end
)

RegisterNetEvent('police:requestUnitInfo')
AddEventHandler(
    'police:requestUnitInfo',
    function()
        UnitsRadar:sendCallsign()
    end
)