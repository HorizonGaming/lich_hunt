include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 90))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 48)

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_small_loop1.wav")
	self.AmbientSound:PlayEx(0.67, 100)
end

function ENT:OnRemove()
	self.Emitter:Finish()
	self.AmbientSound:Stop()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(0.67, 100 + math.sin(RealTime()))
end

--[[local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(0, 255, 0, 255)]]
function ENT:DrawTranslucent()
	local owner = self:GetParent()
	if not IsValid(owner) then return end
	--if owner.Alive and not owner:Alive() then return end
	--if owner:Health() <= 0 then return end
	
	self.Time = self.Time or CurTime()
	if self.Time <= CurTime() then
		self.Time = CurTime() + 1
		local flash = self.Emitter:Add("sprites/orangeflare1",owner:GetPos())
		flash:SetDieTime(0.5)
		flash:SetStartAlpha(255)
		flash:SetEndAlpha(255)
		flash:SetStartSize(400)
		flash:SetEndSize(0)
		flash:SetColor(255,0,0,255)
	end
end
ENT.Draw = ENT.DrawTranslucent