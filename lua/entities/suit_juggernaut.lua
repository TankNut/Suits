AddCSLuaFile()

ENT.Base 			= "base_suit"

ENT.PrintName 		= "Juggernaut suit"
ENT.Category 		= "Suits"
ENT.Author 			= "TankNut"

ENT.Spawnable 		= true
ENT.AdminSpawnable	= true

ENT.SuitData = {
	Model = Model("models/suits/juggernaut.mdl"),

	Hands = {
		Model = Model("models/weapons/c_arms_combine.mdl")
	},

	Footsteps = {
		"npc/combine_soldier/gear1.wav",
		"npc/combine_soldier/gear2.wav",
		"npc/combine_soldier/gear3.wav",
		"npc/combine_soldier/gear4.wav",
		"npc/combine_soldier/gear5.wav",
		"npc/combine_soldier/gear6.wav"
	}
}

local speed = GetConVar("suit_juggernaut_speed")
local damage = GetConVar("suit_juggernaut_damage")

function ENT:ScaleDamage(ply, dmg)
	local mult = damage:GetFloat()

	if mult == 0 then
		return true
	end

	dmg:ScaleDamage(mult)
end

if SERVER then
	function ENT:GetSpeedMod(ply)
		return speed:GetFloat()
	end
end