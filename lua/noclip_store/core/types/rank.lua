-- Ranks
-- Also need to account for a lot more admin systems
NoClip.Store.Core.RegisterType("rank", function(ply, expired, data)
	local rank = expired and (data.data.rank_expire or "") or data.data.rank_to_give
	if (not rank) or (rank == "") then return end

	-- ULIB/ULX (https://github.com/TeamUlysses/ulx)
	if ULib then
		ULib.ucl.addUser(ply:SteamID(), nil, nil, rank)

	-- xAdmin (https://github.com/TheXYZNetwork/xAdmin)
	elseif xAdmin and xAdmin.Github then
		ply:SetUserGroup(rank)

	-- SAM (https://www.gmodstore.com/market/view/sam)
	elseif sam then
		ply:sam_set_rank(rank)

	-- No admin system found
	else
		NoClip.Store.Core.Error("Attempted to assign "..ply:SteamID().." the rank "..rank..", but no admin system was found.")
	end
end)