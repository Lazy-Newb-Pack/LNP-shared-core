-- Sets the quantity of the selected manager job
--[[ By Lethosor
Sample usage:
    keybinding add Alt-Q@jobmanagement manager-quantity

Last tested on 0.40.11-r1
]]

local dialog = require 'gui.dialogs'
local args = {...}

function show_error(text)
    dialog.showMessage("Error", text, COLOR_LIGHTRED)
end

if dfhack.gui.getCurFocus() == 'jobmanagement' then
    local scr = dfhack.gui.getCurViewscreen()
    local orders = df.global.world.manager_orders
    function set_quantity(value)
        if tonumber(value) then
            local i = scr.sel_idx
            local old_total = orders[i].amount_total
            orders[i].amount_total = math.max(1, value)
            orders[i].amount_left = math.max(1, orders[i].amount_left + (value - old_total))
        else
            show_error(value .. " is not a number!")
        end
    end
    if scr.sel_idx < #orders then
        if #args >= 1 then
            set_quantity(args[1])
        else
            dialog.showInputPrompt(
                "Quantity",
                "Quantity:",
                COLOR_WHITE,
                '',
                set_quantity
            )
        end
    else
        show_error("Invalid order selected")
    end
else
    dfhack.printerr('Must be called on the manager screen (j-m or u-m)')
end
