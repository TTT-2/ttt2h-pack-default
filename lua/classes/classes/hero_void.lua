if SERVER then
	resource.AddFile("materials/vgui/ttt/heroes/dark_overlay.vmt")

	util.AddNetworkString("TTTHVoidOverlay")
end

local function ActivateVoid(ply)
	if SERVER then
		-- using networking instead of NWBool, cause they are buggy sometimes

		local plys = {}

		for _, v in ipairs(player.GetAll()) do
			if v ~= ply then
				plys[#plys + 1] = v
			end
		end

		net.Start("TTTHVoidOverlay")
		net.WriteBool(true)
		net.Send(plys)
	end
end

local function DeactivateVoid(ply)
	if SERVER then
		local plys = {}

		for _, v in ipairs(player.GetAll()) do
			if v ~= ply then
				plys[#plys + 1] = v
			end
		end

		net.Start("TTTHVoidOverlay")
		net.WriteBool(false)
		net.Send(plys)
	end
end

CLASS.AddHero("VOID", {
		color = Color(61, 64, 75, 255),
		onActivate = ActivateVoid,
		onDeactivate = DeactivateVoid,
		charging = 2,
		time = 3,
		cooldown = 50,
		avoidWeaponReset = true,
		langs = {
			English = "Void"
		}
})

if CLIENT then
	net.Receive("TTTHVoidOverlay", function()
		if net.ReadBool() then
			LocalPlayer().ttthoverlay = true
		else
			LocalPlayer().ttthoverlay = nil
		end
	end)

	hook.Add("RenderScreenspaceEffects", "TTTHVoidOverlay", function()
		if LocalPlayer().ttthoverlay then

			-- idk why this alpha is buggy as ant
			DrawMaterialOverlay("vgui/ttt/heroes/dark_overlay", 0)
			DrawMaterialOverlay("vgui/ttt/heroes/dark_overlay", 0)
			DrawMaterialOverlay("vgui/ttt/heroes/dark_overlay", 0)
		end
	end)

	hook.Add("HUDShouldDraw", "TTT2HeroesVoidHideHUD", function(name)
		if name == "TTTTargetID" and LocalPlayer().ttthoverlay then
			return false
		end
	end)
end
