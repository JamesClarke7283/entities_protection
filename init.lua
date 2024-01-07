
if minetest.get_modpath("mcl_damage") then
    minetest.log("notice", "[areas_entities] mcl_damage detected, modifying damage handling for entities")

    -- Modify damage handling for entities
    local original_damage_function = mcl_damage.run_modifiers
    mcl_damage.run_modifiers = function(obj, damage, reason)

      -- Log the reason type and the object name
        local reason_type = reason and reason.type or "<nil>"
        local obj_name = obj and (obj:is_player() and obj:get_player_name() or (obj:get_luaentity() and obj:get_luaentity().name)) or "<nil>"

        -- Determine and log the source name
        local source_name = "<nil>"
        if reason and reason.source then
            if reason.source:is_player() then
                source_name = reason.source:get_player_name()
            elseif reason.source.get_luaentity then
                local lua_entity = reason.source:get_luaentity()
                source_name = lua_entity and lua_entity.name or "<non-player entity>"
            else
                source_name = "<unknown source>"
            end
        end
        minetest.log("action","Reason type:\t"..reason_type)
        minetest.log("action","Source Name:\t"..source_name)
        minetest.log("action","Reason type:\t"..obj_name)
        minetest.log("action", "[areas_entities] Damage Modifier Called - Reason Type: " .. reason_type ..
                    ", Source Name: " .. source_name .. ", Object Name: " .. obj_name)


        -- Check if the target is an entity (not a player) and if the source of damage is a player
        if obj and not obj:is_player() and reason.source and reason.source:is_player() then
            -- Get the position of the entity
            local pos = obj:get_pos()

            -- Get the name of the player causing the damage
            local player_name = reason.source:get_player_name()
            local is_protected = minetest.is_protected(pos, player_name)

            -- Check if the player is an owner of the area
            if is_protected then
                -- Prevent the damage if the player is not an owner
                minetest.log("action", "[areas_entities] Preventing damage by non-owner " .. player_name)
                return 0
            end
        end

        -- Call the original damage function for other cases
        return original_damage_function(obj, damage, reason)
    end
end
