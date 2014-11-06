-- Sets adventurer skills/attributes to maximum
--[[ By Lethosor
Last tested on 0.40.10-r1
]]

if dfhack.gui.getCurFocus() ~= 'setupadventure' then
    qerror('Must be called on adventure mode setup screen')
end

adv = dfhack.gui.getCurViewscreen().adventurer
for k, v in pairs(adv.skills) do adv.skills[k] = 20 end
for k, v in pairs(adv.attributes) do adv.attributes[k] = 6 end
