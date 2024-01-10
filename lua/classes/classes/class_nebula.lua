local nebulaRadius = 320 -- ca. 5m (64 * 5)
local nebulaDuration = 20

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

local function NebulaDeactivateFunction(ply)
	if SERVER then
		ply.classes_nebula = nil

		if timer.Exists("tttc_nebula_" .. ply:EntIndex()) then
			timer.Remove("tttc_nebula_" .. ply:EntIndex())
		end

		if timer.Exists("tttc_neb_end_" .. ply:EntIndex()) then
			timer.Remove("tttc_neb_end_" .. ply:EntIndex())
		end

		net.Start("TTTCNebula")
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()

		local plys = player.GetAll()

		-- clear the status from all (normal) players
		for i = 1, #plys do
			local plyNormal = plys[i]

			if not plyNormal.hasNebulaEffect then continue end

			plyNormal.hasNebulaEffect = false

			STATUS:RemoveStatus(plyNormal, "ttt2h_status_nebula")
		end
	end

	hook.Remove("TTTPlayerSpeedModifier", "TTTCNebulaSpeed_" .. ply:SteamID64())
end

local timeNextHeal = 0

local function NebulaActivateFunction(ply)
	-- shared because it is predicted
	hook.Add("TTTPlayerSpeedModifier", "TTTCNebulaSpeed_" .. ply:SteamID64(), function(pl, _, _, refTbl)
		if pl ~= ply or not ply.classes_nebula_pos or not ply.classes_nebula_r then return end

		local pos = pl:GetPos()
		local d = pos:Distance(ply.classes_nebula_pos)

		if d <= ply.classes_nebula_r then
			refTbl[1] = refTbl[1] * 1.5
		end
	end)

	if CLIENT then return end

	ply.classes_nebula = true
	ply.classes_nebula_pos = ply:GetPos() + ply:OBBCenter()
	ply.classes_nebula_r = nebulaRadius

	timer.Create("tttc_nebula_" .. ply:EntIndex(), 0.05, 0, function()
		local plys = player.GetAll()

		for i = 1, #plys do
			local plyNebula = plys[i]

			-- only continue if a nebula player is in round
			if not plyNebula.classes_nebula then continue end

			for j = 1, #plys do
				local plyHealed = plys[j]

				local distance = (plyHealed:GetPos() + plyHealed:OBBCenter()):Distance(plyNebula.classes_nebula_pos)
				local hadNebulaEffect = plyHealed.hasNebulaEffect

				if not hadNebulaEffect and distance <= plyNebula.classes_nebula_r then
					plyHealed.hasNebulaEffect = true

					STATUS:AddStatus(plyHealed, "ttt2h_status_nebula")
				elseif hadNebulaEffect and distance > plyNebula.classes_nebula_r then
					plyHealed.hasNebulaEffect = false

					STATUS:RemoveStatus(plyHealed, "ttt2h_status_nebula")
				end

				-- increase health
				if distance <= plyNebula.classes_nebula_r and CurTime() > timeNextHeal then
					plyHealed:SetHealth(math.min(plyHealed:Health() + 1, plyHealed:GetMaxHealth()))

					timeNextHeal = CurTime() + 0.5
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

CLASS.AddClass("NEBULA", {
	color = Color(75, 139, 157, 255),
	OnAbilityActivate = NebulaActivateFunction,
	OnAbilityDeactivate = NebulaDeactivateFunction,
	time = nebulaDuration,
	cooldown = 40,
	lang = {
		name = {
			en = "Nebula",
			fr = "Nébuleux",
			ru = "Туманность"
		},
		desc = {
			en = "The Nebula is able to spawn huge clouds. These clouds have the added benefit of creating a slow health regen effect for all players staying inside. They also receive a small speed boost inside their mist. They have no passive ability.",
			fr = "Le Nébuleux est capable de produire d'énormes nuages. Ces nuages ont l'avantage de créer une zone de régénération de santé pour tous les joueurs qui restent à l'intérieur. Ils reçoivent également un petit boost de vitesse à l'intérieur du brouillard. Il n'a aucune capacité passive.",
			ru = "Туманность способна создавать огромные облака. Эти облака имеют дополнительное преимущество, создавая эффект медленного восстановления здоровья для всех игроков, находящихся внутри. Она также получает небольшой прирост скорости в своем тумане. У неё нет пассивных способностей."
		}
	}
})

if SERVER then
	hook.Add("TTTPrepareRound", "TTTCDeactivateNebula", function()
		local plys = player.GetAll()

		for _, v in ipairs(plys) do
			if v.classes_nebula then
				NebulaDeactivateFunction(v)
			end
		end
	end)

	hook.Add("TTTEndRound", "TTTCDeactivateNebula", function()
		local plys = player.GetAll()

		for _, ply in ipairs(plys) do
			if ply.classes_nebula then
				NebulaDeactivateFunction(ply)
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
				local r = nebulaRadius

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

						p:SetDieTime(nebulaDuration)

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
			end
		end
	end)
end
