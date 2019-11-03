AddCSLuaFile()

ENT.RenderGroup 	= RENDERGROUP_OPAQUE

ENT.Base 			= "base_anim"
ENT.Type 			= "anim"

ENT.Author 			= "TankNut"

ENT.Spawnable 		= false
ENT.AdminSpawnable	= false

ENT.SuitData = {}

function ENT:SpawnFunction(ply, tr, class)
	local ang = Angle(0, ply:EyeAngles().y + 90, 0)
	local ent = ents.Create(class)

	ent:SetCreator(ply)
	ent:SetPos(tr.HitPos)
	ent:SetAngles(ang)

	ent:Spawn()
	ent:Activate()

	-- Duplicate of the prop alignment code from the spawnmenu
	local pos = tr.HitPos - (tr.HitNormal * 512)

	pos = ent:NearestPoint(pos)
	pos = ent:GetPos() - pos
	pos = tr.HitPos + pos

	ent:SetPos(pos + Vector(0, 0, 1))
	ent:GetPhysicsObject():Wake()

	undo.Create(class)
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
		undo.SetCustomUndoText("Undone " .. ent.PrintName)
	undo.Finish()

	return ent
end

function ENT:Initialize()
	self:SetModel("models/props_c17/SuitCase001a.mdl")

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:Footstep(ply, volume)
	local data = self.SuitData.Footsteps
	local snd

	if isbool(data) then
		return true
	elseif isstring(data) then
		snd = data
	elseif istable(data) then
		snd = table.Random(data)
	end

	if snd then
		ply:EmitSound(snd, 75, 100, volume)

		return true
	end
end

function ENT:ScaleDamage(ply, dmg)
end

if CLIENT then
	function ENT:RenderScreenspaceEffects()
	end
end

if SERVER then
	function ENT:Use(ply)
		if not IsValid(ply) or not ply:IsPlayer() then
			return
		end

		if not self:CanWear(ply) then
			return
		end

		local worn = suit.GetWorn(ply)

		if IsValid(worn) then
			if worn:GetClass() == self:GetClass() then
				return
			end

			if not worn:CanUnwear(ply) then
				return
			end

			suit.Unwear(worn)

			worn:SetPos(self:GetPos() + Vector(0, 0, 1))
			worn:SetAngles(self:GetAngles())
			worn:GetPhysicsObject():Wake()
		end

		suit.Wear(ply, self)

		ply:EmitSound("items/ammopickup.wav")
	end

	function ENT:CanWear(ply)
		local res = hook.Run("CanWearSuit", ply)

		if res then
			return res
		end

		return true
	end

	function ENT:CanUnwear(ply)
		local res = hook.Run("CanUnwearSuit", ply)

		if res then
			return res
		end

		return true
	end

	function ENT:OnRemove()
		suit.Unwear(self)
	end

	function ENT:GetSpeedMod(ply)
		return 1
	end

	function ENT:OnWear(ply)
		self.StoreData = {
			Model = ply:GetModel(),
			Material = ply:GetMaterial(),
			WalkSpeed = ply:GetWalkSpeed(),
			RunSpeed = ply:GetRunSpeed()
		}

		local data = self.SuitData

		ply:SetModel(data.Model)
		ply:SetMaterial(data.Material or "")

		if data.Hands then
			ply:GetHands():SetModel(data.Hands)
		end

		local speed = self:GetSpeedMod(ply)

		ply:SetWalkSpeed(self.StoreData.WalkSpeed * speed)
		ply:SetRunSpeed(self.StoreData.RunSpeed * speed)

		if data.Weapons then
			self.StoreData.Weapons = {}

			for _, v in pairs(data.Weapons) do
				table.insert(self.StoreData.Weapons, ply:Give(v))
			end
		end
	end

	function ENT:OnUnwear(ply)
		local data = self.StoreData

		ply:SetModel(data.Model)
		ply:SetMaterial(data.Material)

		ply:SetupHands()

		ply:SetWalkSpeed(data.WalkSpeed)
		ply:SetRunSpeed(data.RunSpeed)

		if data.Weapons then
			for _, v in pairs(data.Weapons) do
				if IsValid(v) then
					ply:StripWeapon(v:GetClass())
				end
			end
		end
	end
end