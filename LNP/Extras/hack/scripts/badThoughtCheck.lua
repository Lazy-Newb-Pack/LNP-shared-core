do
    local function thoughtIsNegative(thought)
        return df.unit_thought_type.attrs[thought.type].value:sub(1,1)=='-' and df.unit_thought_type[thought.type]~='LackChairs'
    end
    local function write_gamelog_and_announce(msg,color)
        dfhack.gui.showAnnouncement(msg,color)
        local log = io.open('gamelog.txt', 'a')
        log:write(msg.."\n")
        log:close()
    end
    local function checkForBadThoughts()
        local thoughts={}
        local mostPopularNegativeThought={cur_amount=0,thought_type=-1}
        for _,unit in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(unit) then
                for __,thought in ipairs(unit.status.recent_events) do
                    if thoughtIsNegative(thought) then
                        thoughts[thought.type]=thoughts[thought.type] or 0
                        thoughts[thought.type]=thoughts[thought.type]+1
                        if thoughts[thought.type]>mostPopularNegativeThought.cur_amount then
                            mostPopularNegativeThought.cur_amount=thoughts[thought.type]
                            mostPopularNegativeThought.thought_type=thought.type
                        end
                    end
                end
            end
        end
        if df.unit_thought_type[mostPopularNegativeThought.thought_type] then
            write_gamelog_and_announce('Your dwarves are most complaining about this: "' .. df.unit_thought_type.attrs[mostPopularNegativeThought.thought_type].caption..'".',COLOR_CYAN)
        end
    end
    checkForBadThoughts()
end