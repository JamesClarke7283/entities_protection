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

local function update_entity_on_punch(entity)
    local original_on_punch = entity.on_punch
    entity.on_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
        if hitter and hitter:is_player() then
            local pos = self.object:get_pos()
            local player_name = hitter:get_player_name()
            local is_protected = minetest.is_protected(pos, player_name)

            -- Log the output of minetest.is_protected
            minetest.log("action", "[areas_entities] Checking protection at pos " .. minetest.pos_to_string(pos) ..
                         " for player " .. player_name .. ". Is protected: " .. tostring(is_protected))

            if is_protected then
                minetest.log("action", "[areas_entities] Preventing entity damage in protected area by " .. player_name)
                return true  -- Returning true should prevent the default damage handling
            end
        end

        if original_on_punch then
            return original_on_punch(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
        end
    end
end



-- Globalstep function to monitor and update entity punches
minetest.register_globalstep(function(dtime)
    for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 50000)) do
        local lua_entity = obj:get_luaentity()
        if lua_entity then
            local updated_status = lua_entity._areas_entities_updated and "true" or "false"
            local entity_name = lua_entity.name or "<unknown>"
            local pos = obj:get_pos()
            local pos_str = pos and minetest.pos_to_string(pos) or "<unknown pos>"

            -- Log the status, entity name, and position
            minetest.log("action", "[areas_entities] Lua Entity _areas_entities_updated = " .. updated_status ..
                         ", Entity Name: " .. entity_name .. ", Position: " .. pos_str)

            if not lua_entity._areas_entities_updated then
                update_entity_on_punch(lua_entity)
                lua_entity._areas_entities_updated = true
            end
        end
    end
end)



-- Update the on_punch for all registered entities
for _, entity in pairs(minetest.registered_entities) do
    update_entity_on_punch(entity)
end

minetest.register_on_mods_loaded(function()
    minetest.log("action", "[areas_entities] Server restarted, attempting to reset entity punch overrides.")
    for _, obj in pairs(minetest.luaentities) do
        if obj and obj.object and obj.object:get_luaentity() then
            local lua_entity = obj.object:get_luaentity()
            if lua_entity then
                lua_entity._areas_entities_updated = false
            end
        end
    end
end)
