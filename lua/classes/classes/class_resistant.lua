CLASS.AddClass("RESISTANT", {
	color = Color(103, 73, 8, 255),
	items = {
		"item_ttt_blockdmg"
	},
	passiveItems = {
		"item_ttt_noexplosiondmg"
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
	time = 2,
	cooldown = 30,
	lang = {
		name = {
			en = "Resistant",
			fr = "Résistant",
			ru = "Стойкий"
		},
		desc = {
			en = "The Resistant receives no explosion damage. Once every 30 seconds they can block all incoming damage for 2 seconds. However, they are unable to shoot back while deflecting damage.",
			fr = "Le Résistant ne reçoit aucun dégât dû aux explosions. Une fois toutes les 30 secondes, il peut bloquer tous les dégâts  pendant 2 secondes. Cependant, il est incapables de riposter tout en bloquant les dégâts.",
			ru = "Стойкий не получает урона от взрыва. Раз в 30 секунд он может блокировать весь входящий урон на 2 секунды. Однако он не может стрелять, отражая урон."
		}
	}
})
