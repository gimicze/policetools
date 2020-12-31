--================================--
--       POLICE TOOLS v1.1.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

function GetNearestVehicle(x, y, z, radius)
    if not (x and y and z) then
        return false
    end
    radius = radius or 2.0

    local shapeTest = StartShapeTestCapsule(x, y, z, x, y, z, radius, 10, PlayerPedId(), 7)
    local _, hit, _, _, entity = GetShapeTestResult(shapeTest)

    return (hit == 1 and IsEntityAVehicle(entity)) and entity or false
end

--================================--
--              CHAT              --
--================================--

function sendMessage(text, name)
    name = name or "Police Tools"
	TriggerEvent(
		"chat:addMessage",
		{
			templateId = "policetools",
			args = {
				name,
				text
			}
		}
	)
end