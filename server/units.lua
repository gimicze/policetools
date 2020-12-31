--================================--
--       POLICE TOOLS v1.1.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--          BLIP MANAGER          --
--================================--

UnitsRadar = {
    active = {},
    subscribers = {},
	__index = self,
	init = function(o)
		o = o or {active = {}}
		setmetatable(o, self)
		self.__index = self
		return o
	end
}

function UnitsRadar:subscribe(serverID) 
    self.subscribers[serverID] = true
end

function UnitsRadar:unsubscribe(serverID) 
    self.subscribers[serverID] = nil
end

function UnitsRadar:addUnit(serverID, type, number, subscribe)
    type = tonumber(type) or 1
    self.active[serverID] = {
        type = type,
        number = number
    }
    if subscribe ~= false then
        self:subscribe(serverID)
    end
end

function UnitsRadar:setUnitNumber(serverID, number)
    number = tonumber(number)
    if not number then
        return
    end
    if self.active[serverID] then
        self.active[serverID].number = number
    end
end

function UnitsRadar:setUnitType(serverID, type)
    type = tonumber(type)
    if not type then
        return
    end
    if self.active[serverID] then
        self.active[serverID].type = type
    end
end

function UnitsRadar:setCallsign(serverID, callsign)
    if not callsign then
        return
    end

    local letter = callsign:sub(1,1)
    local number = tonumber(callsign:sub(3))

    if not number or not Config.UnitsRadar.callsigns[letter] then
        return false
    end

    UnitsRadar:setUnitNumber(serverID, number)
    UnitsRadar:setUnitType(serverID, Config.UnitsRadar.callsigns[letter])
    return true
end

function UnitsRadar:removeUnit(serverID, unsubscribe)
    if self.active[serverID] then
        self.active[serverID] = nil
        if unsubscribe ~= false then
            TriggerClientEvent('police:removeBlips', serverID)
            self:unsubscribe(serverID)
        end
        for k, v in pairs(self.subscribers) do
            TriggerClientEvent('police:removeUnit', k, serverID)
        end
    end
end

function UnitsRadar:hide()
    if self.blips then
        self.blips = false
    end
end

function UnitsRadar:hideUnit(serverID)
    if self.active[serverID] then
        self:removeUnit(serverID, false)
    end
end

function UnitsRadar:showUnit(serverID)
    if not self.active[serverID] then
        self:addUnit(serverID, nil, nil, false)
        self:requestInfo(serverID)
    end
end

function UnitsRadar:requestInfo(serverID)
    if self.active[serverID] then
        TriggerClientEvent('police:requestUnitInfo', serverID)
    end
end

function UnitsRadar:updateBlips(frequency)
    frequency = tonumber(frequency) or 3000
    self.blips = true
    Citizen.CreateThread(
        function()
            while self.blips do
                Citizen.Wait(frequency)
                for k, v in pairs(self.active) do
                    self.active[k].coords = GetEntityCoords(GetPlayerPed(k))
                end
                for k, v in pairs(self.subscribers) do
                    TriggerClientEvent('police:updateBlips', k, self.active)
                end
            end
            for k, v in pairs(self.subscribers) do
                TriggerClientEvent('police:removeBlips', k)
            end
        end
    )
    return function()
        self.blips = false
    end
end

UnitsRadar:updateBlips()

--================================--
--              SYNC              --
--================================--

RegisterNetEvent('playerDropped')
AddEventHandler(
	'playerDropped',
    function()
        UnitsRadar:removeUnit(source)
    end
)

RegisterNetEvent('police:addUnit')
AddEventHandler(
    'police:addUnit',
    function(serverID, type, number)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 or not GetPlayerIdentifier(serverID, 0) then
            return
        end
        type = tonumber(type) or 1
        UnitsRadar:addUnit(serverID, type, number)
    end
)

RegisterNetEvent('police:removeUnit')
AddEventHandler(
    'police:removeUnit',
    function(serverID, type)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 then
            return
        end
        UnitsRadar:removeUnit(serverID)
    end
)

RegisterNetEvent('police:setUnitCallsign')
AddEventHandler(
    'police:setUnitCallsign',
    function(callsign, callback)
        if source < 1 then
            return
        end
        if not UnitsRadar:setCallsign(source, callsign) then
            sendMessage(source, "Not a valid callsign.")
        else
            sendMessage(source, ("Changed callsign to %s."):format(callsign))
        end
    end
)

--================================--
--            COMMANDS            --
--================================--

RegisterCommand(
	'policeblip',
	function(source, args, rawCommand)
		local _source = source
		local action = args[1]
		local serverId = tonumber(args[2])

		if not action then
			return
		end

        if action == "add" or action == "remove" then
            if not serverId or serverId < 1 then
                return
            end

            local identifier = GetPlayerIdentifier(serverId, 0)

            if not identifier then
                sendMessage(source, "Player not online.")
                return
            end
        end

        if action == "add" then
            local type = tonumber(args[3]) or 1
			UnitsRadar:addUnit(serverId, type)
			sendMessage(source, ("Subscribed %s to police radar."):format(GetPlayerName(serverId)))
        elseif action == "remove" then
            UnitsRadar:removeUnit(serverId)
            sendMessage(source, ("Unsubscribed %s from police radar."):format(GetPlayerName(serverId)))
        elseif action == "hide" then
            local userId = (serverId and serverId > 0) and serverId or source
            UnitsRadar:hideUnit(userId)
			sendMessage(source, ("Hidden %s on the police radar."):format(userId == source and "yourself" or GetPlayerName(serverId)))
        elseif action == "show" then
            local userId = (serverId and serverId > 0) and serverId or source
            UnitsRadar:showUnit(userId)
			sendMessage(source, ("Shown %s on the police radar."):format(userId == source and "yourself" or GetPlayerName(serverId)))
        elseif action == "off" then
            UnitsRadar:hide()
        elseif action == "on" then
            UnitsRadar:updateBlips()
        else
			sendMessage(source, "Invalid action.")
		end
	end,
	true
)

--================================--
--         AUTO-SUBSCRIBE         --
--================================--

if Config.UnitsRadar.enableESX then
    ESX = nil

    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

    RegisterNetEvent("esx:setJob")
    AddEventHandler(
        "esx:setJob",
        function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
    
            if xPlayer.job.name == Config.UnitsRadar.enableESX then
                UnitsRadar:addUnit(source)
            elseif UnitsRadar.active[source] then
                UnitsRadar:removeUnit(source)
            end
        end
    )
    
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler(
        "esx:playerLoaded",
        function(source, xPlayer)    
            if xPlayer.job.name == Config.UnitsRadar.enableESX and not UnitsRadar.active[source] then
                UnitsRadar:addUnit(source)
            elseif UnitsRadar.active[source] then
                UnitsRadar:removeUnit(source)
            end
        end
    )
end