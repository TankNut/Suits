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

	function ENT:SetupNPCRelationship(ply, npc)
		if not IsValid(npc) or not npc:IsNPC() then
			return
		end

		local classify = npc:Classify()
		local relationship = self.SuitData.NPCRelationships[classify]

		if relationship then
			self.StoreData.NPCRelationships[npc] = npc:Disposition(ply)

			npc:AddEntityRelationship(ply, relationship, 99)
		end
	end

	function ENT:SetupNPCRelationships(ply)
		self.StoreData.NPCRelationships = {}

		for _, v in pairs(ents.GetAll()) do
			self:SetupNPCRelationship(ply, v)
		end
	end

	function ENT:RestoreNPCRelationships(ply)
		if not self.StoreData.NPCRelationships then
			return
		end

		for npc, relationship in pairs(self.StoreData.NPCRelationships) do
			if not IsValid(npc) then
				continue
			end

			npc:AddEntityRelationship(ply, relationship, 99)
		end
	end

	function ENT:SetupModel(ply)
		local data = self.SuitData

		if data.Model then
			ply:SetModel(data.Model)
			ply:SetSubMaterial()
			ply:SetMaterial("")
		end

		if data.Material then
			ply:SetMaterial(data.Material)
		end
	end

	function ENT:OnWear(ply)
		self.StoreData = {}
		self:SetupModel(ply)

		ply:SetupHands()

		local speed = self:GetSpeedMod(ply)

		if speed != 1 then
			self.StoreData.WalkSpeed = ply:GetWalkSpeed()
			self.StoreData.RunSpeed = ply:GetRunSpeed()

			ply:SetWalkSpeed(self.StoreData.WalkSpeed * speed)
			ply:SetRunSpeed(self.StoreData.RunSpeed * speed)
		end

		if self.SuitData.Weapons then
			self.StoreData.Weapons = {}

			for _, v in pairs(self.SuitData.Weapons) do
				table.insert(self.StoreData.Weapons, ply:Give(v))
			end
		end

		if self.SuitData.NPCRelationships then
			self:SetupNPCRelationships(ply)
		end
	end

	function ENT:OnUnwear(ply)
		local data = self.StoreData

		hook.Run("PlayerSetModel", ply)

		ply:SetupHands()

		if self.StoreData.WalkSpeed then
			ply:SetWalkSpeed(data.WalkSpeed)
			ply:SetRunSpeed(data.RunSpeed)
		end

		if data.Weapons then
			for _, v in pairs(data.Weapons) do
				if IsValid(v) then
					ply:StripWeapon(v:GetClass())
				end
			end
		end

		if data.NPCRelationships then
			self:RestoreNPCRelationships(ply)
		end
	end
end