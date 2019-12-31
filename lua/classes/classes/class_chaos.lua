if SERVER then
	resource.AddFile("materials/vgui/ttt/heroes/status/hud_icon_chaos.png")

	util.AddNetworkString("TTTCChaosInvert")
end

-- register status effect icon
if CLIENT then
	hook.Add("Initialize", "ttt2h_status_chaos_init", function()
		STATUS:RegisterStatus("ttt2h_status_chaos", {
			hud = Material("vgui/ttt/heroes/status/hud_icon_chaos.png"),
			type = "bad"
		})
	end)
end

local function ChaosActivate(ply)
	if SERVER then
		local plys = {}

		for _, v in ipairs(player.GetAll()) do
			if v ~= ply then
				plys[#plys + 1] = v
			end
		end

		net.Start("TTTCChaosInvert")
		net.WriteBool(true)
		net.Send(plys)

		-- add status effect
		STATUS:AddStatus(plys, "ttt2h_status_chaos")
	end
end

local function ChaosDeactivate(ply)
	if SERVER then
		local plys = {}

		for _, v in ipairs(player.GetAll()) do
			if v ~= ply then
				plys[#plys + 1] = v
			end
		end

		net.Start("TTTCChaosInvert")
		net.WriteBool(false)
		net.Send(plys)

		-- remove status effect
		STATUS:RemoveStatus(plys, "ttt2h_status_chaos")
	end
end

CLASS.AddClass("CHAOS", {
		color = Color(255, 76, 0, 255),
		onActivate = ChaosActivate,
		onDeactivate = ChaosDeactivate,
		time = 5,
		cooldown = 120,
		charging = 3,
		avoidWeaponReset = true,
		langs = {
			English = "Chaos"
		}
})

if CLIENT then
	-- thanks to https://forum.facepunch.com/f/gmoddev/njmz/How-do-I-invert-flip-the-player-s-screen/1/

	--local flippedVertical = CreateConVar("r_flip_vertical", 1, {FCVAR_ARCHIVE})
	local flippedHorizontal = CreateConVar("chaos_flip_horizontal", 0, {FCVAR_ARCHIVE})

	-- Invert key input too
	hook.Add("CreateMove", "ChaosInvertMove", function(cmd) -- Override player movement
		local ply = LocalPlayer()

		if ply.classChaos_inverted then
			local forward = 0
			local right = 0
			local maxspeed = LocalPlayer():GetMaxSpeed() * (flippedHorizontal:GetBool() and - 1 or 1)

			if cmd:KeyDown(IN_FORWARD) then
				forward = forward + maxspeed
			end

			if cmd:KeyDown(IN_BACK) then
				forward = forward - maxspeed
			end

			if cmd:KeyDown(IN_MOVERIGHT) then
				right = right + maxspeed
			end

			if cmd:KeyDown(IN_MOVELEFT) then
				right = right - maxspeed
			end

			cmd:SetForwardMove(-forward)
			cmd:SetSideMove(-right)
		end
	end)

	net.Receive("TTTCChaosInvert", function()
		if net.ReadBool() then
			LocalPlayer().classChaos_inverted = true
		else
			LocalPlayer().classChaos_inverted = nil
		end
	end)
end
