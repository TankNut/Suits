AddCSLuaFile()

CreateConVar("suit_death_behavior", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "What should happen with a player's suit when they die, 0 = destroy, 1 = drop, 2 = keep")

CreateConVar("suit_cloak_time", 1.7, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The amount of time it takes for the cloak suit to fully cloak/uncloak")

CreateConVar("suit_cloak_max", 0.999, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How effective the cloak suit is when viewed by someone else")
CreateConVar("suit_cloak_max_self", 0.8, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How effective the cloak suit is when viewed by the player wearing it")

CreateConVar("suit_juggernaut_speed", 0.4, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The multiplier applied to the player's speed when wearing a juggernaut suit")
CreateConVar("suit_juggernaut_damage", 0.4, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The multiplier applied to any damage the player takes when wearing a juggernaut suit")

if SERVER then
	cvars.AddChangeCallback("suit_juggernaut_speed", function(name, old, new)
		for _, v in pairs(ents.FindByClass("suit_juggernaut")) do
			local ply = v:GetParent()

			if IsValid(ply) and ply:IsPlayer() then
				local speed = v:GetSpeedMod(ply)

				ply:SetWalkSpeed(v.StoreData.WalkSpeed * speed)
				ply:SetRunSpeed(v.StoreData.RunSpeed * speed)
			end
		end
	end)
end