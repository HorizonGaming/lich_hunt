AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
end

function ENT:Think()
	self.DieTime = self.DieTime or CurTime() + 3
	if self.DieTime <= CurTime() then self:Remove() return end		

	local owner = self:GetParent()
	if not IsValid(owner) then self:Remove() return end
end
