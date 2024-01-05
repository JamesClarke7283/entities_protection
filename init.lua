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
-- Modify damage handling for entities
local original_damage_function = mcl_damage.run_modifiers
mcl_damage.run_modifiers = function(obj, damage, reason)
    minetest.log("error", "[areas_entities] Damage function called for "..obj:get_luaentity().name)
    -- Check if the target is an entity (not a player) and if the source of damage is a player
    if obj and obj:get_luaentity() and not obj:is_player() and reason.source and reason.source:is_player() then
        local pos = obj:get_pos()
        local player_name = reason.source:get_player_name()

        -- Debugging: Print a message to check if this part is being executed
        minetest.log("action", "[areas_entities] Checking area protection for entity at " .. minetest.pos_to_string(pos))

        -- Check if the player is an owner of the area
        if not is_player_an_area_owner(player_name, pos) then
            -- Debugging: Print a message when damage is prevented
            minetest.log("action", "[areas_entities] Preventing damage by non-owner " .. player_name)
            return 0 -- Cancel damage if the player is not an area owner
        end
    end

    -- Call the original damage function for other cases
    return original_damage_function(obj, damage, reason)
end
end