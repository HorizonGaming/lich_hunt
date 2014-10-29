include( "shared.lua" )
include( "cl_scoreboard.lua" )
include( "cl_help.lua" )

surface.CreateFont('USAliveFont', { font = 'coolvetica', size = 32 })

net.Receive("Lich_StartRound",function()
	GAMEMODE:StartRound()
end)

local check = 0
local special = {}
function GM:PreDrawHalos()
	local lich = LocalPlayer()
	if lich:Team() == 2 and lich:GetNetVar("HasHeart") and IsValid(lich:GetNetVar("Heart")) then
		special = {lich:GetNetVar("Heart")}
		halo.Add(special, Color( 255, 0, 0 ), 5, 5, 2)
	end
end

local tick = 0
local textIsAlive = true
function GM:HUDPaint()

	local ply = LocalPlayer()
	
	
	if !ply:Alive() and IsValid(ply:GetObserverTarget()) and ply:GetObserverTarget().Nick then
		surface.SetFont("Trebuchet18")
		draw.RoundedBox(8, 20, 10, 150, 25, Color(0, 0, 0, 140))
		draw.DrawText("Spectating "..ply:GetObserverTarget():Nick().."", "Trebuchet18", 650, 15, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	if LocalPlayer():Alive() then
		HP = LocalPlayer():Health()
	else
		HP = ""
	end
	
	if LocalPlayer():Alive() and CLIENT then
		draw.RoundedBox(10, -10, ScrH() - 85, 200, 100, Color(0,0,0,240)) -- Background
		draw.RoundedBox(10, -10, ScrH() - 70, 185 * (LocalPlayer():Health()/(LocalPlayer():GetNetVar("MaxHealth") or 100)), 60, Color(150,0,0,200)) -- Color
		draw.DrawText(HP, "DermaLarge", 55, ScrH() - 55, Color(255, 255, 255, 255))
		
		local ent = ply:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsPlayer() and ent:Team() == ply:Team() then
			draw.SimpleTextOutlined(ent:Name().." (HP: "..ent:Health()..")", "DermaLarge", ScrW()/2, ScrH() * 0.3, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0))
		end
		
		if not IsValid(LocalPlayer():GetActiveWeapon()) then return end
		draw.RoundedBox(10, ScrW() - 200, ScrH() - 50, ScrW(), 40, Color(10,10,10,200)) -- Ammo Background
		draw.DrawText(LocalPlayer():GetActiveWeapon():Clip1().."/"..LocalPlayer():GetAmmoCount("XBowBolt"), "DermaLarge", ScrW() - 100, ScrH() - 45, Color(255, 255, 255, 255)) -- Ammo
	
	end
	

end

hook.Remove("HUDPaint","HZG.HUD.Paint")

function PostProcess()
 
	if LocalPlayer():Team() == 2 then 
		DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.1 )
	end
end
 
hook.Add( "RenderScreenspaceEffects", "ClusterFuck", PostProcess )

function GM:HUDShouldDraw(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo"})do
		if name == v then return false end
	end
	return true
end
