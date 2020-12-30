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
	__index = self
}

function PoliceBlips:updateAll(activeBlips)
    for k, v in pairs(activeBlips) do
        self:update(k, v.coords.x, v.coords.y, v.coords.z, v.type)
    end
end

function PoliceBlips:update(playerID, x, y, z, type)
    if playerID == GetPlayerServerId(PlayerPedId()) then
        return
    end
    local color = Config.PoliceBlips.colors[type] or 12
    if self.active[playerID] == nil then
        self.active[playerID] = AddBlipForCoord(x, y, z)
        SetBlipScale(self.active[playerID], 1.0)
        SetBlipSprite(self.active[playerID], 526)
        SetBlipCategory(self.active[playerID], 7)
        SetBlipHiddenOnLegend(self.active[playerID], true)
        SetBlipShrink(self.active[playerID], true)
    else
        SetBlipCoords(self.active[playerID], x, y, z)
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