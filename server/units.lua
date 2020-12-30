--================================--
--       POLICE TOOLS v1.0.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--          BLIP MANAGER          --
--================================--

PoliceBlips = {
	active = {},
	__index = self,
	init = function(o)
		o = o or {active = {}}
		setmetatable(o, self)
		self.__index = self
		return o
	end
}

function PoliceBlips:add(serverID, type, number)
    type = tonumber(type) or 1
    self.active[serverID] = {
        type = type,
        number = number
    }
end

function PoliceBlips:setNumber(serverID, number)
    number = tonumber(number)
    if not number then
        return
    end
    if self.active[serverID] then
        self.active[serverID].number = number
    end
end

function PoliceBlips:setType(serverID, type)
    type = tonumber(type)
    if not type then
        return
    end
    if self.active[serverID] then
        self.active[serverID].type = type
    end
end

function PoliceBlips:setCallsign(serverID, callsign)
    if not callsign then
        return
    end

    local letter = callsign:sub(1,1)
    local number = tonumber(callsign:sub(3))

    if not number or not Config.PoliceBlips.callsigns[letter] then
        return false
    end

    PoliceBlips:setNumber(serverID, number)
    PoliceBlips:setType(serverID, Config.PoliceBlips.callsigns[letter])
    return true
end

function PoliceBlips:remove(serverID)
    if self.active[serverID] then
        self.active[serverID] = nil
        TriggerClientEvent('police:removeBlips', serverID)
        for k, v in pairs(self.active) do
            TriggerClientEvent('police:removeBlip', k, serverID)
        end
    end
end

function PoliceBlips:hide()
    if self.blips then
        self.blips = false
    end
end

function PoliceBlips:updateBlips(frequency)
    frequency = tonumber(frequency) or 3000
    self.blips = true
    Citizen.CreateThread(
        function()
            while self.blips do
                Citizen.Wait(frequency)
                for k, v in pairs(self.active) do
                    self.active[k].coords = GetEntityCoords(GetPlayerPed(k))
                end
                for k, v in pairs(self.active) do
                    TriggerClientEvent('police:updateBlips', k, self.active)
                end
            end
            for k, v in pairs(self.active) do
                TriggerClientEvent('police:removeBlips', k)
            end
        end
    )
    return function()
        self.blips = false
    end
end

PoliceBlips:updateBlips()

--================================--
--              SYNC              --
--================================--

RegisterNetEvent('playerDropped')
AddEventHandler(
	'playerDropped',
    function()
        PoliceBlips:remove(source)
    end
)

RegisterNetEvent('police:addPlayerBlip')
AddEventHandler(
    'police:addPlayerBlip',
    function(serverID, type, number)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 or not GetPlayerIdentifier(serverID, 0) then
            return
        end
        type = tonumber(type) or 1
        PoliceBlips:add(serverID, type, number)
    end
)

RegisterNetEvent('police:addPlayerBlip')
AddEventHandler(
    'police:removePlayerBlip',
    function(serverID, type)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 then
            return
        end
        PoliceBlips:remove(serverID)
    end
)

RegisterNetEvent('police:setCallsign')
AddEventHandler(
    'police:setCallsign',
    function(callsign, callback)
        if source < 1 then
            return
        end
        if not PoliceBlips:setCallsign(source, callsign) then
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
			PoliceBlips:add(serverId, type)
			sendMessage(source, ("Subscribed %s to police radar."):format(GetPlayerName(serverId)))
        elseif action == "remove" then
            PoliceBlips:remove(serverId)
			sendMessage(source, ("Unsubscribed %s from police radar."):format(GetPlayerName(serverId)))
        elseif action == "off" then
            PoliceBlips:hide()
        elseif action == "on" then
            PoliceBlips:updateBlips()
        else
			sendMessage(source, "Invalid action.")
		end
	end,
	true
)

--================================--
--         AUTO-SUBSCRIBE         --
--================================--

if Config.PoliceBlips.enableESX then
    ESX = nil

    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

    RegisterNetEvent("esx:setJob")
    AddEventHandler(
        "esx:setJob",
        function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
    
            if xPlayer.job.name == Config.PoliceBlips.enableESX then
                PoliceBlips:add(source)
            elseif PoliceBlips.active[source] then
                PoliceBlips:remove(source)
            end
        end
    )
    
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler(
        "esx:playerLoaded",
        function(source, xPlayer)    
            if xPlayer.job.name == Config.PoliceBlips.enableESX and not PoliceBlips.active[source] then
                PoliceBlips:add(source)
            elseif PoliceBlips.active[source] then
                PoliceBlips:remove(source)
            end
        end
    )
end