-- Log aditional info about events in fortress for use in soundsense or other tools.

log = io.open("ss_fix.log", "a")

function msg(m, c)
	dfhack.gui.showAnnouncement(m,dfhack.color(c))
	log:write(m)
	log:write("\n")
	log:flush()
	dfhack.println(m)
end

-- SEASON FIX

--403200 per year, 100800 per season

local season = math.floor(df.global.cur_year_tick/100800) 

if season == 0 then
	msg("Spring has arrived on the calendar.")
elseif season == 1 then
	msg("Summer has arrived on the calendar.")
elseif season == 2 then
	msg("Autumn has arrived on the calendar.")
elseif season == 3 then
	msg("Winter has arrived on the calendar.")
end

-- WEATHER FIX

local raining = false
local snowing = false

for x=0, #df.global.current_weather-1 do
	for y=0, #df.global.current_weather[x]-1 do
		weather = df.global.current_weather[x][y]
		if weather == 1 then
			raining = true
		elseif weather == 2 then
			snowing = true
		end
	end
end

if (not snowing and not raining) then
	msg("The weather has cleared.")
elseif raining then
	msg("It has started raining.")
elseif snowing then
	msg("A snow storm has come.")
end

-- Periodic checkups

local workshopTypes = { "Carpenters Workshop", "Farmers Workshop", "Masons Workshop", "Craftsdwarfs Workshop", "Jewelers Workshop", "Metalsmiths Forge", "Magma Forge", "Bowyers Workshop", "Mechanics Workshop", "Siege Workshop", "Butchers Workshop", "Leatherworks Workshop",  "Tanners Workshop", "Clothiers Workshop", "Fishery", "Still", "Loom", "Quern", "Kennels", "Kitchen", "Ashery", "Dyers Workshop", "Millstone", "Custom", "Tool" }
local furnaceTypes = { "Wood Furnace", "Smelter", "Glass Furnace", "Kiln", "Magma Smelter", "Magma Glass Furnace", "Magma Kiln", "Custom Furnace" }

old_expedition_leader = nil
old_mayor = nil
siege = false
buildStates = {}
unit_skills = {}

first_run = true

local function event_loop()
	local units = df.global.world.units.active

	local expedition_leader = nil
	local mayor = nil
	
	old_siege = siege
	siege = false
	
	for i=0, #units-1 do
		local unit = units[i]
		if dfhack.units.isCitizen(unit) then
			positions = dfhack.units.getNoblePositions(unit)
			if positions ~= nil then
				for p=1, #positions do
					if positions[p].position.name[0] == "expedition leader" then
						expedition_leader = unit
					elseif positions[p].position.name[0] == "mayor" then
						mayor = unit
					end
					--print(dfhack.TranslateName(dfhack.units.getVisibleName(unit)).." "..positions[p].position.name[0])
				end
			end
			
			if unit_skills[unit.id] == nil then
				unit_skills[unit.id] = {}
			end
			-- skill rust announcements removed
		end
		-- siege detection
		if unit.flags1.active_invader then
			siege = true
		end
	end
	
	if siege ~= old_siege and siege then
		msg("A vile force of darkness has arrived!")
	elseif siege ~= old_siege and not siege then
		msg("Siege was broken.")
	end

	if expedition_leader ~= old_expedition_leader then
		if expedition_leader == nil then
			msg("Expedition leader position is now vacant.")
		else
			if not first_run then
				msg(dfhack.TranslateName(dfhack.units.getVisibleName(expedition_leader)).." became expedition leader.")
			end
		end
		old_expedition_leader = expedition_leader
	end
	
	if old_mayor == nil and expedition_leader == nil and mayor ~= nil then
		if not first_run then
			msg("Expedition leader was replaced by mayor.")
		end
	end
	
	if mayor ~= old_mayor then
		if mayor == nil then
			msg("Mayor position is now vacant.")
		else
			if not first_run then
				msg(dfhack.TranslateName(dfhack.units.getVisibleName(mayor)).." became mayor.")
			end
		end
		old_mayor = mayor
	end
	
	local buildings = df.global.world.buildings.all
	
	for i=0, #buildings-1 do
		local building = buildings[i]
		if getmetatable(building) == "building_workshopst" or getmetatable(building) == "building_furnacest" then
			if buildStates[building.id] == nil then
				buildStates[building.id] = building.flags.exists
			end
			local oldval = buildStates[building.id]
			if oldval ~= building.flags.exists then
				buildStates[building.id] = building.flags.exists
				if building.flags.exists then
					if getmetatable(building) == "building_workshopst" then
						msg(workshopTypes[building.type+1].." was built.")
					elseif getmetatable(building) == "building_furnacest" then
						msg(furnaceTypes[building.type+1].." was built.")
					end
				end
			end
		end
	end
	
	first_run = false
	
	dfhack.timeout(25, 'ticks', event_loop)
end

event_loop()

-- io.close(log)