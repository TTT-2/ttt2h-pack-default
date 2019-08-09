--[[
if SERVER then
	util.AddNetworkString("TTTHFacelessCooldown")
end

local extraCooldown = 60

local function FacelessFunction(ply)
	-- Traces a line from the players shoot position to 100 units
	local trace = ply:GetEyeTrace()
	local target = trace.Entity

	if not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive() then
		if SERVER then
			local phr = ply:GetHero()
			local thr = target:GetHero()
			local cd = target:GetHeroCooldown() + extraCooldown
			local cdT = target:GetHeroCooldownTS() or CurTime()

			ply:UpdateHero(thr)

			target:UpdateHero(phr)
			target:SetHeroCooldown(cd)
			target:SetHeroCooldownTS(cdT)

			net.Start("TTTHFacelessCooldown")
			net.Send(target)
		end
	else
		return true -- skip cooldown
	end
end

local function ChargeFaceless(ply)
	if CLIENT then
		local trace = ply:GetEyeTrace()
		local target = trace.Entity

		return not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive()
	end
end

HEROES.AddHero("FACELESS", {
		color = Color(0, 0, 0, 255),
		onDeactivate = FacelessFunction,
		onCharge = ChargeFaceless,
		time = 0, -- skip timer, this will skip onActivate too! Use onDeactivate instead
		cooldown = 90,
		charging = 2,
		langs = {
			English = "Faceless"
		}
})

if CLIENT then
	net.Receive("TTTHFacelessCooldown", function(len)
		local ply = LocalPlayer()
		local cd = ply:GetHeroCooldown() + extraCooldown
		local cdT = ply:GetHeroCooldownTS() or CurTime()

		ply:SetHeroCooldown(cd)
		ply:SetHeroCooldownTS(cdT)
	end)
end
]]--
