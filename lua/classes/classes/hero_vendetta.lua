if SERVER then
	resource.AddFile("sound/classes/vendetta.wav")

	util.AddNetworkString("TTTHVendettaTarget")
end

util.PrecacheSound("classes/vendetta.wav")

-- REWORK
-- maybe use this player model "models/player/charple.mdl"

sound.Add({
		name = "class_vendetta",
		channel = CHAN_STATIC,
		volume = 0.70,
		level = 70,
		sound = "classes/vendetta.wav"
})

CLASS.AddHero("VENDETTA", {
		color = Color(99, 1, 3, 255),
		deactivated = true,
		langs = {
			English = "Vendetta"
		}
})

hook.Add("TTTHUpdateHero", "UpdateVendetta", function(ply, old, new)
	local vendetta = CLASS.CLASSES.VENDETTA.index
	if new == vendetta then
		ply.vendetta = true
	elseif old == vendetta then
		if new then
			ply.vendetta = nil
		end

		ply.vendettaTarget = nil
	end
end)

hook.Add("TTTEndRound", "ResetVendetta", function()
	for _, ply in ipairs(player.GetAll()) do
		ply.vendetta = nil
		ply.vendettaRevived = nil
		ply.vendettaTarget = nil
	end
end)

hook.Add("TTTBeginRound", "ResetVendetta", function()
	for _, ply in ipairs(player.GetAll()) do
		ply.vendetta = nil
		ply.vendettaRevived = nil
		ply.vendettaTarget = nil
	end
end)

if SERVER then
	local function SendVendettaTarget(victim, target)
		net.Start("TTTHVendettaTarget")
		net.WriteEntity(target)
		net.Send(victim)
	end

	hook.Add("TTT2PostPlayerDeath", "OnVendettaDeath", function(victim, inflictor, attacker)
		victim.vendettaRevived = nil

		if IsValid(attacker) and attacker:IsPlayer() and attacker.vendettaRevived
		and IsValid(inflictor) and WEPS.GetClass(inflictor) == "weapon_ttt_bloodyknife"
		then
			attacker:TakeDamage(99999, game.GetWorld(), inflictor)
		end

		if victim.vendettaTarget then
			victim.vendettaTarget = nil

			SendVendettaTarget(victim, nil)
		end

		if victim.vendetta and not victim.reviving then
			victim.vendetta = nil

			if not GetGlobalBool("ttt2_heroes") or victim:HasCrystal() then
				victim:ChatPrint("[TTTH][Vendetta] Fähigkeit aktiviert...")

				-- revive after 5s
				victim:Revive(5, function(p) -- this is a TTT2 function that will handle everything else
					p:EmitSound("class_vendetta", 70)
					p:StripWeapons()
					p:Give("weapon_ttt_bloodyknife")

					p.vendettaRevived = CurTime()

					if IsValid(attacker) then
						p.vendettaTarget = attacker

						SendVendettaTarget(p, attacker)
					end
				end,
				function(p) -- onCheck
					return not GetGlobalBool("ttt2_heroes") or p:HasCrystal()
				end,
				false, true, -- there need to be your corpse and you don't prevent win
				function(p) -- onFail
					if GetGlobalBool("ttt2_heroes") and p:HasCrystal() then
						p:ChatPrint("[TTTH][Vendetta] Du wurdest nicht wiederbelebt, da dein Kristall zerstört wurde...")
					end
				end)
			else
				victim:ChatPrint("[TTTH][Vendetta] Fähigkeit nicht aktiviert, da dein Kristall bereits zerstört wurde...")
			end
		elseif victim.vendetta and victim.reviving then
			victim:ChatPrint("[TTTH][Vendetta] Fähigkeit nicht aktiviert, da du gerade wiederbelebt wirst...")
		end
	end)

	hook.Add("PlayerCanPickupWeapon", "TTTHVendettaPickupWeapon", function(ply, wep)
		if ply.vendettaRevived and WEPS.GetClass(wep) ~= "weapon_ttt_bloodyknife" then
			return false
		end
	end)

	hook.Add("Think", "VendettaDmgHealth", function()
		for _, v in ipairs(player.GetAll()) do
			local time = CurTime()

			if v.vendettaRevived and v.vendettaRevived + 1 <= time then
				v.vendettaRevived = time + 1

				v:TakeDamage(5, game.GetWorld())
			end
		end
	end)

	hook.Add("TTTPlayerSpeedModifier", "HeroVendettaModifySpeed", function(ply, _, _, noLag)
		if IsValid(ply) and ply.vendettaRevived then
			noLag[1] = noLag[1] * 2
		end
	end)
else
	net.Receive("TTTHVendettaTarget", function(len)
		LocalPlayer().vendettaTarget = net.ReadEntity()
	end)

	hook.Add("PostDrawOpaqueRenderables", "VendettaPlayerBorders", function()
		local client = LocalPlayer()
		local target = client.vendettaTarget

		if not IsValid(target) or not target:IsActive() then return end

		--stencil work is done in postdrawopaquerenderables, where surface doesn't work correctly
		--workaround via 3D2D
		local ang = client:EyeAngles()
		local pos = client:EyePos() + ang:Forward() * 10

		ang = Angle(ang.p + 90, ang.y, 0)

		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(15)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_KEEP)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetBlend(0)

		target:DrawModel()

		render.SetBlend(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

		cam.Start3D2D(pos, ang, 1)

		surface.SetDrawColor(255, 50, 50)
		surface.DrawRect(-ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2)

		cam.End3D2D()

		target:DrawModel()

		render.SetStencilEnable(false)
	end)
end
