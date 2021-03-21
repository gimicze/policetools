--================================--
--       POLICE TOOLS v1.1.6      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

Config = {}

Config.Tint = {
    allowed = { -- Set any of these to false to be shown as illegal by the script
        true, -- Stock
        true, -- None
        false, -- Pure Black
        true, -- Dark Smoke
        true, -- Light Smoke
        true, -- Stock
        true, -- Limo
        true -- Green
    }
}

Config.UnitsRadar = {
    callsigns = { -- Sets which marker type (see colors below) should the specified callsign prefix use
        ["L"] = 1, -- e.g. L-21
        ["T"] = 3,
        ["C"] = 2,
        ["G"] = 4,
        ["H"] = 5,
    },
    colors = {
        63, -- Type 1 (set above to callsign prefix "L")
        25, -- Type 2
        18, -- etc.
        82,
        65
    },
    panicColor = 10, -- The color of the route to a panic - set to false or nil if you don't want to enable /panic; See "HUD Colors" (https://wiki.rage.mp/index.php?title=Fonts_and_Colors)
    enableESX = "police", -- Set to false if you don't want to use ESX jobs, if you do you can change this to the name of your police job; Can be a table containing a list of allowed jobs - for example {'police', 'ambulance'}
    requireItem = false, -- Enabled only if you're using ESX (enableESX must be filled in); Sets the required item for the dispatch to register officers onto the map, registers it as usable -> officers may use the item to turn the radar on if it wasn't turned on automatically
    bigmapKey = false, -- Set to a specific key to automatically bind the extend / shrink functionality of the minimap; Set to false if you don't want to use the functionality; Set to true if you don't want to set default keybind
    usePlayerBlips = true, -- When true, the script will only show blips for distant players (OneSync Infinity/Beyond)
    announceDuty = true -- Set to true if you want to send every unit a message about other units going on/off duty
}