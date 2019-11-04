AddCSLuaFile()

concommand.Add("suit_drop", function(ply)
	local worn = suit.GetWorn(ply)

	if not IsValid(worn) then
		return
	end

	if not worn:CanUnwear(ply) then
		return
	end

	suit.Unwear(worn)

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + (ply:GetAimVector() * 100),
		filter = ply
	})

	local pos = tr.HitPos - (tr.HitNormal * 512)
	local ang = Angle(0, ply:EyeAngles().y + 90, 0)

	pos = worn:NearestPoint(pos)
	pos = worn:GetPos() - pos
	pos = tr.HitPos + pos

	worn:SetPos(pos + Vector(0, 0, 1))
	worn:SetAngles(ang)

	worn:PhysWake()

	ply:EmitSound("items/ammopickup.wav")
end)

hook.Add("PlayerFootstep", "suit", function(ply, _, _, _, volume)
	local worn = suit.GetWorn(ply)

	if not IsValid(worn) then
		return
	end

	return worn:Footstep(ply, volume)
end)

hook.Add("EntityTakeDamage", "suit", function(ply, dmg)
	if not IsValid(ply) or not ply:IsPlayer() or dmg:IsFallDamage() then
		return
	end

	local worn = suit.GetWorn(ply)

	if not IsValid(worn) then
		return
	end

	return worn:ScaleDamage(ply, dmg)
end)

if CLIENT then
	hook.Add("RenderScreenspaceEffects", "suit", function()
		local weapon = LocalPlayer():GetActiveWeapon()

		if IsValid(weapon) and weapon.RenderScreenspaceEffects then
			weapon:RenderScreenspaceEffects()
		end

		local worn = suit.GetWorn(LocalPlayer())

		if IsValid(worn) then
			worn:RenderScreenspaceEffects()
		end
	end)

	local max = GetConVar("suit_cloak_max")
	local max_self = GetConVar("suit_cloak_max_self")

	matproxy.Add({
		name = "PlayerCloak",
		init = function(self, mat, values)
			self.Target = values.resultvar
		end,
		bind = function(self, mat, ent)
			if not IsValid(ent) then
				return
			end

			if ent:IsWeapon() then
				ent = ent.Owner
			elseif ent:IsRagdoll() then
				ent = ent:GetRagdollOwner()
			elseif ent:GetClass() == "gmod_hands" then
				ent = ent:GetOwner()
			end

			if not IsValid(ent) or not ent:IsPlayer() then
				mat:SetFloat(self.Target, 0)
			end

			local val = ent.CloakVal or 0
			local ply = LocalPlayer()
			local convar = max

			if ply:GetViewEntity() == ply then
				convar = max_self
			end

			val = math.Clamp(val, 0, math.min(1, convar:GetFloat()))

			mat:SetFloat(self.Target, val)
		end
	})
end

if SERVER then
	local convar = GetConVar("suit_death_behavior")

	hook.Add("PlayerDeath", "suit", function(ply)
		local worn = suit.GetWorn(ply)

		if not IsValid(worn) then
			return
		end

		local setting = convar:GetInt()

		if setting == 0 then
			worn:Remove()
		elseif setting == 1 then
			suit.Unwear(worn)

			worn:SetPos(ply:WorldSpaceCenter())
			worn:SetAngles(Angle(0, ply:EyeAngles().y + 90, 0))
			worn:PhysWake()
		end
	end)

	hook.Add("PlayerSpawn", "suit", function(ply)
		local worn = suit.GetWorn(ply)

		if not IsValid(worn) then
			return
		end

		timer.Simple(0, function()
			worn:OnWear(ply)

			ply:EmitSound("items/ammopickup.wav")
		end)
	end)
end