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
	langs = {
		English = "Blink"
	}
})
