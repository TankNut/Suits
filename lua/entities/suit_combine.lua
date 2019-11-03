AddCSLuaFile()

ENT.Base 			= "base_suit"

ENT.PrintName 		= "Combine suit"
ENT.Category 		= "Suits"
ENT.Author 			= "TankNut"

ENT.Spawnable 		= true
ENT.AdminSpawnable	= true

ENT.SuitData = {
	Model = Model("models/player/combine_soldier.mdl"),
	Material = "models/combine_soldier/combinesoldiersheet",

	Hands = Model("models/weapons/c_arms_combine.mdl"),

	Footsteps = {
		"npc/combine_soldier/gear1.wav",
		"npc/combine_soldier/gear2.wav",
		"npc/combine_soldier/gear3.wav",
		"npc/combine_soldier/gear4.wav",
		"npc/combine_soldier/gear5.wav",
		"npc/combine_soldier/gear6.wav"
	}
}

if CLIENT then
	function ENT:RenderScreenspaceEffects()
		DrawMaterialOverlay("effects/combine_binocoverlay", 0)
	end
end