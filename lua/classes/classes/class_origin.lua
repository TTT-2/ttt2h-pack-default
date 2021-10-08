local function OriginFunction(ply)
	if CLIENT then return end

	local spawnPoint = plyspawn.GetRandomSafePlayerSpawnPoint(ply)

	if not spawnPoint then return end

	ply:SetPos(spawnPoint.pos)
	ply:SetAngles(spawnPoint.ang)
end

CLASS.AddClass("ORIGIN", {
	color = Color(255, 156, 0, 255),
	OnAbilityDeactivate = OriginFunction,
	time = 0,
	cooldown = 60,
	charging = 2,
	lang = {
		name = {
			en = "Origin",
			fr = "Origine",
			ru = "Ориджин"
		},
		desc = {
			en = "The Origin is able to teleport themselves back to the mapspawn once every minute. They have no passive ability.",
			fr = "L'Origine est capable de se téléporter au spawn de la carte une fois par minute. Il n'a pas de capacité passive.",
			ru = "Ориджин может телепортироваться обратно к точке появления на карте раз в минуту. У него нет пассивных способностей."
		}
	}
})
