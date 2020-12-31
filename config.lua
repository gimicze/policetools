--================================--
--       POLICE TOOLS v1.0.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

Config = {}

Config.Tint = {
    allowed = {
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
    callsigns = { -- Sets which marker type (color) should the specified callsign prefix use
        ["L"] = 1, -- e.g. L-21
        ["T"] = 3,
        ["C"] = 2,
        ["G"] = 4,
        ["H"] = 5,
    },
    colors = {
        63,
        25,
        18,
        82,
        65
    },
    enableESX = "police" -- Set to false if you don't want to use ESX jobs
}