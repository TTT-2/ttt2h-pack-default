local timescale = 0.3
local cooldown = 45
local duration = 5

CLASS.AddClass("CLOCKWORK", {
	color = Color(149, 188, 195, 255),
	OnAbilityActivate = function(ply)
		if SERVER then
			ply:EnableSlowMotion2()
		end
	end,
	time = duration * timescale,
	cooldown = cooldown,
	unstoppable = true,
	items = {
		"item_ttt_sm"
	},
	passiveItems = {
		"item_ttt_shootingspeed"
	},
	avoidWeaponReset = true,
	lang = {
		name = {
			en = "Clockwork",
			fr = "Horloger",
			ru = "Часовой"
		},
		desc = {
			en = "The weapons of the clockwork have a faster shooting speed than they would normally have. Additionally, they are able to slow down the time for 3 seconds once every 45 seconds.",
			fr = "Les armes de l'Horloger ont une cadence de tir plus rapide. De plus, elles sont capables de ralentir le temps pendant 3 secondes une fois toutes les 45 secondes.",
			ru = "Оружие часового имеет более высокую скорость стрельбы, чем обычно. Кроме того, он может замедлять время на 3 секунды каждые 45 секунд."
		}
	}
})
