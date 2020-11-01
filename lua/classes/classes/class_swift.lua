local function CanGrab(ply)
	if not IsValid(ply) then return end

	-- We don't want to grab onto a ledge if we're on the ground!
	if ply:OnGround() then
		return false
	end

	local trace2 = {}
	trace2.start = ply:GetShootPos()
	trace2.endpos = trace2.start + ply:GetAimVector() * 30
	trace2.filter = ply

	local trLo = util.TraceLine(trace2)

	-- Is the ledge actually grabbable?
	if trLo and trLo.Hit then
		return true, trLo
	else
		return false, trLo
	end
end

CLASS.AddClass("SWIFT", {
	color = Color(0, 152, 216, 255),
	passiveItems = {
		"item_ttt_climb"
	},
	OnAbilityActivate = function(ply)
		ply.Grab = true
		ply.ClimbJumps = 0
		ply.ClimbPos = ply:GetPos()

		local VelZ = ply:GetVelocity().z

		ply:ViewPunch(Angle(math.max(15, math.min(30, VelZ)) * (VelZ > 0 and 1 or - 1), 0, 0))
		ply:SetLocalVelocity(Vector(0, 0, 0))
		ply:SetMoveType(MOVETYPE_NONE)
		ply:EmitSound(Sound("physics/flesh/flesh_impact_hard" .. math.random(1, 3) .. ".wav"), 75)
	end,
	OnAbilityDeactivate = function(ply)
		if ply:GetMoveType() == MOVETYPE_NONE then
			ply:SetMoveType(MOVETYPE_WALK)
		end

		ply.Grab = false
	end,
	CheckActivation = function(ply)
		return ({CanGrab(ply)})[1]
	end,
	time = 10,
	cooldown = 60,
	avoidWeaponReset = true,
	lang = {
		name = {
			English = "Swift",
			French = "Agile",	
			Русский = "Свифт"
		},
		desc = {
			English = "The Swift receives no falldamage and runs slightly faster than normal players. Additionally, they can climb on walls while looking at them. On activation of their ability, they can hold themselves to the wall for 10 seconds.",
			French = "L'Agile ne subit aucun dégât de chute et court un peu plus vite que les autres joueurs. De plus, il peut grimper sur les murs pendant qu'il les regarde. Lorsqu'il active sa capacité, il peut se tenir au mur pendant 10 secondes.",	
			Русский = "Свифт не получает урона от падения и бегает немного быстрее, чем обычные игроки. Кроме того, он может лазить по стенам, глядя на них. При активации способности он может удерживаться у стены в течение 10 секунд."
		}
	}
})

hook.Add("Think", "ClimbGrabThink", function()
	for _, ply in ipairs(player.GetAll()) do
		if ply.Grab then
			ply:SetLocalVelocity(Vector(0, 0, 0))
			ply:SetPos(ply.ClimbPos)
		end
	end
end)

hook.Add("TTTPlayerSpeedModifier", "TTTCSwiftSpeedMod", function(ply, _, _, speedMultiplierModifier)
	if ply:GetCustomClass() ~= CLASS.CLASSES.SWIFT.index then return end

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 1.25
end)
