if SERVER then
	resource.AddFile("materials/vgui/ttt/heroes/dark_overlay.vmt")
	resource.AddFile("materials/vgui/ttt/heroes/status/hud_icon_void.png")

	util.AddNetworkString("TTTCVoidOverlay")
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

		net.Start("TTTCVoidOverlay")
		net.WriteBool(true)
		net.Send(plys)

		-- add status effect
		STATUS:AddStatus(plys, "ttt2h_status_void")
	end
end

local function DeactivateVoid(ply)
	if not SERVER then return end

	local plys = {}

	for _, v in ipairs(player.GetAll()) do
		if v ~= ply then
			plys[#plys + 1] = v
		end
	end

	net.Start("TTTCVoidOverlay")
	net.WriteBool(false)
	net.Send(plys)

	-- remove status effect
	STATUS:RemoveStatus(plys, "ttt2h_status_void")
end

CLASS.AddClass("VOID", {
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
	net.Receive("TTTCVoidOverlay", function()
		if net.ReadBool() then
			LocalPlayer().tttcoverlay = true
		else
			LocalPlayer().tttcoverlay = nil
		end
	end)

	hook.Add("RenderScreenspaceEffects", "TTTCVoidOverlay", function()
		if not LocalPlayer().tttcoverlay then return end

		-- idk why this alpha is buggy as ant
		DrawMaterialOverlay("vgui/ttt/heroes/dark_overlay", 0)
		DrawMaterialOverlay("vgui/ttt/heroes/dark_overlay", 0)
		DrawMaterialOverlay("vgui/ttt/heroes/dark_overlay", 0)
	end)

	hook.Add("HUDShouldDraw", "TTT2HeroesVoidHideHUD", function(name)
		if name == "TTTTargetID" and LocalPlayer().tttcoverlay then
			return false
		end
	end)
end
