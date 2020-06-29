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
			English = "Clockwork"
		},
		desc = {
			English = "The weapons of the clockwork have a faster shooting speed than they would normally have. Additionally, he is able to slow down the time for 3 seconds once every 45 seconds."
		}
	}
})
