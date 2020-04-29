local bulletActiveSpeedMul = 2

CLASS.AddClass("BULLET", {
	color = Color(204, 39, 136, 255),
	OnAbilityActivate = function(ply)
		if SERVER then
			ply.speedrun_mul = bulletActiveSpeedMul * (ply.speedrun_mul or 1)
		end
	end,
	OnAbilityDeactivate = function(ply)
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
	lang = {
		name = {
			English = "Bullet"
		},
		desc = {
			English = "The Bullet already walks quite a bit faster than the other players. But on activation of his ability, he receives a mear speedboost."
		}
	}
})
