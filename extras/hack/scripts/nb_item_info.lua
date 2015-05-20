--Natural Balance Extended Viewscreens
-- custom description repository :
--https://github.com/Raidau/item_descriptions

--When activated, this script adds additional lines of useful information to item view screen every time the item is inspected. This includes material info, weapon and attack properties, armor thickness and coverage. Also displays additional info related to NB mod.

--Supports user-defined custom descriptions for items and materials. They are loaded from .txt files in raw/item_description folder. Instuction file is in item_description folder.

--By Raidau for Natural Balance
--v 5.1 beta

local standard -- stores standard material to compare with
local args = {...}
local dlg = require ("gui.dialogs")
local gui=require 'gui'
local widgets=require 'gui.widgets'

local help = [[
Natural Balance Extended Viewscreens v 5.1 beta

When activated, this script adds additional
lines of useful information to 
item view screen every time
the item is inspected. This 
includes material info, weapon
and attack properties, armor thickness
and coverage. Also displays additional
info related to NB mod.

Supports user-defined custom descriptions
for items and materials. They are loaded
from .txt files in raw/item_description folder.
Instuction file is in item_description folder.

Usage: 

nb_item_info ?|help - show help, does not enable the script

nb_item_info - enable the script
	Additional arguments (in any order)
	debug - prints file path for descriptions and ascii images
	ascii_item - adds ascii image popup to item text viewer screen
	ascii_unit - adds ascii image popup to unit text viewer screen
	
]]

local debug
local show_ascii
local show_ascii_item
local show_ascii_unit

for i = 1, #args do

	if args[i] == "help" or args[i] == "?"
		then print (help)
		return
	end

	if args[i] == "debug"
		then debug = true
	end
	
	if args[i] == "ascii_item"
		then show_ascii_item = true
		show_ascii = true
	end
	
	if args[i] == "ascii_unit"
		then show_ascii_unit = true
		show_ascii = true
	end
end

local lastframe = df.global.enabler.frame_last

function MatchesAny (object, tab)
	for k,v in pairs (tab) do
		if object == v then return true end
	end
	
	return false
end

local mats_shown_for = {0,1,4,3,5,43,44,56,57,75,24,67,85,64,26,27,59,28,29,25,38}

function BuildCharMatrix (filename)

		local char_matrix = {}
		--print ("reading file",filename)
		local format_tag
		
		local input = io.open(filename , r):read("*a")
		local format_tag = string.match (input,"<FORMAT:(.+)>")
		
		if  format_tag ~= "NB_ASCII" then return nil end
		
		--print ("wrong image format") 
		
		for line in io.open(filename , r):lines() do
			--print (line)
			
			local chartab = {}
			for elem in string.gmatch(line, "%d+") do 
				table.insert (chartab,tonumber(elem))
				--print (#char_matrix,#chartab,elem)
			end
			
			if #chartab>0 then
				table.insert (char_matrix,chartab)
			end
			
		 end
		  
		return char_matrix
		
	--[[	local ascii_image = "" -- convert chars into a single string, but it does not allow different colors
		 for i =1, #char_matrix do
			 for j =1, #char_matrix[i] do
				ascii_image = ascii_image..string.char(char_matrix[i][j])
			 end
			 if char_matrix[i+1] then ascii_image = ascii_image.."\n" end
		 end
		print ascii_image]]
		
	end

function ShowPicNBASCII(char_matrix)

	if not char_matrix then return nil end
	
	local ascii_screen=defclass(tutorial_screen,gui.FramedScreen)

	local draw_start_x,draw_start_y = 0,0
	 
	function ascii_screen:DrawLabels (char_matrix,start_t,start_l)

		 for i =1, #char_matrix do
			 for j =1, #char_matrix[i] do
				self:addviews{	widgets.Label{text=string.char(char_matrix[i][j]),frame={t=start_t+i,l=start_l+j}} }
			 end
		 end

	end

	function ascii_screen:init(args)
		self:addviews{
			widgets.Label{text="Hello World",frame={t=1,l=1}},
			widgets.Label{
				frame = { l = 0, b = 0, w = 10 },
				text = {
					{ key = 'LEAVESCREEN', text = ': Close',
					  on_activate = self:callback('dismiss') },
					  }
			},
		}
		
		self:DrawLabels (char_matrix,draw_start_x,draw_start_y)
		
	end
	
	ascii_screen{
	frame_width	= #char_matrix[1]+1,
	frame_height = #char_matrix+2,
	frame_title = "ASCII View",
	frame_style = gui.GREY_LINE_FRAME
	}:show()

end

function GetMainDir ()

	local filename_root = ""
	
	if dfhack.getSavePath() and df.global.gametype ~= 4 and df.global.gametype ~= 5 then
		filename_root = dfhack.getSavePath()..[[/raw/ascii_images/]]
	else
		filename_root = dfhack.getDFPath()..[[/raw/ascii_images/]]
	end

	return filename_root

end

function GetFilenameCreature (unit)

	local creature_raw = df.creature_raw.find(unit.race)
	
	return "Creature/"..creature_raw.creature_id.."/"..creature_raw.caste[unit.caste].caste_id..".txt"

end

function GetItemTypeID (item)
	return df.item_type[string.match(tostring(item._type),"<type: item_(.+)st>"):upper()],string.match(tostring(item._type),"<type: item_(.+)st>"):upper()
end

function GetMatPlant (item)
	
	if dfhack.matinfo.decode(item).mode == "plant" then
		return dfhack.matinfo.decode(item).plant
	else
		return nil
	end
	
end

function GetMatCreature (item)
	
	if dfhack.matinfo.decode(item).mode == "creature" then
		return dfhack.matinfo.decode(item).creature
	else
		return nil
	end
	
end

function GetReactionClass (mat, rckey, strict) --returns reaction class string or nil if no match found

	if not rckey then return nil end
	
	for k,v in pairs(mat.reaction_class) do
		if v then
		
			if not strict then
				if string.find(v.value,rckey) then
					return v.value
				end
			else
				if v.value == rckey then
					return v.value
				end
			end
			
		else return nil
		end
	end
	return nil
end

function GetMatSyndrome (mat, key, strict) --returns syndrome or nil if no match found

	if not key then return nil end
	
	for k,v in pairs(mat.syndrome) do
			if not strict then
				if string.find(v.syn_name,key) then
					return v
				end
			else
				if v.syn_name == key then
					return v
				end
			end
	end 
	return nil
end

function DecodeGrowthFactors (inpstr) --processes a string and returns table of effect values to apply
	local tab = {outdoor_eff = tonumber(string.match(inpstr, "OE(-?%d+)")) or 0,
	indoor_eff = tonumber(string.match(inpstr, "IE(-?%d+)")) or 0,
	nofert_penalty = tonumber(string.match(inpstr, "noFP(%d+)")) or 0,
	nofert_delay = tonumber(string.match(inpstr, "noFD(%d+)")) or 0,
	crit_heat = tonumber(string.match(inpstr, "crH(%d+)")) or nil,
	crit_frost = tonumber(string.match(inpstr, "crF(%d+)")) or nil,
	dam_heat = tonumber(string.match(inpstr, "dH(%d+)")) or nil,
	heatdam_str = tonumber(string.match(inpstr, "dH%d+/(-?%d+)")) or 0,
	dam_frost = tonumber(string.match(inpstr, "dF(%d+)")) or nil,
	frostdam_str = tonumber(string.match(inpstr, "dF%d+/(-?%d+)")) or 0,
	hitpoints = tonumber(string.match(inpstr, "HP(%d+)"))}
	
	if not tab.hitpoints then 
		tab.hitpoints = 100*setting.farm_hp_mult
	end
	
	return tab
end

function GetReactionProduct(inmat,key) -- takes material object and returns pair of mat type/index values of material reaction product of specific type

	if #inmat.reaction_product.id < 1 then return nil,nil end
	
	for k,v in pairs (inmat.reaction_product.id) do
		if v.value == key then
			return inmat.reaction_product.material.mat_type[k],inmat.reaction_product.material.mat_index[k]
		end
	end
	
	if key == "" then return true end
	
	return nil,nil
end

function GetStringListFromFile (item) -- processes all the custom desctipions

	if debug then
		print ("nb_item_info debug:")
	end
	
	local list = {}
	local indents = {}
	
	local typeid,textid = GetItemTypeID (item)
	local filename_root = ""
	local filename = ""
	
	if dfhack.getSavePath() and df.global.gametype ~= 4 and df.global.gametype ~= 5 then
		filename_root = dfhack.getSavePath()..[[/raw/item_descriptions/]]
	else
		filename_root = dfhack.getDFPath()..[[/raw/item_descriptions/]]
	end
	
	if dfhack.items.getSubtypeCount(typeid) ~= -1 then
		filename = filename_root..textid.. [[/]]..item.subtype.id..[[.txt]]
	else
		filename = filename_root..textid..[[.txt]]
	end
	
	if debug then
		print ("item type text path for item "..item.id)
		print (filename)
	end
	
		
	if io.open(filename , r) then
		
		table.insert(list," ") 	table.insert(indents,0)
		table.insert(list,"Item description:") 	table.insert(indents,0)
		table.insert(list," ") 	table.insert(indents,0)
		
		for line in io.lines(filename) do
			table.insert(list,line) 	table.insert(indents,0)
		end
		
	end
	
	--print("material section")
	------------------------------------------------------
	
	local matinfo = dfhack.matinfo.decode(item)
	if not matinfo then  table.insert(list," ")	table.insert(indents,0) return list,indents end
	
--	print ("nb_item_info: matinfo not found item#"..item.id)

	filename = filename_root..[[Material/]]
	
	local custom_filename = GetReactionClass(matinfo.material,"CUSTOM_DESCR=") or ""
	
	if debug then
		print ("custom reaction class text path for material "..tostring(matinfo))
		print (custom_filename)
	end
	
	if custom_filename then
		custom_filename = filename..tostring(string.match(custom_filename,"CUSTOM_DESCR=(.+)"))
	end
	
	if custom_filename then  -- description from custom filename, from reaction class
		if io.open(custom_filename , r) then 

			table.insert(list," ") 	table.insert(indents,0)
			--table.insert(list,"Material description:") 	table.insert(indents,0)

			for line in io.lines(custom_filename) do
				table.insert(list,line) 	table.insert(indents,0)
			end

		end
	end
	
	local matcode = string.match(tostring(matinfo),"%d (.+)>")
	
	local matstr1,matstr2,matstr3

	if matinfo.mode == "builtin" then
		matstr1 = matcode
	end
	
	if matinfo.mode == "inorganic" then
		matstr1,matstr2 = string.match(tostring(matcode),"(.+):(.+)")
	end
	
	if matinfo.mode == "creature" or matinfo.mode == "plant" then
		matstr1,matstr2,matstr3 = string.match(tostring(matcode),"(.+):(.+):(.+)")
	end
	
	filename = filename..matstr1
	if matstr2 then filename = filename..[[/]]..matstr2 end
	if matstr3 then filename = filename..[[/]]..matstr3 end
	filename = filename..[[.txt]]
	
	if debug then
		print ("material text path for "..tostring(matinfo))
		print (filename)
	end
	
	
	if io.open(filename , r) then 

		table.insert(list," ") 	table.insert(indents,0)
		--table.insert(list,"Material description:") 	table.insert(indents,0)

		for line in io.lines(filename) do
			table.insert(list,line) 	table.insert(indents,0)
		end

	end
	
	table.insert(list," ") 	table.insert(indents,0)
	
	return list,indents
	
end

function GetBoozePropertiesStringList (syndrome)
	if not syndrome then return {"Booze properties:","unknown"},{0,3} end
	
	local list = {}
	local indents = {}
	local booze_prop_tab = {
	degree = string.match(syndrome.syn_name,"d=(%d+)") or "unknown",
	taste = string.match(syndrome.syn_name,"t=(-?%d+)") or "unknown",
	}
	
	table.insert(list,"Booze properties:") 	table.insert(indents,0)
	
	table.insert(list,"Alcoholic degree: "..booze_prop_tab.degree) 	table.insert(indents,3)
	table.insert(list,"Bonus taste: "..booze_prop_tab.taste) 	table.insert(indents,3)
	table.insert(list," ") 	table.insert(indents,0)
	return list,indents
	
end

function GetGrowthFactorsStringList (item)

	local list = {}
	local indents = {}

	table.insert(list,"Growth conditions of this plant:") 	table.insert(indents,0)
	
	if GetMatPlant(item) then
		table.insert(list,"Growth time: "..math.floor(GetMatPlant(item).growdur/12) .." days")
		table.insert(indents,3)
	end
	
	if not GetReactionClass(dfhack.matinfo.decode(item).material,"NB_FARM") then return list,indents end
	
	local efftab = DecodeGrowthFactors(GetReactionClass(dfhack.matinfo.decode(item).material,"NB_FARM"))
	
	if efftab.indoor_eff > 0 then
		table.insert(list,"Cannot grow indoors") 	table.insert(indents,3)
		else
		table.insert(list,"Doesn't require sunlight") 	table.insert(indents,3)
	end
	
	if efftab.outdoor_eff > 0 then
		table.insert(list,"Cannot grow outdoors") 	table.insert(indents,3)
	end
	
	if efftab.nofert_delay > 0 then
		table.insert(list,"Grows slower without fertilization") 	table.insert(indents,3)
	end
	
	if efftab.nofert_penalty > 0 then
		table.insert(list,"Cannot survive without fertilization") 	table.insert(indents,3)
	end
	
	if not efftab.dam_frost then efftab.dam_frost = efftab.crit_frost end
	if not efftab.dam_heat then efftab.dam_heat = efftab.crit_heat end
	
	table.insert(list,"Tolerance: "..tostring(efftab.hitpoints)) 	table.insert(indents,3)
	table.insert(list,"Critical temperatures: "..tostring(efftab.crit_frost).."-"..tostring(efftab.crit_heat)) 	table.insert(indents,3)
	table.insert(list,"Tolerated temperatures: "..tostring(efftab.dam_frost).."-"..tostring(efftab.dam_heat)) 	table.insert(indents,3)
	table.insert(list," ") 	table.insert(indents,0)
	
	return list,indents
	
end

function GetMatPropertiesStringList (item)

	local mat = dfhack.matinfo.decode(item).material
	local list = {}
	local indents = {}
	
	table.insert(list,"Temperature: "..item.temperature.whole.."U".." ("..math.floor((item.temperature.whole-10000)*5/9).."\248C)") 	table.insert(indents,0)
	
	table.insert(list,"Color: "..df.global.world.raws.language.colors[mat.state_color.Solid].name) 	table.insert(indents,0)
	
	
	local function GetStrainDescription (number)
		local str = "unknown"
		if tonumber(number) then str = " (very elastic)" end
		if number < 50000 then str = " (elastic)" end
		if number < 15001 then str = " (medium)" end
		if number < 5001 then str = " (stiff)" end
		if number < 1000 then str = " (very stiff)" end
		if number < 1 then str = " (crystalline)" end
		
		return str
		
	end
	
	if  MatchesAny (item:getType(),mats_shown_for) then
		
		table.insert(list,"Material properties: ") 	table.insert(indents,0)
	
		table.insert(list,"Solid density: "..mat.solid_density..'g/cm^3') 	table.insert(indents,3)
	
		table.insert(list,"Shear yield: "..mat.strength.yield.SHEAR.."("..math.floor(mat.strength.yield.SHEAR/standard.strength.yield.SHEAR*100).."%)"..
		", fr.: "..mat.strength.fracture.SHEAR.."("..math.floor(mat.strength.fracture.SHEAR/standard.strength.fracture.SHEAR*100).."%)"..
		", el.: "..mat.strength.strain_at_yield.SHEAR..GetStrainDescription(mat.strength.strain_at_yield.SHEAR)
		) 	table.insert(indents,3)
		
		table.insert(list,"Impact yield: "..mat.strength.yield.IMPACT.."("..math.floor(mat.strength.yield.IMPACT/standard.strength.yield.IMPACT*100).."%)"..
		", fr.: "..mat.strength.fracture.IMPACT.."("..math.floor(mat.strength.fracture.IMPACT/standard.strength.fracture.IMPACT*100).."%)"..
		", el.: "..mat.strength.strain_at_yield.IMPACT..GetStrainDescription(mat.strength.strain_at_yield.IMPACT)
		) 	table.insert(indents,3)
		
		if mat.molar_mass > 0 then
			table.insert(list,"Molar mass: "..mat.molar_mass) 	table.insert(indents,3)
		end
		table.insert(list,"Maximum sharpness: "..mat.strength.max_edge.." ("..mat.strength.max_edge/standard.strength.max_edge*100 .."%)") 	table.insert(indents,3)
		
	end
	
	table.insert(list," ") 	table.insert(indents,0)

	return list,indents
	
end

function GetArmorPropertiesStringList (item)

	local mat = dfhack.matinfo.decode(item).material
	local list = {}
	local indents = {}
	
	table.insert(list,"Armor properties: ") 	table.insert(indents,0)
	
	table.insert(list,"Thickness: "..item.subtype.props.layer_size) 	table.insert(indents,3)
	table.insert(list,"Coverage: "..item.subtype.props.coverage.."%") 	table.insert(indents,3)
	
	table.insert(list,"Fit for "..df.creature_raw.find(item.maker_race).name[0]) 	table.insert(indents,3)
	
	table.insert(list," ") 	table.insert(indents,0)

	return list,indents
	
end

function GetShieldPropertiesStringList (item)

	local mat = dfhack.matinfo.decode(item).material
	local list = {}
	local indents = {}
	
	table.insert(list,"Shield properties: ") 	table.insert(indents,0)
	
	table.insert(list,"Base block chance: "..item.subtype.blockchance) 	table.insert(indents,3)
	table.insert(list,"Fit for "..df.creature_raw.find(item.maker_race).name[0]) 	table.insert(indents,3)
	
	table.insert(list," ") 	table.insert(indents,0)

	return list,indents
	
end

function GetWeaponPropertiesStringList (item)

	local mat = dfhack.matinfo.decode(item).material
	local list = {}
	local indents = {}
	
	if item._type == df.item_toolst and #item.subtype.attacks < 1 then return {" "},{0} end
	
	table.insert(list,"Weapon properties: ") 	table.insert(indents,0)
	if item.sharpness > 0 then
		table.insert(list,"Sharpness: "..item.sharpness.." ("..item.sharpness/standard.strength.max_edge*100 .."%)") 	table.insert(indents,3)
		else
		table.insert(list,"Not edged") 	table.insert(indents,3)
	end
	
	if string.len(item.subtype.ranged_ammo) > 0 then
		table.insert(list,"Ranged weapon") 	table.insert(indents,3)
		
			table.insert(list,"Ammo: "..item.subtype.ranged_ammo:lower()) 	table.insert(indents,6)
			
		if item.subtype.shoot_force > 0 then
			table.insert(list,"Shoot force: "..item.subtype.shoot_force) 	table.insert(indents,6)
		end
		
		if item.subtype.shoot_maxvel > 0 then
			table.insert(list,"Maximum projectile velocity: "..item.subtype.shoot_maxvel) 	table.insert(indents,6)
		end
		
	end
	
	table.insert(list,"Required size: "..item.subtype.minimum_size*10) 	table.insert(indents,3)
	if item.subtype.two_handed*10 > item.subtype.minimum_size*10 then
		table.insert(list,"Used as 2-handed until: "..item.subtype.two_handed*10) 	table.insert(indents,3)
	end
	--table.insert(list,"Melee skill: "..string.lower(item.subtype.skill_melee._enum)) 	table.insert(indents,3)

	--table.insert(list,"Size: "..item.subtype.size*10) 	table.insert(indents,3)
	
	
	table.insert(list,"Attacks: ") 	table.insert(indents,3)
	
	for k,attack in pairs (item.subtype.attacks) do
		
		local name = attack.verb_2nd
		if attack.noun ~= "NO_SUB" then name = name.." with "..attack.noun end
		
		if attack.edged then name = name.." (edged)" else name = name.." (blunt)" end
		
		table.insert(list,name) 	table.insert(indents,6)
		table.insert(list,"Contact area: "..attack.contact) 	table.insert(indents,9)
		
		if attack.edged then
			table.insert(list,"Penetration: "..attack.penetration) 	table.insert(indents,9)
		end
		
		table.insert(list,"Velocity multiplier: "..attack.velocity_mult/1000) 	table.insert(indents,9)
		if attack.flags.bad_multiattack then
			table.insert(list,"Bad multiattack") 	table.insert(indents,9)
		end
		table.insert(list,"Prepare/recover: "..attack.prepare.."/"..attack.recover) 	table.insert(indents,9)
		
	end
	
	
	table.insert(list," ") 	table.insert(indents,0)

	return list,indents
	
end

function GetAmmoPropertiesStringList (item)

	local mat = dfhack.matinfo.decode(item).material
	local list = {}
	local indents = {}
	
	if item._type == df.item_toolst and #item.subtype.attacks < 1 then return {" "},{0} end
	
	table.insert(list,"Ammo properties: ") 	table.insert(indents,0)
	if item.sharpness > 0 then
		table.insert(list,"Sharpness: "..item.sharpness) 	table.insert(indents,3)
		else
		table.insert(list,"Not edged") 	table.insert(indents,3)
	end

	table.insert(list,"Attacks: ") 	table.insert(indents,3)
	
	for k,attack in pairs (item.subtype.attacks) do
		
		local name = attack.verb_2nd
		if attack.noun ~= "NO_SUB" then name = name.." with "..attack.noun end
		
		if attack.edged then name = name.." (edged)" else name = name.." (blunt)" end
		
		table.insert(list,name) 	table.insert(indents,6)
		table.insert(list,"Contact area: "..attack.contact) 	table.insert(indents,9)
		
		if attack.edged then
			table.insert(list,"Penetration: "..attack.penetration) 	table.insert(indents,9)
		end
		
		table.insert(list,"Velocity multiplier: "..attack.velocity_mult/1000) 	table.insert(indents,9)
		if attack.flags.bad_multiattack then
			table.insert(list,"Bad multiattack") 	table.insert(indents,9)
		end
		table.insert(list,"Prepare/recover: "..attack.prepare.."/"..attack.recover) 	table.insert(indents,9)
		
	end
	
	table.insert(list," ") 	table.insert(indents,0)

	return list,indents
	
end

function GetFoodPropertiesStringList (item)

	local mat = dfhack.matinfo.decode(item).material
	local list = {}
	local indents = {}
	
	if item._type == df.item_foodst then
		table.insert(list,"This is prepared meal") 	table.insert(indents,0)
		table.insert(list," ") 	table.insert(indents,0)
		return list,indents
	end
	
	if mat == dfhack.matinfo.find ("WATER") then
		table.insert(list,"Water is perfectly drinkable") 	table.insert(indents,0)
		table.insert(list," ") 	table.insert(indents,0)
		return list,indents
	end
	
	--table.insert(list,"Food properties: ") 	table.insert(indents,0)
	if mat.flags.EDIBLE_RAW or mat.flags.EDIBLE_COOKED then
		local edible_string = "Edible"
		if mat.flags.EDIBLE_RAW then 
			edible_string = edible_string.." raw" 
				if mat.flags.EDIBLE_COOKED then
					edible_string = edible_string.." and cooked"
				end
			else
				if mat.flags.EDIBLE_COOKED then
					edible_string = edible_string.." only when cooked"
				end
		end
		
		table.insert(list,edible_string) 	table.insert(indents,0)
	end
	
	if not mat.flags.EDIBLE_RAW and not mat.flags.EDIBLE_COOKED then
		table.insert(list,"Not edible") 	table.insert(indents,0)
	end
	
	if GetMatSyndrome (mat, "indigest") then
		table.insert(list,"Can cause indigestion syndrome! Cook before consuming recommended") 	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "SUGARABLE") then
		table.insert(list,"Used to make sugar") 	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "MILLABLE") or GetReactionProduct (mat, "GRAIN_MILLABLE") or GetReactionProduct (mat, "GROWTH_MILLABLE") then
		table.insert(list,"Can be milled") 	table.insert(indents,0)
	end
	
	if GetReactionProduct(mat, "GRAIN_THRESHABLE") then
		table.insert(list,"Grain can be threshed") 	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "DRINK_MAT") then
		local mat_type, mat_index = GetReactionProduct (mat, "DRINK_MAT")
		
		table.insert(list,"Used to brew "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Liquid) 	table.insert(indents,0)
	end
		
	if GetReactionProduct (mat, "GROWTH_JUICE_PROD") then
		local mat_type, mat_index = GetReactionProduct (mat, "GROWTH_JUICE_PROD")
		
		table.insert(list,"Pressed into "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Liquid)	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "PRESS_LIQUID_MAT") then
		local mat_type, mat_index = GetReactionProduct (mat, "PRESS_LIQUID_MAT")
		
		table.insert(list,"Pressed into "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Liquid)	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "LIQUID_EXTRACTABLE") then
		local mat_type, mat_index = GetReactionProduct (mat, "LIQUID_EXTRACTABLE")
		
		table.insert(list,"Extractable product: "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Liquid)	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "WATER_SOLUTION_PROD") then
		local mat_type, mat_index = GetReactionProduct (mat, "WATER_SOLUTION_PROD")
		
		table.insert(list,"Can be mixed with water to make "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Liquid)	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "CHEESE_MAT") then
		local mat_type, mat_index = GetReactionProduct (mat, "CHEESE_MAT")
		
		table.insert(list,"Used to make "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Solid)	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "RENDER_MAT") then
		local mat_type, mat_index = GetReactionProduct (mat, "RENDER_MAT")
		
		table.insert(list,"Rendered into "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Liquid)	table.insert(indents,0)
	end
	
	if GetReactionProduct (mat, "SOAP_MAT") then
		local mat_type, mat_index = GetReactionProduct (mat, "SOAP_MAT")
		
		table.insert(list,"Used to make "..dfhack.matinfo.decode(mat_type, mat_index).material.state_name.Liquid)	table.insert(indents,0)
	end
	
	if item._type == df.item_plantst then
		if GetMatPlant (item) then
			local plant = GetMatPlant (item)
			
			for k,v in pairs (plant.material_defs) do
				if v ~= -1 and string.find (k,"type_") and not (string.find (k,"type_basic") or string.find (k,"type_seed") or string.find (k,"type_tree")) then
					local targetmat = dfhack.matinfo.decode (v, plant.material_defs["idx_"..string.match (k,"type_(.+)")])
					
					local state = "Liquid"
					if string.find (k,"type_mill") then state = "Powder" end
					if string.find (k,"type_thread") then state = "Solid" end
					
					table.insert(list,"Used to make "..targetmat.material.prefix..""..targetmat.material.state_name[state])	table.insert(indents,0)
					
				end
			end
		
		
		end
	end
	
	table.insert(list," ") 	table.insert(indents,0)

	return list,indents
	
end

function AddUsesString (viewscreen,inp_string,indent,reaction)
	local string = df.new("string")
	string.value = tostring(inp_string)
	
	if not reaction then reaction = -1 end
	if not indent then indent = 0 end
	
	viewscreen.entry_ref:insert('#', nil)
	viewscreen.entry_indent:insert('#', indent)
	viewscreen.unk_34:insert('#', nil)
	viewscreen.entry_string:insert('#', string)
	viewscreen.entry_reaction:insert('#', reaction)
end
	
function ProcessASCII (filename)
	
	if io.open(filename , r) then
		local char_matrix =	BuildCharMatrix (filename) 
	 
		if char_matrix then
			ShowPicNBASCII(char_matrix)
			else
			local inputfile = io.open(filename , r):read("*a")
			dlg.showMessage("ASCII View",inputfile, COLOR_WHITE, nil)
		end
		
	end
end
	
dfhack.onStateChange.item_info = function(code)
	if code == SC_VIEWSCREEN_CHANGED and dfhack.isWorldLoaded() then
	
		standard = dfhack.matinfo.find("INORGANIC:IRON").material or dfhack.matinfo.decode(0,0).material
		
		if dfhack.gui.getCurViewscreen()._type == df.viewscreen_itemst then
			local scr = dfhack.gui.getCurViewscreen()
			
			if #scr.entry_string > 0 then
				if scr.entry_string[#scr.entry_string-1].value == " " then return end
			end
			
			
			if df.global.gamemode == 1 and scr.item:getType() ~= 73 then -- shows basic value in adventure mode
				
				local string_list,indents = {},{}
					
				table.insert(string_list,"Value: "..dfhack.items.getValue(scr.item)) 	table.insert(indents,0)
				
					for i = 1, #string_list do
						AddUsesString(scr,string_list[i],indents[i])
					end
				
			end
			
			if true then --custom descr
			
				local string_list,indents = GetStringListFromFile (scr.item)
				
				for i = 1, #string_list do
					AddUsesString(scr,string_list[i],indents[i])
				end
					
			end
		
			
			if scr.item._type == df.item_armorst or scr.item._type == df.item_pantsst or scr.item._type == df.item_helmst or scr.item._type == df.item_glovesst or scr.item._type == df.item_shoesst then --armor info
			
				local string_list,indents = GetArmorPropertiesStringList(scr.item)
				
				for i = 1, #string_list do
					AddUsesString(scr,string_list[i],indents[i])
				end
					
			end
			
			if scr.item._type == df.item_weaponst or scr.item._type == df.item_toolst then --weapon info
			
				local string_list,indents = GetWeaponPropertiesStringList(scr.item)
				
				for i = 1, #string_list do
					AddUsesString(scr,string_list[i],indents[i])
				end
					
					
			end	
	
			if scr.item._type == df.item_ammost then --weapon info
			
				local string_list,indents = GetAmmoPropertiesStringList(scr.item)
				
				for i = 1, #string_list do
					AddUsesString(scr,string_list[i],indents[i])
				end

			end
			
			if scr.item._type == df.item_shieldst then --shield info
			
				local string_list,indents = GetShieldPropertiesStringList(scr.item)
				
				for i = 1, #string_list do
					AddUsesString(scr,string_list[i],indents[i])
				end
					
					
			end
			
			if scr.item._type == df.item_drinkst then --advanced booze info (Natural Balance)
				if GetMatSyndrome(dfhack.matinfo.decode(scr.item).material,"nb_alco") then
					local string_list,indents = GetBoozePropertiesStringList(GetMatSyndrome(dfhack.matinfo.decode(scr.item).material,"nb_alco"))
					
					for i = 1, #string_list do
						AddUsesString(scr,string_list[i],indents[i])
					end
					
				end
			end
			
			if scr.item._type == df.item_seedsst then --seed growth information (Natural Balance)
				--if GetReactionClass(dfhack.matinfo.decode(scr.item).material,"NB_FARM") then
				
					local string_list,indents = GetGrowthFactorsStringList(scr.item)
					
					for i = 1, #string_list do
						AddUsesString(scr,string_list[i],indents[i])
					end
					
				--end
			end
			
			if scr.item._type == df.item_meatst or scr.item._type == df.item_globst or scr.item._type == df.item_powder_miscst or scr.item._type == df.item_plantst or scr.item._type == df.item_plant_growthst or scr.item._type == df.item_liquid_miscst or scr.item._type == df.item_cheesest or scr.item._type == df.item_foodst then --food info, plant usability
			
				local string_list,indents = GetFoodPropertiesStringList(scr.item)
				
				for i = 1, #string_list do
					AddUsesString(scr,string_list[i],indents[i])
				end
					
			end
			
			if not dfhack.items.isCasteMaterial(GetItemTypeID(scr.item)) then -- any non-caste material item, material properties
				local string_list,indents = GetMatPropertiesStringList(scr.item)
				for i = 1, #string_list do
					AddUsesString(scr,string_list[i],indents[i])
				end
			end
			
			scr.caption_uses = true
		end
		
		if dfhack.gui.getCurViewscreen()._type == df.viewscreen_textviewerst and show_ascii then
			
			if df.global.enabler.frame_last-lastframe > 1000 then
				local scr = dfhack.gui.getCurViewscreen()
				local parent = scr.parent
				
				if (parent._type == df.viewscreen_unitst or parent._type == df.viewscreen_dungeon_monsterstatusst) and show_ascii_unit then
			
					local unit = parent.unit
					
					local filename = GetMainDir ()..GetFilenameCreature(unit)
					
					if debug then
						print ("ASCII filename unit")
						print (filename)
					end
					
					ProcessASCII (filename)

					lastframe = df.global.enabler.frame_last
				
				end
				
				if parent._type == df.viewscreen_itemst and show_ascii_item then
			
					local item = parent.item
					local typeid,textid = GetItemTypeID (item)
					
					local filename = ""
					
					if dfhack.items.getSubtypeCount(typeid) ~= -1 then
						filename = GetMainDir ()..[[Item/]]..textid.. [[/]]..item.subtype.id..[[.txt]]
					else
						filename = GetMainDir ()..[[Item/]]..textid..[[.txt]]
					end
					
					if debug then
						print ("ASCII filename item")
						print (filename)
					end
					
					ProcessASCII (filename)
				
					lastframe = df.global.enabler.frame_last
				
				end
				
			end
			
		end
	
	
	end

end

print ("nb_item_info enabled")

if debug then
	print ("debug mode")
end

if show_ascii then
	print ("ascii images enabled")
end

if show_ascii_unit then
	print ("ascii unit images enabled")
end

if show_ascii_item then
	print ("ascii item images enabled")
end