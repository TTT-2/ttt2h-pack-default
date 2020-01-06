if SERVER then
	resource.AddFile("materials/vgui/ttt/heroes/status/hud_icon_heal.png")

	util.AddNetworkString("TTTCNebula")
end

-- register status effect icon
if CLIENT then
	hook.Add("Initialize", "ttt2h_status_nebula_init", function() 
		STATUS:RegisterStatus("ttt2h_status_nebula", {
			hud = Material("vgui/ttt/heroes/status/hud_icon_heal.png"),
			type = "good"
		})
	end)
end

local function DeactivateNebula(ply)
	if SERVER then
		ply.classes_nebula = nil

		if timer.Exists("tttc_nebula_" .. ply:EntIndex()) then
			timer.Remove("tttc_nebula_" .. ply:EntIndex())
		end

		if timer.Exists("ttth_nebula_status_" .. ply:EntIndex()) then
			timer.Remove("ttth_nebula_status_" .. ply:EntIndex())
		end

		if timer.Exists("tttc_neb_end_" .. ply:EntIndex()) then
			timer.Remove("tttc_neb_end_" .. ply:EntIndex())
		end

		net.Start("TTTCNebula")
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()
	end

	hook.Remove("TTTPlayerSpeedModifier", "TTTCNebulaSpeed_" .. ply:SteamID64())
end

local function NebulaFunction(ply)
	if SERVER then
		ply.classes_nebula = true
		ply.classes_nebula_pos = ply:GetPos()
		ply.classes_nebula_r = 320

		timer.Create("tttc_nebula_" .. ply:EntIndex(), 1, 0, function()
			local plys = player.GetAll()

			for _, v in ipairs(plys) do
				if v.classes_nebula_pos then
					for _, pl in ipairs(plys) do
						local pos = pl:GetPos()
						local d = pos:Distance(v.classes_nebula_pos)

						if d <= v.classes_nebula_r then
							pl:SetHealth(math.min(pl:Health() + 2, pl:GetMaxHealth()))
						end
					end
				end
			end
		end)

		timer.Create("ttth_nebula_status_" .. ply:EntIndex(), 0.1, 0, function()
			local plys = player.GetAll()

			for _, v in ipairs(plys) do
				if v.classes_nebula_pos then
					for _, pl in ipairs(plys) do
						local pos = pl:GetPos()

						local last_selected = pl.ttthnebulaselected

						pl.ttthnebulaselected = pos:Distance(v.classes_nebula_pos) <= v.classes_nebula_r

						if not last_selected and pl.ttthnebulaselected then
							STATUS:AddStatus(pl, "ttt2h_status_nebula")
						elseif last_selected and not pl.ttthnebulaselected then
							STATUS:RemoveStatus(pl, "ttt2h_status_nebula")
						end
					end
				end
			end
		end)

		net.Start("TTTCNebula")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.Broadcast()

		timer.Create("tttc_neb_end_" .. ply:EntIndex(), 15, 1, function()
			if IsValid(ply) then
				DeactivateNebula(ply)
			end
		end)
	end

	-- shared because it is predicted
	hook.Add("TTTPlayerSpeedModifier", "TTTCNebulaSpeed_" .. ply:SteamID64(), function(pl, _, _, refTbl)
		if pl ~= ply or not ply.classes_nebula_pos or not ply.classes_nebula_r then return end

		local pos = pl:GetPos()
		local d = pos:Distance(ply.classes_nebula_pos)

		if d <= ply.classes_nebula_r then
			refTbl[1] = refTbl[1] * 1.5
		end
	end)
end

CLASS.AddClass("NEBULA", {
	color = Color(75, 139, 157, 255),
	onDeactivate = NebulaFunction,
	time = 0,
	cooldown = 50,
	lang = {
		name = {
			English = "Nebula"
		},
		desc = {
			English = "The Nebula is able to spawn huge clouds. These clouds have the added benefit of creating a slow health regen effect for all players stuck inside. He also receives a small sprint boost inside his mist. He has no passive ability."
		}
	}
})

if SERVER then
	hook.Add("TTTPrepareRound", "TTTCDeactivateNebula", function()
		local plys = player.GetAll()

		for _, v in ipairs(plys) do
			if v.classes_nebula then
				DeactivateNebula(v)
			end
		end
	end)

	hook.Add("TTTEndRound", "TTTCDeactivateNebula", function()
		local plys = player.GetAll()

		for _, ply in ipairs(plys) do
			if ply.classes_nebula then
				DeactivateNebula(ply)
			end
		end
	end)
else
	local smokeparticles = {
		Model("particle/particle_smokegrenade"),
		Model("particle/particle_noisesphere")
	}

	net.Receive("TTTCNebula", function()
		local ply = net.ReadEntity()
		local bool = net.ReadBool()

		if IsValid(ply) then
			if bool then
				local center = ply:GetPos()
				local em = ParticleEmitter(center)
				local r = 320 -- ca. 5m (64 * 5)

				ply.classes_nebula_pos = center
				ply.classes_nebula_r = r

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

					ply.classes_nebula_p = ply.classes_nebula_p or {}
					ply.classes_nebula_p[#ply.classes_nebula_p + 1] = p
				end

				em:Finish()
			else
				if ply.classes_nebula_p then
					for _, v in ipairs(ply.classes_nebula_p) do
						v:SetDieTime(-1)
					end

					ply.classes_nebula_p = nil
					ply.classes_nebula_pos = nil
					ply.classes_nebula_r = nil
				end

				STATUS:RemoveStatus("ttt2h_status_nebula")
			end
		end
	end)
end
