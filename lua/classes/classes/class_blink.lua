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
			en = "Blink",
			fr = "Le Ressort",
			ru = "Скачок"
		},
		desc = {
			en = "The Blink does not receive any falldamage. Additionally, they can use their blink item for 30 seconds every 45 seconds.",
			fr = "Le ressort ne prend pas de dégâts de chute.  Il peut rebondir pendant 30 secondes toutes les 45 secondes.",
			ru = "Скачок не получает никакого урона от падения. Кроме того, он может использовать свой скачок в течение 30 секунд каждые 45 секунд."
		}
	}
})
