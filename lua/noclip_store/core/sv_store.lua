-- Probably a better name for this function?
function NoClip.Store.Core.Check()
	-- Check the API using the config values
	http.Fetch(string.format("%s/api/v1/servers/%s/events?api_key=%s", NoClip.Store.Config.URL, NoClip.Store.Config.ServerID, NoClip.Store.Config.APIKey),
		function(body, size, headers, code)
			local data = util.JSONToTable(body)
			-- Seems we received some unexpected data
			if not data then
				NoClip.Store.Core.Error("Invalid JSON response from API /events route!")
				return 
			end

			-- Broadcast it in a hook, to allow other devs to do stuff
			hook.Run("NoClipStoreCheck", data)

			-- Have all the events processed
			for k, v in ipairs(data.data) do
				NoClip.Store.Core.EventProcess(v)
			end
		end
	)
end

function NoClip.Store.Core.EventProcess(data)
	-- Allow for this event to be blocked
	local block = hook.Run("NoClipStorePreEventProcess", data.id, data)
	if block == false then return end -- A hook has killed this process

	-- Run the actions for this event
	for k, v in ipairs(data.package.actions.data) do
		local typeFunc = NoClip.Store.Types[v.type]
		if not typeFunc then
			NoClip.Store.Core.Error("Attempted to process an action but the type function was not found.")
			continue
		end

		typeFunc(data.receiver_game_id, false, v)
	end
	
	--
	--- Possibly some kind of thing to notify everyone/the player of their reward?
	--- Possibly a UI? Or even maybe like a small firework particle around the player?
	--- Gotta give that Dopamine rush!
	--

	NoClip.Store.Core.EventMarkProcessed(data.id)
end


function NoClip.Store.Core.EventMarkProcessed(eventID)
	http.Post(string.format("%s/api/v1/servers/%s/events/%s/process?api_key=%s", NoClip.Store.Config.URL, NoClip.Store.Config.ServerID, eventID, NoClip.Store.Config.APIKey))
end

-- NoClip.Store.Core.Check()
-- lua_run NoClip.Store.Core.Check()