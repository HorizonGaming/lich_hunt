if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
else
	killicon.AddFont( "weapon_mu_magnum", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
end
SWEP.Base = "weapon_base"

SWEP.PrintName		= "Flesh Burn"
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
SWEP.Instructions	= "Burn Humans"

SWEP.Primary.Sound				= ""
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 1
SWEP.Primary.Recoil				= 5
SWEP.Primary.Cone				= 0
SWEP.Primary.Delay				= 3
SWEP.Primary.ClipSize			= 10
SWEP.Primary.DefaultClip		= 10
SWEP.Primary.Tracer				= 1
SWEP.Primary.Force				= 5000
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"
SWEP.Primary.ReloadTime = 3.7
SWEP.ReloadFinishedSound		= Sound("Weapon_Crossbow.BoltElectrify")
SWEP.ReloadSound = Sound("")

SWEP.Secondary.Sound				= ""
SWEP.Secondary.Damage				= 10
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

if SERVER then
	util.AddNetworkString("pkshotguncanattack")
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.CanAttack = true
end

function SWEP:BulletCallback(att, tr, dmg)
	return {effects = true,damage = true}
end

function SWEP:PrimaryAttack()
	if (self.NextLower or 0) >= CurTime() then return false end
	if self:Clip1() <= 0 then return end
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = tr.start + self.Owner:GetAimVector() * 400
	tr.filter = {self,self.Owner}
	local eyetrace = util.TraceLine(tr)
	local ent = eyetrace.Entity
	if !ent:IsPlayer() then return end 
	
	if SERVER then
		self:SetClip1(self:Clip1() - 1)
		ent:Ignite(1,0)
		self.NextLower = CurTime() + 0.4
		self.NextAmmo = CurTime() + 2
   end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	if self:Clip1() < 10 then
		self.NextAmmo = self.NextAmmo or CurTime() + 2
		if self.NextAmmo <= CurTime() then
			self.NextAmmo = CurTime() + 2
			self:SetClip1(self:Clip1() + 1)
		end
	end
end

function SWEP:Reload()

end

if CLIENT then
	net.Receive("pkshotguncanattack", function (len)
		local ent = net.ReadEntity()
		local canattack = net.ReadUInt(8)
		if IsValid(ent) then
			ent.CanAttack = canattack != 0
		end
	end)
end

function SWEP:NetCanAttack()
	if SERVER then
		if IsValid(self.Owner) && self.Owner:IsPlayer() then
			net.Start("pkshotguncanattack")
			net.WriteEntity(self)
			net.WriteUInt(self.CanAttack and 1 or 0,8)
			net.Send(self.Owner)
		end
	end
end

function SWEP:Deploy()
	if !self.CanAttack then
		self.NextAttack = nil
		self.NextLower = nil
		self.NextUpper = CurTime() + self.Primary.ReloadTime
		self:EmitSound(self.ReloadSound)
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self:NetCanAttack()
	end
	return true
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
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