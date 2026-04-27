CLASS.AddClass("BLINK", { -- should be called in InitializeHook to be able to use items
	color = Color(24, 68, 57, 255),
	passiveItems = {
		"item_ttt_nofalldmg"
	},
	OnAbilityActivate = function(ply)
		if not SERVER then return end

		local weps = ply:GetWeapons()

		ply.blinkStoredWEPS = {}

		for _, wep in pairs(weps) do
			if wep.Kind == WEAPON_HEAVY then
				local cls = WEPS.GetClass(wep)

				ply.blinkStoredWEPS[#ply.blinkStoredWEPS + 1] = {cls = cls, clip1 = wep:Clip1(), clip2 = wep:Clip2()}

				ply:StripWeapon(cls)
			end
		end

		ply:GiveEquipmentWeapon("weapon_ttt_minty_blink") -- GiveEquipmentWeapon handles giving a weapon like buying it

		-- don't allow dropping blink
		local wep = ply:GetWeapon("weapon_ttt_minty_blink")
		if IsValid(wep) then
			wep.AllowDrop = false
		end

		-- select blink
		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply:SelectWeapon("weapon_ttt_minty_blink")
			end
		end)
	end,
	OnAbilityDeactivate = function(ply)
		if not SERVER then return end

		ply:StripWeapon("weapon_ttt_minty_blink")

		if ply.blinkStoredWEPS then
			for _, tbl in ipairs(ply.blinkStoredWEPS) do
				if tbl.cls then
					local wep = ply:Give(tbl.cls)

					if IsValid(wep) then
						wep:SetClip1(tbl.clip1 or 0)
						wep:SetClip2(tbl.clip2 or 0)
					end
				end
			end

			ply.blinkStoredWEPS = nil
		end
	end,
	time = 30,
	cooldown = 45,
	lang = {
		name = {
			en = "Blink",
			fr = "Le Ressort",
			ru = "Скачок"
		},
		desc = {
			en = "The Blink does not receive any falldamage. Additionally, they can use their blink item for 30 seconds every 45 seconds.",
			fr = "Le ressort ne prend pas de dégâts de chute.  Il peut rebondir pendant 30 secondes toutes les 45 secondes.",
			ru = "Скачок не получает никакого урона от падения. Кроме того, он может использовать свой скачок в течение 30 секунд каждые 45 секунд."
		}
	}
})
