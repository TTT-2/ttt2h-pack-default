if SERVER then
	util.AddNetworkString("TTTCGesture")
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

		timer.Create("class_gesture_" .. ply:UniqueID(), 1, 0, function()
			if IsValid(ply) then
				local health = ply:Health()

				ply:SetHealth(math.Clamp(health + 5, health, ply:GetMaxHealth()))
			end
		end)
	end
end

local function DeactivateMeditate(ply)
	if SERVER then
		ply:RemoveGesture(ACT_GMOD_TAUNT_CHEER) -- TODO necessary ?
		ply:Freeze(false)
		ply:SetColor(ply.meditateCol)
		ply:SetRenderMode(ply.meditateColMode)

		timer.Remove("class_gesture_" .. ply:UniqueID())
	end
end

CLASS.AddClass("MEDITATE", {
		color = Color(160, 204, 66, 255),
		onActivate = ActivateMeditate,
		onDeactivate = DeactivateMeditate,
		endless = true,
		cooldown = 30,
		langs = {
			English = "Meditate"
		}
})

if CLIENT then
	net.Receive("TTTCGesture", function()
		local gesture = net.ReadUInt(32)
		local target = net.ReadEntity()

		if IsValid(target) then
			target:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gesture, false)
		end
	end)
end
