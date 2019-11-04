AddCSLuaFile()

ENT.Base 			= "base_suit"

ENT.PrintName 		= "Cloaking suit"
ENT.Category 		= "Suits"
ENT.Author 			= "TankNut"

ENT.Spawnable 		= true
ENT.AdminSpawnable	= true

ENT.SuitData = {
	Model = Model("models/suits/cloak.mdl"),

	Hands = {
		Model = Model("models/weapons/c_arms_combine.mdl")
	},

	Weapons = {
		"cloak_remote"
	}
}

function ENT:Footstep(ply, volume)
	if ply.CloakVal > 0.1 then
		return true
	end
end

if SERVER then
	function ENT:OnWear(ply)
		self.BaseClass.OnWear(self, ply)

		ply.CloakVal = 0
	end

	function ENT:OnUnWear(ply)
		self.BaseClass.OnUnWear(self, ply)

		ply:DrawShadow(true)
		ply:SetDSP(0)
	end

	function ENT:CanUnwear(ply)
		if ply.CloakVal != 0 then
			return false
		end

		return self.BaseClass.CanUnwear(ply)
	end
end