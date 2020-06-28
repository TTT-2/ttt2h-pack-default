if SERVER then
	util.AddNetworkString("tttc_predator_sync_target")
end

local function PredatorFunction(ply)
	if not SERVER then return end

	-- Traces a line from the players shoot position to 100 units
	local trace = ply:GetEyeTrace()
	local target = trace.Entity

	if not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive() then
		net.Start("tttc_predator_sync_target")
		net.WriteEntity(target)
		net.Send(ply)
	else
		return true -- skip cooldown
	end
end

local function PredatorUnset(ply)
	if CLIENT then
		ply.predatorTarget = nil
	end
end

CLASS.AddClass("PREDATOR", {
	color = Color(56, 40, 63, 255),
	OnUnset = PredatorUnset,
	OnAbilityDeactivate = PredatorFunction,
	time = 0, -- skip timer, this will skip onActivate too! Use onDeactivate instead
	cooldown = 120,
	lang = {
		name = {
			English = "Predator"
		},
		desc = {
			English = "The Predator is able to track one player thrugh the wall every two minutes by using his ability while focuing the player. He has no passive ability."
		}
	}
})

if CLIENT then
	hook.Add("PreDrawOutlines", "PredatorPlayerBorders", function()
		local client = LocalPlayer()
		local target = client.predatorTarget

		if not IsValid(target) or not target:IsActive() then return end

		outline.Add(target, Color(255, 50, 50))
	end)

	net.Receive("tttc_predator_sync_target", function()
		local client = LocalPlayer()
		local target = net.ReadEntity()
		if not IsValid(target) then return end

		client.predatorTarget = target
	end)
end
