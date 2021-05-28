CLASS.AddClass("MIRROR", {
	color = Color(71, 80, 51, 255),
	items = {
		"item_ttt_reflectdmg"
	},
	OnAbilityActivate = function(ply)
		if SERVER then
			ply:EmitSound("buttons/blip1.wav", 100, 100, 1, CHAN_AUTO)
		end
	end,
	OnAbilityDeactivate = function(ply)
		if SERVER then
			ply:EmitSound("buttons/blip1.wav", 100, 100, 1, CHAN_AUTO)
		end
	end,
	avoidWeaponReset = true,
	time = 3,
	cooldown = 60,
	lang = {
		name = {
			English = "Mirror",
			French = "Miroir",	
			Русский = "Зеркальный"
		},
		desc = {
			English = "The Mirror is able to block and reflect all incoming damage for 3 seconds once every minute. They have no passive ability.",
			French = "Le Miroir est capable de bloquer et de refléter tous les dégâts pendant 3 secondes une fois par minute. Il n'a pas de capacité passive.",	
			Русский = "Зеркальный способен блокировать и отражать весь входящий урон в течение 3 секунд каждую минуту. У него нет пассивных способностей."
		}
	}
})
