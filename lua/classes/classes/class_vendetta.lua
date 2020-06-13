if SERVER then
	resource.AddFile("sound/heroes/vendetta.wav")

	util.AddNetworkString("TTTCVendettaTarget")
end

if CLIENT then
	hook.Add("Initialize", "tttc_init_vendetta_lang", function()
		LANG.AddToLanguage("English", "tttc_vendetta_ability_activated", "Vendetta ability enabled! You will be soon revived.")
		LANG.AddToLanguage("English", "tttc_vendetta_ability_activated_error", "Enabling Vendetta ability failed since you are reviving right now.")
		LANG.AddToLanguage("English", "tttc_vendetta_revival_nick", "You were killed by {name}. Use your knife to revenge yourself!")
		LANG.AddToLanguage("English", "tttc_vendetta_revival", "You died. Use your knife to take someone with you!")
	end)
end

util.PrecacheSound("heroes/vendetta.wav")

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
	OnSet = function(ply)
		ply.vendetta = true
	end,
	OnUnset = function(ply)
		ply.vendetta = nil
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

			LANG.Msg(victim, "tttc_vendetta_ability_activated", nil, MSG_MSTACK_PLAIN)

			-- revive after 5s
			victim:Revive(5,
				function(p)
					p:EmitSound("class_vendetta", 70)
					p:StripWeapons()
					p:Give("weapon_ttt_tigers")

					p.vendettaRevived = CurTime()

					local target = IsValid(attacker) and attacker or victim

					if not IsValid(target) then return end

					p.vendettaTarget = target

					SendVendettaTarget(p, target)
				end,
				nil,
				false, -- doesn't need a corpse
				true -- does block the round
			)

			if IsValid(attacker) and attacker ~= victim then
				victim:SendRevivalReason("tttc_vendetta_revival_nick", {name = attacker:Nick()})
			else
				victim:SendRevivalReason("tttc_vendetta_revival")
			end
		elseif victim.vendetta and victim.reviving then
			LANG.Msg(victim, "tttc_vendetta_ability_activated_error", nil, MSG_MSTACK_WARN)
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

hook.Add("TTTPlayerSpeedModifier", "TTTCVendettaSpeedMod", function(ply, _, _, speedMultiplierModifier)
	if not IsValid(ply.vendettaTarget) then return end

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 2.0
end)
