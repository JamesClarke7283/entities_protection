if minetest.get_modpath("mcl_damage") then
    minetest.log("notice", "[areas_entities] mcl_damage detected, adding custom damage handling for entities")

    -- Function to handle custom damage logic
    local function custom_damage_handler(obj, damage, reason)
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
        minetest.log("action", "[areas_entities] Reason Type: " .. reason_type ..
                    ", Source Name: " .. source_name .. ", Object Name: " .. obj_name)

        -- Custom logic to handle damage
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
                return 0 -- Prevent damage
            end
        end

        return damage -- Return the original damage if no conditions are met
    end

    -- Register the custom damage modifier
    mcl_damage.register_modifier(custom_damage_handler, 0)
end
