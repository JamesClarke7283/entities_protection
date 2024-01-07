-- Function to check if a player is an owner of the area
local function is_player_an_area_owner(player_name, pos)
    local owners = areas:getNodeOwners(pos)
    for _, owner in ipairs(owners) do
        if owner == player_name then
            return true
        end
    end
    return false
end

-- Globalstep function to monitor entity punches
minetest.register_globalstep(function(dtime)
    for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 50000)) do
        if obj:is_player() == false then -- Exclude players
            local lua_entity = obj:get_luaentity()
            if lua_entity and lua_entity.punched then
                -- The entity has been punched, reset the flag
                lua_entity.punched = nil

                -- Check if the puncher is a player
                local puncher = lua_entity.last_puncher
                if puncher and puncher:is_player() then
                    local player_name = puncher:get_player_name()
                    local pos = obj:get_pos()

                    -- Check if the player is an owner of the area
                    if not is_player_an_area_owner(player_name, pos) then
                        -- Prevent further processing
                        minetest.log("action", "[areas_entities] Preventing damage by non-owner " .. player_name)
                        lua_entity.hp = lua_entity.old_hp -- Reset HP to previous value
                    end
                end
            end
        end
    end
end)

-- Override the entity punch function
local function override_entity_punch()
    for _, entity in pairs(minetest.registered_entities) do
        if entity.on_punch then
            -- Store the original on_punch function
            local original_on_punch = entity.on_punch

            -- Override the on_punch function
            entity.on_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
                -- Mark the entity as punched and store the puncher and HP
                self.punched = true
                self.last_puncher = hitter
                self.old_hp = self.hp or 0

                -- Call the original on_punch function
                original_on_punch(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
            end
        end
    end
end

-- Call the function to override entity punch behavior
override_entity_punch()
