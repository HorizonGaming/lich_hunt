AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "sv_votemap.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_help.lua" )

include( "shared.lua" )
resource.AddWorkshop(315394811)

// Called when the gamemode is initialized
function GM:Initialize()
	game.ConsoleCommand("us_flashlight 0\n")
	concommand.Remove( "kill" )
	canVote = false
	startVoting = false
	timer.Simple(300,function()
		canVote = true
		startVoting = true
	end)
end

function GM:PlayerInitialSpawn( ply )
	timer.Simple(0, function()
	if #player.GetAll() == 1 then
		ply:SetTeam(2) 
		ply:Spawn()
		ply:ChatPrint("You are the Lich! Waiting for other players.")
	else
		ply:SetTeam(3)
		ply:Kill()
	end
	ply:ConCommand("lh_helpscreen")
	ply:ChatPrint("Hit F1 for Gamemode Help")
	end)
end

function GM:PlayerDisconnected( ply )
	if ply:Team() == 2 then -- Death quit
		timer.Simple(0, function()
			local winner = nil
				if #player.GetAll() > 0 then
					for k,v in RandomPairs(player.GetAll()) do
						if v:Alive() then
							winner = v
						end
					end
				for k, v in pairs(player.GetAll()) do
					v:PrintMessage(HUD_PRINTTALK,"Lich left the game! The new Lich is "..winner:Nick().."!\n")
				end
				timer.Simple(5, function()
					if not IsValid(winner) then
						winner = table.Random(plys)
					end
					winner:SetTeam(2)
					timer.Simple(5, function()
						RunConsoleCommand("us_mapreset")
					end)
				end)
			end
		end)
	end
end

local tick = 0
function GM:Think()
	if tick+5 <= CurTime() then
		tick = CurTime()
		for k,lich in pairs(team.GetPlayers(2)) do
			if lich.LostHeart then
				lich:TakeDamage(1,lich,lich)
			end
		end
		
		for k,v in pairs(ents.FindByClass("prop_physics*")) do
			if v.Heart then
				if IsValid(v.HeartOwner) and v.HeartOwner:Alive() then
					v:EmitSound("player/heartbeat1.wav", math.random(100,140), math.random(100,150))
				else
					local flash = ents.Create("bomb_ticking")
					flash:SetPos(v:GetPos())
					flash:SetParent(v)
					flash:SetOwner(v)
					flash:Spawn()
					
					v:Ignite(3,0)
					v.Exploding = true

					timer.Simple(3, function()
						local explode = ents.Create( "env_explosion" )
						explode:SetPos( v:GetPos() )
						explode:SetOwner(v.HeartOwner or NULL)
						explode:Spawn()
						explode:SetKeyValue( "iMagnitude", "200" )
						explode:Fire( "Explode", 0, 0 )
						explode:EmitSound( "weapon_AWP.Single", 400, 400 )
						v:Remove()
					end)
				end
			end
		end
		
		local players = player.GetAll()
		if #players <= 1 then return end
		local endr = true
		for k,v in pairs(players) do
			if v:Team() == 1 then
				endr = false
				break
			end
		end
		if endr == true then
			GAMEMODE:EndRound(10)
		end
	end
	if GAMEMODE.StartTime and GAMEMODE.StartTime + 60 <= CurTime() then
		for k,lich in pairs(team.GetPlayers(2)) do
			if not lich:GetNetVar("HasHeart") or not IsValid(lich:GetNetVar("Heart")) then
				lich:SetHealth(math.min(lich:Health(),80))
				lich:SetColor(Color(255,255,255,100)) --make him visible, because no heart.
				lich:SetRunSpeed(375)
				lich:SetWalkSpeed(200)
				lich:SetJumpPower(200)
				if not lich.LostHeart then
					lich.LostHeart = true
					lich:SetNetVar("MaxHealth",80)
				end
			end
		end
	end
	
	for k, ply in pairs(player.GetAll()) do
		--if ply:Team() == 2 and ply:GetNetVar("HasHeart") and not IsValid(ply:GetNetVar("Heart")) then
		--	ply:SetHealth(math.min(ply:Health(),80))
		--end
		--
		if IsValid(ply.Spectating) && (!ply.LastSpectatePosSet || ply.LastSpectatePosSet < CurTime()) then
			ply.LastSpectatePosSet = CurTime() + 0.25
			ply:SetPos(ply.Spectating:GetPos())
		end
	end
end

function GM:EntityTakeDamage(ent,dmg)
	if ent.Exploding then
		dmg:SetDamage(0)
		return false
	end
	
	if ent.Heart then
		if dmg:GetAttacker() == ent.HeartOwner or dmg:GetAttacker().Exploding then
			dmg:SetDamage(0)
			return false
		end
		ent.HeartHealth = (ent.HeartHealth or 100) - dmg:GetDamage()
		if ent.HeartHealth <= 0 and not ent.Exploding then
			for k,v in pairs(player.GetAll()) do
				v:ChatPrint("A Lich's heart has been destroyed! He is now vulnerable!")
				
				local music = table.Random({
				"play music/HL2_song20_submix0.mp3",
				"play music/HL2_song3.mp3",
				"play music/HL2_song11.mp3",
				"play music/HL2_song6.mp3",
				"play music/HL2_song20_submix4.mp3",
				"play music/HL2_song15.mp3",
				"play music/HL2_song12_long.mp3"})
				v:ConCommand("play "..music)
				
			end
			
			local flash = ents.Create("bomb_ticking")
			flash:SetPos(ent:GetPos())
			flash:SetParent(ent)
			flash:SetOwner(ent)
			flash:Spawn()
					
			ent:Ignite(5,0)
			ent.Exploding = true

			timer.Simple(5, function()
				local explode = ents.Create( "env_explosion" )
				explode:SetPos( ent:GetPos() )
				explode:SetOwner(ent.HeartOwner)
				explode:Spawn()
				explode:SetKeyValue( "iMagnitude", "100" )
				explode:Fire( "Explode", 0, 0 )
				explode:EmitSound( "weapon_AWP.Single", 400, 400 )
				ent:Remove()
			end)
		end
		dmg:SetDamage(0)
		return false
	end
end

function GM:AllowPlayerPickup(ply,ent)
	return ply:Team() == 1 or (ply:Team() == 2 and not ent.Exploding and not ent.Heart)
end

function GM:PlayerShouldTakeDamage(ply,atk)
	if self.EndingRound then
		return atk.Team and ply:Team() == atk:Team()
	end
	
	if ply:Team() == 2 then
		return (atk:IsPlayer() and atk != ply)
	end

	if atk.Team and ply:Team() == atk:Team() then
		return false
	end
	return true
end
GM.EndingRound = false
function GM:EndRound(time)
	if self.EndingRound then return end
	self.EndingRound = true
	timer.Simple(time, function()
		self.EndingRound = false
		RunConsoleCommand("us_mapreset")
	end)
end
function GM:PlayerDeath(victim, inflictor, killer)
	if victim:Team() == 2 then -- Team Lich
		local alive = 0
		local liches = team.GetPlayers(2)
		for k,lich in pairs(liches) do
			if lich:Alive() and lich != victim then
				alive = alive + 1
			end
		end
		
		if alive == 0 then
			self:EndRound(10)
			victim:SetTeam(1)
			if IsValid(killer) and victim != killer then
				killer:SetTeam(2)
				for k, v in pairs(player.GetAll()) do
					v:PrintMessage(HUD_PRINTTALK,"Lich "..victim:Nick().." has been slain by "..killer:Nick().."!\n")
				end
			else
				for k,v in RandomPairs(player.GetAll()) do
					v:SetTeam(2)
					break
				end
				for k, v in pairs(player.GetAll()) do
					v:PrintMessage(HUD_PRINTTALK,"Lich "..victim:Nick().." has died from natural causes.\n")
				end
			end
			
			for k, v in pairs(player.GetAll()) do
				v:PrintMessage(HUD_PRINTTALK,"All Liches have been slain!\n")
			end
		end
		
	elseif victim:Team() == 1 then
		victim:EmitSound("ambient/creatures/town_child_scream1.wav", 100, math.random(70,140))
		victim:SetTeam(3)
		
		if killer.LostHeart then
			killer:SetHealth(80)
		end
		
		for k, v in pairs(player.GetAll()) do
			if v:Team() == 2 then
				v:AddFrags(1)
			end
			v:PrintMessage(HUD_PRINTTALK,""..victim:Nick().." no longer fears Death.\n")
		end
		if #team.GetPlayers(1) == 0 then
			for k, v in pairs(player.GetAll()) do
				v:PrintMessage(HUD_PRINTTALK,"None shall escape Death.\n")
			end
			self:EndRound(10)
		end
	end
end

util.AddNetworkString("Lich_StartRound")
concommand.Add("us_mapreset",
function(ply,cmd,args)
	if !IsValid(ply) or ply:IsAdmin() then
		game.CleanUpMap()
		GAMEMODE.StartTime = CurTime()
		for k, v in pairs(player.GetAll()) do
			if v:Team() == 3 then
				v:SetTeam(1) -- Spawn the dead back
			end
			v:Spawn()
			
			v.Spectating = nil
			v:UnSpectate()
			
			net.Start("Lich_StartRound")
			net.Send(ply)
		end
	end
end)

function GM:PlayerDeathThink( ply )
		if ply:KeyPressed(IN_ATTACK)
		 || !IsValid(ply.Spectating) || (ply.Spectating:IsPlayer() && !ply.Spectating:Alive()) then

		local players = team.GetPlayers(1)
		for k,v in pairs(players) do
			if !(v:Alive()) then
				players[k] = nil
			end
		end
		local ent = table.Random(players)
		if IsValid(ent) then
			ply:SpectateEntity( ent )
			ply:Spectate( OBS_MODE_IN_EYE )
			ply.Spectating = ent
		elseif IsValid(ply.Spectating) then
			if ply.Spectating != ply:GetRagdollEntity() then
				ply:SpectateEntity( ply:GetRagdollEntity() )
				ply:Spectate( OBS_MODE_CHASE )
				ply.Spectating = ply:GetRagdollEntity()
			end
		elseif ply.Spectating then
			ply.Spectating = nil
			ply:Spectate( OBS_MODE_ROAMING )
		end
	end
end

function GM:PlayerSpawn(ply)
	ply.Spectating = nil
	ply:UnSpectate()
	ply.LostHeart = false
	
	--Team Lich--
	 if ply:Team() == 2 then
		ply:SetModel("models/player/demon_violinist/demon_violinist.mdl")
		ply:StripWeapons()
		ply:Give("weapon_propheart")
		ply:ChatPrint("You are a Lich. Hide your Heart in a prop within 60 seconds to infuse your soul!")
		
		ply:SetRunSpeed(500)
		ply:SetWalkSpeed(250)
		ply:SetJumpPower(300)
		ply:SetRenderMode(4)
		ply:SetColor(Color(0,0,0,0))
		
		ply:SetHealth(300)
		ply:SetNoTarget(true)
		
	--Team Humans--
	elseif ply:Team() == 1 then
		ply.Spectating = nil
		ply:SetRenderMode(1)
		ply:SetColor(Color(255,255,255,255))
		ply:SetRunSpeed(260)
		ply:SetWalkSpeed(200)
		ply:SetJumpPower(200)
		
		ply:StripWeapons()
		ply:Give("weapon_crossbow")
		ply:SetAmmo(50,"XbowBolt")
		
		ply:SetNoTarget(false)
		
		ply:ChatPrint("You are a Human. The Lich is hiding his heart in a prop, listen for the beating and destroy it, then finish him off!")
		
		ply:UnSpectate()
		ply:SetModel(table.Random({
			"models/player/Group01/Female_01.mdl",
			"models/player/Group01/Female_02.mdl",
			"models/player/Group01/Female_03.mdl",
			"models/player/Group01/Female_04.mdl",
			"models/player/Group01/Female_06.mdl",
			"models/player/group01/male_01.mdl",
			"models/player/Group01/Male_02.mdl",
			"models/player/Group01/male_03.mdl",
			"models/player/Group01/Male_04.mdl",
			"models/player/Group01/Male_05.mdl",
			"models/player/Group01/Male_06.mdl",
			"models/player/Group01/Male_07.mdl",
			"models/player/Group01/Male_08.mdl",
			"models/player/Group01/Male_09.mdl"
		}))
		
	--Team Spectator--
	elseif ply:Team()==3 then
		local ent = table.Random(team.GetPlayers(1))
			if IsValid(ent) then
				ply:SpectateEntity( ent )
				ply:Spectate( OBS_MODE_IN_EYE )
				ply.Spectating = ent
			elseif IsValid(ply.Spectating) then
				if ply.Spectating != ply:GetRagdollEntity() then
					ply:SpectateEntity( ply:GetRagdollEntity() )
					ply:Spectate( OBS_MODE_CHASE )
					ply.Spectating = ply:GetRagdollEntity()
				end
			elseif ply.Spectating then
				ply.Spectating = nil
				ply:Spectate( OBS_MODE_ROAMING )
			end
		ply:SetTeam(3)
	end
	ply:SetNetVar("MaxHealth",ply:Health())
end

function GM:ShowSpare2( ply )
	ply:ConCommand("mapvote")
end

concommand.Add("mapvote",
function(ply,cmd,args)
	if !ply:CheckGroup("gold") then 
		ply:ChatPrint("You must be a Gold Member to create a Map Vote. Type !Gold to find out more.")
		return 
	end
	if canVote == true then
		MapVote.Start(30, true, 10, {
		"cs_",
		"de_",		
		"ttt_",
		"clue"})
	canVote = false
	for k, v in pairs(player.GetAll()) do
        v:ChatPrint(ply:Nick().." started a Map Vote.")
    end
	elseif startVoting == false then
		ply:ChatPrint("You must wait five minutes after a Map Change before starting another Map Vote.")
	else
		ply:ChatPrint("You must wait until the next round before starting another Map Vote.")
	end
end)

function GM:ShowHelp( pl )
	pl:ConCommand( "lh_helpscreen" )
end