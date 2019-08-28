if SERVER then
	resource.AddFile("materials/vgui/ttt/heroes/dark_overlay.vmt")
	resource.AddFile("materials/vgui/ttt/heroes/status/hud_icon_void.png")

	util.AddNetworkString("TTTHVoidOverlay")
end

-- register status effect icon
if CLIENT then
	hook.Add("Initialize", "ttt2h_status_void_init", function() 
		STATUS:RegisterStatus("ttt2h_status_void", {
			hud = Material("vgui/ttt/heroes/status/hud_icon_void.png"),
			type = "bad"
		})
	end)
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

		-- add status effect
		STATUS:AddStatus(plys, "ttt2h_status_void")
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

		-- remove status effect
		STATUS:RemoveStatus(plys, "ttt2h_status_void")
	end
end

HEROES.AddHero("VOID", {
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
