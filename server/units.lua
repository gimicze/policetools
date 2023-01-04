--================================--
--       POLICE TOOLS v1.1.8      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--          BLIP MANAGER          --
--================================--

UnitsRadar = {
    active = {},
    subscribers = {},
    callsigns = {},
	__index = self,
	init = function(o)
		o = o or {active = {}, subscribers = {}, callsigns = {}}
		setmetatable(o, self)
		self.__index = self
		return o
	end
}

function UnitsRadar:subscribe(serverID) -- Allows to "spectate" units radar without being shown on the map
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

    local letEnd, numStart = callsign:find("-")

    if not letEnd then
        return false
    end

    local letter = callsign:sub(1, letEnd - 1)
    local number = tonumber(callsign:sub(numStart + 1))

    if not number or not Config.UnitsRadar.callsigns[letter] or number > 99 then
        return false
    end

    if Config.UnitsRadar.announceDuty and self.callsigns[serverID] == nil then
        for k, v in pairs(self.subscribers) do
            sendMessage(k, ("%s is now on duty."):format(callsign), "Radar")
        end
    elseif not Config.UnitsRadar.announceDuty then
        sendMessage(serverID, "You're now shown on duty.", "Radar")
    end

    self.callsigns[serverID] = callsign

    UnitsRadar:setUnitNumber(serverID, number)
    UnitsRadar:setUnitType(serverID, Config.UnitsRadar.callsigns[letter])
    return true
end

function UnitsRadar:removeUnit(serverID, unsubscribe)
    if self.active[serverID] then
        for k, v in pairs(self.subscribers) do
            if Config.UnitsRadar.announceDuty and self.callsigns[serverID] then
                sendMessage(k, ("%s went off duty."):format(self.callsigns[serverID]), "Radar")
            end
            TriggerClientEvent('police:removeUnit', k, serverID)
        end
        sendMessage(serverID, "You're now shown off duty.", "Radar")
        if unsubscribe ~= false then
            self:unsubscribe(serverID)
            TriggerClientEvent('police:removeBlips', serverID)
        end
        self.active[serverID] = nil
        self.callsigns[serverID] = nil
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

function UnitsRadar:panic(serverID)
    local success = false
    if self.active[serverID] then
        for k, v in pairs(self.subscribers) do
            local message = self.callsigns[serverID] and ("Unit %s triggered panic button! Panic #%s"):format(self.callsigns[serverID], serverID) or ("A unit triggered panic button! Panic #%s"):format(serverID)
            sendMessage(k, message, "Panic Button")
            TriggerClientEvent('police:panic', k, serverID)
        end
        success = true
    end
    return success
end

function UnitsRadar:updateBlips(frequency)
    frequency = tonumber(frequency) or 3000
    self.blips = true
    Citizen.CreateThread(
        function()
            while self.blips do
                Citizen.Wait(frequency)
                local playerPed = nil
                for k, v in pairs(self.active) do
                    playerPed = GetPlayerPed(k)
                    self.active[k].coords = GetEntityCoords(playerPed)
                    self.active[k].heading = math.ceil(GetEntityHeading(playerPed))
                end
                playerPed = nil
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
    function(serverID, type, number, subscribe)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 or not GetPlayerIdentifier(serverID, 0) then
            return
        end
        type = tonumber(type) or 1
        UnitsRadar:addUnit(serverID, type, number, subscribe)
    end
)

RegisterNetEvent('police:hideUnit')
AddEventHandler(
    'police:hideUnit',
    function(serverID)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 then
            return
        end
        UnitsRadar:hideUnit(serverID)
    end
)

RegisterNetEvent('police:showUnit')
AddEventHandler(
    'police:showUnit',
    function(serverID)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 then
            return
        end
        UnitsRadar:shotUnit(serverID)
    end
)

RegisterNetEvent('police:subscribe')
AddEventHandler(
    'police:subscribe',
    function(serverID)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 then
            return
        end
        UnitsRadar:subscribe(serverID)
    end
)

RegisterNetEvent('police:unsubscribe')
AddEventHandler(
    'police:unsubscribe',
    function(serverID)
        serverID = tonumber(serverID)
        if source > 0 or not serverID or serverID < 1 then
            return
        end
        UnitsRadar:unsubscribe(serverID)
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
            sendMessage(source, ("Callsign set to %s."):format(callsign))
        end
    end
)

--================================--
--            COMMANDS            --
--================================--

if Config.UnitsRadar.panicColor then
    RegisterCommand(
        'panic',
        function(source, args, rawCommand)
            if source > 0 then
                local success = UnitsRadar:panic(source)
                if not success then
                    sendMessage(source, "You cannot use the panic button.", "Panic Button")
                end
            end
        end,
        false
    )
end

RegisterCommand(
	'policeblip',
	function(source, args, rawCommand)
		local _source = source
		local action = args[1]
		local serverId = tonumber(args[2])

		if not action then
			return
		end

        if action == "add" or action == "remove" or action == "hide" or action == "show" then
            if not serverId or serverId < 1 then
                return
            end

            local identifier = GetPlayerIdentifier(serverId, 0)

            if not identifier then
                sendMessage(source, "Player not online.")
                return
            end

            serverId = (serverId and serverId > 0) and serverId or source
        end

        if action == "add" then
            local type = tonumber(args[3]) or 1
			UnitsRadar:addUnit(serverId, type)
			sendMessage(source, ("Subscribed %s to police radar."):format(GetPlayerName(serverId)))
        elseif action == "remove" then
            UnitsRadar:removeUnit(serverId)
            sendMessage(source, ("Unsubscribed %s from police radar."):format(GetPlayerName(serverId)))
        elseif action == "hide" then
            UnitsRadar:hideUnit(serverId)
			sendMessage(source, ("Hidden %s on the police radar."):format(serverId == source and "yourself" or GetPlayerName(serverId)))
        elseif action == "show" then
            UnitsRadar:showUnit(serverId)
			sendMessage(source, ("Shown %s on the police radar."):format(serverId == source and "yourself" or GetPlayerName(serverId)))
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

if Config.UnitsRadar.ESXJobs then
    ESX = exports['es_extended']:getSharedObject()

    Config.UnitsRadar.ESXrequireItem = Config.UnitsRadar.ESXrequireItem and tostring(Config.UnitsRadar.ESXrequireItem) or false

    local allowedJobs = {}

    if type(Config.UnitsRadar.ESXJobs) == "table" then
        for k, v in pairs(Config.UnitsRadar.ESXJobs) do
            allowedJobs[v] = true
        end
    else
        allowedJobs[Config.UnitsRadar.ESXJobs] = true
    end

    RegisterNetEvent("esx:setJob")
    AddEventHandler("esx:setJob", function(playerId)
            local xPlayer = ESX.GetPlayerFromId(playerId)

            if xPlayer then
                local hasItem = Config.UnitsRadar.ESXrequireItem and xPlayer.getInventoryItem(Config.UnitsRadar.ESXrequireItem).count > 0 or true
    
                if allowedJobs[xPlayer.job.name] and hasItem then
                    UnitsRadar:addUnit(playerId)
                elseif UnitsRadar.active[playerId] then
                    UnitsRadar:removeUnit(playerId)
                end
            end
        end
    )
    
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler("esx:playerLoaded", function(playerId)
            local xPlayer = ESX.GetPlayerFromId(playerId)

            if xPlayer then
                local hasItem = Config.UnitsRadar.ESXrequireItem and xPlayer.getInventoryItem(Config.UnitsRadar.ESXrequireItem).count > 0 or true
                
                if allowedJobs[xPlayer.job.name] and hasItem then
                    UnitsRadar:addUnit(playerId)
                elseif UnitsRadar.active[playerId] then
                    UnitsRadar:removeUnit(playerId)
                end
            end
        end
    )

    if Config.UnitsRadar.ESXrequireItem then
        ESX.RegisterUsableItem(Config.UnitsRadar.ESXrequireItem, function(source)
                local xPlayer = ESX.GetPlayerFromId(source)

                if allowedJobs[xPlayer.job.name] and not UnitsRadar.active[source] then
                    UnitsRadar:addUnit(source)
                elseif UnitsRadar.active[source] then
                    UnitsRadar:removeUnit(source)
                end
            end
        )
    end
end

if Config.UnitsRadar.QBCoreJobs then
    QBCore = exports['qb-core']:GetCoreObject()

    Config.UnitsRadar.QBCorerequireItem = Config.UnitsRadar.QBCorerequireItem and tostring(Config.UnitsRadar.QBCorerequireItem) or false

    local allowedJobs = {}

    if type(Config.UnitsRadar.QBCoreJobs) == "table" then
        for k, v in pairs(Config.UnitsRadar.QBCoreJobs) do
            allowedJobs[v] = true
        end
    else
        allowedJobs[Config.UnitsRadar.QBCoreJobs] = true
    end

    RegisterNetEvent("QBCore:Client:OnJobUpdate")
    AddEventHandler("QBCore:Client:OnJobUpdate", function(playerId)
            local xPlayer = QBCore.Functions.GetPlayer(playerId)

            if xPlayer then
                local hasItem = Config.UnitsRadar.QBCorerequireItem and xPlayer.getInventoryItem(Config.UnitsRadar.QBCorerequireItem).count > 0 or true
    
                if allowedJobs[xPlayer.job.name] and hasItem then
                    UnitsRadar:addUnit(playerId)
                elseif UnitsRadar.active[playerId] then
                    UnitsRadar:removeUnit(playerId)
                end
            end
        end
    )
    
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
    AddEventHandler("QBCore:Client:OnPlayerLoaded", function(playerId)
            local xPlayer = QBCore.Functions.GetPlayer(playerId)

            if xPlayer then
                local hasItem = Config.UnitsRadar.QBCorerequireItem and xPlayer.getInventoryItem(Config.UnitsRadar.QBCorerequireItem).count > 0 or true
                
                if allowedJobs[xPlayer.job.name] and hasItem then
                    UnitsRadar:addUnit(playerId)
                elseif UnitsRadar.active[playerId] then
                    UnitsRadar:removeUnit(playerId)
                end
            end
        end
    )

    if Config.UnitsRadar.QBCorerequireItem then
        QBCore.Functions.AddItem(Config.UnitsRadar.QBCorerequireItem, {
            name = Config.UnitsRadar.QBCorerequireItem,
            label = Config.UnitsRadar.QBCoreitemname,
            weight = 2,
            type = 'item',
            image = Config.UnitsRadar.QBCoreImageName,
            unique = false,
            useable = true,
            shouldClose = true,
            combinable = nil,
            description = 'Tracker for the police'
        })        
        local canUse = QBCore.Functions.CanUseItem(Config.UnitsRadar.QBCorerequireItem)
        if not canUse then return end
        local xPlayer = QBCore.Functions.GetPlayer(source)

        if allowedJobs[xPlayer.job.name] and not UnitsRadar.active[source] then
            UnitsRadar:addUnit(source)
        elseif UnitsRadar.active[source] then
            UnitsRadar:removeUnit(source)
        end
    end
end