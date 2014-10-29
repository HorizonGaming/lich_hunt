if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
else
	killicon.AddFont( "weapon_mu_magnum", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
end
SWEP.Base = "weapon_base"

SWEP.PrintName		= "Summon Undead"
SWEP.Slot			= 2
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
SWEP.Instructions	= "Left to Summon Undead"

SWEP.Primary.Sound				= ""
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 1
SWEP.Primary.Recoil				= 5
SWEP.Primary.Cone				= 1
SWEP.Primary.Delay				= 3
SWEP.Primary.ClipSize			= 5
SWEP.Primary.DefaultClip		= 5
SWEP.Primary.Tracer				= 1
SWEP.Primary.Force				= 0
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "Battery"
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
	self.CanAttack = true
end

function SWEP:BulletCallback(att, tr, dmg)
	return {effects = true,damage = true}
end

function SWEP:SecondaryAttack()
	if SERVER then
		if self:Clip1() <= 0 then return end
		if (self.NextLower or 0) >= CurTime() then return false end
		self.NextLower = CurTime() + 0.4
		self.NextAmmo = CurTime() + 5
		self:SetClip1(self:Clip1() - 1)
		
		local eyetrace = self.Owner:GetEyeTrace()
		local ent = ents.Create("npc_zombie")
		ent:SetPos(eyetrace.HitPos)
		ent:Spawn()
	end
end

function SWEP:PrimaryAttack()
	if SERVER then
		if self:Clip1() <= 0 then return end
		if (self.NextLower or 0) >= CurTime() then return false end
		self.NextLower = CurTime() + 0.4
		self.NextAmmo = CurTime() + 5
		self:SetClip1(self:Clip1() - 1)
		
		local eyetrace = self.Owner:GetEyeTrace()
		local ent = ents.Create("npc_fastzombie")
		ent:SetPos(eyetrace.HitPos)
		ent:Spawn()
	end
end

function SWEP:Think()
	if self:Clip1() < 1 then
		self.NextAmmo = self.NextAmmo or CurTime() + 10
		if self.NextAmmo <= CurTime() then
			self.NextAmmo = CurTime() + 10
			self:SetClip1(self:Clip1() + 1)
		end
	end
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
end

function SWEP:Reload()

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
		
		weapon = "Summon Undead"
		desc = "Left to Summon Undead."
		
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