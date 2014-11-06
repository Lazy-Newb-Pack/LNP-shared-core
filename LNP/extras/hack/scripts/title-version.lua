-- Displays the DFHack version on the title screen
--[[ By Lethosor
Usage:
    title-version [enable/disable]
Last tested on 0.40.11-r1
]]

if old_version == nil then
    old_version = ''
    enabled = false
end
function showVersion(...)
    args = {...}
    if dfhack.gui.getCurFocus() == 'title' then
        scr = dfhack.gui.getCurViewscreen()
        if #args == 0 and scr.str_version:find('DFHack') then return end
        if old_version == '' then old_version = scr.str_version end
        scr.str_version = args[1] or (scr.str_version .. ', DFHack ' .. dfhack.VERSION .. ' ')
    end
end
args = {...}
if #args == 0 or args[1] == 'enable' then
    enabled = true
    dfhack.onStateChange.title_version = function() showVersion() end
    showVersion()
elseif args[1] == 'disable' then
    if old_version ~= '' then
        showVersion(old_version)
        dfhack.onStateChange.title_version = function() showVersion(old_version) end
    end
    enabled = false
else
    print([[Usage:
title-version [enable]: Enable DFHack version display
title-version disable: Disable DFHack version display
]])
end
