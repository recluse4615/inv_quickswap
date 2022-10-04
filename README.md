# inv_quickswap

this is a minetest mod that allows other mods to create "quick swap groupings"

## what is a grouping?

a grouping can be accessed by `SNEAK + AUX_1` (default: `SHIFT + E`) when holding an applicable node. the grouping will display all related nodes that **are in your inventory**

clicking an item in this formspec will swap the items!

## how can i extend this?
```lua
-- first param: the "first" node in the grouping
-- 2nd param: all other nodes in the same group
inv_quickswap.register_grouping("conveyors:conveyor", {
    "conveyors:retriever",
    "default:furnace"
})
```

**it's recommended to have up to 8 nodes in each grouping**, and each node can only be in **1 grouping**
