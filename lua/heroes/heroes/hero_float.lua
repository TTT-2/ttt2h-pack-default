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

HEROES.AddHero("FLOAT", {
		color = Color(35, 44, 160, 255),
		passiveItems = {
			"item_ttt_glider"
		},
		onDeactivate = FloatFunction,
		time = 0,
		cooldown = 30,
		langs = {
			English = "Float"
		}
})
