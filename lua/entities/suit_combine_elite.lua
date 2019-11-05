AddCSLuaFile()

ENT.Base 			= "base_suit"

ENT.PrintName 		= "Combine Elite suit"
ENT.Category 		= "Suits"
ENT.Author 			= "TankNut"

ENT.Spawnable 		= true
ENT.AdminSpawnable	= true

ENT.SuitData = {
	Model = Model("models/player/combine_super_soldier.mdl"),
	Material = "models/combine_soldier/combine_elite",

	Hands = {
		Model = Model("models/weapons/c_arms_combine.mdl")
	},

	FootstepPitch = {95, 105},
	FootstepVolume = 0.75,
	Footsteps = {{
		"npc/combine_soldier/gear1.wav",
		"npc/combine_soldier/gear3.wav",
		"npc/combine_soldier/gear5.wav"
	}, {
		"npc/combine_soldier/gear2.wav",
		"npc/combine_soldier/gear4.wav",
		"npc/combine_soldier/gear6.wav"
	}}
}

if SERVER then
	ENT.SuitData.NPCRelationships = {
		[CLASS_COMBINE] = D_LI,
		[CLASS_COMBINE_GUNSHIP] = D_LI,
		[CLASS_MANHACK] = D_LI,
		[CLASS_METROPOLICE] = D_LI,
		[CLASS_MILITARY] = D_LI,
		[CLASS_SCANNER] = D_LI,
		[CLASS_STALKER] = D_LI,
		[CLASS_PROTOSNIPER] = D_LI,
		[CLASS_COMBINE_HUNTER] = D_LI,
		[CLASS_PLAYER_ALLY] = D_HT,
		[CLASS_PLAYER_ALLY_VITAL] = D_HT,
		[CLASS_CITIZEN_PASSIVE] = D_HT,
		[CLASS_CITIZEN_REBEL] = D_HT,
		[CLASS_VORTIGAUNT] = D_HT,
		[CLASS_HACKED_ROLLERMINE] = D_HT
	}
end

if CLIENT then
	function ENT:RenderScreenspaceEffects()
		local ply = LocalPlayer()

		if ply:GetViewEntity() != ply then
			return
		end

		DrawMaterialOverlay("effects/elite_overlay", 0)
	end
end