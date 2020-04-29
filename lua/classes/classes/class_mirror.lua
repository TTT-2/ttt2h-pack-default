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
			English = "Mirror"
		},
		desc = {
			English = "The Mirror is able to block and reflect all incoming damage for three seconds once every minute. He has no passive ability."
		}
	}
})
