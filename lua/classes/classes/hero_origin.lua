local backup_spawns = {}

local function OriginFunction(ply)
	if SERVER then
		local spawns = {}

		spawns = table.Add(spawns, ents.FindByClass("info_player_start"))
		spawns = table.Add(spawns, ents.FindByClass("info_player_deathmatch"))
		spawns = table.Add(spawns, ents.FindByClass("info_player_combine"))
		spawns = table.Add(spawns, ents.FindByClass("info_player_rebel"))

		-- CS Maps
		spawns = table.Add(spawns, ents.FindByClass("info_player_counterterrorist"))
		spawns = table.Add(spawns, ents.FindByClass("info_player_terrorist"))

		-- DOD Maps
		spawns = table.Add(spawns, ents.FindByClass("info_player_axis"))
		spawns = table.Add(spawns, ents.FindByClass("info_player_allies"))

		-- (Old) GMod Maps
		spawns = table.Add(spawns, ents.FindByClass("gmod_player_start"))

		if spawns and #spawns > 0 then
			ply:SetPos(spawns[math.random(1, #spawns)]:GetPos())
		elseif backup_spawns and #backup_spawns > 0 then
			ply:SetPos(backup_spawns[math.random(1, #backup_spawns)])
		else
			ply:ChatPrint("We are sorry, but this map doesn't have any position you could teleport to. :(")
		end
	end
end

HEROES.AddHero("ORIGIN", {
		color = Color(255, 156, 0, 255),
		onDeactivate = OriginFunction,
		time = 0,
		cooldown = 60,
		charging = 2,
		langs = {
			English = "Origin"
		}
})

if SERVER then
	hook.Add("TTTPrepareRound", "TTTHOriginFindSpawn", function()
		table.Empty(backup_spawns)

		local plys = player.GetAll()

		for _, v in ipairs(plys) do
			table.insert(backup_spawns, v:GetPos())
		end
	end)
end
