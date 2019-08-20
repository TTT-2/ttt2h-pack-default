local function PredatorFunction(ply)
	-- Traces a line from the players shoot position to 100 units
	local trace = ply:GetEyeTrace()
	local target = trace.Entity

	if not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive() then
		if CLIENT then
			ply.predatorTarget = target
		end
	else
		return true -- skip cooldown
	end
end

local function ChargePredator(ply)
	if CLIENT then
		local trace = ply:GetEyeTrace()
		local target = trace.Entity

		return not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive()
	end
end

CLASS.AddHero("PREDATOR", {
		color = Color(56, 40, 63, 255),
		onDeactivate = PredatorFunction,
		--onCharge = ChargePredator,
		time = 0, -- skip timer, this will skip onActivate too! Use onDeactivate instead
		cooldown = 120,
		--charging = 2,
		langs = {
			English = "Predator"
		}
})

if CLIENT then
	hook.Add("TTTHUpdateHero", "UpdatePredator", function(ply, old, new)
		if old == CLASS.CLASSES.PREDATOR.index then
			ply.predatorTarget = nil
		end
	end)

	hook.Add("PostDrawOpaqueRenderables", "PredatorPlayerBorders", function()
		local client = LocalPlayer()
		local target = client.predatorTarget

		if not IsValid(target) or not target:IsActive() then return end

		--stencil work is done in postdrawopaquerenderables, where surface doesn't work correctly
		--workaround via 3D2D
		local ang = client:EyeAngles()
		local pos = client:EyePos() + ang:Forward() * 10

		ang = Angle(ang.p + 90, ang.y, 0)

		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(15)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_KEEP)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetBlend(0)

		target:DrawModel()

		render.SetBlend(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

		cam.Start3D2D(pos, ang, 1)

		surface.SetDrawColor(255, 50, 50)
		surface.DrawRect(-ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2)

		cam.End3D2D()

		target:DrawModel()

		render.SetStencilEnable(false)
	end)
end
