--================================--
--       POLICE TOOLS v1.1.0      --
--            by GIMI             --
--      License: GNU GPL 3.0      --
--================================--

--================================--
--              CHAT              --
--================================--

function sendMessage(source, text, name)
	TriggerClientEvent(
		"chat:addMessage",
		source,
		{
			templateId = "policetools",
			args = {
				name or "PoliceTools",
				text
			}
		}
	)
end