local utils=require('utils')

validArgs = validArgs or utils.invert({
 'pets'
})

local args = utils.processArgs({...}, validArgs)

for k,v in ipairs(df.global.world.buildings.other.COFFIN) do
    if v.owner_id==-1 then
        v.burial_mode.allow_burial=true
        if not args.pets then
            v.burial_mode.no_pets=true
        end
    end
end