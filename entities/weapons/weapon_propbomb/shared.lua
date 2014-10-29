if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
else
	killicon.AddFont( "weapon_mu_magnum", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
end
SWEP.Base = "weapon_base"

SWEP.PrintName		= "The Curse"
SWEP.Slot			= 1
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
SWEP.Instructions	= "Detonate a Prop"

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
SWEP.Primary.Ammo				= "SniperRound"
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

if SERVER then
	util.AddNetworkString("pkshotguncanattack")
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Think()
	if self:Clip1() < 3 then
		self.NextAmmo = self.NextAmmo or CurTime() + 2
		if self.NextAmmo <= CurTime() then
			self.NextAmmo = CurTime() + 2
			self:SetClip1(self:Clip1() + 1)
		end
	end
	if self:Clip2() < 1 then
		self.NextAmmo = self.NextAmmo or CurTime() + 0.5
		if self.NextAmmo <= CurTime() then
			self.NextAmmo = CurTime() + 0.5
			self:SetClip2(self:Clip2() + 1)
		end
	end
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
	if not IsValid(ent) or ent.Exploding or ent.Heart then return end 
	if not ent:GetClass():find("prop_physics") then return end

	local fuse = 3
	self.NextLower = CurTime() + 0.4
	self.NextAmmo = CurTime() + 1
	self:SetClip1(self:Clip1() - 1)
	
	if SERVER then
		--[[local flash = ents.Create("bomb_ticking")
		flash:SetPos(ent:GetPos())
		flash:SetParent(ent)
		flash:SetOwner(ent)
		flash:Spawn()]]
		
		ent:Ignite(3,0)
		ent.Exploding = true
		ent:EmitSound("npc/ichthyosaur/water_growl5.wav")
		
		timer.Simple(fuse, function()
			local explode = ents.Create( "env_explosion" )
			explode:SetPos( ent:GetPos() )
			explode:SetOwner(self.Owner)
			explode:Spawn()
			explode:SetKeyValue( "iMagnitude", "200" )
			explode:Fire( "Explode", 0, 0 )
			explode:EmitSound( "weapon_AWP.Single", 400, 400 )
			ent:Remove()
		end)
	end
	
	// hacky fix for client, don't send immediately
	timer.Simple(0, function () if IsValid(self) then self:NetCanAttack() end end)
end

function SWEP:SecondaryAttack()
	if (self.NextLower or 0) >= CurTime() then return false end
	if self:Clip2() <= 0 then return end
	
	if SERVER then
		self:FirePulse(15, 15)
		self:SetClip2(self:Clip2() - 1)
		self.NextLower = CurTime() + 0.2
		self.NextAmmo = CurTime() + .5
   end
end

function SWEP:FirePulse(force_fwd, force_up)
   if not IsValid(self.Owner) then return end

   self.Owner:SetAnimation( PLAYER_ATTACK1 )

   sound.Play(self.Primary.Sound, self.Weapon:GetPos(), self.Primary.SoundLevel)

   self.Weapon:SendWeaponAnim(ACT_VM_IDLE)

	local props = ents.FindInCone(self.Owner:GetShootPos(),self.Owner:GetAimVector(),400,30)
	for k,v in pairs(props) do
		if v:GetClass():find("prop_physics") then
			v:GetPhysicsObject():ApplyForceCenter((v:GetPos() - self.Owner:GetShootPos()):GetNormal() * 500*v:GetPhysicsObject():GetMass())
		end
	end
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
		
		weapon = "The Curse"
		desc = "Left to Curse. Right to Force."
		
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