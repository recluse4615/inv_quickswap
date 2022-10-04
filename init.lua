inv_quickswap = {}
inv_quickswap.groupings = {}

local modpath = minetest.get_modpath("inv_quickswap")

dofile(modpath .. "/api.lua")

local function get_inventory_index(list, stack)
    for idx, i_stack in pairs(list) do
        if stack == i_stack then
            return idx
        end
    end
    return nil
end

local players = {}
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()

    minetest.create_detached_inventory("inv_quickswap_" .. player_name, {
        allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
            return 0
        end,
        allow_put = function(inv, listname, index, stack, player)
            return 0
        end,
        allow_take = function(inv, listname, index, stack, player)
            return 0
        end,
    }, player_name)
    
    players[player_name] = {
        hud = false
    }
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "inv_quickswap:selector" then
        return
    end

    local player_name = player:get_player_name()

    local wield_idx = -1
    local wield_stack = player:get_wielded_item()
    local inv = player:get_inventory():get_list("main")
    for i = 1, #inv do
        local stack = inv[i]
        if stack:get_name() == wield_stack:get_name() and stack:get_count() == wield_stack:get_count() then
            wield_idx = i
            break
        end
    end

    for i = 2, 9 do
        if fields["_" .. i] ~= nil then
            local fs_inv = minetest.get_inventory({
                type = "detached",
                name = "inv_quickswap_" .. player_name
            })
            local needle = fs_inv:get_stack("main", i)
            
            for idx, stack in pairs(player:get_inventory():get_list("main")) do
                if stack:get_name() == needle:get_name() and stack:get_count() == needle:get_count() then
                    player:get_inventory():set_stack("main", idx, wield_stack)
                    player:get_inventory():set_stack("main", wield_idx, stack)
                    break
                end
            end
        end
    end

    players[player_name].hud = false
    inv_quickswap.close_formspec(player_name)
end)

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()

    players[player_name] = nil
end)

minetest.register_globalstep(function(dtime)
    for player_name, player_info in pairs(players) do
        local player = minetest.get_player_by_name(player_name)
        if player then
            local ctrl = player:get_player_control()

            if ctrl.aux1 and ctrl.sneak then
                if players[player_name].hud == false then
                    
                    if inv_quickswap.show_formspec(player) == true then
                        players[player_name].hud = true
                    end
                else
                    -- players[player_name].hud = false
                    -- inv_quickswap.close_formspec(player_name)
                end
            end
        end
    end
end)