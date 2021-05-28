CLASS.AddClass("BULLET", {
	color = Color(204, 39, 136, 255),
	passiveItems = {
		"item_ttt_speedrun"
	},
	avoidWeaponReset = true,
	time = 2,
	cooldown = 20,
	OnAbilityActivate = function(ply)
		ply.bulletIsAvtive = true
	end,
	OnAbilityDeactivate = function(ply)
		ply.bulletIsAvtive = false
	end,
	lang = {
		name = {
			en = "Bullet",
			fr = "Bullet",
			ru = "Пуля"
		},
		desc = {
			en = "The Bullet already walks quite a bit faster than other players. But on activation of their ability, they receives a short, but even greater, speedboost.",
			fr = "The Bullet marche un peu plus vite que les autres joueurs. Mais à l'activation de sa capacité, il reçoit pendant une courte durée un gros boost de vitesse.",
			ru = "Пуля уже ходит немного быстрее, чем другие игроки. Но при активации способности она получает короткое, но ещё более сильное усиление скорости."
		}
	}
})

hook.Add("TTTPlayerSpeedModifier", "TTTCBulletSpeedMod", function(ply, _, _, speedMultiplierModifier)
	if ply:GetCustomClass() ~= CLASS.CLASSES.BULLET.index or not ply.bulletIsAvtive then return end

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 2.0
end)
