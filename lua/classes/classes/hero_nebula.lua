if SERVER then
	util.AddNetworkString("TTTHNebula")
end

local function DeactivateNebula(ply)
	if SERVER then
		ply.heroes_nebula = nil

		if timer.Exists("ttth_nebula_" .. ply:EntIndex()) then
			timer.Remove("ttth_nebula_" .. ply:EntIndex())
		end

		hook.Remove("TTTPlayerSpeedModifier", "TTTHNebulaSpeed".. ply:UniqueID())

		if timer.Exists("ttth_neb_end_" .. ply:EntIndex()) then
			timer.Remove("ttth_neb_end_" .. ply:EntIndex())
		end

		net.Start("TTTHNebula")
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()
	end
end

local function NebulaFunction(ply)
	if SERVER then
		ply.heroes_nebula = true
		ply.heroes_nebula_pos = ply:GetPos()
		ply.heroes_nebula_r = 320

		timer.Create("ttth_nebula_" .. ply:EntIndex(), 1, 0, function()
			local plys = player.GetAll()

			for _, v in ipairs(plys) do
				if v.heroes_nebula_pos then
					for _, pl in ipairs(plys) do
						local pos = pl:GetPos()
						local d = pos:Distance(v.heroes_nebula_pos)

						if d <= v.heroes_nebula_r then
							pl:SetHealth(math.min(pl:Health() + 2, pl:GetMaxHealth()))
						end
					end
				end
			end
		end)

		hook.Add("TTTPlayerSpeedModifier", "TTTHNebulaSpeed" .. ply:UniqueID(), function(pl, _, _, noLag)
			if pl ~= ply or not ply.heroes_nebula_pos or not ply.heroes_nebula_r then return end

			local pos = pl:GetPos()
			local d = pos:Distance(ply.heroes_nebula_pos)

			if d <= ply.heroes_nebula_r then
				noLag[1] = noLag[1] * 1.5
			end
		end)

		net.Start("TTTHNebula")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.Broadcast()

		timer.Create("ttth_neb_end_" .. ply:EntIndex(), 15, 1, function()
			if IsValid(ply) then
				DeactivateNebula(ply)
			end
		end)
	end
end

CLASS.AddHero("NEBULA", {
		color = Color(75, 139, 157, 255),
		onDeactivate = NebulaFunction,
		time = 0,
		cooldown = 50,
		langs = {
			English = "Nebula"
		}
})

if SERVER then
	hook.Add("TTTPrepareRound", "TTTHDeactivateNebula", function()
		local plys = player.GetAll()

		for _, v in ipairs(plys) do
			if v.heroes_nebula then
				DeactivateNebula(v)
			end
		end
	end)

	hook.Add("TTTEndRound", "TTTHDeactivateNebula", function()
		local plys = player.GetAll()

		for _, ply in ipairs(plys) do
			if ply.heroes_nebula then
				DeactivateNebula(ply)
			end
		end
	end)
else
	local smokeparticles = {
		Model("particle/particle_smokegrenade"),
		Model("particle/particle_noisesphere")
	}

	net.Receive("TTTHNebula", function()
		local ply = net.ReadEntity()
		local bool = net.ReadBool()

		if IsValid(ply) then
			if bool then
				local center = ply:GetPos()
				local em = ParticleEmitter(center)
				local r = 320 -- ca. 5m (64 * 5)

				ply.heroes_nebula_pos = center
				ply.heroes_nebula_r = r

				for i = 1, 200 do
					local prpos = VectorRand() * r
					prpos.z = prpos.z + 332
					prpos.z = math.min(prpos.z, 52)

					local p = em:Add(table.Random(smokeparticles), center + prpos)
					if p then
						local gray = math.random(75, 200)
						p:SetColor(gray, gray, gray)
						p:SetStartAlpha(255)
						p:SetEndAlpha(200)
						p:SetVelocity(VectorRand() * math.Rand(900, 1300))
						p:SetLifeTime(0)

						p:SetDieTime(15)

						p:SetStartSize(math.random(140, 150))
						p:SetEndSize(math.random(1, 40))
						p:SetRoll(math.random(-180, 180))
						p:SetRollDelta(math.Rand(-0.1, 0.1))
						p:SetAirResistance(600)

						p:SetCollide(true)
						p:SetBounce(0.4)

						p:SetLighting(false)
					end

					ply.heroes_nebula_p = ply.heroes_nebula_p or {}
					ply.heroes_nebula_p[#ply.heroes_nebula_p + 1] = p
				end

				em:Finish()
			else
				if ply.heroes_nebula_p then
					for _, v in ipairs(ply.heroes_nebula_p) do
						v:SetDieTime(-1)
					end

					ply.heroes_nebula_p = nil
					ply.heroes_nebula_pos = nil
					ply.heroes_nebula_r = nil
				end
			end
		end
	end)
end
