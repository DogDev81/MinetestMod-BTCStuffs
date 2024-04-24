if minetest.get_modpath("3d_armor") then

	-- Register the item
	armor:register_armor(":btc_stuffs:laser_eyes", {
		description = "Become a true bitcoiner and bitcoinalize all!",
		inventory_image = "btc_stuffs_laser_eyes_inv.png",
		groups = {armor_head=1, armor_heal=15, armor_use=400},
		armor_groups = {fleshy=20, slashy=5, piercy=5, blunty=5, firey=5, icey=5, electry=5, poisony=5, magicy=5},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
			--trying a glow or something...
			light_source = 10,
			paramtype = "light",
			--sunlight_propagates = true,
			--use_texture_alpha = "clip",

	})
	
	-- List of all possible combinations of the three items
	local combinations = {
		{"btc_pizza", "btc_souvenir", "btc_orange_pill"},
		{"btc_pizza", "btc_orange_pill", "btc_souvenir"},
		{"btc_souvenir", "btc_pizza", "btc_orange_pill"},
		{"btc_souvenir", "btc_orange_pill", "btc_pizza"},
		{"btc_orange_pill", "btc_pizza", "btc_souvenir"},
		{"btc_orange_pill", "btc_souvenir", "btc_pizza"}
	}

	-- Registering multiple recipes using each combination
	for _, combination in ipairs(combinations) do
		-- Registering a craft recipe for each combination
		minetest.register_craft({
			-- Defining the output item for the craft recipe
			output = "btc_stuffs:laser_eyes",
			-- Defining the crafting recipe using the current combination
			recipe = {combination}  -- Each combination fits within a single row
		})
	end

end


-- Registering an alias to simplify external usage
minetest.register_alias("btc_laser_eyes", "btc_stuffs:laser_eyes")


print("[MOD] Laser Eyes loaded")
