--================================--
--       POLICE TOOLS v1.1.3      --
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
    panicColor = 6, -- The color of the route to a panic; See "HUD Colors" (https://wiki.rage.mp/index.php?title=Fonts_and_Colors)
    enableESX = "police", -- Set to false if you don't want to use ESX jobs, if you do you can change this to the name of your police job
    requireItem = "gps", -- Enabled only if you're using ESX (enableESX must be filled in); Sets the required item for the dispatch to register officers onto the map, registers it as usable -> officers may use the item to turn the radar on if it wasn't turned on automatically
    bigmapKey = "x" -- Sets the default keybind to show big minimap (set to nil if you don't want to set any default bind)
}