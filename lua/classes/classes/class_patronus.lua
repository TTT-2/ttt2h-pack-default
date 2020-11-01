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
			English = "Patronus",
			French = "Patronus",	
			Русский = "Патронус"
		},
		desc = {
			English = "The Patronus can spawn a shield for 5 seconds once every minute. They have no passive ability.",
			French = "Le Patronus peut faire apparaître un bouclier pendant 5 secondes une fois par minute. Il n'a pas de capacité passive.",	
			Русский = "Патронус может создавать щит на 5 секунд каждую минуту. У него нет пассивных способностей."
		}
	}
})
