if mg_earth.gal then
	mg_earth.node_sound_defaults = gal.node_sound_defaults
	mg_earth.node_sound_stone_defaults = gal.node_sound_stone_defaults
	mg_earth.node_sound_wood_defaults = gal.node_sound_wood_defaults
elseif mg_earth.default then
	mg_earth.node_sound_defaults = default.node_sound_defaults
	mg_earth.node_sound_stone_defaults = default.node_sound_stone_defaults
	mg_earth.node_sound_wood_defaults = default.node_sound_wood_defaults
elseif mg_earth.mcl_sounds then
	mg_earth.node_sound_defaults = mcl_sounds.node_sound_defaults
	mg_earth.node_sound_stone_defaults = mcl_sounds.node_sound_stone_defaults
	mg_earth.node_sound_wood_defaults = mcl_sounds.node_sound_wood_defaults
end

minetest.register_node("mg_earth:junglewood", {
	description = "Mod jungle wood",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:bridgewood", {
	description = "Bridge wood",
	tiles = {"default_stone_block.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:stairn", { -- stair rising to the north
	description = "Jungle wood stair N",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:stairs", {
	description = "Jungle wood stair S",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, -0.5, 0.5, 0.5, 0},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:staire", {
	description = "Jungle wood stair E",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{0, 0, -0.5, 0.5, 0.5, 0.5},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:stairw", {
	description = "Jungle wood stair W",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, -0.5, 0, 0.5, 0.5},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:stairne", {
	description = "Jungle wood stair NE",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{0, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:stairnw", {
	description = "Jungle wood stair NW",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0, 0.5, 0.5},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:stairse", {
	description = "Jungle wood stair SE",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{0, 0, -0.5, 0.5, 0.5, 0},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:stairsw", {
	description = "Jungle wood stair SW",
	tiles = {"default_stone_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, -0.5, 0, 0.5, 0},
		},
	},
	sounds = mg_earth.node_sound_wood_defaults(),
})

minetest.register_node("mg_earth:road_black", {
	description = "Road Black",
	tiles = {"roadv7_road_black.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = mg_earth.node_sound_stone_defaults(),
})

minetest.register_node("mg_earth:road_black_slab", {
	description = "Road Black Slab",
	tiles = {"roadv7_road_black.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
	},
	groups = {cracky = 2},
	sounds = mg_earth.node_sound_stone_defaults(),
})

minetest.register_node("mg_earth:road_white", {
	description = "Road White",
	tiles = {"roadv7_road_white.png"},
	paramtype = "light",
	light_source = 12,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = mg_earth.node_sound_stone_defaults(),
})

minetest.register_node("mg_earth:concrete", {
	description = "Sandy Concrete",
	tiles = {"roadv7_concrete.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = mg_earth.node_sound_stone_defaults(),
})
