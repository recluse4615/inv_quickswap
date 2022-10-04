local nested_grouping_cache = {}

-- registers a new grouping
function inv_quickswap.register_grouping(base_node, grouped_nodes)
    table.insert(grouped_nodes, 1, base_node)
    if inv_quickswap.groupings[base_node] then
        -- todo
    else
        inv_quickswap.groupings[base_node] = grouped_nodes
    end
end

-- returns either a table of { k: node_name } OR nil
function inv_quickswap.get_grouping_for_node(node_name)
    -- short circuit if possible
    if inv_quickswap.groupings[node_name] then
        return inv_quickswap.groupings[node_name]
    end

    -- if cached, return
    if nested_grouping_cache[node_name] then
        return nested_grouping_cache[node_name]
    end

    for base_node, groupings in pairs(inv_quickswap.groupings) do
        for _, grouped_node in pairs(groupings) do
            if grouped_node == node_name then
                nested_grouping_cache[base_node] = groupings
                return groupings
            end
        end
    end

    return nil
end

-- formspec funcs
function inv_quickswap.get_formspec(player_name, inv)
    local fs = "formspec_version[6] size[3.7,3.7] no_prepend[]"

    local size = inv:get_size("main")
    local list = inv:get_list("main")
    for i = 1, #list do
        local stack = list[i]
        local x = (i - 1) % 3
        local y = math.floor((i - 1) / 3)
        if not stack:is_empty() then
            fs = fs .. "item_image_button[" .. (0.125 + x) .. "," .. (0.125 + y) .. ";1,1;" .. stack:get_name() .. ";_" .. i .. ";]"
        end
    end

    return fs
end

local function copy_table(t)
    if t == nil then return nil end
    
    local u = {}
    for k, v in pairs(t) do u[k] = v end
    return u
end

function inv_quickswap.show_formspec(player)
    local player_name = player:get_player_name()
    local wielded_item = player:get_wielded_item()

    local groupings = copy_table(inv_quickswap.get_grouping_for_node(wielded_item:get_name()))
    if groupings ~= nil then
        local player_inv = player:get_inventory()
        
        if not player_inv:is_empty("main") then

            local fs_inv = minetest.get_inventory({
                type = "detached",
                name = "inv_quickswap_" .. player_name
            })

            fs_inv:set_size("main", 9)
            fs_inv:set_stack("main", 1, wielded_item)

            local list = player_inv:get_list("main")
            local idx = 2
            for _, stack in pairs(list) do
                for node_ref, grouped_node in pairs(groupings) do
                    if grouped_node ~= nil and stack:get_name() == grouped_node and grouped_node ~= wielded_item:get_name() then
                        fs_inv:set_stack("main", idx, stack)
                        idx = idx + 1
                        groupings[node_ref] = nil
                        break
                    end
                end
            end
            minetest.show_formspec(player_name, "inv_quickswap:selector", inv_quickswap.get_formspec(player_name, fs_inv))
            return true
        end
    end

    return false
end

function inv_quickswap.close_formspec(player_name)
    minetest.close_formspec(player_name, "inv_quickswap:selector")

    -- clear inventory
    local inv = minetest.get_inventory({
        type = "detached",
        name = "inv_quickswap_" .. player_name
    })
    inv:set_list("main", nil)
end