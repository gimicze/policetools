--================================--
--       POLICE TOOLS v1.0.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--              CHAT              --
--================================--

function sendMessage(source, text, customName)
	TriggerClientEvent(
		"chat:addMessage",
		source,
		{
			templateId = "policetools",
			args = {
				((customName ~= nil) and customName or "PoliceTools"),
				text
			}
		}
	)
end