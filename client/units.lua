--================================--
--       POLICE TOOLS v1.1.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--          BLIP MANAGER          --
--================================--

UnitsRadar = {
    serverID = GetPlayerServerId(PlayerId()),
    sentCallsign = false,
    active = {},
    distant = {},
    _panic = {},
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
    if playerID == self.serverID then
        return
    end

    local color = Config.UnitsRadar.colors[type] or Config.UnitsRadar.colors[1]

    if Config.UnitsRadar.usePlayerBlips then
        local player = GetPlayerFromServerId(playerID)
        local wasDistant = self.distant[playerID]
        self.distant[playerID] = (player ~= -1)
        if (wasDistant and not self.distant[playerID]) or (not wasDistant and self.distant[playerID]) then
            self:remove(playerID, false) -- The player's got into your scope / outside your scope -> remove the existing blip, it'll be re-created below with the new parameters
        end
    end

    if self.active[playerID] == nil then
        self.active[playerID] = self.distant[playerID] and AddBlipForCoord(x, y, z) or AddBlipForEntity(GetPlayerPed(player))
        SetBlipScale(self.active[playerID], 0.8)
        SetBlipSprite(self.active[playerID], 57)
        SetBlipCategory(self.active[playerID], 1)
        SetBlipHiddenOnLegend(self.active[playerID], true)
        SetBlipShrink(self.active[playerID], true)
        SetBlipPriority(self.active[playerID], 10)
    elseif self.distant[playerID] then
        SetBlipCoords(self.active[playerID], x, y, z)
    end

    if number then
        ShowNumberOnBlip(self.active[playerID], number)
    end

    SetBlipColour(self.active[playerID], color)
end

function UnitsRadar:remove(playerID, removeDistant)
    if self.active[playerID] then
        RemoveBlip(self.active[playerID])
        self.active[playerID] = nil
        if removeDistant ~= false then
            self.distant[playerID] = nil
        end
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

function UnitsRadar:panic(playerID)
    if self.active[playerID] then
        ClearGpsMultiRoute()
        self._panic[playerID] = true
        SetBlipFlashes(self.active[playerID], true)
        SetBlipFlashInterval(self.active[playerID], 500)
        StartGpsMultiRoute(Config.UnitsRadar.panicColor, true, true)
        AddPointToGpsMultiRoute(GetBlipCoords(self.active[playerID]))
        SetGpsMultiRouteRender(true)
    end
end

function UnitsRadar:clearPanic(playerID)
    playerID = tonumber(playerID)
    if playerID then
        if self._panic[playerID] and self.active[playerID] then
            SetBlipFlashes(self.active[playerID], false)
        end
    else
        for k, v in pairs(self._panic) do
            if self.active[k] then
                SetBlipFlashes(self.active[k], false)
            end
        end
    end
    ClearGpsMultiRoute()
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

RegisterCommand(
    'clearpanic',
    function(source, args, rawCommands)
        local panicID = tonumber(args[1])
        panicID = panicID or nil
        UnitsRadar:clearPanic(panicID)
    end,
    false
)

RegisterCommand(
    'cp',
    function(source, args, rawCommands)
        local panicID = tonumber(args[1])
        panicID = panicID or nil
        UnitsRadar:clearPanic(panicID)
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

if Config.UnitsRadar.panicColor then
    TriggerEvent('chat:addSuggestion', '/panic', 'Triggers the panic button')

    TriggerEvent('chat:addSuggestion', '/clearpanic', 'Clears the panicked units from the map', {
        {
            name = "panicID",
            help = "Specify the panic ID if you only want to remove specific panic from the map"
        }
    })

    TriggerEvent('chat:addSuggestion', '/cp', 'Clears the panicked units from the map', {
        {
            name = "panicID",
            help = "Specify the panic ID if you only want to remove specific panic from the map"
        }
    })
end

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

if Config.UnitsRadar.panicColor then
    RegisterNetEvent('police:panic')
    AddEventHandler(
        'police:panic',
        function(playerID)
            UnitsRadar:panic(playerID)
        end
    )
end

--================================--
--            CLEAN-UP            --
--================================--

RegisterNetEvent('onResourceStart')
AddEventHandler(
    'onResourceStart',
    function(resourceName)
        if resourceName == GetCurrentResourceName() then
            ClearGpsMultiRoute()
        end
    end
)