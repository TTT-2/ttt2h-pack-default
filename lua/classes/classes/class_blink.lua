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
			English = "The Blink does not receive any fallfamage. Additionally he is once every 45 seconds able to use the blink item for up to 30 seconds."
		}
	}
})
