--Copyright 2021 ShadMOrdre
--License LGPLv2.1


mg_earth = {}
mg_earth.name = "mg_earth"
mg_earth.ver_max = 0
mg_earth.ver_min = 1
mg_earth.ver_rev = 0
mg_earth.ver_str = mg_earth.ver_max .. "." .. mg_earth.ver_min .. "." .. mg_earth.ver_rev
mg_earth.authorship = "ShadMOrdre."
mg_earth.license = "LGLv2.1"
mg_earth.copyright = "2021"
mg_earth.path_mod = minetest.get_modpath(minetest.get_current_modname())
mg_earth.path_world = minetest.get_worldpath()
mg_earth.path = mg_earth.path_mod


minetest.log("[MOD] test:  Loading...")
minetest.log("[MOD] mg_earth:  Version:" .. mg_earth.ver_str)
minetest.log("[MOD] mg_earth:  Legal Info: Copyright " .. mg_earth.copyright .. " " .. mg_earth.authorship .. "")
minetest.log("[MOD] mg_earth:  License: " .. mg_earth.license .. "")


local mg_points = dofile(mg_earth.path .. "/points.lua")
local mg_neighbors = {}

mg_earth.mg_points = mg_points

--dofile(mg_earth.path .. "/voxel.lua")


n_file = "mg_neighbors"

--options:   bterrain, bterrainalt, flat, islands, islandsalt, v6, v7, v7alt, v7voronoi, v7altvoronoi, voronoi, v7voronoicliffs, v7altvoronoicliffs, voronoicliffs
--local mg_map = "v7altvoronoicliffs"

--THE FOLLOWING SETTINGS CAN BE CHANGED

local mg_world_scale			= 1
local mg_water_level			= 1
local mg_base_height			= 300 * mg_world_scale
local max_beach					= 4 * mg_world_scale
local max_highland				= 200 * mg_world_scale
local max_mountain				= 300 * mg_world_scale
local mg_ecosystems				= false

mg_earth.default					= minetest.global_exists("default")
mg_earth.gal						= minetest.global_exists("gal")

if mg_earth.gal then
	mg_world_scale				= gal.mapgen.mg_world_scale
	mg_water_level				= gal.mapgen.water_level
	mg_base_height				= gal.mapgen.mg_base_height
	max_beach					= gal.mapgen.maxheight_beach
	max_highland				= gal.mapgen.maxheight_highland
	max_mountain				= gal.mapgen.maxheight_mountain
	mg_ecosystems				= true
end

local mg_rivers_enabled			= false
--local mg_valley_size = 100 * mg_world_scale
local mg_valley_size			= 50 * mg_world_scale
--local mg_valley_size = 10
local mg_river_size				= 20 * mg_world_scale
--local mg_river_size = 2
local mg_caves_enabled			= true
local dist_metric				= "cm"
local noise_blend				= 0.35
local use_heat_scalar			= true
local use_humid_scalar			= true

--END CONFIG



local abs   = math.abs
local max   = math.max
local min   = math.min
local floor = math.floor
local sin   = math.sin
local cos	= math.cos
local tan	= math.tan
local atan	= math.atan
local atan2	= math.atan2
local pi	= math.pi
local rad	= math.rad

local v_cscale = 0.05
local v_pscale = 0.1
local v_mscale = 0.125

mg_earth.c_air					= minetest.get_content_id("air")
mg_earth.c_ignore				= minetest.get_content_id("ignore")

if mg_earth.default then
	mg_earth.c_top					= minetest.get_content_id("default:dirt_with_grass")
	mg_earth.c_filler				= minetest.get_content_id("default:dirt")
	mg_earth.c_stone				= minetest.get_content_id("default:stone")
	mg_earth.c_water				= minetest.get_content_id("default:water_source")
	mg_earth.c_river				= minetest.get_content_id("default:river_water_source")
	mg_earth.c_gravel				= minetest.get_content_id("default:gravel")

	mg_earth.c_lava					= minetest.get_content_id("default:lava_source")
	mg_earth.c_ice					= minetest.get_content_id("default:ice")
	mg_earth.c_mud					= minetest.get_content_id("default:clay")

	mg_earth.c_cobble				= minetest.get_content_id("default:cobble")
	mg_earth.c_mossy				= minetest.get_content_id("default:mossycobble")
	mg_earth.c_block				= minetest.get_content_id("default:stone_block")
	mg_earth.c_brick				= minetest.get_content_id("default:stonebrick")
	mg_earth.c_sand					= minetest.get_content_id("default:sand")
	mg_earth.c_dirt					= minetest.get_content_id("default:dirt")
	mg_earth.c_dirtdry				= minetest.get_content_id("default:dry_dirt")
	mg_earth.c_dirtgrass			= minetest.get_content_id("default:dirt_with_grass")
	mg_earth.c_dirtdrygrass			= minetest.get_content_id("default:dirt_with_dry_grass")
	mg_earth.c_drydirtdrygrass		= minetest.get_content_id("default:dry_dirt_with_dry_grass")
	mg_earth.c_dirtsnow				= minetest.get_content_id("default:dirt_with_snow")
	mg_earth.c_dirtperm				= minetest.get_content_id("default:permafrost")

	mg_earth.c_coniferous			= minetest.get_content_id("default:dirt_with_coniferous_litter")
	mg_earth.c_rainforest			= minetest.get_content_id("default:dirt_with_rainforest_litter")
	mg_earth.c_desertsandstone		= minetest.get_content_id("default:desert_sandstone")
	mg_earth.c_desertsand			= minetest.get_content_id("default:desert_sand")
	mg_earth.c_desertstone			= minetest.get_content_id("default:desert_stone")
	mg_earth.c_sandstone			= minetest.get_content_id("default:sandstone")
	mg_earth.c_silversandstone		= minetest.get_content_id("default:silver_sandstone")
	mg_earth.c_silversand			= minetest.get_content_id("default:silver_sand")
end
if mg_earth.gal then
	mg_earth.c_top					= minetest.get_content_id("gal:dirt_with_grass")
	mg_earth.c_filler				= minetest.get_content_id("gal:dirt")
	mg_earth.c_stone				= minetest.get_content_id("gal:stone")
	mg_earth.c_water				= minetest.get_content_id("gal:liquid_water_source")
	mg_earth.c_river				= minetest.get_content_id("gal:liquid_water_river_source")
	mg_earth.c_gravel				= minetest.get_content_id("gal:stone_gravel")

	mg_earth.c_lava					= minetest.get_content_id("gal:liquid_lava_source")
	mg_earth.c_ice					= minetest.get_content_id("gal:ice")
	mg_earth.c_mud					= minetest.get_content_id("gal:dirt_clay_white")

	mg_earth.c_cobble				= minetest.get_content_id("gal:stone_cobble")
	mg_earth.c_mossy				= minetest.get_content_id("gal:stone_cobble_mossy")
	mg_earth.c_block				= minetest.get_content_id("gal:stone_block")
	mg_earth.c_brick				= minetest.get_content_id("gal:stone_brick")
	mg_earth.c_sand					= minetest.get_content_id("gal:sand")
	mg_earth.c_dirt					= minetest.get_content_id("gal:dirt")
	mg_earth.c_dirtdry				= minetest.get_content_id("gal:dirt_dry")
	mg_earth.c_dirtgrass			= minetest.get_content_id("gal:dirt_with_grass")
	mg_earth.c_dirtdrygrass			= minetest.get_content_id("gal:dirt_with_grass_dry")
	mg_earth.c_drydirtdrygrass		= minetest.get_content_id("gal:dirt_dry_with_grass_dry")
	mg_earth.c_dirtsnow				= minetest.get_content_id("gal:dirt_with_snow")
	mg_earth.c_dirtperm				= minetest.get_content_id("gal:dirt_permafrost")
	
	mg_earth.c_black				= minetest.get_content_id("gal:dirt_black")
	mg_earth.c_black_lawn			= minetest.get_content_id("gal:dirt_black_with_grass")
	mg_earth.c_brown				= minetest.get_content_id("gal:dirt_brown")
	mg_earth.c_brown_lawn			= minetest.get_content_id("gal:dirt_brown_with_grass")
	mg_earth.c_clayey				= minetest.get_content_id("gal:dirt_clayey")
	mg_earth.c_clayey_lawn			= minetest.get_content_id("gal:dirt_clayey_with_grass")
	mg_earth.c_dry					= minetest.get_content_id("gal:dirt_dry")
	mg_earth.c_dry_lawn				= minetest.get_content_id("gal:dirt_dry_with_grass_dry")
	mg_earth.c_sandy				= minetest.get_content_id("gal:dirt_sandy")
	mg_earth.c_sandy_lawn			= minetest.get_content_id("gal:dirt_sandy_with_grass")
	mg_earth.c_silty				= minetest.get_content_id("gal:dirt_silty")
	mg_earth.c_silty_lawn			= minetest.get_content_id("gal:dirt_silty_with_grass")
	mg_earth.c_clay					= minetest.get_content_id("gal:dirt_clay_red")
	mg_earth.c_dried				= minetest.get_content_id("gal:dirt_cracked")
	mg_earth.c_peat					= minetest.get_content_id("gal:dirt_peat")
	mg_earth.c_silt					= minetest.get_content_id("gal:dirt_silt_01")

	mg_earth.c_coniferous			= minetest.get_content_id("gal:dirt_with_litter_coniferous")
	mg_earth.c_rainforest			= minetest.get_content_id("gal:dirt_with_litter_rainforest")
	mg_earth.c_desertsandstone		= minetest.get_content_id("gal:stone_sandstone_desert")
	mg_earth.c_desertsand			= minetest.get_content_id("gal:sand_desert")
	mg_earth.c_desertstone			= minetest.get_content_id("gal:stone_desert")
	mg_earth.c_sandstone			= minetest.get_content_id("gal:stone_sandstone")
	mg_earth.c_silversandstone		= minetest.get_content_id("gal:stone_sandstone_silver")
	mg_earth.c_silversand			= minetest.get_content_id("gal:sand_silver")
end


-- -- Cave Parameters
--local YMIN = -33000 -- Cave realm limits
--local YMIN = -1024 -- Cave realm limits
local YMIN = -31000 -- Cave realm limits
--local YMAX = -256
--local YMAX = 256
--local YMAX = mg_base_height * 0.5
local YMAX = mg_base_height
--local TCAVE = 0.6		-- Cave threshold: 1 = small rare caves,
--local TCAVE1 = 8.75
local TCAVE1 = 15
--local TCAVE2 = 10		-- 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume.
local TCAVE2 = 20		-- 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume.
--local BLEND = 128		-- Cave blend distance near YMIN, YMAX
local BLEND = mg_base_height * 0.25

-- -- Stuff
local yblmin = YMIN + BLEND * 1.5
local yblmax = YMAX - BLEND * 1.5

mg_earth.heightmap = {}
mg_earth.biomemap = {}
mg_earth.biome_info = {}
mg_earth.eco_fill = {}
mg_earth.eco_top = {}
mg_earth.eco_map = {}
mg_earth.cliffmap = {}
mg_earth.valleymap = {}
mg_earth.riverpath = {}
mg_earth.rivermap = {}
mg_earth.hh_mod = {}
mg_earth.cellmap = {}

mg_earth.center_of_chunk = nil
mg_earth.chunk_points = nil
mg_earth.chunk_terrain = nil
mg_earth.chunk_mean_altitude = nil
mg_earth.chunk_min_altitude = nil
mg_earth.chunk_max_altitude = nil

mg_earth.chunk_terrain = {
	SW	= {x=nil,						y=nil,							z=nil},
	W	= {x=nil,						y=nil,							z=nil},
	NW	= {x=nil,						y=nil,							z=nil},
	S	= {x=nil,						y=nil,							z=nil},
	C	= {x=nil,						y=nil,							z=nil},
	N	= {x=nil,						y=nil,							z=nil},
	SE	= {x=nil,						y=nil,							z=nil},
	E	= {x=nil,						y=nil,							z=nil},
	NE	= {x=nil,						y=nil,							z=nil},
}

mg_earth.player_spawn_point = {x=-5,y=0,z=-5}
mg_earth.origin_y_val = {x=0,y=0,z=0}

local nobj_cave1 = nil
local nbuf_cave1 = {}
local nobj_cave2 = nil
local nbuf_cave2 = {}

local nobj_heatmap = nil
local nbuf_heatmap = {}
local nobj_heatblend = nil
local nbuf_heatblend = {}
local nobj_humiditymap = nil
local nbuf_humiditymap = {}
local nobj_humidityblend = nil
local nbuf_humidityblend = {}

local mg_alt_scale_scale = 1
local mg_base_scale_scale = 1
local mg_noise_spread = (600 * mg_alt_scale_scale) * mg_world_scale
local mg_noise_scale = 25
local mg_alt_noise_scale = mg_noise_scale * mg_world_scale
local mg_base_noise_scale = ((mg_noise_scale * 2.8) * mg_base_scale_scale) * mg_world_scale
local mg_noise_offset = -4 * mg_world_scale
local mg_noise_octaves = 7
local mg_noise_persist = 0.4
local mg_noise_lacunarity = 2.15
-- local mg_noise_octaves = 5
-- local mg_noise_persist = 0.5
-- local mg_noise_lacunarity = 2

local mg_cliff_noise_spread = 180 * mg_world_scale
--local mg_cliff_noise_spread = 180

--local mg_height_noise_spread = 1000 * mg_world_scale
local mg_height_noise_spread = 500 * mg_world_scale
local mg_persist_noise_spread = 2000 * mg_world_scale

local mg_noise_heathumid_spread = 1000 * mg_world_scale
local mg_noise_heat_offset = 50
local mg_noise_heat_scale = 50

if use_heat_scalar == true then
	mg_noise_heat_offset = 0
	mg_noise_heat_scale = 12.5
end

local mg_noise_humid_offset = 50
local mg_noise_humid_scale = 50

-- local black_threshold = 1
-- local brown_threshold = 1
-- local clay_threshold = 1
-- local dry_threshold = 1
-- local sand_threshold = 0.75
-- local silt_threshold = 1
-- local dirt_threshold = 0.5
local eco_threshold = 1
local dirt_threshold = 0.5

--  : Black dirt noise						2D
-- local np_black = {offset = 0, scale = 1, seed = 4767, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
--  : Brown dirt noise						2D
-- local np_brown = {offset = 0, scale = 1, seed = 3497, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
--  : Clayey dirt noise						2D
-- local np_clay = {offset = 0, scale = 1, seed = 2835, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
--  : Dry dirt noise						2D
-- local np_dry = {offset = 0, scale = 1, seed = 8321, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
--  : Sandy dirt noise						2D
-- local np_sand = {offset = 0, scale = 1, seed = 6940, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
--  : Silty dirt noise						2D
-- local np_silt = {offset = 0, scale = 1, seed = 6674, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco1 = {offset = 0, scale = 1, seed = 4767, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco2 = {offset = 0, scale = 1, seed = 3497, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco3 = {offset = 0, scale = 1, seed = 2835, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco4 = {offset = 0, scale = 1, seed = 8321, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco5 = {offset = 0, scale = 1, seed = 6940, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco6 = {offset = 0, scale = 1, seed = 6674, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco7 = {offset = 0, scale = 1, seed = 5423, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}
local np_eco8 = {offset = 0, scale = 1, seed = 9264, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}

local function get_dirt(z,x)

	local n1 = minetest.get_perlin(np_eco1):get_2d({x=x,y=z})
	local n2 = minetest.get_perlin(np_eco2):get_2d({x=x,y=z})
	local n3 = minetest.get_perlin(np_eco3):get_2d({x=x,y=z})
	local n4 = minetest.get_perlin(np_eco4):get_2d({x=x,y=z})
	local n5 = minetest.get_perlin(np_eco5):get_2d({x=x,y=z})
	local n6 = minetest.get_perlin(np_eco6):get_2d({x=x,y=z})
	local n7 = minetest.get_perlin(np_eco7):get_2d({x=x,y=z})
	local n8 = minetest.get_perlin(np_eco8):get_2d({x=x,y=z})

	-- local dirt = mg_earth.c_dirt
	-- local lawn = mg_earth.c_dirtgrass
	local eco = "n0"
	
	local bmax = max(n1, n2, n3, n4, n5, n6, n7, n8)
	if bmax > dirt_threshold then
		if n1 == bmax then
			if n1 > eco_threshold then
				eco = "n9"
			else
				eco = "n1"
			end
		elseif n2 == bmax then
			if n2 > eco_threshold then
				eco = "n10"
			else
				eco = "n2"
			end
		elseif n3 == bmax then
			if n3 > eco_threshold then
				eco = "n11"
			else
				eco = "n3"
			end
		elseif n4 == bmax then
			if n4 > eco_threshold then
				eco = "n12"
			else
				eco = "n4"
			end
		elseif n5 == bmax then
			if n5 > eco_threshold then
				eco = "n13"
			else
				eco = "n5"
			end
		elseif n6 == bmax then
			if n6 > eco_threshold then
				eco = "n14"
			else
				eco = "n6"
			end
		elseif n7 == bmax then
			if n7 > eco_threshold then
				eco = "n15"
			else
				eco = "n7"
			end
		elseif n8 == bmax then
			if n8 > eco_threshold then
				eco = "n16"
			else
				eco = "n8"
			end
		end
	end
	if not eco or eco == "" then
		eco = "n0"
	end
	
	--return dirt, lawn
	return eco

end

local np_2d = {
	offset = mg_noise_offset,
	scale = mg_alt_noise_scale,
	seed = 5934,
	spread = {x = mg_noise_spread, y = mg_noise_spread, z = mg_noise_spread},
	octaves = mg_noise_octaves,
	persist = mg_noise_persist,
	lacunarity = mg_noise_lacunarity,
	--flags = "defaults"
}
local np_base = {
	offset = mg_noise_offset * mg_base_scale_scale,
	scale = mg_base_noise_scale,
	--seed = 82341,
	seed = 5934,
	spread = {x = mg_noise_spread, y = mg_noise_spread, z = mg_noise_spread},
	octaves = mg_noise_octaves,
	persist = mg_noise_persist,
	lacunarity = mg_noise_lacunarity,
	flags = "defaults"
}
local np_height = {
	flags = "defaults",
	lacunarity = mg_noise_lacunarity,
	--offset = 0.25,
	offset = 0.5,
	scale = 1,
	spread = {x = mg_height_noise_spread, y = mg_height_noise_spread, z = mg_height_noise_spread},
	seed = 4213,
	octaves = mg_noise_octaves,
	persist = mg_noise_persist,
}
local np_persist = {
	flags = "defaults",
	lacunarity = mg_noise_lacunarity,
	offset = 0.6,
	scale = 0.1,
	spread = {x = mg_persist_noise_spread, y = mg_persist_noise_spread, z = mg_persist_noise_spread},
	seed = 539,
	octaves = 3,
	persist = 0.6,
}

local np_terrain_base = {
	flags = "defaults",
	lacunarity = 2,
	offset = -4 * mg_world_scale,
	scale = 20 * mg_world_scale,
	spread = {x = (250 * mg_world_scale), y = (250 * mg_world_scale), z = (250 * mg_world_scale)},
	seed = 82341,
	octaves = 5,
	persist = 0.6,
}
local np_terrain_higher = {
	flags = "defaults",
	lacunarity = 2,
	offset = 20 * mg_world_scale,
	scale = 16 * mg_world_scale,
	spread = {x = (500 * mg_world_scale), y = (500 * mg_world_scale), z = (500 * mg_world_scale)},
	seed = 85039,
	octaves = 5,
	persist = 0.6,
}
local np_steepness = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0.85 * mg_world_scale,
	scale = 0.5 * mg_world_scale,
	spread = {x = (125 * mg_world_scale), y = (125 * mg_world_scale), z = (125 * mg_world_scale)},
	seed = -932,
	octaves = 5,
	persist = 0.7,
}
local np_height_select = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0 * mg_world_scale,
	scale = 1 * mg_world_scale,
	spread = {x = (250 * mg_world_scale), y = (250 * mg_world_scale), z = (250 * mg_world_scale)},
	seed = 4213,
	octaves = 5,
	persist = 0.69,
}

-- 3D noise for caves
local np_cave1 = {
	-- offset = 0,
	-- scale = 12,
	-- --scale = 1,
	-- spread = {x = 30, y = 10, z = 30}, -- squashed 3:1
	-- seed = 52534,
	-- --octaves = 3,
	-- octaves = 3,
	-- --persist = 0.5,
	-- persist = 0.5,
	-- --lacunarity = 2.0,
	-- lacunarity = 2.11,
	lacunarity = 2,
	persistence = 0.5,
	scale = 12,
	offset = 0,
	flags = "defaults",
	spread = {x = 61, y = 61, z = 61},
	seed = 52534,
	octaves = 3,
}
local np_cave2 = {
	-- offset = 0,
	-- scale = 12,
	-- spread = {x = 30, y = 10, z = 30}, -- squashed 3:1
	-- seed = 10325,
	-- octaves = 3,
	-- persist = 0.5,
	-- lacunarity = 2.11,
	lacunarity = 2,
	persistence = 0.5,
	scale = 12,
	offset = 0,
	flags = "defaults",
	spread = {x = 67, y = 67, z = 67},
	seed = 10325,
	octaves = 3,
}
local np_cliffs = {
	offset = 0,					
	scale = 0.72,
	--spread = {x = mg_cliff_noise_spread, y = mg_cliff_noise_spread, z = mg_cliff_noise_spread},
	spread = {x = mg_cliff_noise_spread, y = mg_cliff_noise_spread, z = mg_cliff_noise_spread},
	--seed = 78901,
	seed = 82735,
	octaves = 5,
	persist = 0.5,
	lacunarity = 2.19,
}

local np_heat = {
	flags = "defaults",
	lacunarity = 2,
	offset = mg_noise_heat_offset,
	scale = mg_noise_heat_scale,
	--spread = {x = 1000, y = 1000, z = 1000},
	spread = {x = mg_noise_heathumid_spread, y = mg_noise_heathumid_spread, z = mg_noise_heathumid_spread},
	seed = 5349,
	octaves = 3,
	persist = 0.5,
}
local np_heat_blend = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0,
	scale = 1.5,
	spread = {x = 8, y = 8, z = 8},
	seed = 13,
	octaves = 2,
	persist = 1,
}
local np_humid = {
	flags = "defaults",
	lacunarity = 2,
	offset = mg_noise_humid_offset,
	scale = mg_noise_humid_scale,
	--spread = {x = 1000, y = 1000, z = 1000},
	spread = {x = mg_noise_heathumid_spread, y = mg_noise_heathumid_spread, z = mg_noise_heathumid_spread},
	seed = 842,
	octaves = 3,
	persist = 0.5,
}
local np_humid_blend = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0,
	scale = 1.5,
	spread = {x = 8, y = 8, z = 8},
	seed = 90003,
	octaves = 2,
	persist = 1,
}

local cliffs_thresh = floor((np_2d.scale) * 0.5)

local function rangelim(v, min, max)
	if v < min then return min end
	if v > max then return max end
	return v
end

local function max_height(noiseprm)
	local height = 0
	local scale = noiseprm.scale
	for i=1,noiseprm.octaves do
		height=height + scale
		scale = scale * noiseprm.persist
	end	
	return height+noiseprm.offset
end

local function min_height(noiseprm)
	local height = 0
	local scale = noiseprm.scale
	for i=1,noiseprm.octaves do
		height=height - scale
		scale = scale * noiseprm.persist
	end	
	return height+noiseprm.offset
end

local v7_min_height = min_height(np_base)
local v7_max_height = max_height(np_base)
local v7_alt_max_height = max_height(np_2d)

local function get_direction_to_pos(a,b)
	local t_compass
	local t_dir = {x = 0, z = 0}

	if a.z < b.z then
		t_dir.z = 1
		t_compass = "N"
	elseif a.z > b.z then
		t_dir.z = -1
		t_compass = "S"
	else
		t_dir.z = 0
		t_compass = ""
	end
	if a.x < b.x then
		t_dir.x = 1
		t_compass = t_compass .. "E"
	elseif a.x > b.x then
		t_dir.x = -1
		t_compass = t_compass .. "W"
	else
		t_dir.x = 0
		t_compass = t_compass .. ""
	end
	return t_dir, t_compass
end

local function get_dist(a,b,d_type)
	local dist
	if d_type then
		if d_type == "c" then
			dist = (max(abs(a), abs(b)))
		elseif d_type == "e" then
			dist = ((abs(a) * abs(a)) + (abs(b) * abs(b)))^0.5
		elseif d_type == "m" then
			dist = (abs(a) + abs(b))
		elseif d_type == "cm" then
			dist = (max(abs(a), abs(b)) + (abs(a) + abs(b))) * 0.5
		end
	end
	return dist
end

local function get_dist2line(a,b,p)

	local run = a.x - b.x
	local rise = a.z - b.z
	local ln_length = (((run * run) + (rise * rise))^0.5)

	return max(1, (abs((run * (a.z - p.z)) - ((a.x - p.x) * rise)) / ln_length))

end

local function get_dist2endline_inverse(a,b,p)

	local run = a.x-b.x
	local rise = a.z-b.z
	local c = {
		x = b.x - rise,
		z = b.z + run
	}
	local d = {
		x = b.x + rise,
		z = b.z - run
	}
	local lx = c.x - d.x
	local lz = c.z - d.z

	return max(1, (abs((lx * (c.z - p.z)) - ((c.x - p.x) * lz))) / (((lx * lx) + (lz * lz))^0.5))

end

local function get_midpoint(a,b)						--get_midpoint(a,b)
	return ((a.x+b.x) * 0.5), ((a.z+b.z) * 0.5)			--returns the midpoint between two points
end

local function get_slope(a,b)
	local run = a.x-b.x
	local rise = a.z-b.z
	return (rise/run), rise, run
end
	
local function get_slope_inverse(a,b)
	local run = a.x-b.x
	local rise = a.z-b.z
	return (run/rise), run, rise
end

local function update_biomes()

	local t_b = true
	if t_b then

		for name, desc in pairs(minetest.registered_biomes) do
	
			if desc then
	
				mg_earth.biome_info[desc.name] = {}
	
				mg_earth.biome_info[desc.name].b_name = desc.name
				mg_earth.biome_info[desc.name].b_cid = minetest.get_biome_id(name)
	
				mg_earth.biome_info[desc.name].b_top = mg_earth.c_top
				mg_earth.biome_info[desc.name].b_top_depth = 1
				mg_earth.biome_info[desc.name].b_filler = mg_earth.c_filler
				mg_earth.biome_info[desc.name].b_filler_depth = 4
				mg_earth.biome_info[desc.name].b_stone = mg_earth.c_stone
				mg_earth.biome_info[desc.name].b_water_top = mg_earth.c_water
				mg_earth.biome_info[desc.name].b_water_top_depth = 1
				mg_earth.biome_info[desc.name].b_water = mg_earth.c_water
				mg_earth.biome_info[desc.name].b_river = mg_earth.c_river
				mg_earth.biome_info[desc.name].b_riverbed = mg_earth.c_gravel
				mg_earth.biome_info[desc.name].b_riverbed_depth = 2
				mg_earth.biome_info[desc.name].b_cave_liquid = mg_earth.c_lava
				mg_earth.biome_info[desc.name].b_dungeon = mg_earth.c_brick
				mg_earth.biome_info[desc.name].b_dungeon_alt = mg_earth.c_mossy
				mg_earth.biome_info[desc.name].b_dungeon_stair = mg_earth.c_block
				mg_earth.biome_info[desc.name].b_node_dust = mg_earth.c_air
				mg_earth.biome_info[desc.name].vertical_blend = 0
				mg_earth.biome_info[desc.name].min_pos = {x=-31000, y=-31000, z=-31000}
				mg_earth.biome_info[desc.name].max_pos = {x=31000, y=31000, z=31000}
				mg_earth.biome_info[desc.name].b_miny = -31000
				mg_earth.biome_info[desc.name].b_maxy = 31000
				mg_earth.biome_info[desc.name].b_heat = 50
				mg_earth.biome_info[desc.name].b_humid = 50
			
	
				if desc.node_top and desc.node_top ~= "" then
					mg_earth.biome_info[desc.name].b_top = minetest.get_content_id(desc.node_top) or c_dirtgrass
				end
	
				if desc.depth_top and desc.depth_top ~= "" then
					mg_earth.biome_info[desc.name].b_top_depth = desc.depth_top or 1
				end
	
				if desc.node_filler and desc.node_filler ~= "" then
					mg_earth.biome_info[desc.name].b_filler = minetest.get_content_id(desc.node_filler) or c_dirt
				end
	
				if desc.depth_filler and desc.depth_filler ~= "" then
					mg_earth.biome_info[desc.name].b_filler_depth = desc.depth_filler or 4
				end
	
				if desc.node_stone and desc.node_stone ~= "" then
					mg_earth.biome_info[desc.name].b_stone = minetest.get_content_id(desc.node_stone) or c_stone
				end
	
				if desc.node_water_top and desc.node_water_top ~= "" then
					mg_earth.biome_info[desc.name].b_water_top = minetest.get_content_id(desc.node_water_top) or c_water
				end
	
				if desc.depth_water_top and desc.depth_water_top ~= "" then
					mg_earth.biome_info[desc.name].b_water_top_depth = desc.depth_water_top or 1
				end
	
				if desc.node_water and desc.node_water ~= "" then
					mg_earth.biome_info[desc.name].b_water = minetest.get_content_id(desc.node_water) or c_water
				end
				if desc.node_river_water and desc.node_river_water ~= "" then
					mg_earth.biome_info[desc.name].b_river = minetest.get_content_id(desc.node_river_water) or c_river
				end
	

				if desc.node_riverbed and desc.node_riverbed ~= "" then
					mg_earth.biome_info[desc.name].b_riverbed = minetest.get_content_id(desc.node_riverbed)
				end
	
				if desc.depth_riverbed and desc.depth_riverbed ~= "" then
					mg_earth.biome_info[desc.name].b_riverbed_depth = desc.depth_riverbed or 2
				end
--[[
				if desc.node_cave_liquid and desc.node_cave_liquid ~= "" then
					mg_earth.biome_info[desc.name].b_cave_liquid = minetest.get_content_id(desc.node_cave_liquid)
				end
	
				if desc.node_dungeon and desc.node_dungeon ~= "" then
					mg_earth.biome_info[desc.name].b_dungeon = minetest.get_content_id(desc.node_dungeon)
				end
	
				if desc.node_dungeon_alt and desc.node_dungeon_alt ~= "" then
					mg_earth.biome_info[desc.name].b_dungeon_alt = minetest.get_content_id(desc.node_dungeon_alt)
				end
	
				if desc.node_dungeon_stair and desc.node_dungeon_stair ~= "" then
					mg_earth.biome_info[desc.name].b_dungeon_stair = minetest.get_content_id(desc.node_dungeon_stair)
				end

				if desc.node_dust and desc.node_dust ~= "" then
					mg_earth.biome_info[desc.name].b_node_dust = minetest.get_content_id(desc.node_dust)
				end
--]]
				if desc.vertical_blend and desc.vertical_blend ~= "" then
					mg_earth.biome_info[desc.name].vertical_blend = desc.vertical_blend or 0
				end

				if desc.y_min and desc.y_min ~= "" then
					mg_earth.biome_info[desc.name].b_miny = desc.y_min or -31000
				end
	
				if desc.y_max and desc.y_max ~= "" then
					mg_earth.biome_info[desc.name].b_maxy = desc.y_max or 31000
				end
	
				mg_earth.biome_info[desc.name].min_pos = desc.min_pos or {x=-31000, y=-31000, z=-31000}
				if desc.y_min and desc.y_min ~= "" then
					mg_earth.biome_info[desc.name].min_pos.y = math.max(mg_earth.biome_info[desc.name].min_pos.y, desc.y_min)
				end
	
				mg_earth.biome_info[desc.name].max_pos = desc.max_pos or {x=31000, y=31000, z=31000}
				if desc.y_max and desc.y_max ~= "" then
					mg_earth.biome_info[desc.name].max_pos.y = math.min(mg_earth.biome_info[desc.name].max_pos.y, desc.y_max)
				end
	
				if desc.heat_point and desc.heat_point ~= "" then
					mg_earth.biome_info[desc.name].b_heat = desc.heat_point or 50
				end
	
				if desc.humidity_point and desc.humidity_point ~= "" then
					mg_earth.biome_info[desc.name].b_humid = desc.humidity_point or 50
				end
	
	
			end
		end
	else
		local t_default = true
		if t_default then
			local m_top1 = 12.5
			local m_top2 = 37.5
			local m_top3 = 62.5
			local m_top4 = 87.5

			local c_air					= mg_earth.c_air
			local c_ignore				= mg_earth.c_ignore

			local c_top					= mg_earth.c_top
			local c_filler				= mg_earth.c_filler
			local c_stone				= mg_earth.c_stone
			local c_water				= mg_earth.c_water
			local c_river				= mg_earth.c_river
			local c_gravel				= mg_earth.c_gravel

			local c_lava				= mg_earth.c_lava
			local c_ice					= mg_earth.c_ice
			local c_mud					= mg_earth.c_mud

			local c_cobble				= mg_earth.c_cobble
			local c_mossy				= mg_earth.c_mossy
			local c_block				= mg_earth.c_block
			local c_brick				= mg_earth.c_brick
			local c_sand				= mg_earth.c_sand
			local c_dirt				= mg_earth.c_dirt
			local c_dirtdry				= mg_earth.c_drydirt
			local c_dirtgrass			= mg_earth.c_dirtgrass
			local c_dirtdrygrass		= mg_earth.c_dirtdrygrass
			local c_drydirtdrygrass		= mg_earth.c_drydirtdrygrass
			local c_dirtsnow			= mg_earth.c_dirtsnow
			local c_dirtperm			= mg_earth.c_dirtperm

			local c_coniferous			= mg_earth.c_coniferous
			local c_rainforest			= mg_earth.c_rainforest
			local c_desertsandstone		= mg_earth.c_desertsandstone
			local c_desertsand			= mg_earth.c_desertsand
			local c_desertstone			= mg_earth.c_desertstone
			local c_sandstone			= mg_earth.c_sandstone
			local c_silversandstone		= mg_earth.c_silversandstone
			local c_silversand			= mg_earth.c_silversand

			mg_earth.biome_info["default"] = {}
			mg_earth.biome_info["default"].b_name = "default"
			mg_earth.biome_info["default"].b_cid = 0
			mg_earth.biome_info["default"].b_top = c_dirtgrass
			mg_earth.biome_info["default"].b_top_depth = 1
			mg_earth.biome_info["default"].b_filler = c_dirt
			mg_earth.biome_info["default"].b_filler_depth = 4
			mg_earth.biome_info["default"].b_stone = c_stone
			mg_earth.biome_info["default"].b_water_top = c_water
			mg_earth.biome_info["default"].b_water_top_depth = 1
			mg_earth.biome_info["default"].b_water = c_water
			mg_earth.biome_info["default"].b_river = c_river
			mg_earth.biome_info["default"].b_riverbed = c_gravel
			mg_earth.biome_info["default"].b_riverbed_depth = 2
			mg_earth.biome_info["default"].b_cave_liquid = c_lava
			mg_earth.biome_info["default"].b_dungeon = c_brick
			mg_earth.biome_info["default"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["default"].b_dungeon_stair = c_block
			mg_earth.biome_info["default"].b_node_dust = c_air
			mg_earth.biome_info["default"].vertical_blend = 0
			mg_earth.biome_info["default"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["default"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["default"].b_miny = -31000
			mg_earth.biome_info["default"].b_maxy = 31000
			mg_earth.biome_info["default"].b_heat = 50
			mg_earth.biome_info["default"].b_humid = 50

			mg_earth.biome_info["cold_arid"] = {}
			mg_earth.biome_info["cold_arid"].b_name = "cold_arid"
			mg_earth.biome_info["cold_arid"].b_cid = 1
			mg_earth.biome_info["cold_arid"].b_top = c_dirtperm
			mg_earth.biome_info["cold_arid"].b_top_depth = 1
			mg_earth.biome_info["cold_arid"].b_filler = c_dirtperm
			mg_earth.biome_info["cold_arid"].b_filler_depth = 4
			mg_earth.biome_info["cold_arid"].b_stone = c_stone
			mg_earth.biome_info["cold_arid"].b_water_top = c_water
			mg_earth.biome_info["cold_arid"].b_water_top_depth = 1
			mg_earth.biome_info["cold_arid"].b_water = c_ice
			mg_earth.biome_info["cold_arid"].b_river = c_ice
			mg_earth.biome_info["cold_arid"].b_riverbed = c_silversand
			mg_earth.biome_info["cold_arid"].b_riverbed_depth = 2
			mg_earth.biome_info["cold_arid"].b_cave_liquid = c_lava
			mg_earth.biome_info["cold_arid"].b_dungeon = c_brick
			mg_earth.biome_info["cold_arid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["cold_arid"].b_dungeon_stair = c_block
			mg_earth.biome_info["cold_arid"].b_node_dust = c_air
			mg_earth.biome_info["cold_arid"].vertical_blend = 0
			mg_earth.biome_info["cold_arid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["cold_arid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["cold_arid"].b_miny = -31000
			mg_earth.biome_info["cold_arid"].b_maxy = 31000
			mg_earth.biome_info["cold_arid"].b_heat = m_top1
			mg_earth.biome_info["cold_arid"].b_humid = m_top1

			mg_earth.biome_info["temperate_arid"] = {}
			mg_earth.biome_info["temperate_arid"].b_name = "temperate_arid"
			mg_earth.biome_info["temperate_arid"].b_cid = 2
			mg_earth.biome_info["temperate_arid"].b_top = c_silversand
			mg_earth.biome_info["temperate_arid"].b_top_depth = 1
			mg_earth.biome_info["temperate_arid"].b_filler = c_silversand
			mg_earth.biome_info["temperate_arid"].b_filler_depth = 4
			mg_earth.biome_info["temperate_arid"].b_stone = c_silversandstone
			mg_earth.biome_info["temperate_arid"].b_water_top = c_water
			mg_earth.biome_info["temperate_arid"].b_water_top_depth = 1
			mg_earth.biome_info["temperate_arid"].b_water = c_water
			mg_earth.biome_info["temperate_arid"].b_river = c_river
			mg_earth.biome_info["temperate_arid"].b_riverbed = c_silversand
			mg_earth.biome_info["temperate_arid"].b_riverbed_depth = 2
			mg_earth.biome_info["temperate_arid"].b_cave_liquid = c_lava
			mg_earth.biome_info["temperate_arid"].b_dungeon = c_brick
			mg_earth.biome_info["temperate_arid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["temperate_arid"].b_dungeon_stair = c_block
			mg_earth.biome_info["temperate_arid"].b_node_dust = c_air
			mg_earth.biome_info["temperate_arid"].vertical_blend = 0
			mg_earth.biome_info["temperate_arid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["temperate_arid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["temperate_arid"].b_miny = -31000
			mg_earth.biome_info["temperate_arid"].b_maxy = 31000
			mg_earth.biome_info["temperate_arid"].b_heat = m_top2
			mg_earth.biome_info["temperate_arid"].b_humid = m_top1

			mg_earth.biome_info["warm_arid"] = {}
			mg_earth.biome_info["warm_arid"].b_name = "warm_arid"
			mg_earth.biome_info["warm_arid"].b_cid = 3
			mg_earth.biome_info["warm_arid"].b_top = c_sand
			mg_earth.biome_info["warm_arid"].b_top_depth = 1
			mg_earth.biome_info["warm_arid"].b_filler = c_sand
			mg_earth.biome_info["warm_arid"].b_filler_depth = 4
			mg_earth.biome_info["warm_arid"].b_stone = c_desertsandstone
			mg_earth.biome_info["warm_arid"].b_water_top = c_water
			mg_earth.biome_info["warm_arid"].b_water_top_depth = 1
			mg_earth.biome_info["warm_arid"].b_water = c_water
			mg_earth.biome_info["warm_arid"].b_river = c_river
			mg_earth.biome_info["warm_arid"].b_riverbed = c_sand
			mg_earth.biome_info["warm_arid"].b_riverbed_depth = 2
			mg_earth.biome_info["warm_arid"].b_cave_liquid = c_lava
			mg_earth.biome_info["warm_arid"].b_dungeon = c_brick
			mg_earth.biome_info["warm_arid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["warm_arid"].b_dungeon_stair = c_block
			mg_earth.biome_info["warm_arid"].b_node_dust = c_air
			mg_earth.biome_info["warm_arid"].vertical_blend = 0
			mg_earth.biome_info["warm_arid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["warm_arid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["warm_arid"].b_miny = -31000
			mg_earth.biome_info["warm_arid"].b_maxy = 31000
			mg_earth.biome_info["warm_arid"].b_heat = m_top3
			mg_earth.biome_info["warm_arid"].b_humid = m_top1

			mg_earth.biome_info["hot_arid"] = {}
			mg_earth.biome_info["hot_arid"].b_name = "hot_arid"
			mg_earth.biome_info["hot_arid"].b_cid = 4
			mg_earth.biome_info["hot_arid"].b_top = c_desertsand
			mg_earth.biome_info["hot_arid"].b_top_depth = 1
			mg_earth.biome_info["hot_arid"].b_filler = c_desertsand
			mg_earth.biome_info["hot_arid"].b_filler_depth = 4
			mg_earth.biome_info["hot_arid"].b_stone = c_desertstone
			mg_earth.biome_info["hot_arid"].b_water_top = c_water
			mg_earth.biome_info["hot_arid"].b_water_top_depth = 1
			mg_earth.biome_info["hot_arid"].b_water = c_water
			mg_earth.biome_info["hot_arid"].b_river = c_river
			mg_earth.biome_info["hot_arid"].b_riverbed = c_desertsand
			mg_earth.biome_info["hot_arid"].b_riverbed_depth = 2
			mg_earth.biome_info["hot_arid"].b_cave_liquid = c_lava
			mg_earth.biome_info["hot_arid"].b_dungeon = c_brick
			mg_earth.biome_info["hot_arid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["hot_arid"].b_dungeon_stair = c_block
			mg_earth.biome_info["hot_arid"].b_node_dust = c_air
			mg_earth.biome_info["hot_arid"].vertical_blend = 0
			mg_earth.biome_info["hot_arid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["hot_arid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["hot_arid"].b_miny = -31000
			mg_earth.biome_info["hot_arid"].b_maxy = 31000
			mg_earth.biome_info["hot_arid"].b_heat = m_top4
			mg_earth.biome_info["hot_arid"].b_humid = m_top1

			mg_earth.biome_info["cold_temperate"] = {}
			mg_earth.biome_info["cold_temperate"].b_name = "cold_temperate"
			mg_earth.biome_info["cold_temperate"].b_cid = 5
			mg_earth.biome_info["cold_temperate"].b_top = c_dirtperm
			mg_earth.biome_info["cold_temperate"].b_top_depth = 1
			mg_earth.biome_info["cold_temperate"].b_filler = c_dirtperm
			mg_earth.biome_info["cold_temperate"].b_filler_depth = 4
			mg_earth.biome_info["cold_temperate"].b_stone = c_stone
			mg_earth.biome_info["cold_temperate"].b_water_top = c_water
			mg_earth.biome_info["cold_temperate"].b_water_top_depth = 1
			mg_earth.biome_info["cold_temperate"].b_water = c_water
			mg_earth.biome_info["cold_temperate"].b_river = c_river
			mg_earth.biome_info["cold_temperate"].b_riverbed = c_silversand
			mg_earth.biome_info["cold_temperate"].b_riverbed_depth = 2
			mg_earth.biome_info["cold_temperate"].b_cave_liquid = c_lava
			mg_earth.biome_info["cold_temperate"].b_dungeon = c_brick
			mg_earth.biome_info["cold_temperate"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["cold_temperate"].b_dungeon_stair = c_block
			mg_earth.biome_info["cold_temperate"].b_node_dust = c_air
			mg_earth.biome_info["cold_temperate"].vertical_blend = 0
			mg_earth.biome_info["cold_temperate"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["cold_temperate"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["cold_temperate"].b_miny = -31000
			mg_earth.biome_info["cold_temperate"].b_maxy = 31000
			mg_earth.biome_info["cold_temperate"].b_heat = m_top1
			mg_earth.biome_info["cold_temperate"].b_humid = m_top2

			mg_earth.biome_info["temperate_temperate"] = {}
			mg_earth.biome_info["temperate_temperate"].b_name = "temperate_temperate"
			mg_earth.biome_info["temperate_temperate"].b_cid = 6
			mg_earth.biome_info["temperate_temperate"].b_top = c_dirtgrass
			mg_earth.biome_info["temperate_temperate"].b_top_depth = 1
			mg_earth.biome_info["temperate_temperate"].b_filler = c_dirtdry
			mg_earth.biome_info["temperate_temperate"].b_filler_depth = 4
			mg_earth.biome_info["temperate_temperate"].b_stone = c_sandstone
			mg_earth.biome_info["temperate_temperate"].b_water_top = c_water
			mg_earth.biome_info["temperate_temperate"].b_water_top_depth = 1
			mg_earth.biome_info["temperate_temperate"].b_water = c_water
			mg_earth.biome_info["temperate_temperate"].b_river = c_river
			mg_earth.biome_info["temperate_temperate"].b_riverbed = c_sand
			mg_earth.biome_info["temperate_temperate"].b_riverbed_depth = 2
			mg_earth.biome_info["temperate_temperate"].b_cave_liquid = c_lava
			mg_earth.biome_info["temperate_temperate"].b_dungeon = c_brick
			mg_earth.biome_info["temperate_temperate"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["temperate_temperate"].b_dungeon_stair = c_block
			mg_earth.biome_info["temperate_temperate"].b_node_dust = c_air
			mg_earth.biome_info["temperate_temperate"].vertical_blend = 0
			mg_earth.biome_info["temperate_temperate"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["temperate_temperate"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["temperate_temperate"].b_miny = -31000
			mg_earth.biome_info["temperate_temperate"].b_maxy = 31000
			mg_earth.biome_info["temperate_temperate"].b_heat = m_top2
			mg_earth.biome_info["temperate_temperate"].b_humid = m_top2

			mg_earth.biome_info["warm_temperate"] = {}
			mg_earth.biome_info["warm_temperate"].b_name = "warm_temperate"
			mg_earth.biome_info["warm_temperate"].b_cid = 7
			mg_earth.biome_info["warm_temperate"].b_top = c_dirtgrass
			mg_earth.biome_info["warm_temperate"].b_top_depth = 1
			mg_earth.biome_info["warm_temperate"].b_filler = c_dirtdry
			mg_earth.biome_info["warm_temperate"].b_filler_depth = 4
			mg_earth.biome_info["warm_temperate"].b_stone = c_sandstone
			mg_earth.biome_info["warm_temperate"].b_water_top = c_water
			mg_earth.biome_info["warm_temperate"].b_water_top_depth = 1
			mg_earth.biome_info["warm_temperate"].b_water = c_water
			mg_earth.biome_info["warm_temperate"].b_river = c_river
			mg_earth.biome_info["warm_temperate"].b_riverbed = c_sand
			mg_earth.biome_info["warm_temperate"].b_riverbed_depth = 2
			mg_earth.biome_info["warm_temperate"].b_cave_liquid = c_lava
			mg_earth.biome_info["warm_temperate"].b_dungeon = c_brick
			mg_earth.biome_info["warm_temperate"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["warm_temperate"].b_dungeon_stair = c_block
			mg_earth.biome_info["warm_temperate"].b_node_dust = c_air
			mg_earth.biome_info["warm_temperate"].vertical_blend = 0
			mg_earth.biome_info["warm_temperate"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["warm_temperate"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["warm_temperate"].b_miny = -31000
			mg_earth.biome_info["warm_temperate"].b_maxy = 31000
			mg_earth.biome_info["warm_temperate"].b_heat = m_top3
			mg_earth.biome_info["warm_temperate"].b_humid = m_top2

			mg_earth.biome_info["hot_temperate"] = {}
			mg_earth.biome_info["hot_temperate"].b_name = "hot_temperate"
			mg_earth.biome_info["hot_temperate"].b_cid = 8
			mg_earth.biome_info["hot_temperate"].b_top = c_dirtgrass
			mg_earth.biome_info["hot_temperate"].b_top_depth = 1
			mg_earth.biome_info["hot_temperate"].b_filler = c_desertsandstone
			mg_earth.biome_info["hot_temperate"].b_filler_depth = 4
			mg_earth.biome_info["hot_temperate"].b_stone = c_desertstone
			mg_earth.biome_info["hot_temperate"].b_water_top = c_water
			mg_earth.biome_info["hot_temperate"].b_water_top_depth = 1
			mg_earth.biome_info["hot_temperate"].b_water = c_water
			mg_earth.biome_info["hot_temperate"].b_river = c_river
			mg_earth.biome_info["hot_temperate"].b_riverbed = c_sand
			mg_earth.biome_info["hot_temperate"].b_riverbed_depth = 2
			mg_earth.biome_info["hot_temperate"].b_cave_liquid = c_lava
			mg_earth.biome_info["hot_temperate"].b_dungeon = c_brick
			mg_earth.biome_info["hot_temperate"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["hot_temperate"].b_dungeon_stair = c_block
			mg_earth.biome_info["hot_temperate"].b_node_dust = c_air
			mg_earth.biome_info["hot_temperate"].vertical_blend = 0
			mg_earth.biome_info["hot_temperate"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["hot_temperate"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["hot_temperate"].b_miny = -31000
			mg_earth.biome_info["hot_temperate"].b_maxy = 31000
			mg_earth.biome_info["hot_temperate"].b_heat = m_top4
			mg_earth.biome_info["hot_temperate"].b_humid = m_top2

			mg_earth.biome_info["cold_semihumid"] = {}
			mg_earth.biome_info["cold_semihumid"].b_name = "cold_semihumid"
			mg_earth.biome_info["cold_semihumid"].b_cid = 9
			mg_earth.biome_info["cold_semihumid"].b_top = c_snow
			mg_earth.biome_info["cold_semihumid"].b_top_depth = 1
			mg_earth.biome_info["cold_semihumid"].b_filler = c_dirt
			mg_earth.biome_info["cold_semihumid"].b_filler_depth = 4
			mg_earth.biome_info["cold_semihumid"].b_stone = c_stone
			mg_earth.biome_info["cold_semihumid"].b_water_top = c_water
			mg_earth.biome_info["cold_semihumid"].b_water_top_depth = 1
			mg_earth.biome_info["cold_semihumid"].b_water = c_water
			mg_earth.biome_info["cold_semihumid"].b_river = c_river
			mg_earth.biome_info["cold_semihumid"].b_riverbed = c_silversand
			mg_earth.biome_info["cold_semihumid"].b_riverbed_depth = 2
			mg_earth.biome_info["cold_semihumid"].b_cave_liquid = c_lava
			mg_earth.biome_info["cold_semihumid"].b_dungeon = c_brick
			mg_earth.biome_info["cold_semihumid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["cold_semihumid"].b_dungeon_stair = c_block
			mg_earth.biome_info["cold_semihumid"].b_node_dust = c_air
			mg_earth.biome_info["cold_semihumid"].vertical_blend = 0
			mg_earth.biome_info["cold_semihumid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["cold_semihumid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["cold_semihumid"].b_miny = -31000
			mg_earth.biome_info["cold_semihumid"].b_maxy = 31000
			mg_earth.biome_info["cold_semihumid"].b_heat = m_top1
			mg_earth.biome_info["cold_semihumid"].b_humid = m_top3

			mg_earth.biome_info["temperate_semihumid"] = {}
			mg_earth.biome_info["temperate_semihumid"].b_name = "temperate_semihumid"
			mg_earth.biome_info["temperate_semihumid"].b_cid = 10
			mg_earth.biome_info["temperate_semihumid"].b_top = c_dirtgrass
			mg_earth.biome_info["temperate_semihumid"].b_top_depth = 1
			mg_earth.biome_info["temperate_semihumid"].b_filler = c_dirt
			mg_earth.biome_info["temperate_semihumid"].b_filler_depth = 4
			mg_earth.biome_info["temperate_semihumid"].b_stone = c_stone
			mg_earth.biome_info["temperate_semihumid"].b_water_top = c_water
			mg_earth.biome_info["temperate_semihumid"].b_water_top_depth = 1
			mg_earth.biome_info["temperate_semihumid"].b_water = c_water
			mg_earth.biome_info["temperate_semihumid"].b_river = c_river
			mg_earth.biome_info["temperate_semihumid"].b_riverbed = c_sand
			mg_earth.biome_info["temperate_semihumid"].b_riverbed_depth = 2
			mg_earth.biome_info["temperate_semihumid"].b_cave_liquid = c_lava
			mg_earth.biome_info["temperate_semihumid"].b_dungeon = c_brick
			mg_earth.biome_info["temperate_semihumid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["temperate_semihumid"].b_dungeon_stair = c_block
			mg_earth.biome_info["temperate_semihumid"].b_node_dust = c_air
			mg_earth.biome_info["temperate_semihumid"].vertical_blend = 0
			mg_earth.biome_info["temperate_semihumid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["temperate_semihumid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["temperate_semihumid"].b_miny = -31000
			mg_earth.biome_info["temperate_semihumid"].b_maxy = 31000
			mg_earth.biome_info["temperate_semihumid"].b_heat = m_top2
			mg_earth.biome_info["temperate_semihumid"].b_humid = m_top3

			mg_earth.biome_info["warm_semihumid"] = {}
			mg_earth.biome_info["warm_semihumid"].b_name = "warm_semihumid"
			mg_earth.biome_info["warm_semihumid"].b_cid = 11
			mg_earth.biome_info["warm_semihumid"].b_top = c_dirtgrass
			mg_earth.biome_info["warm_semihumid"].b_top_depth = 1
			mg_earth.biome_info["warm_semihumid"].b_filler = c_dirt
			mg_earth.biome_info["warm_semihumid"].b_filler_depth = 4
			mg_earth.biome_info["warm_semihumid"].b_stone = c_stone
			mg_earth.biome_info["warm_semihumid"].b_water_top = c_water
			mg_earth.biome_info["warm_semihumid"].b_water_top_depth = 1
			mg_earth.biome_info["warm_semihumid"].b_water = c_water
			mg_earth.biome_info["warm_semihumid"].b_river = c_river
			mg_earth.biome_info["warm_semihumid"].b_riverbed = c_sand
			mg_earth.biome_info["warm_semihumid"].b_riverbed_depth = 2
			mg_earth.biome_info["warm_semihumid"].b_cave_liquid = c_lava
			mg_earth.biome_info["warm_semihumid"].b_dungeon = c_brick
			mg_earth.biome_info["warm_semihumid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["warm_semihumid"].b_dungeon_stair = c_block
			mg_earth.biome_info["warm_semihumid"].b_node_dust = c_air
			mg_earth.biome_info["warm_semihumid"].vertical_blend = 0
			mg_earth.biome_info["warm_semihumid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["warm_semihumid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["warm_semihumid"].b_miny = -31000
			mg_earth.biome_info["warm_semihumid"].b_maxy = 31000
			mg_earth.biome_info["warm_semihumid"].b_heat = m_top3
			mg_earth.biome_info["warm_semihumid"].b_humid = m_top3

			mg_earth.biome_info["hot_semihumid"] = {}
			mg_earth.biome_info["hot_semihumid"].b_name = "hot_semihumid"
			mg_earth.biome_info["hot_semihumid"].b_cid = 12
			mg_earth.biome_info["hot_semihumid"].b_top = c_dirtgrass
			mg_earth.biome_info["hot_semihumid"].b_top_depth = 1
			mg_earth.biome_info["hot_semihumid"].b_filler = c_dirt
			mg_earth.biome_info["hot_semihumid"].b_filler_depth = 4
			mg_earth.biome_info["hot_semihumid"].b_stone = c_desertstone
			mg_earth.biome_info["hot_semihumid"].b_water_top = c_water
			mg_earth.biome_info["hot_semihumid"].b_water_top_depth = 1
			mg_earth.biome_info["hot_semihumid"].b_water = c_water
			mg_earth.biome_info["hot_semihumid"].b_river = c_river
			mg_earth.biome_info["hot_semihumid"].b_riverbed = c_sand
			mg_earth.biome_info["hot_semihumid"].b_riverbed_depth = 2
			mg_earth.biome_info["hot_semihumid"].b_cave_liquid = c_lava
			mg_earth.biome_info["hot_semihumid"].b_dungeon = c_brick
			mg_earth.biome_info["hot_semihumid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["hot_semihumid"].b_dungeon_stair = c_block
			mg_earth.biome_info["hot_semihumid"].b_node_dust = c_air
			mg_earth.biome_info["hot_semihumid"].vertical_blend = 0
			mg_earth.biome_info["hot_semihumid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["hot_semihumid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["hot_semihumid"].b_miny = -31000
			mg_earth.biome_info["hot_semihumid"].b_maxy = 31000
			mg_earth.biome_info["hot_semihumid"].b_heat = m_top4
			mg_earth.biome_info["hot_semihumid"].b_humid = m_top3

			mg_earth.biome_info["temperate_humid"] = {}
			mg_earth.biome_info["temperate_humid"].b_name = "temperate_humid"
			mg_earth.biome_info["temperate_humid"].b_cid = 13
			mg_earth.biome_info["temperate_humid"].b_top = c_coniferous
			mg_earth.biome_info["temperate_humid"].b_top_depth = 1
			mg_earth.biome_info["temperate_humid"].b_filler = c_dirt
			mg_earth.biome_info["temperate_humid"].b_filler_depth = 4
			mg_earth.biome_info["temperate_humid"].b_stone = c_desertsandstone
			mg_earth.biome_info["temperate_humid"].b_water_top = c_water
			mg_earth.biome_info["temperate_humid"].b_water_top_depth = 1
			mg_earth.biome_info["temperate_humid"].b_water = c_water
			mg_earth.biome_info["temperate_humid"].b_river = c_river
			mg_earth.biome_info["temperate_humid"].b_riverbed = c_sand
			mg_earth.biome_info["temperate_humid"].b_riverbed_depth = 2
			mg_earth.biome_info["temperate_humid"].b_cave_liquid = c_lava
			mg_earth.biome_info["temperate_humid"].b_dungeon = c_brick
			mg_earth.biome_info["temperate_humid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["temperate_humid"].b_dungeon_stair = c_block
			mg_earth.biome_info["temperate_humid"].b_node_dust = c_air
			mg_earth.biome_info["temperate_humid"].vertical_blend = 0
			mg_earth.biome_info["temperate_humid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["temperate_humid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["temperate_humid"].b_miny = -31000
			mg_earth.biome_info["temperate_humid"].b_maxy = 31000
			mg_earth.biome_info["temperate_humid"].b_heat = m_top2
			mg_earth.biome_info["temperate_humid"].b_humid = m_top4

			mg_earth.biome_info["hot_humid"] = {}
			mg_earth.biome_info["hot_humid"].b_name = "hot_humid"
			mg_earth.biome_info["hot_humid"].b_cid = 14
			mg_earth.biome_info["hot_humid"].b_top = c_rainforest
			mg_earth.biome_info["hot_humid"].b_top_depth = 1
			mg_earth.biome_info["hot_humid"].b_filler = c_dirt
			mg_earth.biome_info["hot_humid"].b_filler_depth = 4
			mg_earth.biome_info["hot_humid"].b_stone = c_desertstone
			mg_earth.biome_info["hot_humid"].b_water_top = c_water
			mg_earth.biome_info["hot_humid"].b_water_top_depth = 1
			mg_earth.biome_info["hot_humid"].b_water = c_water
			mg_earth.biome_info["hot_humid"].b_river = c_river
			mg_earth.biome_info["hot_humid"].b_riverbed = c_desertsand
			mg_earth.biome_info["hot_humid"].b_riverbed_depth = 2
			mg_earth.biome_info["hot_humid"].b_cave_liquid = c_lava
			mg_earth.biome_info["hot_humid"].b_dungeon = c_brick
			mg_earth.biome_info["hot_humid"].b_dungeon_alt = c_mossy
			mg_earth.biome_info["hot_humid"].b_dungeon_stair = c_block
			mg_earth.biome_info["hot_humid"].b_node_dust = c_air
			mg_earth.biome_info["hot_humid"].vertical_blend = 0
			mg_earth.biome_info["hot_humid"].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info["hot_humid"].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info["hot_humid"].b_miny = -31000
			mg_earth.biome_info["hot_humid"].b_maxy = 31000
			mg_earth.biome_info["hot_humid"].b_heat = m_top4
			mg_earth.biome_info["hot_humid"].b_humid = m_top4
		end
	end
end
update_biomes()


local function calc_biome_from_noise(heat, humid, pos)
	local biome_closest = nil
	local biome_closest_blend = nil
	local dist_min = 31000
	local dist_min_blend = 31000

		--for i, biome in pairs(biomes) do
	for i, biome in pairs(mg_earth.biome_info) do
		local min_pos, max_pos = biome.min_pos, biome.max_pos
			--if pos.y >= min_pos.y and pos.y <= max_pos.y+biome.vertical_blend
		if pos.y >= min_pos.y and pos.y <= max_pos.y
				and pos.x >= min_pos.x and pos.x <= max_pos.x
				and pos.z >= min_pos.z and pos.z <= max_pos.z then
				--local d_heat = heat - biome.heat_point
			local d_heat = heat - biome.b_heat
				--local d_humid = humid - biome.humidity_point
			local d_humid = humid - biome.b_humid
			local dist = d_heat*d_heat + d_humid*d_humid -- Pythagorean distance

			if pos.y <= max_pos.y then -- Within y limits of biome
				if dist < dist_min then
					dist_min = dist
					biome_closest = biome
				elseif dist < dist_min_blend and dist > dist_min then -- Blend area above biome
					dist_min_blend = dist
					biome_closest_blend = biome
				end
			end
		end
	end

	-- Carefully tune pseudorandom seed variation to avoid single node dither
	-- and create larger scale blending patterns similar to horizontal biome
	-- blend.
	local seed = math.floor(pos.y + (heat+humid) * 0.9)
	local rng = PseudoRandom(seed)

		--if biome_closest_blend and dist_min_blend <= dist_min
				--and rng:next(0, biome_closest_blend.vertical_blend) >= pos.y - biome_closest_blend.max_pos.y then
			--return biome_closest_blend
	if biome_closest_blend and dist_min_blend <= dist_min then
		return biome_closest_blend.b_name
	end
	
		-- if not biome_closest then
			-- return biome_closest_blend.b_name
		-- end

		--return biome_closest
	-- if biome_closest then
		-- if biome_closest.b_name and biome_closest.b_name ~= "" then
			-- return biome_closest.b_name
		-- end
	-- end
	
	-- return
	return biome_closest.b_name
	
end


local function get_heat_scalar(z)

	if use_heat_scalar == true then

		local t_z = abs(z)
		local t_heat = 50
		local t_heat_scale = 0.0071875 
		local t_heat_mid = ((60000 * mg_world_scale) * 0.25)
		local t_diff = t_heat_mid - t_z
		local t_map_scale = t_heat_scale / mg_world_scale

		return t_heat + (t_diff * t_map_scale)

	else
		return 0
	end

end

local function get_humid_scalar(z)

	if use_humid_scalar == true then

		local t_z = abs(z)
		local t_humid_mid = ((60000 * mg_world_scale) * 0.062)
		local t_world = 0.0125 / mg_world_scale
		local t_diff = 0

		if t_z <= (t_humid_mid * 2) then
			local t_mid = t_humid_mid
			if t_z > t_mid then
				t_diff = abs((t_z - t_mid) * t_world) * -1
			else
				t_diff = abs((t_mid - t_z) * t_world)
			end
		elseif (t_z > (t_humid_mid * 2)) and (t_z <= (t_humid_mid * 4)) then
			local t_mid = t_humid_mid * 3
			if t_z > t_mid then
				t_diff = abs((t_z - t_mid) * t_world)
			else
				t_diff = abs((t_mid - t_z) * t_world) * -1
			end
		elseif (t_z > (t_humid_mid * 4)) then
			local t_mid = t_humid_mid * 5
			if t_z > t_mid then
				t_diff = abs((t_z - t_mid) * t_world) * -1
			else
				t_diff = abs((t_mid - t_z) * t_world)
			end
		end

		return t_diff

	else
		return 0
	end

end


--local function get_terrain_height_cliffs(theight,cheight)
local function get_terrain_height_cliffs(theight,z,x)

	local cheight = minetest.get_perlin(np_cliffs):get_2d({x=x,y=z})

		-- cliffs
	local t_cliff = 0
	if theight > 1 and theight < cliffs_thresh then 
		local clifh = max(min(cheight,1),0) 
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			theight = theight + (cliffs_thresh - theight) * clifh * ((theight < 2) and theight - 1 or 1)
		end
	end
	return theight, t_cliff
end

local function get_v6_base(terrain_base, terrain_higher,
	steepness, height_select)

	local base   = 1 + terrain_base
	local higher = 1 + terrain_higher

	-- Limit higher ground level to at least base
	if higher < base then
		higher = base
	end

	-- Steepness factor of cliffs
	local b = steepness
	b = rangelim(b, 0.0, 1000.0)
	b = 5 * b * b * b * b * b * b * b
	b = rangelim(b, 0.5, 1000.0)

	-- Values 1.5...100 give quite horrible looking slopes
	if b > 1.5 and b < 100.0 then
		if b < 10 then
			b = 1.5
		else
			b = 100
		end
	end

	local a_off = -0.20 -- Offset to more low
	local a = 0.5 + b * (a_off + height_select);
	a = rangelim(a, 0.0, 1.0) -- Limit

	return math.floor(base * (1.0 - a) + higher * a)
end

local function get_v6_height(z,x)

	local terrain_base = minetest.get_perlin(np_terrain_base):get_2d({
			x = x + 0.5 * np_terrain_base.spread.x,
			y = z + 0.5 * np_terrain_base.spread.y})

	local terrain_higher = minetest.get_perlin(np_terrain_higher):get_2d({
			x = x + 0.5 * np_terrain_higher.spread.x,
			y = z + 0.5 * np_terrain_higher.spread.y})

	local steepness = minetest.get_perlin(np_steepness):get_2d({
			x = x + 0.5 * np_steepness.spread.x,
			y = z + 0.5 * np_steepness.spread.y})

	local height_select = minetest.get_perlin(np_height_select):get_2d({
			x = x + 0.5 * np_height_select.spread.x,
			y = z + 0.5 * np_height_select.spread.y})

	return get_v6_base(terrain_base, terrain_higher, steepness, height_select) + 2 -- (Dust)
end

local function get_v7_height(z,x)

	local aterrain = 0

	local hselect = minetest.get_perlin(np_height):get_2d({x=x,y=z})
	local hselect = rangelim(hselect, 0, 1)

	local persist = minetest.get_perlin(np_persist):get_2d({x=x,y=z})
	--local lacun = 2 + (persist * persist)

	np_base.persistence = persist;
	--np_v7_base.lacunarity = lacun
	local height_base = minetest.get_perlin(np_base):get_2d({x=x,y=z})

	np_2d.persistence = persist;
	--np_v7_alt.lacunarity = lacun
	local height_alt = minetest.get_perlin(np_2d):get_2d({x=x,y=z})

	if (height_alt > height_base) then
		aterrain = floor(height_alt)
	else
		aterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
	end

	return aterrain
end

local function get_terrain_height(z,x)

	local tterrain = 0

	local hselect = minetest.get_perlin(np_height):get_2d({x=x,y=z})
	local hselect = rangelim(hselect, 0, 1)

	local persist = minetest.get_perlin(np_persist):get_2d({x=x,y=z})

	np_base.persistence = persist;
	local height_base = minetest.get_perlin(np_base):get_2d({x=x,y=z})

	np_2d.persistence = persist;
	local height_alt = minetest.get_perlin(np_2d):get_2d({x=x,y=z})

	if (height_alt > height_base) then
		tterrain = floor(height_alt)
	else
		tterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
	end

	local cliffs_thresh = floor((np_2d.scale) * 0.5)
	local cheight = minetest.get_perlin(np_cliffs):get_2d({x=x,y=z})
	
	local t_cliff = 0
	
	if tterrain > 1 and tterrain < cliffs_thresh then 
		local clifh = max(min(cheight,1),0) 
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			tterrain = tterrain + (cliffs_thresh - tterrain) * clifh * ((tterrain < 2) and tterrain - 1 or 1)
		end
	end
	
	return tterrain, t_cliff

end

local function get_nearest_cell(pos, tier)

	local thisidx
	local thiscellx
	local thiscellz
	local thisdist
	local lastidx
	local lastcellx
	local lastcellz
	local lastdist
	local last
	local this
	for i, point in ipairs(mg_points) do
		--euclidean
		--local platform = get_distance_3d_euclid({x=x,y=y,z=z},{x=center_of_chunk.x,y=center_of_chunk.y,z=center_of_chunk.z})
		--local cell = get_distance_3d_euclid({x=x,y=y,z=z},{x=point.x,y=point.y,z=point.z})
		--((abs(a) * abs(a)) + (abs(b) * abs(b)))^0.5
		--manhattan
		--local platform = (abs(x-center_of_chunk.x) + abs(y-center_of_chunk.y) + abs(z-center_of_chunk.z))
		--local chnk = (abs(x-point.x) + abs(y-point.y) + abs(z-point.z))
		--chebyshev
		--local platform = (max(abs(x-center_of_chunk.x), max(abs(y-center_of_chunk.y), abs(z-center_of_chunk.z))))
		--local cell = (max(abs(x-point.x), max(abs(y-point.y), abs(z-point.z))))
		
		local pointidx, pointz, pointx, pointtier = unpack(point)
		local dist_x = abs(pos.x-(tonumber(pointx) * mg_world_scale))
		local dist_z = abs(pos.z-(tonumber(pointz) * mg_world_scale))

		--this = (max(dist_x, dist_z) + (dist_x + dist_z)) * 0.5
		this = get_dist(dist_x,dist_z,dist_metric)
		--this = ((dist_x * dist_x) + (dist_z * dist_z))^0.5

		if tonumber(pointtier) == tier then
	
			if last then
				if last > this then
					last = this
					thisidx = tonumber(pointidx)
					thiscellz = (tonumber(pointz) * mg_world_scale)
					thiscellx = (tonumber(pointx) * mg_world_scale)
					thisdist = this
					lastidx = tonumber(pointidx)
					lastcellz = (tonumber(pointz) * mg_world_scale)
					lastcellx = (tonumber(pointx) * mg_world_scale)
					lastdist = this
				elseif last == this then
					thisidx = tonumber(pointidx)
					thiscellz = (tonumber(pointz) * mg_world_scale)
					thiscellx = (tonumber(pointx) * mg_world_scale)
					thisdist = this
					if not mg_neighbors[thisidx] then
						mg_neighbors[thisidx] = {}
					end
					if not mg_neighbors[lastidx] then
						mg_neighbors[lastidx] = {}
					end
					if not mg_neighbors[thisidx][lastidx] then
						mg_neighbors[thisidx][lastidx] = {}
					end
					if not mg_neighbors[lastidx][thisidx] then
						mg_neighbors[lastidx][thisidx] = {}
					end
					t_mid_x, t_mid_z = get_midpoint({x = thiscellx, z = thiscellz}, {x = lastcellx, z = lastcellz})
					mg_neighbors[thisidx][lastidx].m_x = t_mid_x
					mg_neighbors[thisidx][lastidx].m_z = t_mid_z
					mg_neighbors[thisidx][lastidx].n_x = lastcellx
					mg_neighbors[thisidx][lastidx].n_z = lastcellz
					mg_neighbors[lastidx][thisidx].m_x = t_mid_x
					mg_neighbors[lastidx][thisidx].m_z = t_mid_z
					mg_neighbors[lastidx][thisidx].n_x = thiscellx
					mg_neighbors[lastidx][thisidx].n_z = thiscellz
				end
			else
				last = this
				thisidx = tonumber(pointidx)
				thiscellz = (tonumber(pointz) * mg_world_scale)
				thiscellx = (tonumber(pointx) * mg_world_scale)
				thisdist = this
				lastidx = tonumber(pointidx)
				lastcellz = (tonumber(pointz) * mg_world_scale)
				lastcellx = (tonumber(pointx) * mg_world_scale)
				lastdist = this
			end
		end
	end

	--return idx, closest, cell
	return thisidx, thisdist, thiscellz, thiscellx

end

local function get_nearest_midpoint(pos, ppoints)

	if not pos then
		return
	end

	local c_midpoint
	local this_dist
	--local c_z
	--local c_x
	--local c_dx
	--local c_dz
	--local c_si
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.m_x
		local t_z = pos.z - i_neighbor.m_z

		this_dist = get_dist(t_x, t_z, dist_metric)

		if last_dist then
			if last_dist >= this_dist then
				last_dist = this_dist
				c_midpoint = i
				--c_z = i_neighbor.m_z
				--c_x = i_neighbor.m_x
				--c_dz = i_neighbor.cm_zd
				--c_dx = i_neighbor.cm_xd
				--c_si = i_neighbor.m_si
			end
		else
				last_dist = this_dist
				c_midpoint = i
				--c_z = i_neighbor.m_z
				--c_x = i_neighbor.m_x
				--c_dz = i_neighbor.cm_zd
				--c_dx = i_neighbor.cm_xd
				--c_si = i_neighbor.m_si
		end
	end

	--return c_midpoint, c_z, c_x, c_dz, c_dx, c_si
	return c_midpoint

end

local function get_cell_neighbors(cell_idx,cell_z,cell_x,cell_tier)

	local t_points = mg_points

	--local curr_cell = t_points[cell_idx]
	local t_neighbors = {}

	if mg_neighbors[cell_idx] then

		t_neighbors = mg_neighbors[cell_idx]

	else

		mg_neighbors[cell_idx] = {}

		for i, i_point in ipairs(t_points) do

			local pointidx, pointz, pointx, pointtier = unpack(i_point)

			if cell_tier == pointtier then

				local t_mid_x, t_mid_z
				local t_cell
				local neighbor_add = false

				if i ~= cell_idx then

					t_mid_x, t_mid_z = get_midpoint({x = (tonumber(pointx) * mg_world_scale), z = (tonumber(pointz) * mg_world_scale)}, {x = cell_x, z = cell_z})

					t_cell = get_nearest_cell({x = t_mid_x, z = t_mid_z}, cell_tier)

					if (t_cell == i) or (t_cell == cell_idx) then
						neighbor_add = true
					end

				end

				if neighbor_add == true then

					-- t_neighbors[i] = {}
					-- t_neighbors[i].m_z = t_mid_z
					-- t_neighbors[i].m_x = t_mid_x
					mg_neighbors[cell_idx][pointidx] = {}
					mg_neighbors[cell_idx][pointidx].m_z = t_mid_z
					mg_neighbors[cell_idx][pointidx].m_x = t_mid_x
					mg_neighbors[cell_idx][pointidx].n_z = (tonumber(pointz) * mg_world_scale)
					mg_neighbors[cell_idx][pointidx].n_x = (tonumber(pointx) * mg_world_scale)

					t_neighbors = mg_neighbors[cell_idx]

				end
			end
		end
	end

	return t_neighbors

end

local function load_worldpath(separator, path)
	local file = io.open(mg_earth.path_world.."/"..path..".csv", "r")
	if file then
		local t = {}
		for line in file:lines() do
			if line:sub(1,1) ~= "#" and line:find("[^%"..separator.."% ]") then
				table.insert(t, line:split(separator, true))
			end
		end
		if type(t) == "table" then
			return t
		end
	end

	return nil
end

local function load_neighbors(pfile)

	if not pfile or pfile == "" then
		return
	end

	local t_neighbors

	if (t_neighbors == nil) then
		t_neighbors = load_worldpath("|", pfile)
	end

	if not (t_neighbors == nil) then

		for i_p, p_neighbors in ipairs(t_neighbors) do
	
			local c_i, n_i, m_z, m_x, n_z, n_x = unpack(p_neighbors)

			if not (mg_neighbors[tonumber(c_i)]) then
				mg_neighbors[tonumber(c_i)] = {}
			end

			mg_neighbors[tonumber(c_i)][tonumber(n_i)] = {}
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].m_z = tonumber(m_z)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].m_x = tonumber(m_x)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].n_z = tonumber(n_z)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].n_x = tonumber(n_x)
	
		end

		minetest.log("[MOD] test: Voronoi Cell Neighbors loaded from file.")

	end
end
load_neighbors(n_file)


local function save_worldpath(pobj, pfilename)
	local file = io.open(mg_earth.path_world.."/"..pfilename..".csv", "w")
	if file then
		file:write(pobj)
		file:close()
	end
end

local function save_neighbors(pfile)

	if not pfile or pfile == "" then
		return
	end

	local temp_neighbors = "#Cell_Index|Neighbor_Index|Midpoint_Zpos|Midpoint_Xpos|Neighbor_Zpos|Neighbor_Xpos\n"

	for i_c, i_cell in pairs(mg_neighbors) do

		temp_neighbors = temp_neighbors .. "#C_I|N_I|M_Z|M_X|N_Z|N_X\n"

		for i_n, i_neighbor in pairs(i_cell) do

			temp_neighbors = temp_neighbors .. i_c .. "|" .. i_n .. "|" .. i_neighbor.m_z .. "|" .. i_neighbor.m_x .. "|" .. i_neighbor.n_z .. "|" .. i_neighbor.n_x .. "\n"

		end

		temp_neighbors = temp_neighbors .. "#" .. "\n"

	end

	--gal.lib.csv.save_worldpath(temp_neighbors, pfile)
	save_worldpath(temp_neighbors, pfile)

end

minetest.register_chatcommand("emerge_area", {
 	params = "x1 y1 z1 x2 y2 z2",
 	description = "Generate map in a square box from pos1(x1,y1,z1) to pos2(x2,y2,z2)./nUsage:  /emerge_area x1 y1 z1 x2 y2 z2",
 	func = function(name, params)
--		local found, _, s_x1, s_y1, s_z1, s_x2, s_y2, s_z2 = params:find("^%s*(%d+)%s*(-?%d*)%s*$")
		local found, _, s_x1, s_y1, s_z1, s_x2, s_y2, s_z2 = params:find("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)[ ] *([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
	if found == nil then
		minetest.chat_send_player(name, "Usage: /mapgen x1 y1 z1 x2 y2 z2")
		return
	end

	local pos1 = {x=tonumber(s_x1), y=tonumber(s_y1), z=tonumber(s_z1)}
	local pos2 = {x=tonumber(s_x2), y=tonumber(s_y2), z=tonumber(s_z2)}	

	local start_time = minetest.get_us_time()

	minetest.emerge_area(pos1, pos2, function(blockpos, action, remaining)
		local dt = math.floor((minetest.get_us_time() - start_time) / 1000)
		local block = (blockpos.x * 16)..","..(blockpos.y * 16)..","..(blockpos.z * 16)
		local info = "(mapgen-"..remaining.."-"..dt.."ms) "
		if action==core.EMERGE_GENERATED then
			minetest.chat_send_player(name, info.."Generated new block at "..block)
			--minetest.get_player_by_name(name):send_mapblock({x=(blockpos.x * 16),y=(blockpos.y * 16),z=(blockpos.z * 16)})
		elseif (action==core.EMERGE_CANCELLED) or (action==core.EMERGE_ERRORED) then
			minetest.chat_send_player(name, info.."Block at "..block.." did not emerge")
		else
			--minetest.chat_send_player(name, "(mapgen-"..remaining.."-"..dt.."s) Visited block at "..(blockpos.x)..","..(blockpos.y)..","..(blockpos.z))
		end
	
		if remaining<=0 then
			minetest.chat_send_player(name, "(mapgen-"..dt.."ms) Generation done.")
		end
	end
	)
end
})

minetest.register_chatcommand("emerge_radius", {
 	params = "radius [max_height]",
 	description = "Generate map in a square box of size 2*radius centered at your current position.",
 	func = function(name, params)
		local found, _, s_radius, s_height = params:find("^%s*(%d+)%s*(-?%d*)%s*$")
	if found == nil then
		minetest.chat_send_player(name, "Usage: /mapgen radius max_height")
		return
	end

	local player = minetest.get_player_by_name(name)
	local pos = player:getpos()

	local radius = tonumber(s_radius)
	local max_height = tonumber(s_height)

	if max_height == nil then
		max_height = pos.y+1
	end

	if radius == 0 then
		radius = 1
	end

	local start_pos = {
		x = pos.x - radius,
		y = pos.y,
		z = pos.z - radius
	}

	local end_pos = {
		x = pos.x + radius,
		y = max_height,
		z = pos.z + radius
	}

	local start_time = minetest.get_us_time()

	minetest.emerge_area(start_pos, end_pos, function(blockpos, action, remaining)
		local dt = math.floor((minetest.get_us_time() - start_time) / 1000)
		local block = (blockpos.x * 16)..","..(blockpos.y * 16)..","..(blockpos.z * 16)
		local info = "(mapgen-"..remaining.."-"..dt.."ms) "
		if action==core.EMERGE_GENERATED then
			minetest.chat_send_player(name, info.."Generated new block at "..block)
		elseif (action==core.EMERGE_CANCELLED) or (action==core.EMERGE_ERRORED) then
			minetest.chat_send_player(name, info.."Block at "..block.." did not emerge")
		else
			--minetest.chat_send_player(name, "(mapgen-"..remaining.."-"..dt.."s) Visited block at "..(blockpos.x)..","..(blockpos.y)..","..(blockpos.z))
		end
	
		if remaining<=0 then
			minetest.chat_send_player(name, "(mapgen-"..dt.."ms) Generation done.")
		end
	end
	)
end
})

local mapgen_times = {
	noisemaps = {},
	preparation = {},
	loop2d = {},
	loop3d = {},
	biomes = {},
	mainloop = {},
	setdata = {},
	liquid_lighting = {},
	writing = {},
	make_chunk = {},
}

local data = {}

minetest.register_on_generated(function(minp, maxp, seed)

	-- Start time of mapchunk generation.
	local t0 = os.clock()


	nobj_cave1 = nobj_cave1 or minetest.get_perlin_map(np_cave1, {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
	nbuf_cave1 = nobj_cave1:get_3d_map_flat({x = minp.x, y = minp.y, z = minp.z})
	nobj_cave2 = nobj_cave2 or minetest.get_perlin_map(np_cave2, {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
	nbuf_cave2 = nobj_cave2:get_3d_map_flat({x = minp.x, y = minp.y, z = minp.z})

	
	nobj_heatmap = nobj_heatmap or minetest.get_perlin_map(np_heat, {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_heatmap = nobj_heatmap:get_2d_map({x = minp.x, y = minp.z})

	nobj_heatblend = nobj_heatblend or minetest.get_perlin_map(np_heat_blend, {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_heatblend = nobj_heatblend:get_2d_map({x = minp.x, y = minp.z})

	nobj_humiditymap = nobj_humiditymap or minetest.get_perlin_map(np_humid, {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_humiditymap = nobj_humiditymap:get_2d_map({x = minp.x, y = minp.z})

	nobj_humidityblend = nobj_humidityblend or minetest.get_perlin_map(np_humid_blend, {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_humidityblend = nobj_humidityblend:get_2d_map({x = minp.x, y = minp.z})

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local csize = vector.add(vector.subtract(maxp, minp), 1)

	local write = false

	--2D HEIGHTMAP GENERATION
	local mean_alt = 0
	local min_alt = -31000
	local max_alt = 31000

	mg_earth.center_of_chunk = {
		-- x = (maxp.x - (sidelen / 2)) + (10 - math.random(20)),
		-- y = (maxp.y - (sidelen / 2)) + (10 - math.random(20)),
		-- z = (maxp.z - (sidelen / 2)) + (10 - math.random(20)),
		x = (maxp.x - ((maxp.x - minp.x + 1) / 2)) + (10 - math.random(20)),
		y = (maxp.y - ((maxp.x - minp.x + 1) / 2)) + (10 - math.random(20)),
		z = (maxp.z - ((maxp.x - minp.x + 1) / 2)) + (10 - math.random(20)),
	}

	mg_earth.chunk_points = {
		{x=minp.x,						y=minp.y,							z=minp.z},
		{x=mg_earth.center_of_chunk.x,		y=minp.y,							z=minp.z},
		{x=maxp.x,						y=minp.y,							z=minp.z},
		{x=minp.x,						y=minp.y,							z=mg_earth.center_of_chunk.z},
		{x=mg_earth.center_of_chunk.x,		y=minp.y,							z=mg_earth.center_of_chunk.z},
		{x=maxp.x,						y=minp.y,							z=mg_earth.center_of_chunk.z},
		{x=minp.x,						y=minp.y,							z=maxp.z},
		{x=mg_earth.center_of_chunk.x,		y=minp.y,							z=maxp.z},
		{x=maxp.x,						y=minp.y,							z=maxp.z},
		{x=minp.x,						y=mg_earth.center_of_chunk.y,			z=minp.z},
		{x=mg_earth.center_of_chunk.x,		y=mg_earth.center_of_chunk.y,			z=minp.z},
		{x=maxp.x,						y=mg_earth.center_of_chunk.y,			z=minp.z},
		{x=minp.x,						y=mg_earth.center_of_chunk.y,			z=mg_earth.center_of_chunk.z},
		{x=mg_earth.center_of_chunk.x,		y=mg_earth.center_of_chunk.y,			z=mg_earth.center_of_chunk.z},
		{x=maxp.x,						y=mg_earth.center_of_chunk.y,			z=mg_earth.center_of_chunk.z},
		{x=minp.x,						y=mg_earth.center_of_chunk.y,			z=maxp.z},
		{x=mg_earth.center_of_chunk.x,		y=mg_earth.center_of_chunk.y,			z=maxp.z},
		{x=maxp.x,						y=mg_earth.center_of_chunk.y,			z=maxp.z},
		{x=minp.x,						y=maxp.y,							z=minp.z},
		{x=mg_earth.center_of_chunk.x,		y=maxp.y,							z=minp.z},
		{x=maxp.x,						y=maxp.y,							z=minp.z},
		{x=minp.x,						y=maxp.y,							z=mg_earth.center_of_chunk.z},
		{x=mg_earth.center_of_chunk.x,		y=maxp.y,							z=mg_earth.center_of_chunk.z},
		{x=maxp.x,						y=maxp.y,							z=mg_earth.center_of_chunk.z},
		{x=minp.x,						y=maxp.y,							z=maxp.z},
		{x=mg_earth.center_of_chunk.x,		y=maxp.y,							z=maxp.z},
		{x=maxp.x,						y=maxp.y,							z=maxp.z},
	}


	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	local t1 = os.clock()

	local index2d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do

			index2d = (z - minp.z) * csize.x + (x - minp.x) + 1
			
			--local nheat = nbuf_heatmap[z-minp.z+1][x-minp.x+1] + nbuf_heatblend[z-minp.z+1][x-minp.x+1]
			local nheat = get_heat_scalar(z) + nbuf_heatmap[z-minp.z+1][x-minp.x+1] + nbuf_heatblend[z-minp.z+1][x-minp.x+1]
			--local nhumid = nbuf_humiditymap[z-minp.z+1][x-minp.x+1] + nbuf_humidityblend[z-minp.z+1][x-minp.x+1]
			local nhumid = get_humid_scalar(z) + nbuf_humiditymap[z-minp.z+1][x-minp.x+1] + nbuf_humidityblend[z-minp.z+1][x-minp.x+1]

			local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = x, z = z}, 1)
			get_cell_neighbors(m_idx, m_z, m_x, 1)
			--local m_slope = (m_z - z) / (m_x - x)
			--local m_slope_inv = (m_x - x) / (m_z - z)
			local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = x, z = z}, 2)
			get_cell_neighbors(p_idx, p_z, p_x, 2)
			--local p_slope = (p_z - z) / (p_x - x)
			--local p_slope_inv = (p_x - x) / (p_z - z)
			--local p_ridge = sin(abs((tan((p_z - z) / (p_x - x))) + (tan((p_x - x) / (p_z - z)))))

			local bcontinental = ((m_dist * v_cscale) + (p_dist * v_pscale))
			local bterrain = ((mg_base_height + v7_max_height) - (m_dist * v_cscale)) - (p_dist * v_pscale)
			--local bterrain = ((mg_base_height + v7_max_height) - (m_dist * v_cscale)) - sin(abs((tan((p_z - z) / (p_x - x))) + (tan((p_x - x) / (p_z - z)))))

			local p_n = mg_neighbors[p_idx]
			local p_ni = get_nearest_midpoint({x = x, z = z}, p_n)
			local pe_dist = get_dist2endline_inverse({x = p_x, z = p_z}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = x, z = z})
			local p2e_dist = get_dist((p_x - p_n[p_ni].m_x), (p_z - p_n[p_ni].m_z), dist_metric)
			local n2pe_dist = get_dist2line({x = p_x, z = p_z}, {x = p_n[p_ni].n_x, z = p_n[p_ni].n_z}, {x = x, z = z})
			local pe_dir, pe_comp = get_direction_to_pos({x = x, z = z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})
			local e_slope = get_slope_inverse({x = p_x, z = p_z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})

			local v6_noise = get_v6_height(z,x)
			--local v7_height = get_v7_height(z,x)
			local v7_height = (get_v7_height(z,x) / v7_max_height) * (mg_world_scale / 0.01)
			--local v7_height = ((get_v7_height(z,x) / v7_max_height) * (mg_world_scale / 0.01) / v7_max_height) * (mg_world_scale / 0.01)

			local v6_height = 0
			if v7_height > 0 then
				--local d_height = (v6_noise * (v7_height / v7_max_height))
				local d_height = (v6_noise * (bterrain / mg_base_height))
				local d_humid = 0
				if nhumid < 50 then
					d_humid = (v6_noise * ((50 - nhumid) / 50))
				end
				v6_height = (d_height * 0.25) + (d_humid * 0.5)
			end
			
			local nterrain = v7_height + v6_height

			local vheight = (bterrain * 0.30) + ((((bterrain / bcontinental) * (mg_world_scale / 0.01)) * 0.30) * 0.35)
			local vterrain = (((bterrain + nterrain) * 0.25) + (((bterrain / bcontinental) * (mg_world_scale / 0.01)) * 0.35) + ((nterrain * (bterrain / mg_base_height)) * 0.5) * 0.35)

			mg_earth.valleymap[index2d] = -31000
			mg_earth.riverpath[index2d] = 0
			mg_earth.rivermap[index2d] = 0
			
			if mg_rivers_enabled then
				if vterrain >= 0 then

					local terrain_scalar_inv = (min(0,((250 * mg_world_scale) - vterrain)) / (250 * mg_world_scale))
					local r_size = mg_valley_size * terrain_scalar_inv
					
					if n2pe_dist >= (vterrain - r_size) then

						local t_sin = 0
						local t_terrain = vterrain
						-- if (e_slope >= -0.1) and (e_slope <= 0.1) then
							-- t_sin = sin(n2pe_dist * pe_dir.x)
						-- elseif (e_slope < -10) or (e_slope > 10) then
							-- t_sin = sin(n2pe_dist * pe_dir.z)
						-- else
							-- t_sin = sin(n2pe_dist + (x * pe_dir.x) + (z * pe_dir.z))
						-- end
						
						local v_sin = mg_valley_size + t_sin
						--local r_height = (vheight * 0.8)
						--local r_height = (vheight * 0.9)
						local r_height = vheight
						--if (pe_dist <= v_sin + max(0,(t_terrain - r_height))) and (pe_dist > v_sin + max(0,(t_terrain - r_height))) then
						--elseif (pe_dist <= v_sin + max(0,(t_terrain - r_height))) and (pe_dist > v_sin) then
							
						if (pe_dist <= v_sin + max(0,(t_terrain - r_height))) and (pe_dist > v_sin) then
							vterrain = min(r_height, t_terrain)
						elseif (pe_dist <= v_sin) then
							vterrain = min(r_height, t_terrain)
						end
					
						-- local v_floor = ((mg_valley_size * mg_valley_size) * 0.5)
						-- local v_lift = ((mg_valley_size * mg_valley_size) * 0.8)
						-- local v_rise = (mg_valley_size * mg_valley_size)
						
						-- if (pe_dist <= v_rise) and (pe_dist > v_lift) then
							-- vterrain = min((vheight + max(1,(t_terrain - vheight))), t_terrain)
						-- elseif (pe_dist <= v_lift) and (pe_dist > v_floor) then
							-- vterrain = min((vheight + max(0,(t_terrain - vheight))), t_terrain)
						-- elseif (pe_dist <= v_floor) then
							-- vterrain = min(vheight, t_terrain)
						-- end
						
						mg_earth.valleymap[index2d] = pe_dist
						mg_earth.riverpath[index2d] = t_sin
						
					end
				end
			end

			local t_y, t_c = get_terrain_height_cliffs(vterrain,z,x)

			mg_earth.heightmap[index2d] = t_y
			mg_earth.cliffmap[index2d] = t_c

			--local biome_name = calc_biome_from_noise(nheat,nhumid,{x=x,y=t_y,z=z})
			--mg_earth.biomemap[index2d] = biome_name
			mg_earth.biomemap[index2d] = calc_biome_from_noise(nheat,nhumid,{x=x,y=t_y,z=z})

			mg_earth.cellmap[index2d] = p_idx

			--mg_earth.eco_fill[index2d], mg_earth.eco_top[index2d] = get_dirt(z,x)
			--mg_earth.eco_map[index2d] = get_dirt(biome_name,z,x)
			mg_earth.eco_map[index2d] = get_dirt(z,x)

			mg_earth.hh_mod[index2d] = 0

			if z == minp.z then
				if x == minp.x then
					mg_earth.chunk_terrain["SW"]		= {x=minp.x,					y=t_y,		z=minp.z}
				elseif x == mg_earth.center_of_chunk.x then
					mg_earth.chunk_terrain["W"]			= {x=mg_earth.center_of_chunk.x,	y=t_y,		z=minp.z}
				elseif x == maxp.x then
					mg_earth.chunk_terrain["NW"]		= {x=maxp.x,					y=t_y,		z=minp.z}
				end
			elseif z == mg_earth.center_of_chunk.z then
				if x == minp.x then
					mg_earth.chunk_terrain["S"]			= {x=minp.x,					y=t_y,		z=mg_earth.center_of_chunk.z}
				elseif x == mg_earth.center_of_chunk.x then
					mg_earth.chunk_terrain["C"]			= {x=mg_earth.center_of_chunk.x,	y=t_y,		z=mg_earth.center_of_chunk.z}
				elseif x == maxp.x then
					mg_earth.chunk_terrain["N"]			= {x=maxp.x,					y=t_y,		z=mg_earth.center_of_chunk.z}
				end
			elseif z == maxp.z then
				if x == minp.x then
					mg_earth.chunk_terrain["SE"]		= {x=minp.x,					y=t_y,		z=maxp.z}
				elseif x == mg_earth.center_of_chunk.x then
					mg_earth.chunk_terrain["E"]			= {x=mg_earth.center_of_chunk.x,	y=t_y,		z=maxp.z}
				elseif x == maxp.x then
					mg_earth.chunk_terrain["NE"]		= {x=maxp.x,					y=t_y,		z=maxp.z}
				end
			end

--## MEAN, MIN, MAX ALTITUDES
			mean_alt = mean_alt + t_y
			if min_alt == -31000 then
				min_alt = t_y
			else
				min_alt = min(t_y,min_alt)
			end
			if max_alt == 31000 then
				max_alt = t_y
			else
				max_alt = max(t_y,max_alt)
			end

--## SPAWN SELECTION
			if z == mg_earth.player_spawn_point.z then
				if x == mg_earth.player_spawn_point.x then
					mg_earth.player_spawn_point.y = t_y
				end
			end
			if z == mg_earth.origin_y_val.z then
				if x == mg_earth.origin_y_val.x then
					mg_earth.origin_y_val.y = t_y
				end
			end

		end
	end

	mg_earth.chunk_mean_altitude = mean_alt / ((maxp.x - minp.x) * (maxp.z - minp.z))
	mg_earth.chunk_min_altitude = min_alt
	mg_earth.chunk_max_altitude = max_alt

	local t2 = os.clock()

	--mg_earth.generate(minp, maxp, seed)
		--aus.generate(minp, maxp, seed)
	
	local t3 = os.clock()


	local nixyz = 1
	local index2d = 0

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			local tcave1
			local tcave2

			if y < yblmin then
				tcave1 = TCAVE1 + ((yblmin - y) / BLEND) ^ 2
				tcave2 = TCAVE2 + ((yblmin - y) / BLEND) ^ 2
			elseif y > yblmax then
				tcave1 = TCAVE1 + ((y - yblmax) / BLEND) ^ 2
				tcave2 = TCAVE2 + ((y - yblmax) / BLEND) ^ 2
			else
				tcave1 = TCAVE1
				tcave2 = TCAVE2
			end
			for x = minp.x, maxp.x do

				index2d = (z - minp.z) * csize.x + (x - minp.x) + 1   
				local ivm = a:index(x, y, z)
				
				local t_biome = mg_earth.biomemap[index2d]
				local t_eco = mg_earth.eco_map[index2d]

				local t_filldepth = 4
				local t_top_depth = 1
				local t_riverbed_depth = 1
				local t_stone_height = (mg_earth.heightmap[index2d] - (t_filldepth + t_top_depth))
				local t_fill_height = (mg_earth.heightmap[index2d] - t_top_depth)

				local t_ignore = mg_earth.c_ignore
				local t_air  = mg_earth.c_air

				local t_node = t_ignore

				local t_stone = mg_earth.c_stone
				local t_filler = mg_earth.c_dirt
				local t_top = mg_earth.c_dirtgrass
				local t_snow = mg_earth.c_dirtsnow
				local t_sand = mg_earth.c_sand
				local t_ice = mg_earth.c_ice
				local t_water = mg_earth.c_water
				local t_river = mg_earth.c_river
				local t_riverbed = mg_earth.c_dirt
				local t_mud = mg_earth.c_dirt

				t_stone				= mg_earth.biome_info[t_biome].b_stone
				t_filler			= mg_earth.biome_info[t_biome].b_filler
				t_top				= mg_earth.biome_info[t_biome].b_top
				t_water				= mg_earth.biome_info[t_biome].b_water
				t_river				= mg_earth.biome_info[t_biome].b_river
				t_riverbed_depth	= mg_earth.biome_info[t_biome].b_riverbed_depth

				if mg_ecosystems then
					if (mg_earth.heightmap[index2d] > max_beach) and (mg_earth.heightmap[index2d] < max_highland) then
						if (not string.find(t_biome, "swamp")) or (not string.find(t_biome, "beach")) or (not string.find(t_biome, "highland"))
							 or (not string.find(t_biome, "ocean")) or (not string.find(t_biome, "mountain")) or (not string.find(t_biome, "strato"))then
							if mg_earth.eco_map[index2d] ~= "n0" then
								if (t_biome and (t_biome ~= "")) and (t_eco and (t_eco ~= "")) then
									if gal.ecosystems[t_biome] then
										if gal.ecosystems[t_biome][t_eco] then
											--minetest.log(t_biome .. ", " .. t_eco)
											t_stone				= gal.ecosystems[t_biome][t_eco].stone
											t_filler			= gal.ecosystems[t_biome][t_eco].fill
											t_top				= gal.ecosystems[t_biome][t_eco].top
											t_water				= mg_earth.biome_info[t_biome].b_water
											t_river				= gal.ecosystems[t_biome][t_eco].river
											t_riverbed_depth	= mg_earth.biome_info[t_biome].b_riverbed_depth
										end
									end
								end
							end
						end
					end
				end


				if mg_earth.cliffmap[index2d] > 0 then
					t_filler = t_stone
				end
				
				--if mg_earth.heightmap[index2d] > (max_highland + mg_earth.hh_mod[index2d]) then
				if mg_earth.heightmap[index2d] > max_highland then
					t_top = t_stone
					t_filler = t_stone
					t_stone = t_stone
					t_water = t_water
					t_river = t_ice
				end
				-- --if theight > ((max_mountain + h_mod) - (z / 100)) then
				--if mg_earth.heightmap[index2d] > (max_mountain + mg_earth.hh_mod[index2d]) then
				if mg_earth.heightmap[index2d] > max_mountain then
					t_top = t_ice
					t_filler = t_stone
					t_water = t_ice
					t_river = t_ice
				end

				if mg_rivers_enabled then
					local r_path = mg_earth.valleymap[index2d] + mg_earth.riverpath[index2d]
					local r_size = t_riverbed_depth * mg_river_size
					--local r_size = t_riverbed_depth + t_rivermap
					if (r_path >= 0) and (r_path <= r_size) then
						if y >= (mg_water_level - r_path) then
							if y >= (t_stone_height + r_path) and y < t_fill_height then
								t_filler = t_river
							else
								t_filler = t_riverbed
							end
							if y > mg_water_level then
								t_top = t_air
							else
								t_top = t_river
							end
						end
					end
				end

				if y < t_stone_height then
					t_node = t_stone
				elseif y >= t_stone_height and y < t_fill_height then
					t_node = t_filler
				elseif y >= t_fill_height and y <= mg_earth.heightmap[index2d] then
					t_node = t_top
				elseif y > mg_earth.heightmap[index2d] and y <= mg_water_level then
					--Water Level (Sea Level)
					t_node = t_water
				end

				if mg_caves_enabled then
					if (y <= mg_earth.heightmap[index2d]) and (y >= (mg_water_level - 10)) and (mg_earth.valleymap[index2d] > 10) then
						local ncave1 = nbuf_cave1[nixyz]
						local ncave2 = nbuf_cave2[nixyz]

						if (ncave2 > tcave2) then
							if string.find(mg_earth.biomemap[index2d], "_humid") or string.find(mg_earth.biomemap[index2d], "_semihumid") then
								t_node = t_air
							end
						end
						if (ncave1 > tcave1) and (ncave2 > tcave2) then
							if string.find(mg_earth.biomemap[index2d], "_temperate") then
								t_node = t_air
							end
						end
						if (ncave1 > tcave1) or (ncave2 > tcave2) then
							if string.find(mg_earth.biomemap[index2d], "_arid") or string.find(mg_earth.biomemap[index2d], "_semiarid") then
								t_node = t_air
							end
							if string.find(mg_earth.biomemap[index2d], "_coastal") or string.find(mg_earth.biomemap[index2d], "_beach") or string.find(mg_earth.biomemap[index2d], "_ocean") then
								if y <= mg_water_level then
									t_node = t_water
								end
							end
						end
					end
				end

				data[ivm] = t_node

				nixyz = nixyz + 1

				write = true

			end
		end
	end

	local t4 = os.clock()

	if write then
		vm:set_data(data)
	end

	local t5 = os.clock()
	
	if write then

		minetest.generate_ores(vm,minp,maxp)
		minetest.generate_decorations(vm,minp,maxp)
			
		vm:set_lighting({day = 0, night = 0})
		vm:calc_lighting()
		vm:update_liquids()
	end

	local t6 = os.clock()

	if write then
		vm:write_to_map()
	end

	local t7 = os.clock()

	-- Print generation time of this mapchunk.
	local chugent = math.ceil((os.clock() - t0) * 1000)
	print(("[mg_earth] Generating from %s to %s"):format(minetest.pos_to_string(minp), minetest.pos_to_string(maxp)) .. "  :  " .. chugent .. " ms")
	--print("[mg_earth] Mapchunk generation time " .. chugent .. " ms")

	table.insert(mapgen_times.noisemaps, 0)
	table.insert(mapgen_times.preparation, t1 - t0)
	table.insert(mapgen_times.loop3d, t2 - t1)
	table.insert(mapgen_times.loop2d, t3 - t2)
	table.insert(mapgen_times.mainloop, t4 - t3)
	table.insert(mapgen_times.setdata, t5 - t4)
	table.insert(mapgen_times.liquid_lighting, t6 - t5)
	table.insert(mapgen_times.writing, t7 - t6)
	table.insert(mapgen_times.make_chunk, t7 - t0)

	-- Deal with memory issues. This, of course, is supposed to be automatic.
	local mem = math.floor(collectgarbage("count")/1024)
	if mem > 1000 then
		print("mg_earth is manually collecting garbage as memory use has exceeded 500K.")
		collectgarbage("collect")
	end
end)


	local function mean( t )
		local sum = 0
		local count= 0
	
		for k,v in pairs(t) do
			if type(v) == 'number' then
				sum = sum + v
				count = count + 1
			end
		end
	
		return (sum / count)
	end

	minetest.register_on_shutdown(function()


		save_neighbors(n_file)
		
		if #mapgen_times.make_chunk == 0 then
			return
		end
	
		local average, standard_dev
		minetest.log("mg_earth lua Mapgen Times:")
	
		average = mean(mapgen_times.noisemaps)
		minetest.log("  noisemaps: - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.preparation)
		minetest.log("  preparation: - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.loop2d)
		minetest.log(" 2D Noise loops: - - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.loop3d)
		minetest.log(" 3D Noise loops: - - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.mainloop)
		minetest.log(" Main Render loops: - - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.setdata)
		minetest.log("  writing: - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.liquid_lighting)
		minetest.log("  liquid_lighting: - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.writing)
		minetest.log("  writing: - - - - - - - - - - - - - - - -  "..average)

		average = mean(mapgen_times.make_chunk)
		minetest.log("  makeChunk: - - - - - - - - - - - - - - -  "..average)
	
	end)




minetest.log("[MOD] mg_earth:  Successfully loaded.")




