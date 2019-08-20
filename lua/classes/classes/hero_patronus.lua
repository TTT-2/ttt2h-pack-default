local function PatronusActivate(ply)
	if SERVER then
		local ent = ents.Create("prop_physics")
		ent:SetModel("models/hunter/tubes/tube1x1x2c.mdl")
		ent:SetPos(ply:EyePos() + Vector(0, 0, 35))
		ent:SetAngles(ply:EyeAngles() + Angle(160, 0, 0))
		ent:SetParent(ply)
		ent:Spawn()

		ent:SetMaterial("models/effects/splodearc_sheet")
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:SetMoveType(MOVETYPE_NONE)

		undo.Create("Shield")
		undo.AddEntity(ent)
		undo.Finish()

		ply.heroPatronus_shield = ent
	end
end

local function PatronusDeactivate(ply)
	if SERVER and IsValid(ply.heroPatronus_shield) then
		ply.heroPatronus_shield:Remove("Shield")
	end
end

CLASS.AddHero("PATRONUS", {
		color = Color(191, 215, 252, 255),
		onActivate = PatronusActivate,
		onDeactivate = PatronusDeactivate,
		time = 5,
		cooldown = 60,
		avoidWeaponReset = true,
		langs = {
			English = "Patronus"
		}
})
