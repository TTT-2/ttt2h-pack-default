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

CLASS.AddClass("HUNTER", {
	color = Color(137, 72, 6, 255),
	passiveItems = {
		"item_ttt_nofalldmg"
	},
	OnAbilityDeactivate = HunterFunction,
	time = 0,
	cooldown = 10,
	lang = {
		name = {
			English = "Hunter"
		},
		desc = {
			English = "The Hunter does not receive any falldamage. By using his ability, he performs a huge jump in his viewing direction."
		}
	}
})

hook.Add("OnPlayerHitGround", "TTTCHunterHitGround", function(ply)
	if not ply.classHunting then return end

	ply.classHunting = nil

	return false
end)
