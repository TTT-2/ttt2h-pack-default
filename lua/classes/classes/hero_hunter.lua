local function HunterFunction(ply)
	if SERVER and ply:OnGround() then
		ply:ConCommand("+jump")
		ply:SetVelocity(Vector(ply:GetAimVector().x * 900, ply:GetAimVector().y * 900, ply:GetAimVector().z * 900 + ply:GetUp().z * 100))

		ply.classHunting = true

		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply:ConCommand("-jump")
			end
		end)
	end
end

CLASS.AddHero("HUNTER", {
		color = Color(137, 72, 6, 255),
		passiveItems = {
			"item_ttt_nofalldmg"
		},
		onDeactivate = HunterFunction,
		time = 0,
		cooldown = 10,
		langs = {
			English = "Hunter"
		}
})

hook.Add("OnPlayerHitGround", "TTTCHunterHitGround", function(ply)
	if ply.classHunting then
		ply.classHunting = nil

		return false
	end
end)
