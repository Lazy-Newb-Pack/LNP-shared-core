-- Adjusts dwarves' skills when embarking
--[[ By Lethosor
Last tested on 0.40.13-r1
]]

VERSION = '0.1'

function usage()
    print([[Usage:
    embark-skills points N:      Sets the skill points remaining of the selected dwarf to 'N'.
    embark-skills points N all:  Sets the skill points remaining of all dwarves to 'N'.
    embark-skills max:           Sets all skills of the selected dwarf to "Proficient".
    embark-skills max all:       Sets all skills of all dwarves to "Proficient".
    embark-skills legendary:     Sets all skills of the selected dwarf to "Legendary".
    embark-skills legendary all: Sets all skills of all dwarves to "Legendary".
    embark-skills help:          Display this help
embark-skills v]] .. VERSION)
end
function err(msg)
    dfhack.printerr(msg)
    usage()
    qerror('')
end

function adjust(dwarves, callback)
    for _, dwf in pairs(dwarves) do
        callback(dwf)
    end
end

scr = dfhack.gui.getCurViewscreen()
if dfhack.gui.getCurFocus() ~= 'setupdwarfgame' or scr.show_play_now == 1 then
    qerror('Must be called on the "Prepare carefully" screen')
end

dwarf_info = scr.dwarf_info
dwarves = dwarf_info
selected_dwarf = {[0] = scr.dwarf_info[scr.dwarf_cursor]}

args = {...}
if args[1] == 'points' then
    points = tonumber(args[2])
    if points == nil then
        err('Invalid points')
    end
    if args[3] ~= 'all' then dwarves = selected_dwarf end
    adjust(dwarves, function(dwf)
        dwf.levels_remaining = points
    end)
elseif args[1] == 'max' then
    if args[2] ~= 'all' then dwarves = selected_dwarf end
    adjust(dwarves, function(dwf)
        for skill, level in pairs(dwf.skills) do
            dwf.skills[skill] = df.skill_rating.Proficient
        end
    end)
elseif args[1] == 'legendary' then
    if args[2] ~= 'all' then dwarves = selected_dwarf end
    adjust(dwarves, function(dwf)
        for skill, level in pairs(dwf.skills) do
            dwf.skills[skill] = df.skill_rating.Legendary5
        end
    end)
else
    usage()
end