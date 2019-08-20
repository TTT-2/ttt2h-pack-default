--[[
if SERVER then
	util.AddNetworkString("TTTCFacelessCooldown")
end

local extraCooldown = 60

local function FacelessFunction(ply)
	-- Traces a line from the players shoot position to 100 units
	local trace = ply:GetEyeTrace()
	local target = trace.Entity

	if not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive() then
		if SERVER then
			local phr = ply:GetCustomClass()
			local thr = target:GetCustomClass()
			local cd = target:GetClassCooldown() + extraCooldown
			local cdT = target:SetClassCooldownTS() or CurTime()

			ply:UpdateClass(thr)

			target:UpdateClass(phr)
			target:SetClassCooldown(cd)
			target:SetClassCooldownTS(cdT)

			net.Start("TTTCFacelessCooldown")
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

CLASS.AddClass("FACELESS", {
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
	net.Receive("TTTCFacelessCooldown", function(len)
		local ply = LocalPlayer()
		local cd = ply:GetClassCooldown() + extraCooldown
		local cdT = ply:SetClassCooldownTS() or CurTime()

		ply:SetClassCooldown(cd)
		ply:SetClassCooldownTS(cdT)
	end)
end
]]--
