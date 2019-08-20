CLASS.AddHero("BREACH", {
		color = Color(200, 70, 35, 255),
		passiveItems = {
			"item_ttt_armor"
		},
		avoidWeaponReset = true,
		onActivate = function(ply)
			if SERVER then
				local weps = ply:GetWeapons()

				ply.breachStoredWEPS = {}

				for _, wep in pairs(weps) do
					if wep.Kind == WEAPON_HEAVY then
						local cls = WEPS.GetClass(wep)

						ply.breachStoredWEPS[#ply.breachStoredWEPS + 1] = {cls = cls, clip1 = wep:Clip1(), clip2 = wep:Clip2()}

						ply:StripWeapon(cls)
					end
				end

				ply:GiveEquipmentWeapon("weapon_ttt_bulldozer") -- GiveEquipmentWeapon handles giving a weapon like buying it
			end
		end,
		onDeactivate = function(ply)
			if SERVER then
				ply:StripWeapon("weapon_ttt_bulldozer")

				if ply.breachStoredWEPS then
					for _, tbl in ipairs(ply.breachStoredWEPS) do
						if tbl.cls then
							local wep = ply:Give(tbl.cls)

							if IsValid(wep) then
								wep:SetClip1(tbl.clip1 or 0)
								wep:SetClip2(tbl.clip2 or 0)
							end
						end
					end

					ply.breachStoredWEPS = nil
				end
			end
		end,
		time = 30,
		amount = 1,
		langs = {
			English = "Breach"
		}
})
