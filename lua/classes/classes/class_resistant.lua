CLASS.AddClass("RESISTANT", {
	color = Color(103, 73, 8, 255),
	items = {
		"item_ttt_blockdmg"
	},
	passiveItems = {
		"item_ttt_noexplosiondmg"
	},
	onActivate = function(ply)
		if SERVER then
			ply:EmitSound("buttons/blip1.wav", 100, 100, 1, CHAN_AUTO)
		end
	end,
	onDeactivate = function(ply)
		if SERVER then
			ply:EmitSound("buttons/blip1.wav", 100, 100, 1, CHAN_AUTO)
		end
	end,
	time = 2,
	cooldown = 30,
	lang = {
		name = {
			English = "Resistant"
		},
		desc = {
			English = "The Resistant receives no explosion damage. Once every 30 seconds he can block all incoming damage for two seconds. However he is unable to shoot back while deflecting damage."
		}
	}
})
