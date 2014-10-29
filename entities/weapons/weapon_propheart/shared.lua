if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
else
	killicon.AddFont( "weapon_mu_magnum", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
end
SWEP.Base = "weapon_base"

SWEP.PrintName		= "Your Heart"
SWEP.Slot			= 0
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= true
SWEP.DrawCrosshair	= true
SWEP.ViewModelFlip	= false
SWEP.ViewModelFOV	= 50
SWEP.ViewModel		= ""
SWEP.WorldModel		= ""
SWEP.HoldType		= ""
SWEP.PKOneOnly = true

SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.Author			= "Hipster"
SWEP.Contact		= ""
SWEP.Purpose		= "Lich"
SWEP.Instructions	= "Designate a heart"

SWEP.Primary.Sound				= ""
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 1
SWEP.Primary.Recoil				= 5
SWEP.Primary.Cone				= 1
SWEP.Primary.Delay				= 0.4

SWEP.Primary.ClipSize			= 3
SWEP.Primary.DefaultClip		= 3

SWEP.Primary.Tracer				= 1
SWEP.Primary.Force				= 0
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "None"
SWEP.Primary.ReloadTime = 3.7
SWEP.ReloadFinishedSound		= Sound("Weapon_Crossbow.BoltElectrify")
SWEP.ReloadSound = Sound("Weapon_357.Reload")

SWEP.Secondary.Sound				= ""
SWEP.Secondary.Damage				= 0
SWEP.Secondary.NumShots				= 1
SWEP.Secondary.Recoil				= 1
SWEP.Secondary.Cone					= 0
SWEP.Secondary.Delay				= 0.25
SWEP.Secondary.ClipSize				= -1
SWEP.Secondary.DefaultClip			= -1
SWEP.Secondary.Tracer				= -1
SWEP.Secondary.Force				= 5
SWEP.Secondary.TakeAmmoPerBullet	= false
SWEP.Secondary.Automatic			= false
SWEP.Secondary.Ammo					= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	if SERVER and IsValid(self) then
		timer.Simple(60,function() self.Owner:ChatPrint("Your heart is weakening! Hide it within a prop to regain your strength!") end)
	end
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
	if (self.NextLower or 0) >= CurTime() then return false end
	if self:Clip1() <= 0 then return end
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(Sound(self.Primary.Sound))

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = tr.start + self.Owner:GetAimVector() * 400
	tr.filter = {self,self.Owner}
	local eyetrace = util.TraceLine(tr)
	local ent = eyetrace.Entity
	if not IsValid(ent) or ent.Exploding then return end 
	if not ent:GetClass():find("prop_physics") then return end
	
	self.Owner:SetHealth(300 + (#player.GetAll() * 100))
	self.Owner:SetNetVar("MaxHealth",self.Owner:Health())
	self.Owner:SetNetVar("HasHeart",true)
	self.Owner:SetNetVar("Heart",ent)

	self.Owner:SetRunSpeed(500)
	self.Owner:SetWalkSpeed(250)
	self.Owner:SetJumpPower(300)

	self.Owner:SetColor(Color(255,255,255,0))
	ent.Heart = true
	ent.HeartOwner = self.Owner
	
	local nick = self.Owner:Nick()
	timer.Simple(180, function() 
		if IsValid(ent) then 
			ent:SetColor(Color(255,0,0)) 
			if SERVER then
				for k,v in pairs(player.GetAll()) do
					v:ChatPrint("Lich "..nick.."'s heart is bleeding red!")
				end
			end 
		end
	end)
	
	if SERVER then
		self.Owner:Give("weapon_propbomb")
		self.Owner:Give("weapon_propspawn")
		self.Owner:Give("weapon_warp")
		self.Owner:Give("weapon_burn")
		self.Owner:Give("weapon_undead")
		
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("Lich "..self.Owner:Nick().." has hidden their heart!")
		end
	end
	
	self:Remove()
end

function SWEP:SecondaryAttack()
end


function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
end

function SWEP:Reload()

end

if CLIENT then
end

function SWEP:NetCanAttack()
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
end

function SWEP:OnRestore()
end

function SWEP:Precache()
end

function SWEP:OwnerChanged()
end

if CLIENT then -- Weapon HUD
	function SWEP:DrawHUD()
		local weapon = self.PrintName
		local desc = self.Instructions
		
		weapon = "Your Heart"
		desc = "Left Click to Hide Your Heart"
		
		local hudtxt = {
		{text=weapon, font="Trebuchet24", xalign=TEXT_ALIGN_CENTER},
		{text=desc, font="Trebuchet18", xalign=TEXT_ALIGN_CENTER}}
	
		local x = ScrW() - 95
		local xbox = ScrW() - 200
		
		hudtxt[1].pos = {x, ScrH() - 120}
		hudtxt[2].pos = {x, ScrH() - 75}
		
		draw.RoundedBox(10, xbox, ScrH() - 135, ScrW(), 50, Color(10,10,10,200))
		if self.CanAttack then
			draw.RoundedBox(10, xbox, ScrH() - 80, ScrW(), 25, Color(10,70,10,200))
		else
			draw.RoundedBox(10, xbox, ScrH() - 80, ScrW(), 25, Color(70,10,10,200))
		end
		
		draw.TextShadow(hudtxt[1], 2)
		draw.TextShadow(hudtxt[2], 2)
		
	end
end