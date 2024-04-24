-- Oragange Pill activation handle 
local pill_active = false

-- HUD vars
local hud_orange
local timer_hud

-- Checking if the environment is MCL2 and setting properties accordingly
local is_mcl2 = minetest.get_modpath("mcl_core") ~= nil

-- Buff BTC Souvenir / pickaxe mode initial values
local btc_souvenir_def = minetest.registered_items["btc_stuffs:btc_souvenir"]
local mcl_diggroups
local pickaxey
local initial_speed
local initial_level
local initial_uses
local tool_capabilities
local groupcaps
local cracky_caps
local initial_times
local initial_uses
local initial_maxlevel
if is_mcl2 then
    if btc_souvenir_def then 
        mcl_diggroups = btc_souvenir_def._mcl_diggroups
        if mcl_diggroups then
            pickaxey = mcl_diggroups.pickaxey
            if pickaxey then 
                initial_speed = pickaxey.speed
                initial_level = pickaxey.level
                initial_uses = pickaxey.uses
            end
        end
    end
else 
    if btc_souvenir_def then 
        tool_capabilities = btc_souvenir_def.tool_capabilities
        if tool_capabilities then 
            groupcaps = tool_capabilities.groupcaps
            if groupcaps then 
                cracky_caps = groupcaps.cracky
                if cracky_caps then 
                    initial_times = cracky_caps.times
                    initial_uses = cracky_caps.uses
                    initial_maxlevel = cracky_caps.maxlevel
                end
            end
        end
    end
end


-- Register Orange Pill 
minetest.register_craftitem(":btc_stuffs:orange_pill", {
    description = "Orange Pill",
    inventory_image = "orange_pill_inv.png",
    wield_image = "orange_pill_wield.png",
    wield_scale = {x = 0.8, y = 0.7, z = 0.8}, 

    -- Function called when the player consumes the pill
    on_use = function(itemstack, user, pointed_thing)
        --minetest.chat_send_player(user:get_player_name(), "You consumed a Orange Pill!")

        -- Getting player name
        local player_name = user:get_player_name()

        -- Setting activation duration
        local duration = 300  -- duration in seconds

        -- Invulnerability
        user:set_armor_groups({immortal = 1})

        -- Buff BTC Souvenir / pickaxe mode
        if not pill_active then 
            if btc_souvenir_def then 
                if is_mcl2 then 
                    if mcl_diggroups then 
                        if pickaxey then 
                            modified_speed = initial_speed * 2
                            modified_level = initial_level * 2
                            minetest.override_item("btc_stuffs:btc_souvenir", {
                                _mcl_diggroups = {
                                    pickaxey = {speed = modified_speed, level = modified_level, uses = initial_uses}
                                }
                            })
                        end
                    end
                else
                    if tool_capabilities then 
                        if groupcaps then 
                            if cracky_caps then 
                                local modified_times = {}
                                for i = 1, #initial_times do
                                    modified_times[i] = initial_times[i] / 2
                                end
                                modified_maxlevel = initial_maxlevel * 2

                                --minetest.log("error", minetest.serialize(minetest.registered_items["btc_stuffs:btc_souvenir"].tool_capabilities))
                                minetest.override_item("btc_stuffs:btc_souvenir", {
                                    tool_capabilities = {
                                        groupcaps = {
                                            cracky = {
                                                times = modified_times, 
                                                uses = initial_uses, 
                                                maxlevel = modified_maxlevel
                                            }
                                        }
                                    }
                                })
                                --minetest.log("error", minetest.serialize(minetest.registered_items["btc_stuffs:btc_souvenir"].tool_capabilities))
                            end
                        end
                    end
                end
            end
        end

        -- Screen color change to orange
        if hud_orange and pill_active then
            user:hud_remove(hud_orange) 
        end
        hud_orange = user:hud_add({
            hud_elem_type = "image",
            position = {x = 0, y = 0},
            scale = {x = -100, y = -100}, 
            text = "orange_overlay.png",  
            alignment = {x = 1, y = 1},
        })

        -- Timer on screen system
        if timer_hud and pill_active then
            user:hud_remove(timer_hud) 
        end
        timer_hud = user:hud_add({
            hud_elem_type = "text",
            position = {x = 0.98, y = 0.02},
            offset = {x = 0, y = 0},
            text = duration,
            alignment = {x = 0, y = 0},
            scale = {x = 100, y = 100},
            number = 0xFFFFFF,
        })

        timer_duration = duration

        function update_timer()
            timer_duration = timer_duration - 1
            local timer_minutes = math.floor(timer_duration / 60)
            local timer_seconds = timer_duration % 60
            local text = string.format("%02d:%02d", timer_minutes, timer_seconds)
            user:hud_change(timer_hud, "text", text)
            if timer_duration > 0 then
                minetest.after(1, update_timer)
                --minetest.log("error", tostring(timer_duration))
            end
        end

        if not pill_active then
            update_timer()
        end
        -- End timer on screen system


        -- Check nearby ores system
        --*using minetest.after to wait the pill_active be updated
        local check_interval = 5  -- in seconds
        local function check_ores(user)
            minetest.after(1, function() 
                if pill_active then
                    local pos = user:get_pos()
                    local max_distance = 9
                    local ores_to_detect
                    if is_mcl2 then
                        ores_to_detect = {"mcl_deepslate:deepslate_with_gold", "mcl_deepslate:deepslate_with_diamond"}
                    else
                        ores_to_detect = {"default:stone_with_gold", "default:stone_with_diamond"}
                    end
                    for _, ore_name in ipairs(ores_to_detect) do
                        local nearby_nodes = minetest.find_nodes_in_area(
                            vector.subtract(pos, max_distance),
                            vector.add(pos, max_distance),
                            {ore_name}
                        )
                        if #nearby_nodes > 0 then
                            minetest.chat_send_player(player_name, "You feel the presence of something valuable nearby!")
                            return
                        end
                    end
                end
            end)
        end
        local function check_and_update()
            check_ores(user)
            minetest.after(1, function()
                if pill_active then
                    minetest.after(check_interval, check_and_update)
                else
                    return
                end
            end)
        end
        if not pill_active then
            check_and_update()
        end
        -- End nearby ores system


        -- Removing one consumed item
        if not minetest.is_creative_enabled(player_name) then
            itemstack:take_item(1)
        end

        -- Deactivation effects system     
        function deactivate_pill()
            -- Removing attributes
            if hud_orange then
                user:hud_remove(hud_orange) 
            end
            if timer_hud then
                user:hud_remove(timer_hud) 
            end
            user:set_armor_groups({immortal = 0}) 
            if is_mcl2 then
                minetest.override_item("btc_stuffs:btc_souvenir", {
                    _mcl_diggroups = {
                        pickaxey = {speed = initial_speed, level = initial_level, uses = initial_uses}
                    }
                })
            else
                minetest.override_item("btc_stuffs:btc_souvenir", {
                    tool_capabilities = {
                        groupcaps = {
                            cracky = {
                                times = initial_times, 
                                uses = initial_uses, 
                                maxlevel = initial_maxlevel
                            }
                        }
                    }
                })
            end

            -- Setting activation handle to false
            pill_active = false

            minetest.chat_send_player(player_name, "The effect of the Orange Pill has passed.")

        end

        deactivate_pill_timer = duration

        function update_deactivate_pill_timer()
            deactivate_pill_timer = deactivate_pill_timer - 1
            if deactivate_pill_timer > 0 then
                minetest.after(1, update_deactivate_pill_timer)
            else 
                deactivate_pill()
            end
        end

        if not pill_active then
            update_deactivate_pill_timer()
        end
        -- End deactivation effects system     

        -- Setting activation handle to true 
        pill_active = true

        return itemstack
    end,
})


-- Define the recipe
local is_mcl2 = minetest.get_modpath("mcl_core") ~= nil
local baked_clay_mod_exists = minetest.get_modpath("bakedclay")
local mat_1 = is_mcl2 and "mcl_colorblocks:glazed_terracotta_orange" or (baked_clay_mod_exists and "bakedclay:terracotta_orange" or "dye:orange")
local mat_2 = "btc_stuffs:btc_souvenir"
local mat_3 = is_mcl2 and "mcl_buckets:bucket_lava" or "bucket:bucket_lava"

-- Register the recipe
minetest.register_craft({
    output = "btc_stuffs:orange_pill",
    recipe = {
        {mat_1},
        {mat_2},
        {mat_3},
    }
})


-- Registering an alias to simplify external usage
minetest.register_alias("btc_orange_pill", "btc_stuffs:orange_pill")

print("[MOD] Orange pill loaded")
