local bulletActiveSpeedMul = 2

CLASS.AddClass("BULLET", {
		color = Color(204, 39, 136, 255),
		onActivate = function(ply)
			if SERVER then
				ply.speedrun_mul = bulletActiveSpeedMul * (ply.speedrun_mul or 1)
			end
		end,
		onDeactivate = function(ply)
			if SERVER then
				ply.speedrun_mul = (ply.speedrun_mul or bulletActiveSpeedMul) / bulletActiveSpeedMul
			end
		end,
		passiveItems = {
			"item_ttt_speedrun"
		},
		avoidWeaponReset = true,
		time = 2,
		cooldown = 20,
		langs = {
			English = "Bullet"
		}
})
