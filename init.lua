-- Function to check if a player is an owner of the area
local function is_player_an_area_owner(player_name, pos)
    local owners = areas:getNodeOwners(pos)
    minetest.log("action", "[areas_entities] Ran is_player_an_area_owner with owners: "..minetest.serialize(owners))
    for _, owner in ipairs(owners) do
        if owner == player_name then
            return true
        end
    end
    return false
end

-- Override the entity punch function
local function override_entity_punch()
    -- Iterate over all registered entities
    for _, entity in pairs(minetest.registered_entities) do
        -- Store the original on_punch function
        minetest.log("action", "[areas_entities] On Punch: "..minetest.serialize(entity.on_punch))
        local original_on_punch = entity.on_punch

        -- Override the on_punch function
        entity.on_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
            -- Check if the hitter is a player and the entity is not a player
            if hitter and hitter:is_player() and not self.object:is_player() then
                local pos = self.object:get_pos()
                local player_name = hitter:get_player_name()

                -- Check if the player is an owner of the area
                if not is_player_an_area_owner(player_name, pos) then
                    -- Prevent the damage if the player is not an owner
                    damage = 0
                    minetest.log("action", "[areas_entities] Preventing damage by non-owner " .. player_name)
                    return true
                end
            end

            -- Otherwise, call the original on_punch function
            if original_on_punch then
                original_on_punch(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
            end
        end
    end
end

-- Call the function to override entity punch behavior
override_entity_punch()
