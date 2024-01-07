if minetest.get_modpath("mcl_damage") then
    minetest.log("notice", "[areas_entities] mcl_damage detected, adding custom damage handling for entities")

    local function custom_damage_handler(obj, damage, reason)
        -- Detailed logging for debugging
        local reason_type = reason and reason.type or "<nil>"
        local obj_name = obj and (obj:is_player() and obj:get_player_name() or (obj:get_luaentity() and obj:get_luaentity().name)) or "<nil>"
        local source = reason and reason.source
        local source_info = "<nil>"
        if source then
            if source:is_player() then
                source_info = "Player: " .. source:get_player_name()
            else
                local lua_entity = source:get_luaentity()
                source_info = lua_entity and ("Entity: " .. lua_entity.name) or "Non-player entity"
            end
        end

        -- Log the details
        minetest.log("action", "[areas_entities] Custom Damage Handler: Obj=" .. obj_name ..
                     ", Damage=" .. damage .. ", Reason=" .. reason_type .. ", Source=" .. source_info)

        -- Custom logic to handle player-caused damage
        if source and source:is_player() and not obj:is_player() then
            local pos = obj:get_pos()
            local player_name = source:get_player_name()
            local is_protected = minetest.is_protected(pos, player_name)

            if is_protected then
                minetest.log("action", "[areas_entities] Preventing damage by non-owner " .. player_name)
                return 0 -- Prevent damage
            end
        end

        return damage
    end

    mcl_damage.register_modifier(custom_damage_handler, 0)
end
