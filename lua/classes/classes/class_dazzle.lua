local DIETIMER = 1.5 -- time in seconds, for the grenade to transition from full white to clear
local EFFECT_DELAY = 0.5 -- time, in seconds when the effects still are going on, even when the whiteness of the flash is gone (set to -1 for no effects at all =]).

local FLASH_INTENSITY = 2250 --the higher the number, the longer the flash will be whitening your screen

local function CreateDazzleEffect(ply)
	local pos = ply:GetPos()
	local time = CurTime()

	ply.dazzleSpeedRunEndTime = CurTime() + DIETIMER

	if SERVER then
		ply:EmitSound(Sound("weapons/flashbang/flashbang_explode" .. math.random(1, 2) .. ".wav"))

		local plys = player.GetAll()

		for i = 1, #plys do
			local target = plys[i]

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

CLASS.AddClass("DAZZLE", {
	color = Color(255, 242, 109, 255),
	OnAbilityDeactivate = CreateDazzleEffect,
	time = 0, -- skip timer, this will skip OnAbilityActivate too! Use OnAbilityDeactivate instead
	cooldown = 75,
	charging = 2,
	lang = {
		name = {
			English = "Dazzle",
			French = "Éblouisseur",	
			Русский = "Даззл"
		},
		desc = {
			English = "The Dazzle can blind their opponents by firing a flashbang. This flashbang affects everyone on the map looking into their broad direction. After firing the flashbang, they receive a short speedboost. They have no passive ability.",
			French = "L'Éblouisseur peut aveugler les adversaires en tirant une grenade flash. Ce flash affecte tous ceux qui  regardent dans la direction du flash. Après avoir déclenché le flash, il reçoit un petit bonus de vitesse. Il n'a aucune capacité passive.",	
			Русский = "Даззл может ослепить своих противников, выпустив светошумовую гранату. Эта световая граната поражает всех на карте, смотрящих в их сторону. После запуска светошумовой гранаты он получает кратковременное ускорение. У него нет пассивных способностей."
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

hook.Add("TTTPlayerSpeedModifier", "TTTCDazzleSpeedMod", function(ply, _, _, speedMultiplierModifier)
	if ply:GetCustomClass() ~= CLASS.CLASSES.DAZZLE.index
		or not ply.dazzleSpeedRunEndTime or CurTime() > ply.dazzleSpeedRunEndTime
	then return end

	speedMultiplierModifier[1] = speedMultiplierModifier[1] * 3.0
end)
