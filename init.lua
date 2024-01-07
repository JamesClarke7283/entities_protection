-- Function to check if a player is an owner of the area
local function is_player_an_area_owner(player_name, pos)
    minetest.log("action", "[areas_entities] Checking area ownership for player: " .. player_name)
    local owners = areas:getNodeOwners(pos)
    for _, owner in ipairs(owners) do
        if owner == player_name then
            minetest.log("action", "[areas_entities] Player is an area owner.")
            return true
        end
    end
    minetest.log("action", "[areas_entities] Player is not an area owner.")
    return false
end

-- Override entity punch function
local function override_entity_punch()
    minetest.log("action", "[areas_entities] Overriding entity punch functions.")
    for _, entity in pairs(minetest.registered_entities) do
        local original_on_punch = entity.on_punch
        entity.on_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
            if hitter and hitter:is_player() then
                local pos = self.object:get_pos()
                local player_name = hitter:get_player_name()
                if not is_player_an_area_owner(player_name, pos) then
                    minetest.log("action", "[areas_entities] Preventing entity damage by non-owner " .. player_name)
                    return
                end
            end
            if original_on_punch then
                original_on_punch(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
            end
        end
    end
end

-- Call the function to override entity punch behavior
override_entity_punch()

-- Globalstep function to monitor entity punches
minetest.register_globalstep(function(dtime)
    for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 50000)) do
        if obj:is_player() == false then -- Exclude players
            local lua_entity = obj:get_luaentity()
            if lua_entity and lua_entity.punched then
                -- The entity has been punched, reset the flag
                lua_entity.punched = false
                local puncher = lua_entity.last_puncher
                if puncher and puncher:is_player() then
                    local player_name = puncher:get_player_name()
                    local pos = obj:get_pos()
                    if not is_player_an_area_owner(player_name, pos) then
                        minetest.log("action", "[areas_entities] Preventing damage by non-owner " .. player_name)
                        lua_entity.hp = lua_entity.old_hp
                    end
                end
            end
        end
    end
end)
