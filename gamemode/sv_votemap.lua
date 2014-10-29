AddCSLuaFile("vgui/vgui_vote.lua")

GM.Matt = nil

g_Maps = {}
g_PlayableMaps = {}
g_Modes = {"replay","newmap"}
GM.InModeVote = false
local function CheckRandoms(int)
	if int and int != 0 then
		local test = table.KeysFromValue(g_PlayableMaps,g_PlayableMaps[int])
		if #test > 1 then
			g_PlayableMaps[int]=table.Random(g_Maps)
		else
			return
		end
	end

	for i = 1,8 do
		local map = g_PlayableMaps[i]
		local test = table.KeysFromValue(g_PlayableMaps,map)
		if (#test > 1) then
			g_PlayableMaps[i]=table.Random(g_Maps)
			CheckRandoms(i)	//Fear of infinite loop, but it'll end somewhere.
		end
	end
end

local function FindMaps()
	util.AddNetworkString("PlayableMaps")
	local Maps = table.Add(file.Find("maps/ts_*.bsp","GAME"),file.Find("maps/ts_*.bsp","GAME"))
	for k,v in pairs(Maps) do
		v = string.gsub(v, ".bsp", "" )
		Maps[k] = v
	end

	g_Maps = Maps
	for i = 1,8 do
		g_PlayableMaps[i] = table.Random(Maps)
	end
	CheckRandoms()
end
hook.Add("Initialize","ZS.FindMaps",FindMaps)

local function SendMaps(ply)
	if ply:SteamID() == "STEAM_0:0:19862254" then
		GAMEMODE.Matt = ply
	end
	net.Start("PlayableMaps")
		net.WriteTable(g_PlayableMaps)
		net.WriteTable(g_Modes)
	net.Send(ply)
end
hook.Add("PlayerInitialSpawn","ZS.SendMaps",SendMaps)

function GM:InMapVote()
	return GetGlobalBool("InMapVote")
end

function GM:VotePlayMap( ply, map )
	
	if ( !map ) then return end 
	if ( !GAMEMODE:InMapVote() ) then return end 
	if not (table.HasValue(g_PlayableMaps,map)) and not (table.HasValue(g_Modes,map)) then return end
	
	ply:SetNWString( "Wants", map )

end

concommand.Add( "votemap", function( pl, cmd, args ) GAMEMODE:VotePlayMap( pl, args[1] ) end )

function GM:StartMapVote()
	SetGlobalBool( "InMapVote", true )
	timer.Simple(40,function() if not (self.RestartMap) then RunConsoleCommand("changelevel",table.Random(g_PlayableMaps)) end end)
	local bool = false
	local time = 10
	GAMEMODE.InModeVote = false
	bool = true
	time = 20
	timer.Simple(20,function() GAMEMODE:FinishMapVote() end)
	SetGlobalFloat( "VoteEndTime", CurTime() + time )
	BroadcastLua( "GAMEMODE:ShowMapChooser("..tostring(bool)..") if pEndBoard then pEndBoard:Remove() end" );	
end

function GM:ClearPlayerWants()

	for k, ply in pairs( player.GetAll() ) do
		ply:SetNWString( "Wants", "" )
	end
	
end

function GM:GetWinningWant()

	local Votes = {}
	
	for k, ply in pairs( player.GetAll() ) do
	
		local want = ply:GetNWString( "Wants", nil )
		if ( want && want != "" ) then
			Votes[ want ] = Votes[ want ] or 0
			Votes[ want ] = Votes[ want ] + 1			
		end
		
	end
	
	return table.GetWinningKey( Votes )
	
end

function GM:GetWinningMap()

	if ( GAMEMODE.WinningMap ) then return GAMEMODE.WinningMap end

	local winner = GAMEMODE:GetWinningWant()
	if ( !winner ) then return (table.Random(g_PlayableMaps)) end
	return winner
	
end

function GM:FinishMapVote()
	
	GAMEMODE.WinningMap = GAMEMODE:GetWinningMap()
	GAMEMODE:ClearPlayerWants()
	// Send bink bink notification
	BroadcastLua( "GAMEMODE:ChangingMap( '"..GAMEMODE.WinningMap.."' )" );

	// Start map vote?
	timer.Simple( 10, function() RunConsoleCommand("changelevel",GAMEMODE.WinningMap) end )
	
end


hook.Add("LoadNextMap","ZS.StartVoteMap",function()
	GAMEMODE:StartMapVote()
	return false
end)