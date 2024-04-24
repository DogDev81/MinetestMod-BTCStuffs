-- Getting the texture size option
local souvenir_size = minetest.settings:get("souvenir_size") or "32px"
local inventory_image

if souvenir_size == "32px" then
    inventory_image = "btc_souvenir_32px.png"
elseif souvenir_size == "16px" then
    inventory_image = "btc_souvenir_16px.png"
else
    inventory_image = "btc_souvenir_64px.png"
end



local placed_entities = {}  -- Tabela para armazenar as lua_entities

-- Register "btc_souvenir"
minetest.register_tool(":btc_stuffs:btc_souvenir", {
    description = "BTC Souvenir",
    inventory_image = inventory_image,
    wield_scale = {x = 1.2, y = 1.2, z = 1},
    light_source = 3,
    tool_capabilities = {
        full_punch_interval = 0.7,
        max_drop_level=5,
        damage_groups = {fleshy=5},
    },
    sound = {breaks = "default_tool_breaks"},
    groups = {pickaxe = 1},
    
    -- Placing as Souvenir
    on_place = function(itemstack, placer, pointed_thing)
        -- Checking if the player clicked on a node
        if pointed_thing.type == "node" then
            local pos = minetest.find_node_near(pointed_thing.above, 1, {"air"}, true)
            if pos then

                -- Skipping if target is 'righclickable'
                local node_clicked = pointed_thing.under
                local node_data = minetest.get_node(node_clicked)
                local rightclick = minetest.registered_nodes[node_data.name].on_rightclick
                if rightclick then return itemstack end

                -- Checking if the player has permission to modify this node
                if minetest.is_protected(pos, placer:get_player_name()) then
                    minetest.record_protection_violation(pos, placer:get_player_name())
                    return
                end

                -- Placing the BTC Souvenir above the block
                local obj = minetest.add_item(pos, ItemStack("btc_stuffs:btc_souvenir"))

                -- Checking if the object was successfully created
                if obj then
                    local lua_entity = obj:get_luaentity()
                    if lua_entity then
                        -- Store wear on the LuaEntity
                        lua_entity.wear = itemstack:get_wear()

                            --trying to make the item do not despawns, not working
                            lua_entity.timeout = 999999
                            lua_entity.time_left = 999999
                            lua_entity.no_remove = true
                            local meta = minetest.get_meta(pos)
                            meta:set_int("lifetime", -1)

                        placed_entities[tostring(obj)] = lua_entity                        
                        --minetest.log("error", "Lua Entity added: " .. dump(placed_entities))
                        
                    end
                    -- Removing the BTC Souvenir from the player's inventory
                    itemstack:take_item()
                end
            end
            return itemstack
        end
    end,

})


-- Add an on_picked_up function to restore wear
minetest.register_on_item_pickup( 
  function(itemstack, player, pointed_thing, time_from_last_punch) 
    if ItemStack(itemstack):to_string() == "btc_stuffs:btc_souvenir" then 
        if pointed_thing.type == "object" then        
            local ref_str = tostring(pointed_thing.ref)
            local start_idx, end_idx = ref_str:find("userdata: ")
            if start_idx then
                local userdata_id = ref_str:sub(end_idx + 1)
                local userdata = "userdata: " .. tostring(userdata_id)
                if placed_entities[userdata] then
                    local wear = placed_entities[userdata].wear
                    --persisting wear
                    if wear then
                        itemstack:set_wear(wear)
                        --minetest.log("error", dump(placed_entities[userdata].wear))
                    end
                    
                    --cleaning entity
                    placed_entities[userdata] = nil
                    --minetest.log("error", "Lua Entity cleaned: " .. dump(placed_entities))
                end
            end
        end
    end
end)


-- Checking if the environment is MCL2 and setting properties accordingly
local is_mcl2 = minetest.get_modpath("mcl_core") ~= nil

if is_mcl2 then
    minetest.override_item("btc_stuffs:btc_souvenir", {
        _mcl_diggroups = {
            pickaxey = {speed = 7, level = 5, uses = 500}
        }
    })
else
    minetest.override_item("btc_stuffs:btc_souvenir", {
        tool_capabilities = {
            groupcaps = {
                cracky = {times={[1]=1.6, [2]=0.8, [3]=0.4}, uses=50, maxlevel=3}
            }
        }
    })
end


-- Register the recipe "btc_souvenir"
local mat_1, mat_2, mat_3, mat_4

if is_mcl2 then
    mat_1 = "mcl_core:iron_ingot"
    mat_2 = "mcl_core:gold_ingot"
    mat_3 = "mcl_core:diamond"
    mat_4 = "mcl_buckets:bucket_lava"
else
    if minetest.registered_items["default:steel_ingot"] then
        mat_1 = "default:steel_ingot"
    elseif minetest.registered_items["default:iron_ingot"] then
        mat_1 = "default:iron_ingot"
    end
    if minetest.registered_items["default:gold_ingot"] then
        mat_2 = "default:gold_ingot"
    end
    if minetest.registered_items["default:bronze_ingot"] then
        mat_3 = "default:bronze_ingot"
    elseif minetest.registered_items["default:diamond"] then
        mat_3 = "default:diamond"
    end
    mat_4 = "bucket:bucket_lava"
end

minetest.register_craft({
    output = is_mcl2 and "btc_stuffs:btc_souvenir" or ":btc_stuffs:btc_souvenir", 
    recipe = {
        {mat_1, mat_2, mat_1},
        {mat_2, mat_3, mat_2},
        {mat_4, mat_2, mat_4},
    }
})


-- Registering an alias to simplify external usage
minetest.register_alias("btc_souvenir", "btc_stuffs:btc_souvenir")

print("[MOD] BTC Souvenir loaded")
