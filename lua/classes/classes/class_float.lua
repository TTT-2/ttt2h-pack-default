local function FloatFunction(ply)
	if SERVER and ULib then
		if ply:GetMoveType() == MOVETYPE_OBSERVER or not ply:Alive() then return end -- Nothing we can do.

		if ply:InVehicle() then
			ply:ExitVehicle()
		end

		if ply:GetMoveType() == MOVETYPE_NOCLIP then
			ply:SetMoveType(MOVETYPE_WALK)
		end

		ULib.applyAccel(ply, 1500, Vector(0, 0, 10))
	end
end

CLASS.AddClass("FLOAT", {
	color = Color(35, 44, 160, 255),
	passiveItems = {
		"item_ttt_glider"
	},
	OnAbilityDeactivate = FloatFunction,
	time = 0,
	cooldown = 30,
	lang = {
		name = {
			English = "Float",
			French = "Flotteur",	
			Русский = "Поплавок"
		},
		desc = {
			English = "The Float slowly glides to the ground and therefore never receives any falldamage. Activating their ability propulses them into the sky only to slowly glide back to the ground.",
			French = "Le Flotteur glisse lentement vers le sol et ne subit donc jamais de dégâts de chute. L'activation de sa capacité le propulse dans le ciel pour ensuite retomber lentement au sol.",	
			Русский = "Поплавок медленно скользит к земле и поэтому никогда не получает урона от падения. Активация его способности толкает его в небо только для того, чтобы медленно скользить обратно на землю."
		}
	}
})
