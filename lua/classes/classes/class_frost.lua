if SERVER then
	resource.AddFile("materials/vgui/ttt/heroes/frost_overlay.vmt")
	resource.AddFile("materials/vgui/ttt/heroes/status/hud_icon_frost.png")

	util.AddNetworkString("TTTCFrost")
end

-- register status effect icon
if CLIENT then
	hook.Add("Initialize", "ttt2h_status_frost_init", function()
		STATUS:RegisterStatus("ttt2h_status_frost", {
			hud = Material("vgui/ttt/heroes/status/hud_icon_frost.png"),
			type = "bad"
		})
	end)
end

local frostRad = 320
local col_wire = Color(0, 255, 255, 100)

local function PrepareFrostActivation(ply)
	if CLIENT then
		hook.Add("PostDrawTranslucentRenderables", "TTTCFrostPreview", function()
			if LocalPlayer() ~= ply then return end

			local et = ply:GetEyeTrace()

			render.SetColorMaterial()
			render.DrawWireframeSphere(et.HitPos, frostRad, 30, 30, col_wire, true)
		end)
	end
end

local function FinishFrostPreparing(ply)
	if CLIENT then
		hook.Remove("PostDrawTranslucentRenderables", "TTTCFrostPreview")
	end
end

local function ActivateFrost(ply)
	ply.frostPos = ply:GetEyeTrace().HitPos

	hook.Add("TTTPlayerSpeedModifier", "TTTCFrostSpeed_" .. ply:SteamID64(), function(pl, _, _, refTbl)
		if not ply.frostPos or pl == ply then return end

		local entities = ents.FindInSphere(ply.frostPos, frostRad)

		for i = 1, #entities do
			if entities[i] == pl then
				refTbl[1] = refTbl[1] * 0.5

				return
			end
		end
	end)

	if not SERVER then return end

	net.Start("TTTCFrost")
	net.WriteString(ply:SteamID64())
	net.WriteBit(true)
	net.WriteVector(ply.frostPos)
	net.WriteUInt(frostRad, 32)
	net.Broadcast()
end

local function DeactivateFrost(ply)
	local sid = ply:SteamID64()

	hook.Remove("TTTPlayerSpeedModifier", "TTTCFrostSpeed_" .. sid)

	if not SERVER then return end

	net.Start("TTTCFrost")
	net.WriteString(sid)
	net.WriteBit(false)
	net.Broadcast()
end

CLASS.AddClass("FROST", {
	color = Color(0, 156, 156, 255),
	OnStartPrepareAbilityActivation = PrepareFrostActivation,
	OnFinishPrepareAbilityActivation = FinishFrostPreparing,
	OnAbilityActivate = ActivateFrost,
	OnAbilityDeactivate = DeactivateFrost,
	avoidWeaponReset = true,
	time = 10,
	cooldown = 60,
	lang = {
		name = {
			English = "Frost"
		},
		desc = {
			English = "The Frost can spawn a frozen sphere of ice. Every player inside this sphere has limited sight and walks really slow. He has no passive ability."
		}
	}
})

local col_outside = Color(255, 255, 255, 210)
local col_inside = Color(255, 255, 255, 20)

if CLIENT then
	local frostMaterial = Material("models/props_c17/frostedglass_01a")

	net.Receive("TTTCFrost", function()
		local client = LocalPlayer()
		local sid = net.ReadString()

		if net.ReadBit() == 1 then
			local ply = player.GetBySteamID64(sid)
			if not IsValid(ply) then return end

			ply.tttcfrostindicator = true
			ply.frostPos = net.ReadVector()

			hook.Add("PostDrawTranslucentRenderables", "TTTCFrost_" .. sid, function(bDepth, bSkybox)
				if bSkybox or not ply.tttcfrostindicator then return end

				local entities = ents.FindInSphere(ply.frostPos, frostRad)
				local inSphere = false

				for i = 1, #entities do
					if entities[i] == client then
						inSphere = true

						break
					end
				end

				if inSphere then
					render.SetColorMaterial()
					render.CullMode(MATERIAL_CULLMODE_CW)
					render.DrawSphere(ply.frostPos, frostRad, 30, 30, col_inside)
					render.CullMode(MATERIAL_CULLMODE_CCW)
				else
					render.SetMaterial(frostMaterial)
					render.CullMode(MATERIAL_CULLMODE_CCW)
					render.DrawSphere(ply.frostPos, frostRad, 30, 30, col_outside)
				end
			end)

			hook.Add("RenderScreenspaceEffects", "TTTCFrostOverlay_" .. sid, function()
				if not ply.tttcfrostindicator or client:HasClass(CLASS.CLASSES.FROST.index) then return end

				local entities = ents.FindInSphere(ply.frostPos, frostRad)
				local last_selected = client.ttthfrostselected or false

				client.ttthfrostselected = false

				for i = 1, #entities do
					if entities[i] == client then
						client.ttthfrostselected = true

						break
					end
				end

				if client.ttthfrostselected then
					DrawMaterialOverlay("vgui/ttt/heroes/frost_overlay", 0)
				end

				if not last_selected and client.ttthfrostselected then
					STATUS:AddStatus("ttt2h_status_frost")
				elseif last_selected and not client.ttthfrostselected then
					STATUS:RemoveStatus("ttt2h_status_frost")
				end
			end)

			sound.Play("ambient/wind/windgust_strong.wav", ply.frostPos)
		else
			hook.Remove("PostDrawTranslucentRenderables", "TTTCFrost_" .. sid)
			hook.Remove("RenderScreenspaceEffects", "TTTCFrostOverlay_" .. sid)

			STATUS:RemoveStatus("ttt2h_status_frost")

			local ply = player.GetBySteamID64(sid)
			if not IsValid(ply) then return end

			ply.tttcfrostindicator = nil
			ply.frostPos = nil
		end
	end)
end
