HEROES.AddHero("MIRROR", {
		color = Color(71, 80, 51, 255),
		items = {
			"item_ttt_reflectdmg"
		},
		onActivate = function(ply)
			if SERVER then
				ply:EmitSound("buttons/blip1.wav", 100, 100, 1, CHAN_AUTO)
			end
		end,
		onDeactivate = function(ply)
			if SERVER then
				ply:EmitSound("buttons/blip1.wav", 100, 100, 1, CHAN_AUTO)
			end
		end,
		avoidWeaponReset = true,
		time = 3,
		cooldown = 60,
		langs = {
			English = "Mirror"
		}
})
