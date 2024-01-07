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

-- Override entity punch function for existing and new entities
local function update_entity_on_punch(entity)
    local original_on_punch = entity.on_punch
    entity.on_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
        if hitter and hitter:is_player() then
            local pos = self.object:get_pos()
            local player_name = hitter:get_player_name()
            if minetest.is_protected(pos, player_name) == true then
                minetest.log("action", "[areas_entities] Preventing entity damage by non-owner " .. player_name)
                return
            end
        end
        if original_on_punch then
            original_on_punch(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
        end
    end
end

-- Globalstep function to monitor and update entity punches
minetest.register_globalstep(function(dtime)
    for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 50000)) do
        local lua_entity = obj:get_luaentity()
        if lua_entity and not lua_entity._areas_entities_updated then
            update_entity_on_punch(lua_entity)
            lua_entity._areas_entities_updated = true
        end
    end
end)

-- Update the on_punch for all registered entities
for _, entity in pairs(minetest.registered_entities) do
    update_entity_on_punch(entity)
end

-- Function called when all mods have finished loading
minetest.register_on_mods_loaded(function()
    minetest.log("action", "[areas_entities] Server restarted, resetting entity punch overrides.")
    for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 50000)) do
        local lua_entity = obj:get_luaentity()
        if lua_entity then
            lua_entity._areas_entities_updated = false
        end
    end
end)
