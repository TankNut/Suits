AddCSLuaFile()

SWEP.PrintName 				= "Cloak"
SWEP.Author 				= "TankNut"
SWEP.Instructions 			= "Primary: Toggle cloak"

SWEP.ViewModel 				= Model("models/weapons/c_slam.mdl")
SWEP.WorldModel 			= ""

SWEP.ViewModelFlip 			= true
SWEP.UseHands 				= true

SWEP.SwayScale 				= 1

SWEP.DrawCrosshair 			= false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= ""
SWEP.Primary.Automatic 		= false

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= ""
SWEP.Secondary.Automatic 	= false

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active")

	self:NetworkVar("Float", 0, "StartTime")
end

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:Deploy()
	self:SetHoldType("normal")

	self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)

	self:SetActive(false)
	self:SetStartTime(0)

	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:Holster()
	if self:GetActive() then
		return false
	end

	return self.Owner.CloakVal == 0
end

local convar = GetConVar("suit_cloak_time")

function SWEP:Think()
	local ply = self.Owner

	if not IsValid(ply) then
		return
	end

	local val = 0
	local time = convar:GetFloat()

	if self:GetActive() then
		val = CurTime() - self:GetStartTime()
	else
		val = time - (CurTime() - self:GetStartTime())
	end

	val = math.Remap(val, 0, time, 0, 1)
	val = math.Clamp(val, 0, 1)

	ply.CloakVal = val

	ply:DrawShadow(val == 0)
	ply:SetDSP(val > 0.1 and 31 or 0)

	if self.Sound then
		self.Sound:ChangeVolume(val)

		if val == 0 then
			self.Sound:Stop()
		end
	end

	if SERVER then
		ply:SetNoTarget(val > 0.1)
	end

	self:NextThink(CurTime())

	return true
end

function SWEP:OnRemove()
	if SERVER and self.Sound then
		self.Sound:Stop()
	end
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)

	self:SetActive(not self:GetActive())
	self:SetStartTime(CurTime())

	if self:GetActive() then
		self:EmitSound("suits/cloak_activate.wav")

		if SERVER then
			if not self.Sound then
				local filter = RecipientFilter()

				filter:AddPlayer(self.Owner)

				self.Sound = CreateSound(self, "suits/cloak_loop.wav", filter)
				self.Sound:SetSoundLevel(0)
			end

			self.Sound:Play()
		end
	else
		self:EmitSound("suits/cloak_deactivate.wav")
	end

	self:SetNextPrimaryFire(CurTime() + convar:GetFloat())
end

function SWEP:SecondaryAttack()
end

if CLIENT then
	function SWEP:RenderScreenspaceEffects()
		local ply = LocalPlayer()

		if ply:GetViewEntity() != ply then
			return
		end

		local val = math.EaseInOut(ply.CloakVal or 0, 1, 1)
		local tab = {}

		tab["$pp_colour_addr"] = 0
		tab["$pp_colour_addg"] = 0
		tab["$pp_colour_addb"] = 0
		tab["$pp_colour_brightness"] = 0
		tab["$pp_colour_contrast"] = 1 + (0.5 * val)
		tab["$pp_colour_colour"] = 1 - val
		tab["$pp_colour_mulr"] = 0
		tab["$pp_colour_mulg"] = 0
		tab["$pp_colour_mulb"] = 0

		DrawColorModify(tab)
		DrawMotionBlur(0.5, 0.4 * val, 0.04)
	end

	local mat = Material("effects/cloak_overlay")

	function SWEP:DrawHUDBackground()
		local ply = LocalPlayer()

		if ply:GetViewEntity() != ply then
			return
		end

		local cloak = math.EaseInOut(ply.CloakVal or 0, 1, 1)
		local val = math.Remap(cloak, 0, 1, 0, -0.1)

		render.UpdateScreenEffectTexture()

		surface.SetDrawColor(0, 0, 0, cloak * 255)

		surface.SetMaterial(mat)

		for k, v in pairs({Vector(cloak, 1 - cloak, 1 - cloak), Vector(1 - cloak, cloak, 1 - cloak), Vector(1 - cloak, 1 - cloak, cloak), Vector(1 - cloak, 1 - cloak, 1 - cloak)}) do
			mat:SetFloat("$refractamount", val * k)
			mat:SetVector("$refracttint", v)

			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end
end