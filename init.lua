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

if minetest.get_modpath("mcl_damage") then
    minetest.log("notice", "[areas_entities] mcl_damage detected, modifying damage handling for entities")

    -- Modify damage handling for entities
    local original_damage_function = mcl_damage.run_modifiers
    mcl_damage.run_modifiers = function(obj, damage, reason)
        -- Check if the target is an entity (not a player) and if the source of damage is a player
        if obj and not obj:is_player() and reason.source and reason.source:is_player() then
            -- Get the position of the entity
            local pos = obj:get_pos()

            -- Get the name of the player causing the damage
            local player_name = reason.source:get_player_name()

            -- Check if the player is an owner of the area
            if not is_player_an_area_owner(player_name, pos) then
                -- Prevent the damage if the player is not an owner
                minetest.log("action", "[areas_entities] Preventing damage by non-owner " .. player_name)
                return 0
            end
        end

        -- Call the original damage function for other cases
        return original_damage_function(obj, damage, reason)
    end
end
