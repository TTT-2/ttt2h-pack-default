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

CLASS.AddHero("SWIFT", {
		color = Color(0, 152, 216, 255),
		passiveItems = {
			"item_ttt_climb"
		},
		onActivate = function(ply)
			ply.Grab = true
			ply.ClimbJumps = 0
			ply.ClimbPos = ply:GetPos()

			local VelZ = ply:GetVelocity().z

			ply:ViewPunch(Angle(math.max(15, math.min(30, VelZ)) * (VelZ > 0 and 1 or - 1), 0, 0))
			ply:SetLocalVelocity(Vector(0, 0, 0))
			ply:SetMoveType(MOVETYPE_NONE)
			ply:EmitSound(Sound("physics/flesh/flesh_impact_hard" .. math.random(1, 3) .. ".wav"), 75)
		end,
		onDeactivate = function(ply)
			if ply:GetMoveType() == MOVETYPE_NONE then
				ply:SetMoveType(MOVETYPE_WALK)
			end

			ply.Grab = false
		end,
		checkActivation = function(ply)
			return ({CanGrab(ply)})[1]
		end,
		time = 10,
		cooldown = 60,
		avoidWeaponReset = true,
		langs = {
			English = "Swift"
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

local speedup = 10

hook.Add("TTTCUpdateHero", "TTTCSwiftSprintMod", function(ply, old, new)
	local i = CLASS.CLASSES.SWIFT.index

	if new == i then
		print("test")
		ply.sprintMultiplierModifier = (ply.sprintMultiplierModifier or 1) * speedup
	elseif old == i then
		ply.sprintMultiplierModifier = (ply.sprintMultiplierModifier or 1) / speedup
	end
end)
