local function remove_nearby_arrows(entity, radius)
    if not entity then
        return
    end

    local pos = entity:get_pos()
    local radius = radius or 5 -- default radius of 5 units

    -- Get all objects within the radius
    local objects = minetest.get_objects_inside_radius(pos, radius)
    for _, obj in ipairs(objects) do
        local luaentity = obj:get_luaentity()
        -- Check if the object is the specific arrow entity
        if luaentity and luaentity.name == "mcl_bows:arrow_entity" then
            obj:remove() -- Remove the arrow entity
        end
    end
end


-- Utility function to check if a table contains a specific value
local function table_contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end


-- Function to check if an entity type or specific entity should be excluded from protection
local function should_exclude_entity(entity)
    -- Read the settings
    local exclude_monsters = minetest.settings:get_bool("entities_protection.exclude_monsters", true)
    local excluded_entities_list = minetest.settings:get("entities_protection.excluded_entities") or ""
    local excluded_entities = {}
    for entity_instance in excluded_entities_list:gmatch("[^,]+") do
        table.insert(excluded_entities, entity_instance:trim())
    end

    -- Check if the entity type is 'monster' and should be excluded
    if exclude_monsters and entity.type == "monster" then
        return true
    end

    -- Check if the specific entity is in the excluded list
    if table_contains(excluded_entities, entity.name) then
        return true
    end

    return false
end


local function update_entity_on_punch(entity)
    local original_on_punch = entity.on_punch
    entity.on_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)

      -- Before checking for area protection, determine if the entity should be excluded
        if should_exclude_entity(self.object:get_luaentity()) then
            return original_on_punch(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
        end

        local pos = self.object:get_pos()

        -- Initialize variables
        local player_name, is_protected

        -- Check for attachments and children of the hitter
        if hitter then
            -- Check if the hitter has a "_shooter" property
            local shooter = hitter:get_luaentity() and hitter:get_luaentity()._shooter
            if shooter and shooter:is_player() then
                -- If the shooter is a player, use their name for protection checks
                player_name = shooter:get_player_name()
                is_protected = minetest.is_protected(pos, player_name)
                minetest.log("action", "[entities_protection] Shooter Detected: " .. player_name .. ". Is protected: " ..
                tostring(is_protected))
            elseif hitter:is_player() then
                -- If the hitter is a player, use their name for protection checks
                player_name = hitter:get_player_name()
                is_protected = minetest.is_protected(pos, player_name)
                minetest.log("action", "[entities_protection] Hitter is player: " .. player_name .. ". Is protected: "
                .. tostring(is_protected))
            end

            -- If the area is protected, prevent damage
            if is_protected then
                minetest.log("action", "[entities_protection] Preventing entity damage in protected area by "
                .. (player_name or "unknown source"))
                if minetest.get_modpath("mcl_hunger") and minetest.get_modpath("mcl_potions") and minetest.get_modpath("mcl_burning") then
                  remove_nearby_arrows(self.object)
                  --mcl_hunger.stop_poison(self) -- Stop poisoning the player
                  --._reset_player_effects(self) -- Remove all potion effects from the player
                  mcl_burning.extinguish(self.object) -- Extinguish the player if they are on fire
              end
                return true
            end
        end

        -- Call the original on_punch function if no protection logic was triggered
        if original_on_punch then
            return original_on_punch(self, hitter, time_from_last_punch, tool_capabilities, dir, damage)
        end
    end
end


-- Define the reset interval (in seconds)
local reset_interval = 60
local time_since_last_reset = 0

minetest.register_globalstep(function(dtime)
    -- Increment the timer
    time_since_last_reset = time_since_last_reset + dtime

    -- Check if the reset interval has been reached
    if time_since_last_reset >= reset_interval then
        -- Reset the timer
        time_since_last_reset = 0

        -- Reset _areas_entities_updated flag for entities around each player
        for _, player in ipairs(minetest.get_connected_players()) do
            local player_pos = player:get_pos()
            for _, obj in ipairs(minetest.get_objects_inside_radius(player_pos, 1000)) do
                local lua_entity = obj:get_luaentity()
                if lua_entity then
                    lua_entity._areas_entities_updated = false
                end
            end
        end
    end

    -- Regular update logic
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_pos = player:get_pos()
        for _, obj in ipairs(minetest.get_objects_inside_radius(player_pos, 1000)) do
            local lua_entity = obj:get_luaentity()
            if lua_entity then
                local updated_status = lua_entity._areas_entities_updated and "true" or "false"
                local entity_name = lua_entity.name or "<unknown>"
                local pos = obj:get_pos()
                local pos_str = pos and minetest.pos_to_string(pos) or "<unknown pos>"

                -- Log the status, entity name, and position
                --minetest.log("action", "[entities_protection] Lua Entity _areas_entities_updated = " .. updated_status ..
                --             ", Entity Name: " .. entity_name .. ", Position: " .. pos_str)

                -- Update the entity if it hasn't been updated yet
                if not lua_entity._areas_entities_updated then
                    update_entity_on_punch(lua_entity)
                    lua_entity._areas_entities_updated = true
                end
            end
        end
    end
end)





-- Update the on_punch for all registered entities
for _, entity in pairs(minetest.registered_entities) do
    update_entity_on_punch(entity)
end

minetest.register_on_mods_loaded(function()
    --minetest.log("action", "[entities_protection] Server restarted, attempting to reset entity punch overrides.")
    for _, obj in pairs(minetest.luaentities) do
        if obj and obj.object and obj.object:get_luaentity() then
            local lua_entity = obj.object:get_luaentity()
            if lua_entity then
                lua_entity._areas_entities_updated = false
            end
        end
    end
end)
