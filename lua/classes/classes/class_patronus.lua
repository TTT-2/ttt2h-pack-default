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

		ply.classPatronus_shield = ent
	end
end

local function PatronusDeactivate(ply)
	if SERVER and IsValid(ply.classPatronus_shield) then
		ply.classPatronus_shield:Remove("Shield")
	end
end

CLASS.AddClass("PATRONUS", {
	color = Color(191, 215, 252, 255),
	OnAbilityActivate = PatronusActivate,
	OnAbilityDeactivate = PatronusDeactivate,
	time = 5,
	cooldown = 60,
	avoidWeaponReset = true,
	lang = {
		name = {
			English = "Patronus"
		},
		desc = {
			English = "The Patronus can spawn a shield for 5 seconds once every minute. He has no passive ability."
		}
	}
})
