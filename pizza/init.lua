-- check for available mods
local hmod = minetest.get_modpath("hunger")
local stmod = minetest.global_exists("stamina")
local defmod = minetest.get_modpath("default")
local mclhunger = minetest.get_modpath("mcl_hunger")
local screwdriver_exists = minetest.get_modpath("screwdriver") ~= nil


-- sound support
local pizza_sound = defmod and default.node_sound_dirt_defaults()

if minetest.get_modpath("mcl_sounds") then
	cake_sound = mcl_sounds.node_sound_dirt_defaults()
end


-- preparing dough and cheese
local recipe
if minetest.registered_items["farming:flour"] then
	recipe = {
		{"mobs:cheese", "mobs:cheese", "mobs:cheese" },
		{"farming:flour", "farming:flour", "farming:flour" }
	}
elseif minetest.registered_items["mcl_farming:wheat_item"] then
	recipe = {
		{"mobs:cheese", "mobs:cheese", "mobs:cheese" },
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item" }
	}
else 
	recipe = {
		{"mobs:cheese", "mobs:cheese", "mobs:cheese" },
	}
end

minetest.register_craft({
	output = "btc_pizza:dough_and_cheese",
	recipe = recipe
})


--cooking the pizza
minetest.register_craftitem("btc_pizza:dough_and_cheese", {
	description = "Dough and Cheese for Pizza",
	inventory_image = "dough_and_cheese_inv.png",
})

minetest.register_craft({
	type = "cooking",
	output = "btc_pizza:slice_0",
	recipe = "btc_pizza:dough_and_cheese",
	cooktime = 5,
})


-- eat pizza slice function
slice = {}

local function replace_pizza(node, puncher, pos)

	-- is this my pizza?
	-- if minetest.is_protected(pos, puncher:get_player_name()) then
	-- 	return
	-- end

	-- which size of pizza did we hit?
	local slice = node.name:sub(1,-3)
	local num = tonumber(node.name:sub(-1))

	-- eat slice or remove whole pizza
	if num == 3 then
		node.name = "air"
	elseif num < 3 then
		node.name = slice .. "_" .. (num + 1)
	end

	minetest.swap_node(pos, node)

	if num == 3 then
		minetest.check_for_falling(pos)
	end

	-- default eat sound
	local sound = "default_dig_crumbly"

	-- Blockmen's hud_hunger mod
	if hmod then

		local h = hunger.read(puncher)

		h = math.min(h + 6, 30)

		local ok = hunger.update_hunger(puncher, h)

		sound = "hunger_eat"

	-- Sofar's stamina mod
	elseif stmod then

		stamina.change(puncher, 6)

		sound = "stamina_eat"

	-- mineclone2 mcl_hunger mod
	elseif mclhunger then

		local h = mcl_hunger.get_hunger(puncher)

		h = math.min(h + 4, 20)

		mcl_hunger.set_hunger(puncher, h)

		sound = "mcl_hunger_bite"

	-- none of the above found? add to health instead
	else

		local h = puncher:get_hp()

		h = math.min(h + 6, 20)

		puncher:set_hp(h)
	end

	minetest.sound_play(sound, {pos = pos, gain = 0.7, max_hear_distance = 5}, true)

end


-- register pizza bits:
-- full pizza
local nodebox = 
minetest.register_node("btc_pizza:slice_0", {
	description = "Celebrating the Pizza Day!",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	sunlight_propagates = false,
	tiles = {
		"btc_pizza_top.png", "btc_pizza_bottom.png", "btc_pizza_side.png"
	},
	inventory_image = "btc_pizza_inv.png",
	wield_image = "btc_pizza_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5}
	},
	sounds = pizza_sound,

	on_rotate = screwdriver_exists and screwdriver.rotate_simple,

	on_punch = function(pos, node, puncher, pointed_thing)
		replace_pizza(node, puncher, pos)
	end
})

-- 3/4 pizza
minetest.register_node("btc_pizza:slice_1", {
	description = "3/4 of Pizza",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	tiles = {
		"btc_pizza_top.png", "btc_pizza_bottom.png", "btc_pizza_inside_side.png",
		"btc_pizza_side.png", "btc_pizza_side.png", "btc_pizza_side_inside.png"
	},
	groups = {not_in_creative_inventory = 1},
	drop = {},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0, -0.3, 0.5},
			{-0.5, -0.5, 0, 0.5, -0.3, 0.5}
		}
	},
	sounds = pizza_sound,

	on_rotate = screwdriver_exists and screwdriver.rotate_simple,

	on_punch = function(pos, node, puncher, pointed_thing)
		replace_pizza(node, puncher, pos)
	end
})

-- 1/2 pizza
minetest.register_node("btc_pizza:slice_2", {
	description = "Half of Pizza",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	tiles = {
		"btc_pizza_top.png", "btc_pizza_bottom.png", "btc_pizza_inside.png",
		"btc_pizza_side.png", "btc_pizza_side.png", "btc_pizza_side.png"
	},
	groups = {not_in_creative_inventory = 1},
	drop = {},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -.5, 0, -0.3, 0.5}
	},
	sounds = pizza_sound,

	on_rotate = screwdriver_exists and screwdriver.rotate_simple,

	on_punch = function(pos, node, puncher, pointed_thing)
		replace_pizza(node, puncher, pos)
	end
})

-- 1/4 pizza
minetest.register_node("btc_pizza:slice_3", {
	description = "Slice of Pizza",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	tiles = {
		"btc_pizza_top.png", "btc_pizza_bottom.png", "btc_pizza_inside.png",
		"btc_pizza_side.png", "btc_pizza_side.png", "btc_pizza_inside_inside.png"
	},
	groups = {not_in_creative_inventory = 1},
	drop = {},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.0, 0.0, -0.3, 0.5}
	},
	sounds = pizza_sound,

	on_rotate = screwdriver_exists and screwdriver.rotate_simple,

	on_punch = function(pos, node, puncher, pointed_thing)
		replace_pizza(node, puncher, pos)
	end
})


-- Registering an alias to simplify external usage
minetest.register_alias("btc_pizza", "btc_pizza:slice_0")


print("[MOD] BTC Pizza loaded")



