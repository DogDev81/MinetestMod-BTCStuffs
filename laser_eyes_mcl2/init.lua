if minetest.get_modpath("mcl_armor") then

	if mcl_armor then

		local armor_set = {
			name = "laser_eyes", 
			description = "Become a true bitcoiner and bitcoinalize all!", 
			durability = 1200, 
			enchantability = 10, 
			points = {head = 3, torso = 0, legs = 0, feet = 0}, 
			craft_material = "default:diamond", 
			textures = { 
				head = "laser_eyes_helmet.png", 
				-- torso = "mcl_armor_diamond_chestplate.png", 
				-- legs = "mcl_armor_diamond_leggings.png", 
				-- feet = "mcl_armor_diamond_boots.png" 
			},
		}

		mcl_armor.register_set(armor_set)

		minetest.unregister_item("laser_eyes:chestplate_laser_eyes")
		minetest.unregister_item("laser_eyes:leggings_laser_eyes")
		minetest.unregister_item("laser_eyes:boots_laser_eyes")

		local combinations = {
			{"btc_pizza", "btc_souvenir", "btc_orange_pill"},
			{"btc_pizza", "btc_orange_pill", "btc_souvenir"},
			{"btc_souvenir", "btc_pizza", "btc_orange_pill"},
			{"btc_souvenir", "btc_orange_pill", "btc_pizza"},
			{"btc_orange_pill", "btc_pizza", "btc_souvenir"},
			{"btc_orange_pill", "btc_souvenir", "btc_pizza"}
		}

		for _, combination in ipairs(combinations) do
			minetest.register_craft({
				output = "laser_eyes:helmet_laser_eyes",
				recipe = {combination}  
			})
		end

	end

end


-- Registering an alias to simplify external usage
minetest.register_alias("btc_laser_eyes", "laser_eyes:helmet_laser_eyes")

print("[MOD] Laser Eyes loaded")



















