local utils = require('utils')
 
validArgs = utils.invert({
  'all',
  'citizens',
  'named',
  'notStraight',
  'gayOnly',
  'biOnly',
  'straightOnly',
  'asexualOnly',
  'help'
})

 
local args = utils.processArgs({...}, validArgs)

if args.help then
 print(
[[gaydar.lua
arguments:
    -help
        print this help message
unit filters:
    -all
        shows orientation of every creature
    -citizens
        shows only orientation of citizens in fort mode
    -named
        shows orientation of all named units on map
orientation filters:
    -notStraight
        shows only creatures who are not strictly straight
    -gayOnly
        shows only creatures who are strictly gayOnly
    -biOnly
        shows only creatures who can get into romances with
        both sexes
    -straightOnly
        shows only creatures who are strictly straight.
    -asexualOnly
        shows only creatures who are strictly asexual.
    
    No argument will show the orientation of the unit
    under the cursor.
]])
 return
end

function getSexString(sex)
    local sexStr
    if sex==0 then
        sexStr=string.char(12)
    elseif sex==1 then
        sexStr=string.char(11)
    else
        return ""
    end
    return string.char(40)..sexStr..string.char(41)
end

orientation_flags=orientation_flags or {
' is asexual',
' likes males',
' likes males',
' likes males',
' would marry males',
' has been tampered with',
' has been tampered with',
' has been tampered with',
' likes females',
' likes females and males',
' likes females and males',
' likes females and males',
' likes females and would marry males',
' has been tampered with',
' has been tampered with',
' has been tampered with',
' would marry females',
' would marry females and likes males',
' would marry females and likes males',
' would marry females and likes males',
' would marry males or females'}


local function determineorientation(unit)
    if unit.sex~=-1 then
        return orientation_flags[unit.status.current_soul.unk1+1]
    else
        return "is not biologically capable of sex"
    end
end

local function nameOrSpeciesAndNumber(unit)
    if unit.name.has_name then
        return dfhack.TranslateName(dfhack.units.getVisibleName(unit))..' '..getSexString(unit.sex),true
    else
        return 'Unit #'..unit.id..' ('..df.creature_raw.find(unit.race).caste[unit.caste].caste_name[0]..' '..getSexString(unit.sex)..')',false
    end
end

local orientations={}

if args.citizens then
    for k,v in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(v) then
            table.insert(orientations,nameOrSpeciesAndNumber(v) .. determineorientation(v))
        end
    end
elseif args.all then
    for k,v in ipairs(df.global.world.units.active) do
        table.insert(orientations,nameOrSpeciesAndNumber(v)..determineorientation(v))
    end
elseif args.named then
    for k,v in ipairs(df.global.world.units.active) do
        local name,ok=nameOrSpeciesAndNumber(v)
        if ok then
            table.insert(orientations,name..determineorientation(v))
        end
    end
else
    qerror(determineorientation(dfhack.gui.getSelectedUnit(true)))
end

function isNotStraight(v)
    if v:find(string.char(12)) and v:find(' female') then return true end
    if v:find(string.char(11)) and v:find(' male') then return true end
    if v:find('asexual') then return true end
    return false
end

function isGay(v)
    if v:find('asexual') then return false end
    if v:find(string.char(12)) and not v:find(' male') then return true end
    if v:find(string.char(11)) and not v:find(' female') then return true end
    return false
end

function isAsexual(v)
    if v:find('asexual') then return true else return false end
end

function isBi(v)
    if v:find(' female') and v:find(' male') then return true else return false end
end

if args.notStraight then
    local totalNotShown=0
    for k,v in ipairs(orientations) do
        if isNotStraight(v) then print(v) else totalNotShown=totalNotShown+1 end
    end
    print('Total not shown: '..totalNotShown)
elseif args.gayOnly then
    local totalNotShown=0
    for k,v in ipairs(orientations) do
        if isGay(v) then print(v) else totalNotShown=totalNotShown+1 end
    end
    print('Total not shown: '..totalNotShown)
elseif args.asexualOnly then
    local totalNotShown=0
    for k,v in ipairs(orientations) do
        if isAsexual(v) then print(v) else totalNotShown=totalNotShown+1 end
    end
    print('Total not shown: '..totalNotShown)
elseif args.straightOnly then
    local totalNotShown=0
    for k,v in ipairs(orientations) do
        if not isNotStraight(v) then print(v) else totalNotShown=totalNotShown+1 end
    end
    print('Total not shown: '..totalNotShown)
elseif args.biOnly then
    local totalNotShown=0
    for k,v in ipairs(orientations) do
        if isBi(v) then print(v) else totalNotShown=totalNotShown+1 end
    end
    print('Total not shown: '..totalNotShown)
else
    for k,v in ipairs(orientations) do
        print(v)
    end
end