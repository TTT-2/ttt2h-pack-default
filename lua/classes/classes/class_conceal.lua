local function ConcealFunction(ply)
	-- Traces a line from the players shoot position to 100 units
	local pos = ply:GetShootPos()
	local ang = ply:GetAimVector()

	local tracedata = {
		start = pos,
		endpos = pos + ang * 100,
		filter = ply
	}

	local trace = util.TraceLine(tracedata)
	local target = trace.Entity

	if not trace.HitWorld and IsValid(target) and target:GetClass() == "prop_ragdoll" then
		if SERVER then
			local role = target.was_role
			local team = target.was_team
			
			if role ~= ROLE_ZOMBIE then
				if team ~= TEAM_INNOCENT and ply:HasTeam(TEAM_INNOCENT) then
					ply:Give("weapon_ttt_traitor_case")
				elseif team == TEAM_INNOCENT and not ply:HasTeam(TEAM_INNOCENT) then
					local maxHealth = ply:GetMaxHealth() + 10
					local newHealth = ply:Health() + 10

					ply:SetMaxHealth(maxHealth)
					ply:SetHealth(newHealth)
				end
			end

			target:Remove()

			SendFullStateUpdate()
		end
	else
		return true -- skip cooldown
	end
end

CLASS.AddClass("CONCEAL", {
		color = Color(68, 208, 187, 255),
		onDeactivate = ConcealFunction,
		time = 0, -- skip timer, this will skip onActivate too! Use onDeactivate instead
		cooldown = 60,
		langs = {
			English = "Conceal"
		}
})
