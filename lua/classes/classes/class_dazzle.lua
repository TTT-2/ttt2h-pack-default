local DIETIMER = 1.5 -- time in seconds, for the grenade to transition from full white to clear
local EFFECT_DELAY = 0.5 -- time, in seconds when the effects still are going on, even when the whiteness of the flash is gone (set to -1 for no effects at all =]).

local FLASH_INTENSITY = 2250 --the higher the number, the longer the flash will be whitening your screen

local BOOST = 2 --the initial speed boost after the flash

local function CreateDazzleEffect(ply)
	local pos = ply:GetPos()
	local time = CurTime()

	if SERVER then
		ply:EmitSound(Sound("weapons/flashbang/flashbang_explode" .. math.random(1, 2) .. ".wav"))
		ply:GiveItem("item_ttt_speedrun")

		ply.speedrun_mul = BOOST * (ply.speedrun_mul or 1)
		ply.tttc_class_speedmod = true

		timer.Create("TTTCDazzleSpeedBoost_" .. ply:SteamID64(), 2, 1, function()
			if IsValid(ply) and ply.tttc_class_speedmod then
				ply:RemoveItem("item_ttt_speedrun")

				ply.speedrun_mul = (ply.speedrun_mul or 1) / BOOST
			end
		end)

		local plys = player.GetAll()

		for _, target in ipairs(plys) do
			if target ~= ply then
				local eyeToTarget = (pos - target:EyePos()):GetNormalized() -- Normalized direction to the target
				local degreeLimit = target:GetFOV() -- FOV
				local dotProduct = eyeToTarget:Dot(target:EyeAngles():Forward()) -- How similar is the player's aim direction to the direction of the target?
				local aimDegree = math.deg(math.acos(dotProduct)) -- Convert similarity to degrees

				local dist = target:GetShootPos():Distance(pos)
				local endtime = FLASH_INTENSITY / dist

				-- If the degree difference in similarity is bigger than the player's FOV, then most likely it isn't being rendered
				if aimDegree < degreeLimit then
					if endtime > 6 then
						endtime = 6
					elseif endtime < 0.4 then
						endtime = 0.4
					end

					simpendtime = math.floor(endtime)

					local nwftime = target:GetNWFloat("RCS_ftime")

					if nwftime > time then -- if you're already flashed
						target:SetNWFloat("RCS_ftime", endtime + nwftime + time - target:GetNWFloat("RCS_ftime_start")) -- add more to it
					else -- not flashed
						target:SetNWFloat("RCS_ftime", endtime + time)
					end

					target:SetNWFloat("RCS_ftime_start", time)
				end
			end
		end
	else
		local beeplight = DynamicLight(ply:EntIndex())
		if beeplight then
			beeplight.Pos = pos
			beeplight.r = 255
			beeplight.g = 255
			beeplight.b = 255
			beeplight.Brightness = 6
			beeplight.Size = 1000
			beeplight.Decay = 1000
			beeplight.DieTime = time + 0.15
		end
	end
end

local function DazzleUnset(ply)
	if not SERVER then return end
	
	local identifier = "TTTCDazzleSpeedBoost_" .. ply:SteamID64()

	if timer.Exists(identifier) then
		if IsValid(ply) and ply.tttc_class_speedmod then
			ply:RemoveItem("item_ttt_speedrun")

			ply.speedrun_mul = (ply.speedrun_mul or 1) / BOOST
		end

		timer.Remove(identifier)
	end
end

CLASS.AddClass("DAZZLE", {
	color = Color(255, 242, 109, 255),
	onClassUnset = DazzleUnset,
	onDeactivate = CreateDazzleEffect,
	time = 0, -- skip timer, this will skip onActivate too! Use onDeactivate instead
	cooldown = 75,
	charging = 2, -- TODO why 1 s doesn't work
	lang = {
		name = {
			English = "Dazzle"
		},
		desc = {
			English = "The Dazzle can blind his opponents by firing a flashbang. This flashbang affects everyone on the map looking into his broad direction. After firing the flashbang, he receives a short speedboost. He has no passive ability."
		}
	}
})

if CLIENT then
	function SimulateFlash_CS()
		local pl = LocalPlayer()
		local time = CurTime()

		if pl:GetNWFloat("RCS_ftime") > time then
			local e = pl:GetNWFloat("RCS_ftime") -- when it dies away
			--local s = pl:GetNWFloat("RCS_ftime_start") -- when it started TODO

			local alpha

			if e - time > DIETIMER then
				alpha = 255
			else
				local ed = e - DIETIMER
				local pf = 1 - (time - ed) / (e - ed)

				alpha = pf * 255
			end

			surface.SetDrawColor(255, 255, 255, math.Round(alpha))
			surface.DrawRect(0, 0, surface.ScreenWidth(), surface.ScreenHeight())
		end
	end
	hook.Add("HUDPaint", "SimulateFlash_CS", SimulateFlash_CS)

	--motion blur and other junk
	local function SimulateBlur_CS()
		local pl = LocalPlayer()
		local time = CurTime()
		local e = pl:GetNWFloat("RCS_ftime") + EFFECT_DELAY -- when it dies away
		--local s = pl:GetNWFloat("RCS_ftime_start") -- when it started

		if e > time and e - EFFECT_DELAY - time <= DIETIMER then
			local pf = 1 - (time - (e - DIETIMER)) / DIETIMER

			DrawMotionBlur(0, pf / ((DIETIMER + EFFECT_DELAY) / DIETIMER), 0)
		elseif e > time then
			DrawMotionBlur(0, 0.01, 0)
		else
			DrawMotionBlur(0, 0, 0)
		end
	end
	hook.Add("RenderScreenspaceEffects", "SimulateBlur_CS", SimulateBlur_CS)
end
