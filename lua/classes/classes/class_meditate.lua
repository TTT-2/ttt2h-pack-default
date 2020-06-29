if SERVER then
	resource.AddFile("materials/vgui/ttt/heroes/meditate_overlay.vmt")
	resource.AddFile("materials/vgui/ttt/heroes/status/hud_icon_meditate.png")

	util.AddNetworkString("TTTCGesture")
	util.AddNetworkString("TTTCHMeditateToggle")
end

-- register status effect icon
if CLIENT then
	hook.Add("Initialize", "ttt2h_status_meditate_init", function()
		STATUS:RegisterStatus("ttt2h_status_meditate", {
			hud = Material("vgui/ttt/heroes/status/hud_icon_meditate.png"),
			type = "good"
		})
	end)
end

local function ActivateMeditate(ply)
	if SERVER then
		net.Start("TTTCGesture")
		net.WriteUInt(ACT_GMOD_TAUNT_CHEER, 32)
		net.WriteEntity(ply)
		net.Broadcast()

		ply:Freeze(true)

		ply.meditateCol = ply:GetColor()
		ply.meditateColMode = ply:GetRenderMode()

		local col = table.Copy(ply.meditateCol)
		col.a = math.Round(col.a * 0.5)

		ply:SetColor(col)
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)

		timer.Create("class_gesture_" .. ply:SteamID64(), 0.75, 0, function()
			if not IsValid(ply) then return end

			local health = ply:Health()

			ply:SetHealth(math.Clamp(health + 5, health, ply:GetMaxHealth()))
		end)

		-- add status effect
		STATUS:AddStatus(ply, "ttt2h_status_meditate")

		-- add overlay
		net.Start("TTTCHMeditateToggle")
		net.WriteBool(true)
		net.Send(ply)
	end
end

local function DeactivateMeditate(ply)
	if SERVER then
		ply:RemoveGesture(ACT_GMOD_TAUNT_CHEER) -- TODO necessary ?
		ply:Freeze(false)

		if ply.meditateCol then
			ply:SetColor(ply.meditateCol)
		end

		if ply.meditateColMode then
			ply:SetRenderMode(ply.meditateColMode)
		end

		timer.Remove("class_gesture_" .. ply:SteamID64())

		-- remove status effect
		STATUS:RemoveStatus(ply, "ttt2h_status_meditate")

		-- remove overlay
		net.Start("TTTCHMeditateToggle")
		net.WriteBool(false)
		net.Send(ply)
	end
end

hook.Add("PlayerDeath", "TTTCMeditateDeath", function(ply)
	if ply:GetCustomClass() ~= CLASS.CLASSES.MEDITATE.index then return end

	DeactivateMeditate(ply)
end)

CLASS.AddClass("MEDITATE", {
	color = Color(160, 204, 66, 255),
	OnAbilityActivate = ActivateMeditate,
	OnAbilityDeactivate = DeactivateMeditate,
	endless = true,
	cooldown = 30,
	lang = {
		name = {
			English = "Meditate"
		},
		desc = {
			English = "The Meditate can use their ability to heal himself. While they are in the healing process, they can't move. They have no passive ability."
		}
	}
})

if CLIENT then
	net.Receive("TTTCGesture", function()
		local gesture = net.ReadUInt(32)
		local target = net.ReadEntity()

		if not IsValid(target) then return end

		target:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gesture, false)
	end)

	net.Receive("TTTCHMeditateToggle", function()
		local client = LocalPlayer()

		client.ttthmeditateoverlay = net.ReadBool()
	end)

	hook.Add("RenderScreenspaceEffects", "TTTCMeditateOverlay", function()
		local client = LocalPlayer()

		if client.ttthmeditateoverlay then
			DrawMaterialOverlay("vgui/ttt/heroes/meditate_overlay", 0)
		end
	end)
end
