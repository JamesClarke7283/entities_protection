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

-- Modify damage handling for entities
local original_damage_function = mcl_damage.run_modifiers
mcl_damage.run_modifiers = function(obj, damage, reason)
    -- Check if the target is an entity and the damage source is a player
    if obj and obj:get_luaentity() and not obj:is_player() and reason.source and reason.source:is_player() then
        local pos = obj:get_pos()
        local player_name = reason.source:get_player_name()

        -- Check if the player is an owner of the area
        if not is_player_an_area_owner(player_name, pos) then
            return 0 -- Cancel damage if the player is not an area owner
        end
    end

    -- Call the original damage function for other cases
    return original_damage_function(obj, damage, reason)
end
