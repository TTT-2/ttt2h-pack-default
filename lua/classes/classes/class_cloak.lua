if SERVER then
	AddCSLuaFile("gamemodes/terrortown/entities/effects/druncloak.lua")
end

CLASS.AddClass("CLOAK", {
	color = Color(109, 64, 138, 255),
	OnAbilityActivate = function(ply)
		if SERVER then
			ply:DrawWorldModel(false)
			ply:SetBloodColor(DONT_BLEED)
			ply:DrawShadow(false)
			ply:Flashlight(false)
			ply:AllowFlashlight(false)
			ply:SetFOV(0, 0.2)
			ply:SetNoDraw(true)

			local ownerwep = ply:GetActiveWeapon()

			if ownerwep.Base == "weapon_tttbase" then
				ownerwep:SetIronsights(false)
			end

			ply:SetNWBool("disguised", true)
		end
	end,
	OnAbilityDeactivate = function(ply)
		if SERVER then
			ply:DrawWorldModel(true)
			ply:SetBloodColor(BLOOD_COLOR_RED)
			ply:DrawShadow(true)
			ply:AllowFlashlight(true)
			ply:SetNoDraw(false)

			local effectdata = EffectData()
			effectdata:SetOrigin(ply:GetPos())

			util.Effect("druncloak", effectdata, true, true)

			ply:SetNWBool("disguised", false)
		end
	end,
	time = 5,
	cooldown = 45,
	lang = {
		name = {
			English = "Cloak"
		},
		desc = {
			English = "The Cloak is able to turn fully invisible for five seconds by activating their ability. They have no passive ability."
		}
	}
})
