if SERVER then
	util.AddNetworkString("TTTHChaosInvert")
end

local function ChaosActivate(ply)
	if SERVER then
		local plys = {}

		for _, v in ipairs(player.GetAll()) do
			if v ~= ply then
				plys[#plys + 1] = v
			end
		end

		net.Start("TTTHChaosInvert")
		net.WriteBool(true)
		net.Send(plys)
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

		net.Start("TTTHChaosInvert")
		net.WriteBool(false)
		net.Send(plys)
	end
end

CLASS.AddHero("CHAOS", {
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

	net.Receive("TTTHChaosInvert", function()
		if net.ReadBool() then
			LocalPlayer().classChaos_inverted = true
		else
			LocalPlayer().classChaos_inverted = nil
		end
	end)

	--[[
	local mirrorRT = GetRenderTarget("MirrorTexture", ScrW(), ScrH(), false)

	local function GetBaseTransform()
		return string.format("center .5 .5 scale %i %i rotate 0 translate 0 0", flippedVertical:GetBool() and - 1 or 1, flippedHorizontal:GetBool() and - 1 or 1)
	end

	local MirroredMaterial = CreateMaterial(
		"MirroredMaterial",
		"UnlitGeneric",
		{
			["$basetexture"] = mirrorRT,
			["$basetexturetransform"] = GetBaseTransform(),
		}
	)

	local view = {}

	hook.Add("RenderScene", "Mirror.RenderScene", function(origin, angles)
		local ply = LocalPlayer()

		if ply.classChaos_inverted then
			view.x = 0
			view.y = 0
			view.w = ScrW()
			view.h = ScrH()
			view.origin = origin
			view.angles = angles
			view.drawhud = true

			-- get the old rendertarget
			local oldrt = render.GetRenderTarget()

			-- set the rendertarget
			render.SetRenderTarget(mirrorRT)

			-- clear
			render.Clear(0, 0, 0, 255, true)
			render.ClearDepth()
			render.ClearStencil()
			render.RenderView(view)

			-- restore
			render.SetRenderTarget(oldrt)

			MirroredMaterial:SetTexture("$basetexture", mirrorRT)

			render.SetMaterial(MirroredMaterial)
			render.DrawScreenQuad()

			render.RenderHUD(0, 0, view.w, view.h)

			return true
		end
	end)
	]]--

	-- Invert mouse input
	--[[
	hook.Add("InputMouseApply", "flipmouse", function(cmd, x, y, angle)
		local ply = LocalPlayer()

		if ply.classChaos_inverted then
			local pitchchange = y * GetConVar("m_pitch"):GetFloat()
			local yawchange = x * -GetConVar("m_yaw"):GetFloat()

			angle.p = angle.p + pitchchange * (flippedHorizontal:GetBool() and - 1 or 1)
			angle.y = angle.y + yawchange * (flippedVertical:GetBool() and - 1 or 1)

			cmd:SetViewangles(angle)

			return true
		end
	end)
	]]--
end
