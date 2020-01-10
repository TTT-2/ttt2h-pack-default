if SERVER then
	resource.AddFile("sound/heroes/vendetta.wav")

	util.AddNetworkString("TTTCVendettaTarget")
end

util.PrecacheSound("heroes/vendetta.wav")

-- REWORK
-- maybe use this player model "models/player/charple.mdl"

sound.Add({
	name = "class_vendetta",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	sound = "heroes/vendetta.wav"
})

CLASS.AddClass("VENDETTA", {
	color = Color(99, 1, 3, 255),
	deactivated = true,
	activeDuringDeath = true,
	surpressKeepOnRespawn = true,
	onClassSet = function(ply)
		ply.vendetta = true
	end,
	onClassUnset = function(ply)
		ply.vendetta = nil
		ply.vendettaTarget = nil
	end,
	lang = {
		name = {
			English = "Vendetta"
		},
		desc = {
			English = "The Vendetta plays with his life. After beeing killed, he will respawn with a knife to revenge himself! He has no active ability."
		}
	}
})

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
		net.Start("TTTCVendettaTarget")
		net.WriteEntity(target)
		net.Send(victim)
	end

	hook.Add("TTT2PostPlayerDeath", "OnVendettaDeath", function(victim, inflictor, attacker)
		victim.vendettaRevived = nil

		if IsValid(attacker) and attacker:IsPlayer() and attacker.vendettaRevived then
			local dmg = DamageInfo()

			dmg:SetDamage(2000)
			dmg:SetAttacker(attacker)
			dmg:SetDamageForce(attacker:GetAimVector())
			dmg:SetDamagePosition(attacker:GetPos())
			dmg:SetDamageType(DMG_SLASH)

			attacker:TakeDamageInfo(dmg)
		end

		if victim.vendettaTarget then
			victim.vendettaTarget = nil

			SendVendettaTarget(victim, nil)
		end

		if victim.vendetta and not victim.reviving then
			victim.vendetta = nil

			victim:ChatPrint("[TTTC][Vendetta] Fähigkeit aktiviert...")

			-- revive after 5s
			victim:Revive(5, function(p) -- this is a TTT2 function that will handle everything else
				p:EmitSound("class_vendetta", 70)
				p:StripWeapons()
				p:Give("weapon_ttt_tigers")

				p.vendettaRevived = CurTime()

				if IsValid(attacker) then
					p.vendettaTarget = attacker

					SendVendettaTarget(p, attacker)
				end
			end,
			nil,
			false, true, -- there need to be your corpse and you don't prevent win
			nil)
		elseif victim.vendetta and victim.reviving then
			victim:ChatPrint("[TTTC][Vendetta] Fähigkeit nicht aktiviert, da du gerade wiederbelebt wirst...")
		end
	end)

	hook.Add("PlayerCanPickupWeapon", "TTTCVendettaPickupWeapon", function(ply, wep)
		if not ply.vendettaRevived then return end

		if WEPS.GetClass(wep) == "weapon_ttt_tigers" and not ply:HasWeapon("weapon_ttt_tigers") then
			return true
		end

		return false
	end)

	hook.Add("Think", "VendettaDmgHealth", function()
		for _, v in ipairs(player.GetAll()) do
			local time = CurTime()

			if v.vendettaRevived and v.vendettaRevived + 1 <= time and GetRoundState() == ROUND_ACTIVE then
				v.vendettaRevived = time + 1

				v:TakeDamage(5, game.GetWorld())
			end
		end
	end)
else
	net.Receive("TTTCVendettaTarget", function(len)
		LocalPlayer().vendettaTarget = net.ReadEntity()
	end)

	hook.Add("PreDrawOutlines", "VendettaPlayerBorders", function()
		local client = LocalPlayer()
		local target = client.vendettaTarget

		if not IsValid(target) or not target:IsActive() then return end

		outline.Add(target, Color(255, 50, 50))
	end)
end

-- shared because this is predicted
hook.Add("TTTPlayerSpeedModifier", "HeroVendettaModifySpeed", function(ply, _, _, refTbl)
	if not IsValid(ply) or not ply:Alive() or not ply:IsTerror() or not ply.vendettaTarget then return end

	refTbl[1] = refTbl[1] * 2
end)
