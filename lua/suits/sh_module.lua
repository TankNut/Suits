AddCSLuaFile()

module("suit", package.seeall)

function GetWorn(ply)
	return ply:GetNWEntity("WornSuit")
end

if SERVER then
	function Wear(ply, suit)
		if IsValid(GetWorn(ply)) then
			return
		end

		ply:SetNWEntity("WornSuit", suit)
		ply:DeleteOnRemove(suit)

		suit:SetParent(ply)
		suit:SetNoDraw(true)
		suit:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		suit:OnWear(ply)

		suit:SetPos(Vector())
	end

	function Unwear(suit)
		local ply = suit:GetParent()

		if not IsValid(ply) then
			return
		end

		ply:SetNWEntity("WornSuit", NULL)
		ply:DontDeleteOnRemove(suit)

		suit:SetParent(nil)
		suit:SetNoDraw(false)
		suit:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		suit:OnUnwear(ply)

		table.Empty(suit.StoreData)
	end
end