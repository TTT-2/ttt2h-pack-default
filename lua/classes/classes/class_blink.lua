CLASS.AddClass("BLINK", { -- should be called in InitializeHook to be able to use items
	color = Color(24, 68, 57, 255),
	passiveItems = {
		"item_ttt_nofalldmg"
	},
	weapons = {
		"weapon_vadim_blink"
	},
	time = 30,
	cooldown = 45,
	lang = {
		name = {
			English = "Blink"
		},
		desc = {
			English = "The Blink does not receive any falldamage. Additionally, he can use his blink item for 30 seconds every 45 seconds."
		}
	}
})
