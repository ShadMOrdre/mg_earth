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


minetest.log("[MOD] mg_earth:  Loading...")
minetest.log("[MOD] mg_earth:  Version:" .. mg_earth.ver_str)
minetest.log("[MOD] mg_earth:  Legal Info: Copyright " .. mg_earth.copyright .. " " .. mg_earth.authorship .. "")
minetest.log("[MOD] mg_earth:  License: " .. mg_earth.license .. "")



-- if minetest.get_mapgen_setting("mg_name") ~= "singlenode" then
	-- return
-- end

mg_earth.enabled = true
-- mg_earth.enabled = false
if mg_earth.enabled == false then
	return
end

mg_earth.settings = {
	mg_world_scale				= tonumber(minetest.settings:get("mg_earth.mg_world_scale")) or 1.0,
	mg_base_height				= tonumber(minetest.settings:get("mg_earth.mg_base_height")) or 300,
	sea_level					= tonumber(minetest.settings:get("mg_earth.sea_level")) or 1,
	flat_height					= tonumber(minetest.settings:get("mg_earth.flat_height")) or 5,
	river_width					= tonumber(minetest.settings:get("mg_earth.river_width")) or 20,
	enable_rivers				= minetest.settings:get_bool("mg_earth.enable_rivers") or false,
	enable_caves				= minetest.settings:get_bool("mg_earth.enable_caves") or false,
	enable_caverns				= minetest.settings:get_bool("mg_earth.enable_caverns") or false,
	enable_lakes				= minetest.settings:get_bool("mg_earth.enable_lakes") or false,
	enable_boulders				= true,
	enable_streets				= true,
	street_width				= 1,
	street_sin_amplitude		= 50,
	street_sin_frequency		= 0.01,
	street_grid_width			= 1000,
	street_min_height			= 4,
	street_max_height			= 150,	--40
	street_terrain_min_height	= -2,
	enable_roads				= true,
	road_width					= 1,
	road_sin_amplitude			= 50,
	road_sin_frequency			= 0.0125,
	road_grid_width				= 500,
	road_min_height				= 4,
	road_max_height				= 180,	--50
	road_terrain_min_height		= -2,
	enable_paths				= true,
	path_width					= 2,
	path_sin_amplitude			= 25,
	path_sin_frequency			= 0.025,
	path_grid_width				= 250,
	path_min_height				= 4,
	path_max_height				= 200,	--60
	path_terrain_min_height		= -2,
	heat_scalar					= minetest.settings:get_bool("mg_earth.enable_heat_scalar") or false,
	humidity_scalar				= minetest.settings:get_bool("mg_earth.enable_humidity_scalar") or false,
	-- Options: 1-12.  Default = 1.  See table 'mg_heightmap_select_options' below for description.
	-- 1 = vEarth, 2 = v3D, 3 = v6, 4 = v67, 5 = v7, 6 = vCarp, 7 = vIslands, 8 = vValleys, 9 = vFlat, 10 = vVoronoi,
	-- 11 = vVoronoiPlus, 12 = vSpheres, 13 = vCubes, 14 = vDiamonds, 15 = vPlanetoids, 16 = vVoronoiCell, 17 = v3dNoise, 18 = v2dNoise, 19 = "vRand3D"
	heightmap					= tonumber(minetest.settings:get("mg_earth.heightmap")) or 8,
	noisemap					= 19,
	-- Options: 1-4.  Default = 4.  1 = chebyshev, 2 = euclidean, 3 = manhattan, 4 = (chebyshev + manthattan) / 2
	voronoi_distance			= tonumber(minetest.settings:get("mg_earth.voronoi_distance")) or 3,
	--manual seed options.		The named seeds below were used during dev, but were interesting enough to include.  The names were entered in the menu, and these resulted.
	--Default					= Terraria
	--		Terraria			= "16096304901732432682",
	--			Terraria mix	= "17324326821609630490"
	--			Ariaterr		= "17324326821609630490",
	--		TheIsleOfSodor		= "4866059420164947791",
	--			Sodor mix		= "1649477914866059420"
	--		TheGardenOfEden		= "4093201477345457311",
	--			Eden mix		= "7345457311409320147"
	-- 		Fermat				= "14971822871466973040",	
	--		Patience			= "7986080089770239873",
	--			Patience mix	= "9770239873798608008"
	--		Home				= "11071344221654115949",
	--			Home mix		= "16541159491107134422"
	--		Gaia				= "388272015917266855",			--snow forest coast
	--		Theia				= "130097141630163915",			--very  hilly
	--		Eufrisia			= "6535600191662084952",
	--		Coluerica			= "9359082767202495376",
	--		Pando				= "9237930693197265599",		--mountainous desert
	--		Pangaea				= "5475850681584857691",
	--		Gondwana			= "11779916298069921535",
	--		Alone				= "11763298958449250406",		--ocean
	--			Alone mix		= "25040611763298958449"
	--		Agape				= "12213145824342997182",		--very  hilly and dry
	--		Walmart				= "5081532735129490002",
	--		riptiderazor		= "9669210684502096314"
	--		PharrMana			= "18217774043071924725"
	--		Minetest			= "10165813357553435001"		--rocky terrain
	--		Ukraine				= "14828335442226763674"		--desert mountain
	--		MiddleEarth			= "12450724596403949764"
	--		Laurentia			= "17325403042080800314"
	--		AlphaCentauri		= "18396784063229894250"
	--		Ascad				= "12895840871375575661"
	--		Cambraea			= "12744930397153043766"
	--		Dagobah				= "7715333272270809012"
	--		Westeros			= "60511299203150728"
	--		Tethys				= "14649545929652778322"
	--		Anglaea				= "18092077199824008846"
	seed						= minetest.settings:get("mg_earth.seed") or "12744930397153043766",
	--voronoi_file				= minetest.settings:get("mg_earth.voronoi_file") or "points_earth",
	--voronoi_file				= "points_earth",					--		"points_dev_isle"
	voronoi_file				= tonumber(minetest.settings:get("mg_earth.voronoi_file")) or 1,
	--voronoi_neighbor_file_suf	= minetest.settings:get("mg_earth.voronoi_neighbor_file_suf") or "neighbors",
	voronoi_neighbor_file_suf	= "neighbors",

	np_2d_base					= minetest.settings:get_np_group("mg_earth.np_2d_base") or {offset=-4,scale=25,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2.11,},
	np_2d_alt					= minetest.settings:get_np_group("mg_earth.np_2d_alt") or {offset=-4,scale=70,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2.11,},
	np_2d_peak					= 														   {offset=-4,scale=105,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
	np_2d_sin					= minetest.settings:get_np_group("mg_earth.np_2d_sin") or {offset=0,scale=1.2,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.11,},
	--np_2d_sin					= minetest.settings:get_np_group("mg_earth.np_2d_sin") or {offset=0,scale=1.2,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.3,lacunarity=2,},
	np_river_jitter				= minetest.settings:get_np_group("mg_earth.np_river_jitter") or {offset=0,scale=50,spread={x=512,y=512,z=512},seed=513337,octaves=7,persist=0.6,lacunarity=2.11,},
	-- np_road_jitter				= minetest.settings:get_np_group("mg_earth.np_road_jitter") or {offset=0,scale=50,spread={x=512,y=512,z=512},seed=8675309,octaves=7,persist=0.6,lacunarity=2.11,},

	-- np_v7_alt					= minetest.settings:get_np_group("mg_earth.np_v7_alt") or {offset=-4,scale=25,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2,},
	np_v7_alt					= minetest.settings:get_np_group("mg_earth.np_v7_alt") or {offset=-4,scale=25,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
	-- np_v7_base					= minetest.settings:get_np_group("mg_earth.np_v7_base") or {offset=-4,scale=140,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2,},
	np_v7_base					= minetest.settings:get_np_group("mg_earth.np_v7_base") or {offset=-4,scale=70,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
	-- np_v7_base					= minetest.settings:get_np_group("mg_earth.np_v7_base") or {offset=-4,scale=70,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
	-- np_v7_peak					= 														   {offset=-4,scale=196,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2,},
	np_v7_peak					= 														   {offset=-4,scale=140,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
	np_v7_height				= minetest.settings:get_np_group("mg_earth.np_v7_height") or {offset=0.5,scale=1,spread={x=500,y=500,z=500},seed=4213,octaves=7,persist=0.6,lacunarity=2,},
	-- np_v7_height				= minetest.settings:get_np_group("mg_earth.np_v7_height") or {offset=0.5,scale=1,spread={x=750,y=750,z=750},seed=4213,octaves=7,persist=0.6,lacunarity=2,},
	np_v7_persist				= minetest.settings:get_np_group("mg_earth.np_v7_persist") or {offset=0.6,scale=0.1,spread={x=2000,y=2000,z=2000},seed=539,octaves=3,persist=0.6,lacunarity=2,},

	np_v6_base					= minetest.settings:get_np_group("mg_earth.np_v6_base") or {offset=-4,scale=20,spread={x=250,y=250,z=250},seed=82341,octaves=5,persist=0.6,lacunarity=2,},
	np_v6_higher				= minetest.settings:get_np_group("mg_earth.np_v6_higher") or {offset=20,scale=16,spread={x=500,y=500,z=500},seed=85039,octaves=5,persist=0.6,lacunarity=2,},
	np_v6_steep					= minetest.settings:get_np_group("mg_earth.np_v6_steep") or {offset=0.85,scale=0.5,spread={x=125,y=125,z=125},seed=-932,octaves=5,persist=0.7,lacunarity=2,},
	np_v6_height				= minetest.settings:get_np_group("mg_earth.np_v6_height") or {offset=0,scale=1,spread={x=250,y=250,z=250},seed=4213,octaves=5,persist=0.69,lacunarity=2,},

	np_v5_factor				= minetest.settings:get_np_group("mg_earth.np_v5_factor") or {offset=0,scale=1,spread={x=250,y=250,z=250},seed=920381,octaves=3,persist=0.45,lacunarity=2,},
	np_v5_height				= minetest.settings:get_np_group("mg_earth.np_v5_height") or {offset=0,scale=10,spread={x=250,y=250,z=250},seed=84174,octaves=4,persist=0.5,lacunarity=2,},
	np_v5_ground				= minetest.settings:get_np_group("mg_earth.np_v5_ground") or {offset=0,scale=40,spread={x=80,y=80,z=80},seed=983240,octaves=4,persist=0.55,lacunarity=2,},

	--np_val_terrain				= minetest.settings:get_np_group("mg_earth.np_val_terrain") or {offset=-10,scale=50,spread={x=1024,y=1024,z=1024},seed=5934,octaves=6,persist=0.4,lacunarity=2,},
	np_val_terrain				= minetest.settings:get_np_group("mg_earth.np_val_terrain") or {offset=-10,scale=50,spread={x=1024,y=1024,z=1024},seed=5202,octaves=6,persist=0.4,lacunarity=2,},
	np_val_river				= minetest.settings:get_np_group("mg_earth.np_val_river") or {offset=0,scale=1,spread={x=256,y=256,z=256},seed=-6050,octaves=5,persist=0.6,lacunarity=2,},
	np_val_depth				= minetest.settings:get_np_group("mg_earth.np_val_depth") or {offset=5,scale=4,spread={x=512,y=512,z=512},seed=-1914,octaves=1,persist=1,lacunarity=2,},
	np_val_profile				= minetest.settings:get_np_group("mg_earth.np_val_profile") or {offset=0.6,scale=0.5,spread={x=512,y=512,z=512},seed=777,octaves=1,persist=1,lacunarity=2,},
	np_val_slope				= minetest.settings:get_np_group("mg_earth.np_val_slope") or {offset=0.5,scale=0.5,spread={x=128,y=128,z=128},seed=746,octaves=1,persist=1,lacunarity=2,},
	np_val_fill					= minetest.settings:get_np_group("mg_earth.np_val_fill") or {offset=0,scale=1,spread={x=256,y=512,z=256},seed=1993,octaves=6,persist=0.8,lacunarity=2,},

--vCarpathian Noises
	np_carp_base				= minetest.settings:get_np_group("mg_earth.np_carp_base") or {offset = 1, scale = 1, spread = {x = 8192, y = 8192, z = 8192}, seed = 211, octaves = 6, persist = 0.8, lacunarity = 0.5},
	np_carp_filler_depth		= minetest.settings:get_np_group("mg_earth.np_carp_filler_depth") or {offset = 0, scale = 1, spread = {x = 512, y = 512, z = 512}, seed = 261, octaves = 3, persist = 0.7, lacunarity = 2},
	np_carp_terrain_step		= minetest.settings:get_np_group("mg_earth.np_carp_terrain_step") or {offset = 1, scale = 1, spread = {x = 1889, y = 1889, z = 1889}, seed = 4157, octaves = 5, persist = 0.5, lacunarity = 2},
	np_carp_terrain_hills		= minetest.settings:get_np_group("mg_earth.np_carp_terrain_hills") or {offset = 1, scale = 1, spread = {x = 1301, y = 1301, z = 1301}, seed = 1692, octaves = 5, persist = 0.5, lacunarity = 2},
	np_carp_terrain_ridge		= minetest.settings:get_np_group("mg_earth.np_carp_terrain_ridge") or {offset = 1, scale = 1, spread = {x = 1889, y = 1889, z = 1889}, seed = 3568, octaves = 5, persist = 0.5, lacunarity = 2},
	np_carp_height1				= minetest.settings:get_np_group("mg_earth.np_carp_height1") or {offset = 0, scale = 5, spread = {x = 251, y = 251, z = 251}, seed = 9613, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
	np_carp_height2				= minetest.settings:get_np_group("mg_earth.np_carp_height2") or {offset = 0, scale = 5, spread = {x = 383, y = 383, z = 383}, seed = 1949, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
	np_carp_height3				= minetest.settings:get_np_group("mg_earth.np_carp_height3") or {offset = 0, scale = 5, spread = {x = 509, y = 509, z = 509}, seed = 3211, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
	np_carp_height4				= minetest.settings:get_np_group("mg_earth.np_carp_height4") or {offset = 0, scale = 5, spread = {x = 631, y = 631, z = 631}, seed = 1583, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
	np_carp_hills				= minetest.settings:get_np_group("mg_earth.np_carp_hills") or {offset = 0, scale = 3, spread = {x = 257, y = 257, z = 257}, seed = 6604, octaves = 6, persist = 0.5, lacunarity = 2},
	np_carp_mnt_step			= minetest.settings:get_np_group("mg_earth.np_carp_mnt_step") or {offset = 0, scale = 8, spread = {x = 509, y = 509, z = 509}, seed = 2590, octaves = 6, persist = 0.6, lacunarity = 2},
	np_carp_mnt_ridge			= minetest.settings:get_np_group("mg_earth.np_carp_mnt_ridge") or {offset = 0, scale = 12, spread = {x = 743, y = 743, z = 743}, seed = 5520, octaves = 6, persist = 0.7, lacunarity = 2},
	np_carp_mnt_var				= minetest.settings:get_np_group("mg_earth.np_carp_mnt_var") or {offset = 0, scale = 1, spread = {x = 499, y = 499, z = 499}, seed = 2490, octaves = 5, persist = 0.55, lacunarity = 2},


	np_3dterrain				= minetest.settings:get_np_group("mg_earth.np_3dterrain") or {offset=0,scale=1,spread={x=384,y=192,z=384},seed=5934,octaves=5,persist=0.5,lacunarity=2.11,},

	np_cliffs					= minetest.settings:get_np_group("mg_earth.np_cliffs") or {offset=0,scale=0.72,spread={x=180,y=180,z=180},seed=82735,octaves=5,persist=0.5,lacunarity=2.15,},
	-- np_cliffs					= minetest.settings:get_np_group("mg_earth.np_cliffs") or {offset=0,scale=0.72,spread={x=720,y=720,z=720},seed=82735,octaves=5,persist=0.5,lacunarity=2.15,},

	np_fill						= minetest.settings:get_np_group("mg_earth.np_fill") or {offset=0,scale=1.2,spread={x=150,y=150,z=150},seed=261,octaves=3,persist=0.7,lacunarity=2,},
	-- np_fill						= minetest.settings:get_np_group("mg_earth.np_fill") or {offset=0,scale=12,spread={x=150,y=150,z=150},seed=261,octaves=3,persist=0.7,lacunarity=2,},

	np_cave1					= minetest.settings:get_np_group("mg_earth.np_cave1") or {offset=0,scale=12,spread={x=61,y=61,z=61},seed=52534,octaves=3,persist=0.5,lacunarity=2,},
	-- np_cave1					= minetest.settings:get_np_group("mg_earth.np_cave1") or {offset=0,scale=12,spread={x=61,y=61,z=61},seed=52534,octaves=5,persist=0.6,lacunarity=2.11,},
	np_cave2					= minetest.settings:get_np_group("mg_earth.np_cave2") or {offset=0,scale=12,spread={x=67,y=67,z=67},seed=10325,octaves=3,persist=0.5,lacunarity=2,},
	-- np_cave2					= minetest.settings:get_np_group("mg_earth.np_cave2") or {offset=0,scale=12,spread={x=67,y=67,z=67},seed=10325,octaves=5,persist=0.6,lacunarity=2.11,},
	np_cavern1					= minetest.settings:get_np_group("mg_earth.np_cavern1") or {offset=0,scale=1,spread={x=192,y=96,z=192},seed=59033,octaves=5,persist=0.5,lacunarity=2,},
	np_cavern2					= minetest.settings:get_np_group("mg_earth.np_cavern2") or {offset=0,scale=1,spread={x=768,y=256,z=768},seed=10325,octaves=6,persist=0.63,lacunarity=2,},
	np_wave						= minetest.settings:get_np_group("mg_earth.np_wave") or {offset=0,scale=1,spread={x=256,y=256,z=256},seed=-400000000089,octaves=3,persist=0.67,lacunarity=2,},
	np_cave_biome				= minetest.settings:get_np_group("mg_earth.np_cave_biome") or {offset=0,scale=1,spread={x=250,y=250,z=250},seed=9130,octaves=3,persist=0.5,lacunarity=2,},

}

--THE FOLLOWING SETTINGS CAN BE CHANGED VIA THE MAIN MENU

minetest.set_mapgen_setting("seed", mg_earth.settings.seed, true)
minetest.set_mapgen_setting("mg_flags", "nocaves, nodungeons, light, decorations, biomes, ores", true)
mg_earth.mg_seed = minetest.get_mapgen_setting("seed")

mg_earth.config = {}

--World Scale:  Supported values range from 0.01 to 1.0.  This scales the voronoi cells and noise values.
local mg_world_scale						= mg_earth.settings.mg_world_scale
if mg_world_scale < 0.01 then
	mg_world_scale = 0.01
-- elseif mg_world_scale > 1.0 then
	-- mg_world_scale = 1.0
end
--This value is multiplied by 1.4 or added to max v7 noise height.  From this total, cell distance is then subtracted.
local mg_base_height						= mg_earth.settings.mg_base_height * mg_world_scale

--Sets the water level used by the mapgen.  This should / could use map_meta value, but that is less controllable.
-- local mg_water_level						= mg_earth.settings.sea_level * mg_world_scale
local mg_water_level						= mg_earth.settings.sea_level
-- mg_earth.water_level						= mg_earth.settings.sea_level * mg_world_scale
mg_earth.water_level						= mg_earth.settings.sea_level

--Sets the height of the flat mapgen
mg_earth.config.mg_flat_height				= mg_earth.settings.flat_height

--Sets the max width of rivers.  Needs work.
mg_earth.config.mg_river_size				= mg_earth.settings.river_width * mg_world_scale

--Enables voronoi rivers.  Valleys are naturally formed at the edges of voronoi cells in this mapgen.  This turns those edges into rivers.
mg_earth.config.mg_rivers_enabled			= mg_earth.settings.enable_rivers

--Enables cave generation.
mg_earth.config.mg_caves_enabled			= mg_earth.settings.enable_caves

--Enables cave generation.
mg_earth.config.mg_caverns_enabled			= mg_earth.settings.enable_caverns

--Enables lake generation.
mg_earth.config.mg_lakes_enabled			= mg_earth.settings.enable_lakes

--Boulders
mg_earth.config.mg_boulders					= mg_earth.settings.enable_boulders

--Streets
mg_earth.config.mg_streets					= mg_earth.settings.enable_streets
mg_earth.config.mg_street_size				= mg_earth.settings.street_width
mg_earth.config.mg_street_sin_amp			= mg_earth.settings.street_sin_amplitude
mg_earth.config.mg_street_sin_freq			= mg_earth.settings.street_sin_frequency
mg_earth.config.mg_street_grid				= mg_earth.settings.street_grid_width
mg_earth.config.mg_street_min_height		= mg_earth.settings.street_min_height
mg_earth.config.mg_street_max_height		= mg_earth.settings.street_max_height
mg_earth.config.mg_street_terrain_min_height= mg_earth.settings.street_terrain_min_height

--Roads
mg_earth.config.mg_roads					= mg_earth.settings.enable_roads
mg_earth.config.mg_road_size				= mg_earth.settings.road_width
mg_earth.config.mg_road_sin_amp				= mg_earth.settings.road_sin_amplitude
mg_earth.config.mg_road_sin_freq			= mg_earth.settings.road_sin_frequency
mg_earth.config.mg_road_grid				= mg_earth.settings.road_grid_width
mg_earth.config.mg_road_min_height			= mg_earth.settings.road_min_height
mg_earth.config.mg_road_max_height			= mg_earth.settings.road_max_height
-- mg_earth.config.mg_road_max_height			= mg_base_height * 0.1
mg_earth.config.mg_road_terrain_min_height	= mg_earth.settings.road_terrain_min_height

mg_earth.config.mg_paths					= mg_earth.settings.enable_paths
mg_earth.config.mg_path_size				= mg_earth.settings.path_width
mg_earth.config.mg_path_sin_amp				= mg_earth.settings.path_sin_amplitude
mg_earth.config.mg_path_sin_freq			= mg_earth.settings.path_sin_frequency
mg_earth.config.mg_path_grid				= mg_earth.settings.path_grid_width
mg_earth.config.mg_path_min_height			= mg_earth.settings.path_min_height
mg_earth.config.mg_path_max_height			= mg_earth.settings.path_max_height
mg_earth.config.mg_path_terrain_min_height	= mg_earth.settings.path_terrain_min_height

local HSAMP = 0.025 -- Height select amplitude.
					-- Controls maximum steepness of paths.
local DEBUG = false -- Print generation time



--Sets whether to use true earth like heat distribution.  Hot equator, cold polar regions.
mg_earth.config.use_heat_scalar				= mg_earth.settings.heat_scalar
--Sets whether to use rudimentary earthlike humidity distribution.  Some latitudes appear to carry more moisture than others.
mg_earth.config.use_humid_scalar			= mg_earth.settings.humidity_scalar

--Heightmap generation method options.
mg_earth.mg_heightmap_select_options = {
	"vEarth",		--1
	"v3D",			--2
	"v5",			--3
	"v6",			--4
	"v67",			--5
	"v7",			--6
	"vCarp2D",		--7
	"vCarp3D",		--8
	"vIslands",		--9
	"vValleys",		--10
	"vValleys3D",	--11
	"vFlat",		--12
	"vVoronoi",		--13
	"vVoronoiPlus",	--14
	"vSpheres",		--15
	"vCubes",		--16
	"vDiamonds",	--17
	"vPlanetoids",	--18
	"vPlanets",		--19
	"vSolarSystem",	--20
	"vVoronoiCell",	--21
	"v3dNoise",		--22
	"v2dNoise",		--23
	"vFill",		--24
	"vRand2D",		--25
	"vRand3D",		--26
	"vDev_01",		--27
--	"vDiaSqr",		--28
	"vStraight3D",	--28
	"Builtin",		--29
}
local mg_heightmap_select					= mg_earth.mg_heightmap_select_options[mg_earth.settings.heightmap]
if minetest.get_mapgen_setting("mg_name") ~= "singlenode" then
	-- mg_heightmap_select = 29
end

--Allowed options: c, e, m, cm.		These stand for Chebyshev, Euclidean, Manhattan, and Chebyshev Manhattan.  They determine the type of voronoi
--cell that is produces.  Chebyshev produces square cells.  Euclidean produces circular cells.  Manhattan produces diamond cells.
mg_earth.dist_metrics = {
	"c",
	"e",
	"m",
	"cm",
}
local dist_metric							= mg_earth.dist_metrics[mg_earth.settings.voronoi_distance]

--The following allows the use of custom voronoi point sets.  All point sets must be a file that returns a specially formatted lua table.  The file
--must exist in the point_sets folder within the mod.  Current sets are points_earth, (the default), and points_dev_isle
--OPTIONS:		points_earth (default), points_dev_isle, points_dev_isle_02
local voronoi_point_files = {
	"points_earth",
	"points_3D",
	"points_3D_SolSys",
	"points_pangeae",
	"points_earth_isle",
	"points_dev_isle",
	"points_terra",
	"points_grid",
	"points_dev",
}

p_file = voronoi_point_files[mg_earth.settings.voronoi_file]

if mg_heightmap_select == "vPlanets" or mg_heightmap_select == "vRand3D" then
	p_file									= voronoi_point_files[2]
end

if mg_heightmap_select == "vSolarSystem" then
	p_file									= voronoi_point_files[3]
end

--The following is the name of a file that is created on shutdown of all voronoi cells and their respective neighboring cells.  A unique file is created based on mg_world_scale.
--n_file = p_file .. "_" .. mg_earth.settings.voronoi_neighbor_file_suf .. ""
n_file = p_file .. "_" .. tostring(mg_world_scale) .. "_" .. dist_metric .. "_" .. mg_earth.settings.voronoi_neighbor_file_suf .. ""


local mg_points = dofile(mg_earth.path .. "/point_sets/" .. p_file .. ".lua")
local mg_neighbors = {}

mg_earth.mg_points = mg_points


--The following section are possible additional user exposed settings.

--local mg_3d_terrain_enabled		= false

--Noise heightmap additive options for vEarth mapgen.
local mg_noise_select_options = {
	"v2d",							--1			--Single 2D Noise
	"v6",							--2			--v6 Terrain (No caves)
	"v6Carp",						--3			--v6 + Carpathian
	"v6CarpIslands",				--4			--v6 + Islands Carpathian
	"v67",							--5			--v6 + v7
	"v67Carp",						--6			--v6 + v7 + Carpathian
	"v67CarpIslands",				--7			--v6 + v7 + Islands Carpathian
	"v67Islands",					--8			--v6 + v7 + Islands
	"v7",							--9			--v7
	"v7Carp",						--10		--v7 + Carpathian
	"vCarp",						--11		--Carpathian
	"vCarpIslands",					--12		--Islands Carpathian
	"vCust",						--13		--Customized Noise.  (v7 base and alt noises Islands, then Islands again.
	"vIslands",						--14		--Islands
	"vValleys",						--15		--Valleys 2d
	"v67Valleys",					--16		--v6 + v7 + Valleys 2d
	"v3D",							--17		--3D Terrain
	"vFill",						--18		--No additional noise
	"None",							--19		--No additional noise
}
local mg_noise_select						= mg_noise_select_options[mg_earth.settings.noisemap]

-- local mg_enable_noise_2d					=  false
-- local mg_enable_noise_3d					=  false
-- local mg_enable_noise_v6					=  true
-- local mg_enable_noise_v7					=  true
-- local mg_enable_noise_vCarp				=  false
-- local mg_enable_noise_vIslands			=  true
-- local mg_enable_noise_vValleys			=  false



--Determines percentage of base voronoi terrain, alt voronoi terrain, and noise terrain values that are then added together.
local noise_blend							= 0.65
--local noise_blend							= 0.40
--Determines density value used by 3D terrain generation
local mg_density							= 128
--Determines density value used by 3D cave generation
local mg_cave_density						= 54

--local mg_cave_width						= 0.09
local mg_cave_width							= 0.08
local mg_cave_thresh						= 1.0			-- Cave threshold: 1 = small rare caves,

-- -- Cave Parameters
local YMIN									= -31000 -- Cave realm limits
--local YMAX								= -256
local YMAX1									= -64
--local YMAX2								= -256
local YMAX2									= -64
local mg_cave_thresh1						= 0.9			-- Cave threshold: 1 = small rare caves,
local mg_cave_thresh2						= 0.6		-- 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume.
local BLEND									= 128		-- Cave blend distance near YMIN, YMAX

-- -- Stuff
local yblmin								= YMIN + BLEND * 1.5
local yblmax1								= YMAX1 - BLEND * 1.5
local yblmax2								= YMAX2 - BLEND * 1.5

mg_earth.DEEP_CAVE							= -7000 --level at which deep cave biomes take over
mg_earth.STAGCHA							= 0.002 --chance of stalagmites
mg_earth.STALCHA							= 0.003 --chance of stalactites
mg_earth.CRYSTAL							= 0.007 --chance of glow crystal formations
mg_earth.GIANTSCHA							= 0.001 --chance of giant mushroom formations
mg_earth.GIANTCCHA							= 0.001 --chance of giant crystal formations
mg_earth.STAGSCHA							= 0.002 --chance of glow salt crystal formations

--####
--##
--##	END CUSTOMIZATION OPTIONS.
--##
--####



--####
--##
--##	Settings below should not be changed at risk of crashing.
--##
--####


if (mg_world_scale < 1.0) and (mg_world_scale >= 0.1) then
	mg_earth.config.mg_river_size				= 5
	mg_earth.config.mg_caves_enabled			= false
	mg_earth.config.mg_caverns_enabled			= false
	mg_earth.config.mg_lakes_enabled			= false
elseif mg_world_scale < 0.1 then
	mg_earth.config.mg_rivers_enabled			= false
	mg_earth.config.mg_caves_enabled			= false
	mg_earth.config.mg_caverns_enabled			= false
	mg_earth.config.mg_lakes_enabled			= false
end

if mg_heightmap_select == "vDiaSqr" then
	
	dofile(mg_earth.path_mod.."/heightmap.lua")					--WORKING MAPGEN with and without biomes

end

if mg_heightmap_select == "vValleys" or mg_heightmap_select == "vValleys3D" then
	mg_earth.config.mg_rivers_enabled			= true
	--mg_earth.config.mg_river_size				= mg_earth.settings.river_width
	mg_earth.config.mg_river_size				= 5
end

if not ((mg_heightmap_select == "vEarth") or (mg_heightmap_select == "vValleys") or (mg_heightmap_select == "vValleys3D")) then
	mg_earth.config.mg_rivers_enabled			= false
end

if mg_heightmap_select == "v3D" then

	mg_earth.config.mg_rivers_enabled			= false
	mg_earth.config.mg_caves_enabled			= false
	mg_earth.config.mg_caverns_enabled			= false
	mg_earth.config.mg_lakes_enabled			= false

end

if mg_noise_select == "v3D" then

	--mg_earth.config.mg_rivers_enabled			= false
	mg_earth.config.mg_caves_enabled			= false
	mg_earth.config.mg_caverns_enabled			= false
	mg_earth.config.mg_lakes_enabled			= false

end	
	
--Enables use of gal provided ecosystems.  Disables ecosystems for all other biome related mods.
mg_earth.config.mg_ecosystems				= false
local eco_threshold = 1
local dirt_threshold = 0.5

mg_earth.config.v_tscale = 0.02
mg_earth.config.v_cscale = 0.05
mg_earth.config.v_pscale = 0.1
local v_mscale = 0.125


--Sets the max width of valley formation.  Also needs refining.
--mg_earth.config.mg_valley_size			= mg_earth.config.mg_river_size * mg_earth.config.mg_river_size
mg_earth.config.mg_valley_size				= mg_earth.config.mg_river_size * 5

mg_earth.config.river_size_factor			= mg_earth.config.mg_river_size / 100
	
mg_earth.config.biome_vertical_range		=  mg_base_height / 5

--Sets altitude ranges.
local ocean_depth							= (mg_base_height * -1) * mg_world_scale
local beach_depth							= -4 * mg_world_scale
mg_earth.config.max_beach					= 4 * mg_world_scale
mg_earth.config.max_coastal					= mg_water_level + mg_earth.config.biome_vertical_range
mg_earth.config.max_lowland					= mg_earth.config.max_coastal + mg_earth.config.biome_vertical_range
mg_earth.config.max_shelf					= mg_earth.config.max_lowland + mg_earth.config.biome_vertical_range
mg_earth.config.max_highland				= mg_earth.config.max_shelf + mg_earth.config.biome_vertical_range
mg_earth.config.max_mountain				= mg_earth.config.max_highland + (mg_earth.config.biome_vertical_range * 2)

--dofile(mg_earth.path .. "/voxel.lua")

mg_earth.default							= minetest.global_exists("default")
mg_earth.gal								= minetest.global_exists("gal")
mg_earth.nodes_nature						= minetest.global_exists("nodes_nature")

if mg_earth.gal then
	mg_world_scale							= gal.mapgen.mg_world_scale
	mg_water_level							= gal.mapgen.water_level
	mg_base_height							= gal.mapgen.mg_base_height
	-- mg_earth.config.biome_vertical_range	= (gal.mapgen.mg_base_height / 4)
	-- mg_earth.config.max_beach				= gal.mapgen.maxheight_beach
	-- mg_earth.config.max_coastal				= gal.mapgen.sea_level + gal.mapgen.biome_vertical_range
	-- mg_earth.config.max_lowland				= gal.mapgen.maxheight_coastal + gal.mapgen.biome_vertical_range
	-- mg_earth.config.max_shelf				= gal.mapgen.maxheight_lowland + gal.mapgen.biome_vertical_range
	-- mg_earth.config.max_highland			= gal.mapgen.maxheight_shelf + gal.mapgen.biome_vertical_range
	-- mg_earth.config.max_mountain			= gal.mapgen.maxheight_highland + gal.mapgen.biome_vertical_range
	-- mg_earth.config.max_highland			= gal.mapgen.maxheight_highland
	-- mg_earth.config.max_mountain			= gal.mapgen.maxheight_mountain
	mg_earth.config.biome_vertical_range	= gal.mapgen.biome_vertical_range
	mg_earth.config.max_beach				= gal.mapgen.maxheight_beach
	mg_earth.config.max_coastal				= gal.mapgen.maxheight_coastal
	mg_earth.config.max_lowland				= gal.mapgen.maxheight_lowland
	mg_earth.config.max_shelf				= gal.mapgen.maxheight_shelf
	mg_earth.config.max_highland			= gal.mapgen.maxheight_highland
	mg_earth.config.max_mountain			= gal.mapgen.maxheight_mountain
end

if mg_earth.gal then
	mg_earth.config.mg_ecosystems			= true
end

mg_earth.c_air								= minetest.get_content_id("air")
mg_earth.c_ignore							= minetest.get_content_id("ignore")

-- if mg_earth.nodes_nature then
	-- mg_earth.c_top							= minetest.get_content_id("air")
	-- mg_earth.c_filler						= minetest.get_content_id("air")
	-- mg_earth.c_stone						= minetest.get_content_id("nodes_nature:conglomerate")
	-- mg_earth.c_water						= minetest.get_content_id("nodes_nature:salt_water_source")
	-- mg_earth.c_water_top					= minetest.get_content_id("air")
	-- mg_earth.c_river						= minetest.get_content_id("nodes_nature:freshwater_source")
	-- mg_earth.c_river_bed					= minetest.get_content_id("air")

	-- mg_earth.c_cave_liquid					= minetest.get_content_id("air")
	-- mg_earth.c_dungeon						= minetest.get_content_id("air")
	-- mg_earth.c_dungeon_alt					= minetest.get_content_id("air")

	-- mg_earth.c_snow							= minetest.get_content_id("air")
	-- mg_earth.c_ice							= minetest.get_content_id("air")

	-- mg_earth.c_road							= minetest.get_content_id("air")
	-- mg_earth.c_path							= minetest.get_content_id("air")
	-- mg_earth.c_road_sup						= minetest.get_content_id("air")
-- end

if mg_earth.default then
	mg_earth.c_top							= minetest.get_content_id("default:dirt_with_grass")
	mg_earth.c_filler						= minetest.get_content_id("default:dirt")
	mg_earth.c_stone						= minetest.get_content_id("default:stone")
	mg_earth.c_water						= minetest.get_content_id("default:water_source")
	mg_earth.c_water_top					= minetest.get_content_id("default:water_source")
	mg_earth.c_river						= minetest.get_content_id("default:river_water_source")
	--mg_earth.c_river_bed					= minetest.get_content_id("default:gravel")
	--mg_earth.c_river_bed					= minetest.get_content_id("default:dirt")
	mg_earth.c_river_bed					= minetest.get_content_id("default:sand")

	mg_earth.c_cave_liquid					= minetest.get_content_id("default:lava_source")
	mg_earth.c_dungeon						= minetest.get_content_id("default:cobble")
	mg_earth.c_dungeon_alt					= minetest.get_content_id("default:mossycobble")
	
	mg_earth.c_snow							= minetest.get_content_id("default:snowblock")
	mg_earth.c_ice							= minetest.get_content_id("default:ice")
	
	mg_earth.c_road							= minetest.get_content_id("default:cobble")
	mg_earth.c_path							= minetest.get_content_id("default:dry_dirt")
	mg_earth.c_road_sup						= minetest.get_content_id("default:stone_block")
end

if mg_earth.gal then
	mg_earth.c_top							= minetest.get_content_id("gal:dirt_with_grass")
	mg_earth.c_filler						= minetest.get_content_id("gal:dirt")
	mg_earth.c_stone						= minetest.get_content_id("gal:stone")
	mg_earth.c_water						= minetest.get_content_id("gal:liquid_water_source")
	mg_earth.c_water_top					= minetest.get_content_id("gal:liquid_water_source")
	mg_earth.c_river						= minetest.get_content_id("gal:liquid_water_river_source")
	mg_earth.c_river_bed					= minetest.get_content_id("gal:dirt_mud_01")

	mg_earth.c_cave_liquid					= minetest.get_content_id("gal:liquid_lava_source")
	mg_earth.c_dungeon						= minetest.get_content_id("gal:stone_cobble")
	mg_earth.c_dungeon_alt					= minetest.get_content_id("gal:stone_cobble_mossy")
	
	mg_earth.c_snow							= minetest.get_content_id("gal:snow_block")
	mg_earth.c_ice							= minetest.get_content_id("gal:ice")
	
	-- mg_earth.c_road							= minetest.get_content_id("gal:stone_cobble")
	mg_earth.c_road							= minetest.get_content_id("gal:dirt_with_stone_cobble")
	mg_earth.c_path							= minetest.get_content_id("gal:dirt_dry")
	mg_earth.c_road_sup						= minetest.get_content_id("gal:stone_brick")
end

if mg_heightmap_select == "vSolarSystem" then
	if mg_earth.default then
		mg_earth.c_sun							= minetest.get_content_id("default:meselamp")
		mg_earth.c_mercury						= minetest.get_content_id("default:stone")
		mg_earth.c_venus						= minetest.get_content_id("default:wood")
		mg_earth.c_earth						= minetest.get_content_id("default:diamondblock")
		mg_earth.c_mars							= minetest.get_content_id("default:acacia_wood")
		mg_earth.c_jupiter						= minetest.get_content_id("default:coral_orange")
		mg_earth.c_saturn						= minetest.get_content_id("default:coral_brown")
		mg_earth.c_saturn_rings					= minetest.get_content_id("default:glass")
		mg_earth.c_uranus						= minetest.get_content_id("default:copperblock")
		mg_earth.c_neptune						= minetest.get_content_id("default:ice")
		mg_earth.c_pluto						= minetest.get_content_id("default:bronzeblock")
	end
end


mg_earth.heightmap = {}
mg_earth.heightmap2d = {}
mg_earth.heightmap3d = {}
mg_earth.biomemap = {}
mg_earth.biome_info = {}
mg_earth.fillmap = {}
mg_earth.eco_fill = {}
mg_earth.eco_top = {}
mg_earth.eco_map = {}
local mg_voronoimap = {}
mg_earth.cliffmap = {}
mg_earth.cliffterrainmap = {}
mg_earth.valleymap = {}
mg_earth.rivermap = {}
mg_earth.riverpath = {}
mg_earth.lfmap = {}
mg_earth.lfpath = {}
mg_earth.rfmap = {}
mg_earth.rfpath = {}
mg_earth.hh_mod = {}
mg_earth.cellmap = {}
mg_earth.detected = {}
mg_earth.surfacemap = {}
mg_earth.slopemap = {}
mg_earth.valleysrivermap = {}
-- mg_earth.densitymap = {}
mg_earth.streetmap = {}
mg_earth.streetheight = {}
mg_earth.streetdirmap = {}
mg_earth.roadmap = {}
mg_earth.roadheight = {}
mg_earth.roaddirmap = {}
mg_earth.pathmap = {}
mg_earth.pathheight = {}
mg_earth.pathdirmap = {}
-- mg_earth.carpmap = {}
-- -- mg_earth.height1 = {}
-- -- mg_earth.height2 = {}
-- -- mg_earth.height3 = {}
-- -- mg_earth.height4 = {}
-- -- mg_earth.hill_mnt = {}
-- -- mg_earth.ridge_mnt = {}
-- -- mg_earth.step_mnt = {}
-- mg_earth.v5_factormap = {}
-- mg_earth.v5_heightmap = {}
-- mg_earth.cave1map = {}
-- mg_earth.cave2map = {}
-- mg_earth.cavern1map = {}
-- mg_earth.cavern2map = {}
-- mg_earth.cavernwavemap = {}

mg_earth.center_of_chunk = nil
mg_earth.chunk_points = nil
mg_earth.chunk_terrain = nil
mg_earth.chunk_mean_altitude = nil
mg_earth.chunk_min_altitude = nil
mg_earth.chunk_max_altitude = nil
mg_earth.chunk_rng_altitude = nil
mg_earth.chunk_altitude_variance = nil

mg_earth.chunk_terrain = {
	SW	= {x=nil,						y=nil,							z=nil},
	S	= {x=nil,						y=nil,							z=nil},
	SE	= {x=nil,						y=nil,							z=nil},
	W	= {x=nil,						y=nil,							z=nil},
	C	= {x=nil,						y=nil,							z=nil},
	E	= {x=nil,						y=nil,							z=nil},
	NW	= {x=nil,						y=nil,							z=nil},
	N	= {x=nil,						y=nil,							z=nil},
	NE	= {x=nil,						y=nil,							z=nil},
}

mg_earth.player_spawn_point = {x=-5,y=0,z=-5}
mg_earth.origin_y_val = {x=0,y=0,z=0}

local nobj_cave1 = nil
local nbuf_cave1 = {}
local nobj_cave2 = nil
local nbuf_cave2 = {}

local nobj_cavern1 = nil
local nbuf_cavern1 = {}
local nobj_cavern2 = nil
local nbuf_cavern2 = {}
local nobj_wave = nil
local nbuf_wave = {}
local nobj_cavebiome = nil
local nbuf_cavebiome = {}

local nobj_3dterrain = nil
local nbuf_3dterrain = {}

local nobj_3d_noise = nil
local nbuf_3d_noise = {}

local nobj_carp_mnt_var = nil
local nbuf_carp_mnt_var = {}

local nobj_v5_ground = nil
local nbuf_v5_ground = {}

local nobj_val_fill = nil
local nbuf_val_fill = {}

local nobj_bridge_column = nil
-- local nbuf_bridge_column = {}
local nbuf_bridge_column


local nobj_heatmap = nil
local nbuf_heatmap = {}
local nobj_heatblend = nil
local nbuf_heatblend = {}
local nobj_humiditymap = nil
local nbuf_humiditymap = {}
local nobj_humidityblend = nil
local nbuf_humidityblend = {}

local mg_noise_heathumid_spread = 1000 * mg_world_scale
local mg_noise_heat_offset = 50
local mg_noise_heat_scale = 50
local mg_noise_humid_offset = 50
local mg_noise_humid_scale = 50

if mg_earth.config.use_heat_scalar == true then
	mg_noise_heat_offset = 0
	mg_noise_heat_scale = 12.5
end
if mg_earth.config.use_humid_scalar == true then
	mg_noise_humid_offset = 0
	mg_noise_humid_scale = 25
end


mg_earth.noise = {}

--2D Noise
mg_earth.noise["np_2d_base"] = {
	--flags = "defaults",
	lacunarity = mg_earth.settings.np_2d_base.lacunarity,
	offset = mg_earth.settings.np_2d_base.offset * mg_world_scale,
	scale = mg_earth.settings.np_2d_base.scale * mg_world_scale,
	seed = mg_earth.settings.np_2d_base.seed,
	spread = {x = (mg_earth.settings.np_2d_base.spread.x * mg_world_scale), y = (mg_earth.settings.np_2d_base.spread.y * mg_world_scale), z = (mg_earth.settings.np_2d_base.spread.z * mg_world_scale)},
	octaves = mg_earth.settings.np_2d_base.octaves,
	persist = mg_earth.settings.np_2d_base.persist,
}
mg_earth.noise["np_2d_alt"] = {
	offset = (mg_earth.settings.np_2d_alt.offset * mg_world_scale),
	scale = (mg_earth.settings.np_2d_alt.scale * mg_world_scale),
	spread = {x = (mg_earth.settings.np_2d_alt.spread.x * mg_world_scale), y = (mg_earth.settings.np_2d_alt.spread.y * mg_world_scale), z = (mg_earth.settings.np_2d_alt.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_2d_alt.seed,
	octaves = mg_earth.settings.np_2d_alt.octaves,
	persist = mg_earth.settings.np_2d_alt.persist,
	lacunarity = mg_earth.settings.np_2d_alt.lacunarity,
}
mg_earth.noise["np_2d_peak"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_2d_peak.lacunarity,
	offset = mg_earth.settings.np_2d_peak.offset * mg_world_scale,
	scale = mg_earth.settings.np_2d_peak.scale * mg_world_scale,
	--seed = 82341,
	seed = mg_earth.settings.np_2d_peak.seed,
	spread = {x = (mg_earth.settings.np_2d_peak.spread.x * mg_world_scale), y = (mg_earth.settings.np_2d_peak.spread.y * mg_world_scale), z = (mg_earth.settings.np_2d_peak.spread.z * mg_world_scale)},
	octaves = mg_earth.settings.np_2d_peak.octaves,
	persist = mg_earth.settings.np_2d_peak.persist,
}
mg_earth.noise["np_2d_sin"] = {
	offset = mg_earth.settings.np_2d_sin.offset,
	scale = mg_earth.settings.np_2d_sin.scale,
	spread = {x = (mg_earth.settings.np_2d_sin.spread.x * mg_world_scale), y = (mg_earth.settings.np_2d_sin.spread.y * mg_world_scale), z = (mg_earth.settings.np_2d_sin.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_2d_sin.seed,
	octaves = mg_earth.settings.np_2d_sin.octaves,
	persist = mg_earth.settings.np_2d_sin.persist,
	lacunarity = mg_earth.settings.np_2d_sin.lacunarity,
}
mg_earth.noise["np_river_jitter"] = {
	--flags = "defaults, absvalue",
	offset = mg_earth.settings.np_river_jitter.offset * mg_world_scale,
	scale = mg_earth.settings.np_river_jitter.scale * mg_world_scale,
	spread = {x = (mg_earth.settings.np_river_jitter.spread.x * mg_world_scale), y = (mg_earth.settings.np_river_jitter.spread.y * mg_world_scale), z = (mg_earth.settings.np_river_jitter.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_river_jitter.seed,
	octaves = mg_earth.settings.np_river_jitter.octaves,
	persist = mg_earth.settings.np_river_jitter.persist,
	lacunarity = mg_earth.settings.np_river_jitter.lacunarity,
}


--v5 Noises
--if mg_heightmap_select == "v5" then
	mg_earth.noise["np_v5_factor"] = {
		offset=0,
		scale=1,
		spread={x=250,y=250,z=250},
		seed=920381,
		octaves=3,
		persist=0.45,
		lacunarity=2,
	}
	mg_earth.noise["np_v5_height"] = {
		offset=0,
		scale=10,
		spread={x=250,y=250,z=250},
		seed=84174,
		octaves=4,
		persist=0.5,
		lacunarity=2,
	}
	mg_earth.noise["np_v5_ground"] = {
		offset=0,
		scale=40,
		spread={x=80,y=80,z=80},
		seed=983240,
		octaves=4,
		persist=0.55,
		lacunarity=2,
	}
--end


--v7 Noises
mg_earth.noise["np_v7_alt"] = {
	--flags = "defaults",
	lacunarity = mg_earth.settings.np_v7_alt.lacunarity,
	offset = mg_earth.settings.np_v7_alt.offset * mg_world_scale,
	scale = mg_earth.settings.np_v7_alt.scale * mg_world_scale,
	seed = mg_earth.settings.np_v7_alt.seed,
	spread = {x = (mg_earth.settings.np_v7_alt.spread.x * mg_world_scale), y = (mg_earth.settings.np_v7_alt.spread.y * mg_world_scale), z = (mg_earth.settings.np_v7_alt.spread.z * mg_world_scale)},
	octaves = mg_earth.settings.np_v7_alt.octaves,
	persist = mg_earth.settings.np_v7_alt.persist,
}
mg_earth.noise["np_v7_base"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v7_base.lacunarity,
	offset = mg_earth.settings.np_v7_base.offset * mg_world_scale,
	scale = mg_earth.settings.np_v7_base.scale * mg_world_scale,
	--seed = 82341,
	seed = mg_earth.settings.np_v7_base.seed,
	spread = {x = (mg_earth.settings.np_v7_base.spread.x * mg_world_scale), y = (mg_earth.settings.np_v7_base.spread.y * mg_world_scale), z = (mg_earth.settings.np_v7_base.spread.z * mg_world_scale)},
	octaves = mg_earth.settings.np_v7_base.octaves,
	persist = mg_earth.settings.np_v7_base.persist,
}
mg_earth.noise["np_v7_peak"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v7_peak.lacunarity,
	offset = mg_earth.settings.np_v7_peak.offset * mg_world_scale,
	scale = mg_earth.settings.np_v7_peak.scale * mg_world_scale,
	--seed = 82341,
	seed = mg_earth.settings.np_v7_peak.seed,
	spread = {x = (mg_earth.settings.np_v7_peak.spread.x * mg_world_scale), y = (mg_earth.settings.np_v7_peak.spread.y * mg_world_scale), z = (mg_earth.settings.np_v7_peak.spread.z * mg_world_scale)},
	octaves = mg_earth.settings.np_v7_peak.octaves,
	persist = mg_earth.settings.np_v7_peak.persist,
}
mg_earth.noise["np_v7_height"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v7_height.lacunarity,
	offset = mg_earth.settings.np_v7_height.offset,
	scale = mg_earth.settings.np_v7_height.scale,
	spread = {x = (mg_earth.settings.np_v7_height.spread.x * mg_world_scale), y = (mg_earth.settings.np_v7_height.spread.y * mg_world_scale), z = (mg_earth.settings.np_v7_height.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_v7_height.seed,
	octaves = mg_earth.settings.np_v7_height.octaves,
	persist = mg_earth.settings.np_v7_height.persist,
}
mg_earth.noise["np_v7_persist"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v7_persist.lacunarity,
	offset = mg_earth.settings.np_v7_persist.offset,
	scale = mg_earth.settings.np_v7_persist.scale,
	spread = {x = (mg_earth.settings.np_v7_persist.spread.x * mg_world_scale), y = (mg_earth.settings.np_v7_persist.spread.y * mg_world_scale), z = (mg_earth.settings.np_v7_persist.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_v7_persist.seed,
	octaves = mg_earth.settings.np_v7_persist.octaves,
	persist = mg_earth.settings.np_v7_persist.persist,
}

--v6 Noises
mg_earth.noise["np_v6_base"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v6_base.lacunarity,
	offset = mg_earth.settings.np_v6_base.offset * mg_world_scale,
	scale = mg_earth.settings.np_v6_base.scale * mg_world_scale,
	spread = {x = (mg_earth.settings.np_v6_base.spread.x * mg_world_scale), y = (mg_earth.settings.np_v6_base.spread.y * mg_world_scale), z = (mg_earth.settings.np_v6_base.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_v6_base.seed,
	octaves = mg_earth.settings.np_v6_base.octaves,
	persist = mg_earth.settings.np_v6_base.persist,
}
mg_earth.noise["np_v6_higher"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v6_higher.lacunarity,
	offset = mg_earth.settings.np_v6_higher.offset * mg_world_scale,
	scale = mg_earth.settings.np_v6_higher.scale * mg_world_scale,
	spread = {x = (mg_earth.settings.np_v6_higher.spread.x * mg_world_scale), y = (mg_earth.settings.np_v6_higher.spread.y * mg_world_scale), z = (mg_earth.settings.np_v6_higher.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_v6_higher.seed,
	octaves = mg_earth.settings.np_v6_higher.octaves,
	persist = mg_earth.settings.np_v6_higher.persist,
}
mg_earth.noise["np_v6_steep"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v6_steep.lacunarity,
	offset = mg_earth.settings.np_v6_steep.offset,
	scale = mg_earth.settings.np_v6_steep.scale,
	spread = {x = (mg_earth.settings.np_v6_steep.spread.x * mg_world_scale), y = (mg_earth.settings.np_v6_steep.spread.y * mg_world_scale), z = (mg_earth.settings.np_v6_steep.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_v6_steep.seed,
	octaves = mg_earth.settings.np_v6_steep.octaves,
	persist = mg_earth.settings.np_v6_steep.persist,
}
mg_earth.noise["np_v6_height"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_v6_height.lacunarity,
	offset = mg_earth.settings.np_v6_height.offset,
	scale = mg_earth.settings.np_v6_height.scale,
	spread = {x = (mg_earth.settings.np_v6_height.spread.x * mg_world_scale), y = (mg_earth.settings.np_v6_height.spread.y * mg_world_scale), z = (mg_earth.settings.np_v6_height.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_v6_height.seed,
	octaves = mg_earth.settings.np_v6_height.octaves,
	persist = mg_earth.settings.np_v6_height.persist,
}



--vCarpathian Noises
--if mg_heightmap_select == "vCarp" or mg_heightmap_select == "vCarp3D" then
	-- Base terrain noise, low and mostly flat  2D
--[[mg_earth.noise["np_carp_base"] = {
		offset = 1,
		scale = 1,
		spread = {x = 8192, y = 8192, z = 8192},
		seed = 211,
		octaves = 6,
		persist = 0.8,
		lacunarity = 0.5
	}
--]]
--[[mg_earth.noise["np_carp_filler_depth"] = {
		offset = 0,
		scale = 1,
		spread = {x = 512, y = 512, z = 512},
		seed = 261,
		octaves = 3,
		persist = 0.7,
		lacunarity = 2
	}
--]]
	-- Terrain feature noise  2D
	mg_earth.noise["np_carp_terrain_step"] = {
		offset = 1,
		scale = 1,
		spread = {x = 1889, y = 1889, z = 1889},
		seed = 4157,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2
	}
	mg_earth.noise["np_carp_terrain_hills"] = {
		offset = 1,
		scale = 1,
		spread = {x = 1301, y = 1301, z = 1301},
		seed = 1692,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2
	}
	mg_earth.noise["np_carp_terrain_ridge"] = {
		offset = 1,
		scale = 1,
		spread = {x = 1889, y = 1889, z = 1889},
		seed = 3568,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2
	}

	-- Terrain height noises  2D
	mg_earth.noise["np_carp_height1"] = {
		offset = 0,
		scale = 5,
		spread = {x = 251, y = 251, z = 251},
		seed = 9613,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}
	mg_earth.noise["np_carp_height2"] = {
		offset = 0,
		scale = 5,
		spread = {x = 383, y = 383, z = 383},
		seed = 1949,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}
	mg_earth.noise["np_carp_height3"] = {
		offset = 0,
		scale = 5,
		spread = {x = 509, y = 509, z = 509},
		seed = 3211,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}
	mg_earth.noise["np_carp_height4"] = {
		offset = 0,
		scale = 5,
		spread = {x = 631, y = 631, z = 631},
		seed = 1583,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}

	-- Hill and mountain noise, large  2D
	mg_earth.noise["np_carp_hills"] = {
		offset = 0,
		scale = 3,
		spread = {x = 257, y = 257, z = 257},
		seed = 6604,
		octaves = 6,
		persist = 0.5,
		lacunarity = 2
	}
	mg_earth.noise["np_carp_mnt_step"] = {
		offset = 0,
		scale = 8,
		spread = {x = 509, y = 509, z = 509},
		seed = 2590,
		octaves = 6,
		persist = 0.6,
		lacunarity = 2
	}
	mg_earth.noise["np_carp_mnt_ridge"] = {
		offset = 0,
		scale = 12,
		spread = {x = 743, y = 743, z = 743},
		seed = 5520,
		octaves = 6,
		persist = 0.7,
		lacunarity = 2
	}
	-- Hill/mountain noise modifier, influences mountains for overhangs 3D
	mg_earth.noise["np_carp_mnt_var"] = {
		offset = 0,
		scale = 1,
		spread = {x = 499, y = 499, z = 499},
		seed = 2490,
		octaves = 5,
		persist = 0.55,
		lacunarity = 2
	}
--end



--#	Valleys Noises
--if mg_heightmap_select == "vValleys" or mg_heightmap_select == "vValleys3D" then
	mg_earth.noise["np_val_terrain"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.np_val_terrain.lacunarity,
		offset = mg_earth.settings.np_val_terrain.offset,
		scale = mg_earth.settings.np_val_terrain.scale,
		spread = {x = (mg_earth.settings.np_val_terrain.spread.x * mg_world_scale), y = (mg_earth.settings.np_val_terrain.spread.y * mg_world_scale), z = (mg_earth.settings.np_val_terrain.spread.z * mg_world_scale)},
		--seed = 5202,
		seed = mg_earth.settings.np_val_terrain.seed,
		octaves = mg_earth.settings.np_val_terrain.octaves,
		persist = mg_earth.settings.np_val_terrain.persist,
	}
	mg_earth.noise["np_val_river"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.np_val_river.lacunarity,
		offset = mg_earth.settings.np_val_river.offset,
		scale = mg_earth.settings.np_val_river.scale,
		spread = {x = (mg_earth.settings.np_val_river.spread.x), y = (mg_earth.settings.np_val_river.spread.y), z = (mg_earth.settings.np_val_river.spread.z)},
		seed = mg_earth.settings.np_val_river.seed,
		octaves = mg_earth.settings.np_val_river.octaves,
		persist = mg_earth.settings.np_val_river.persist,
	}
	mg_earth.noise["np_val_depth"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.np_val_depth.lacunarity,
		offset = mg_earth.settings.np_val_depth.offset,
		scale = mg_earth.settings.np_val_depth.scale,
		spread = {x = (mg_earth.settings.np_val_depth.spread.x), y = (mg_earth.settings.np_val_depth.spread.y), z = (mg_earth.settings.np_val_depth.spread.z)},
		seed = mg_earth.settings.np_val_depth.seed,
		octaves = mg_earth.settings.np_val_depth.octaves,
		persist = mg_earth.settings.np_val_depth.persist,
	}
	mg_earth.noise["np_val_profile"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.np_val_profile.lacunarity,
		offset = mg_earth.settings.np_val_profile.offset,
		scale = mg_earth.settings.np_val_profile.scale,
		spread = {x = (mg_earth.settings.np_val_profile.spread.x), y = (mg_earth.settings.np_val_profile.spread.y), z = (mg_earth.settings.np_val_profile.spread.z)},
		seed = mg_earth.settings.np_val_profile.seed,
		octaves = mg_earth.settings.np_val_profile.octaves,
		persist = mg_earth.settings.np_val_profile.persist,
	}
	mg_earth.noise["np_val_slope"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.np_val_slope.lacunarity,
		offset = mg_earth.settings.np_val_slope.offset,
		scale = mg_earth.settings.np_val_slope.scale,
		spread = {x = (mg_earth.settings.np_val_slope.spread.x), y = (mg_earth.settings.np_val_slope.spread.y), z = (mg_earth.settings.np_val_slope.spread.z)},
		seed = mg_earth.settings.np_val_slope.seed,
		octaves = mg_earth.settings.np_val_slope.octaves,
		persist = mg_earth.settings.np_val_slope.persist,
	}
	mg_earth.noise["np_val_fill"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.np_val_fill.lacunarity,
		offset = mg_earth.settings.np_val_fill.offset,
		scale = mg_earth.settings.np_val_fill.scale,
		spread = {x = (mg_earth.settings.np_val_fill.spread.x), y = (mg_earth.settings.np_val_fill.spread.y), z = (mg_earth.settings.np_val_fill.spread.z)},
		seed = mg_earth.settings.np_val_fill.seed,
		octaves = mg_earth.settings.np_val_fill.octaves,
		persist = mg_earth.settings.np_val_fill.persist,
	}
--end


--3D Terrain Noise
if mg_heightmap_select == "v3D" or mg_heightmap_select == "v3dNoise" or mg_heightmap_select == "vRand3D" or mg_heightmap_select == "vStraight3D" then
	mg_earth.noise["np_3dterrain"] = {
		--flags = ""
		lacunarity = mg_earth.settings.np_3dterrain.lacunarity,
		offset = mg_earth.settings.np_3dterrain.offset,
		scale = mg_earth.settings.np_3dterrain.scale,
		spread = {x = (mg_earth.settings.np_3dterrain.spread.x * mg_world_scale), y = (mg_earth.settings.np_3dterrain.spread.y * mg_world_scale), z = (mg_earth.settings.np_3dterrain.spread.z * mg_world_scale)},
		seed = mg_earth.settings.np_3dterrain.seed,
		octaves = mg_earth.settings.np_3dterrain.octaves,
		persist = mg_earth.settings.np_3dterrain.persist,
	}
end

local v3d_noise_scaler = 0.1
local v3d_noise_density = 128 * v3d_noise_scaler
if mg_noise_select == "v3D" then
	mg_earth.noise["np_3d_noise"] = {
		offset = 0,
		scale = 1,
		spread = {x = (384 * v3d_noise_scaler), y = (192 * v3d_noise_scaler), z = (384 * v3d_noise_scaler)},
		seed = 5934,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2
	}
end


-- 3D noise for caves
if mg_earth.settings.enable_caves then
	mg_earth.noise["np_cave1"] = {
		-- -- Caverealms
		offset = mg_earth.settings.np_cave1.offset,
		scale = mg_earth.settings.np_cave1.scale,
		spread = {x = (mg_earth.settings.np_cave1.spread.x * mg_world_scale), y = (mg_earth.settings.np_cave1.spread.y * mg_world_scale), z = (mg_earth.settings.np_cave1.spread.z * mg_world_scale)},
		seed = mg_earth.settings.np_cave1.seed,
		octaves = mg_earth.settings.np_cave1.octaves,
		persist = mg_earth.settings.np_cave1.persist,
	}
	mg_earth.noise["np_cave2"] = {
		-- -- Subterrain
		offset = mg_earth.settings.np_cave2.offset,
		scale = mg_earth.settings.np_cave2.scale,
		spread = {x = (mg_earth.settings.np_cave2.spread.x * mg_world_scale), y = (mg_earth.settings.np_cave2.spread.y * mg_world_scale), z = (mg_earth.settings.np_cave2.spread.z * mg_world_scale)},
		seed = mg_earth.settings.np_cave2.seed,
		octaves = mg_earth.settings.np_cave2.octaves,
		persist = mg_earth.settings.np_cave2.persist,
	}
end

if mg_earth.settings.enable_caves then
	mg_earth.noise["np_cavern1"] = {
		-- -- Caverealms
		offset = mg_earth.settings.np_cavern1.offset,
		scale = mg_earth.settings.np_cavern1.scale,
		spread = {x = (mg_earth.settings.np_cavern1.spread.x * mg_world_scale), y = (mg_earth.settings.np_cavern1.spread.y * mg_world_scale), z = (mg_earth.settings.np_cavern1.spread.z * mg_world_scale)},
		seed = mg_earth.settings.np_cavern1.seed,
		octaves = mg_earth.settings.np_cavern1.octaves,
		persist = mg_earth.settings.np_cavern1.persist,
	}
	mg_earth.noise["np_cavern2"] = {
		-- -- Subterrain
		offset = mg_earth.settings.np_cavern2.offset,
		scale = mg_earth.settings.np_cavern2.scale,
		spread = {x = (mg_earth.settings.np_cavern2.spread.x * mg_world_scale), y = (mg_earth.settings.np_cavern2.spread.y * mg_world_scale), z = (mg_earth.settings.np_cavern2.spread.z * mg_world_scale)},
		seed = mg_earth.settings.np_cavern2.seed,
		octaves = mg_earth.settings.np_cavern2.octaves,
		persist = mg_earth.settings.np_cavern2.persist,
	}
	mg_earth.noise["np_wave"] = {
		offset = mg_earth.settings.np_wave.offset,
		scale = mg_earth.settings.np_wave.scale,
		spread = {x = (mg_earth.settings.np_wave.spread.x * mg_world_scale), y = (mg_earth.settings.np_wave.spread.y * mg_world_scale), z = (mg_earth.settings.np_wave.spread.z * mg_world_scale)},
		seed = mg_earth.settings.np_wave.seed,
		octaves = mg_earth.settings.np_wave.octaves,
		persist = mg_earth.settings.np_wave.persist,
	}
--[[mg_earth.noise["np_cave_biome"] = {
		offset = mg_earth.settings.np_cave_biome.offset,
		scale = mg_earth.settings.np_cave_biome.scale,
		spread = {x = (mg_earth.settings.np_cave_biome.spread.x * mg_world_scale), y = (mg_earth.settings.np_cave_biome.spread.y * mg_world_scale), z = (mg_earth.settings.np_cave_biome.spread.z * mg_world_scale)},
		seed = mg_earth.settings.np_cave_biome.seed,
		octaves = mg_earth.settings.np_cave_biome.octaves,
		persist = mg_earth.settings.np_cave_biome.persist,
	 }
--]]
end


mg_earth.noise["np_cliffs"] = {
	lacunarity = mg_earth.settings.np_cliffs.lacunarity,
	offset = mg_earth.settings.np_cliffs.offset,					
	scale = mg_earth.settings.np_cliffs.scale * mg_world_scale,
	spread = {x = (mg_earth.settings.np_cliffs.spread.x * mg_world_scale), y = (mg_earth.settings.np_cliffs.spread.y * mg_world_scale), z = (mg_earth.settings.np_cliffs.spread.z * mg_world_scale)},
	--seed = 78901,
	seed = mg_earth.settings.np_cliffs.seed,
	octaves = mg_earth.settings.np_cliffs.octaves,
	persist = mg_earth.settings.np_cliffs.persist,
}
mg_earth.noise["np_fill"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.np_fill.lacunarity,
	offset = mg_earth.settings.np_fill.offset * mg_world_scale,
	scale = mg_earth.settings.np_fill.scale * mg_world_scale,
	spread = {x = (mg_earth.settings.np_fill.spread.x * mg_world_scale), y = (mg_earth.settings.np_fill.spread.y * mg_world_scale), z = (mg_earth.settings.np_fill.spread.z * mg_world_scale)},
	seed = mg_earth.settings.np_fill.seed,
	octaves = mg_earth.settings.np_fill.octaves,
	persistence = mg_earth.settings.np_fill.persist,
}

mg_earth.noise["np_heat"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = mg_noise_heat_offset,
	scale = mg_noise_heat_scale,
	spread = {x = mg_noise_heathumid_spread, y = mg_noise_heathumid_spread, z = mg_noise_heathumid_spread},
	seed = 5349,
	octaves = 3,
	persist = 0.5,
}
mg_earth.noise["np_heat_blend"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0,
	scale = 1.5,
	spread = {x = 8, y = 8, z = 8},
	seed = 13,
	octaves = 2,
	persist = 1,
}
mg_earth.noise["np_humid"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = mg_noise_humid_offset,
	scale = mg_noise_humid_scale,
	spread = {x = mg_noise_heathumid_spread, y = mg_noise_heathumid_spread, z = mg_noise_heathumid_spread},
	seed = 842,
	octaves = 3,
	persist = 0.5,
}
mg_earth.noise["np_humid_blend"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0,
	scale = 1.5,
	spread = {x = 8, y = 8, z = 8},
	seed = 90003,
	octaves = 2,
	persist = 1,
}

-- Note that because there is 1 octave, changing 'persistence' has no effect.
-- For wider lines, but also fewer less gaps in the lines change 'scale' towards -20000.0.
-- For lines further apart, increase the scale of the entire pattern by increasing all components of 'spread'. This will make the lines wider so you will then need to tune 'scale'.
mg_earth.noise["np_road"] = {
	flags = "defaults, absvalue",
	--lacunarity = 2,
	offset = 0,
	-- scale = 1.2,
	scale = 20,
	spread = {x = 256, y = 256, z = 256},
	seed = 8675309,
	octaves = 7,
	persist = 0.6,
	lacunarity = 2,
}
-- local np_sin = {
	-- flags = "defaults, absvalue",
	-- --lacunarity = 2,
	-- offset = 0,
	-- scale = 1.2,
	-- spread = {x = 512, y = 512, z = 512},
	-- seed = 513337,
	-- octaves = 5,
	-- persist = 0.5,
	-- lacunarity = 2,
-- }

mg_earth.noise["np_bridge_column"] = {
	offset = 0,
	scale = 1,
	spread = {x = 8, y = 8, z = 8},
	seed = 1728833,
	octaves = 3,
	persist = 2
}



--[[mg_earth.road_schem_3x3 = {
	size = {x = 3, y = 6, z = 3},
	data = {
		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},

		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},

		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}
	},
	yslice_prob = {
		-- {ypos = 0,prob = 254},
		-- {ypos = 1,prob = 254},
		-- {ypos = 2,prob = 254},
		-- {ypos = 3,prob = 254},
		-- {ypos = 4,prob = 254},
		-- {ypos = 5,prob = 254}
	}
}--]]
mg_earth.road_schem_3x1 = {
	size = {x = 3, y = 7, z = 1},
	data = {
		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254}, {name = "default:cobble", param2 = 0, force_place = true, prob = 254},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0},
		{name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}, {name = "air", param2 = 0, force_place = true, prob = 0}
	},
	yslice_prob = {
		-- {ypos = 0,prob = 254},
		-- {ypos = 1,prob = 254},
		-- {ypos = 2,prob = 254},
		-- {ypos = 3,prob = 254},
		-- {ypos = 4,prob = 254},
		-- {ypos = 5,prob = 254}
	}
}


-- Do files

dofile(mg_earth.path_mod .. "/nodes.lua")


-- Constants

mg_earth.c_wood			= minetest.get_content_id("mg_earth:junglewood")
mg_earth.c_column		= minetest.get_content_id("mg_earth:bridgewood")
mg_earth.c_stairn		= minetest.get_content_id("mg_earth:stairn")
mg_earth.c_stairs		= minetest.get_content_id("mg_earth:stairs")
mg_earth.c_staire		= minetest.get_content_id("mg_earth:staire")
mg_earth.c_stairw		= minetest.get_content_id("mg_earth:stairw")
mg_earth.c_stairne		= minetest.get_content_id("mg_earth:stairne")
mg_earth.c_stairnw		= minetest.get_content_id("mg_earth:stairnw")
mg_earth.c_stairse		= minetest.get_content_id("mg_earth:stairse")
mg_earth.c_stairsw		= minetest.get_content_id("mg_earth:stairsw")
mg_earth.c_roadblack	= minetest.get_content_id("mg_earth:road_black")
mg_earth.c_roadslab		= minetest.get_content_id("mg_earth:road_black_slab")
mg_earth.c_roadwhite	= minetest.get_content_id("mg_earth:road_white")
mg_earth.c_concrete		= minetest.get_content_id("mg_earth:concrete")


-- mg_earth.c_stone        = minetest.get_content_id("air")
-- mg_earth.c_stone        = minetest.get_content_id("default:stone")
mg_earth.c_sastone      = minetest.get_content_id("default:sandstone")
mg_earth.c_destone      = minetest.get_content_id("default:desert_stone")
-- mg_earth.c_ice          = minetest.get_content_id("default:ice")
mg_earth.c_tree         = minetest.get_content_id("default:tree")
mg_earth.c_leaves       = minetest.get_content_id("default:leaves")
mg_earth.c_apple        = minetest.get_content_id("default:apple")
mg_earth.c_jungletree   = minetest.get_content_id("default:jungletree")
mg_earth.c_jungleleaves = minetest.get_content_id("default:jungleleaves")
mg_earth.c_pinetree     = minetest.get_content_id("default:pine_tree")
mg_earth.c_pineneedles  = minetest.get_content_id("default:pine_needles")
-- mg_earth.c_snow         = minetest.get_content_id("default:snow")
mg_earth.c_acaciatree   = minetest.get_content_id("default:acacia_tree")
mg_earth.c_acacialeaves = minetest.get_content_id("default:acacia_leaves")
mg_earth.c_aspentree    = minetest.get_content_id("default:aspen_tree")
mg_earth.c_aspenleaves  = minetest.get_content_id("default:aspen_leaves")
mg_earth.c_meselamp     = minetest.get_content_id("default:meselamp")




local abs		= math.abs
local max		= math.max
local min		= math.min
local floor		= math.floor
local modf		= math.modf
local sin		= math.sin
local cos		= math.cos
local tan		= math.tan
local atan		= math.atan
local atan2		= math.atan2
local pi		= math.pi
local rad		= math.rad
local random	= math.random


local debug_this = ""
local debug_last = ""



mg_earth.config.cliffs_thresh = floor((mg_earth.noise["np_v7_alt"].scale) * 0.5)

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

local v7_base_min_height = min_height(mg_earth.noise["np_v7_base"])
local v7_alt_min_height = min_height(mg_earth.noise["np_v7_alt"])
local v7_alt_max_height = max_height(mg_earth.noise["np_v7_alt"])

local v2d_base_min_height = min_height(mg_earth.noise["np_2d_base"])
local v2d_base_max_height = max_height(mg_earth.noise["np_2d_base"])
local v2d_base_rng = v2d_base_max_height - v2d_base_min_height

local v2d_alt_min_height = min_height(mg_earth.noise["np_2d_alt"])
local v2d_alt_max_height = max_height(mg_earth.noise["np_2d_alt"])
local v2d_alt_rng = v2d_alt_max_height - v2d_alt_min_height

-- local v3d_min_height = min_height(mg_earth.noise["np_3dterrain"])
-- local v3d_max_height = max_height(mg_earth.noise["np_3dterrain"])
-- local v3d_rng = v3d_max_height - v3d_min_height

-- local heat_max		= max_height(mg_earth.noise["np_heat"])
-- local humid_min		= min_height(mg_earth.noise["np_humid"])
-- local humid_max		= max_height(mg_earth.noise["np_humid"])
-- local humid_rng		= humid_max - humid_min

--##Metrics functions.  Distance, direction, slope.
local function get_direction_to_pos(a,b)
	local t_compass
	local t_dir = {x = 0, z = 0}

	if a.z < b.z then
		t_dir.z = -1
		t_compass = "S"
	elseif a.z > b.z then
		t_dir.z = 1
		t_compass = "N"
	else
		t_dir.z = 0
		t_compass = ""
	end
	if a.x < b.x then
		t_dir.x = -1
		t_compass = t_compass .. "W"
	elseif a.x > b.x then
		t_dir.x = 1
		t_compass = t_compass .. "E"
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

local function get_3d_dist(a,b,c,d_type)
	local dist
	if d_type then
		if d_type == "c" then
			dist = (max(abs(a), max(abs(b), abs(c))))
		elseif d_type == "e" then
			dist = ((a * a) + (b * b) + (c * c))^0.5
		elseif d_type == "m" then
			dist = (abs(a) + abs(b) + abs(c))
		elseif d_type == "cm" then
			dist = (max(abs(a), max(abs(b), abs(c))) + (abs(a) + abs(b) + abs(c))) * 0.5
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

local function get_dist2midline_inverse(a,b,p)

	local run = a.x-b.x
	local rise = a.z-b.z
	--local inverse = (run - rise) / 2
	local inverse = (run / rise) * -1
	local c = {
		x = a.x + inverse,
		--x = a.x - run,
		z = b.z + inverse
		--z = b.z - rise
	}
	local d = {
		x = b.x - inverse,
		--x = b.x + run,
		z = a.z - inverse
		--z = a.z + rise
	}
	local lx = c.x - d.x
	local lz = c.z - d.z

	return max(1, (abs((lx * (c.z - p.z)) - ((c.x - p.x) * lz)) / (((lx * lx) + (lz * lz))^0.5)))

end

local function get_midpoint(a,b)						--get_midpoint(a,b)
	return ((a.x+b.x) * 0.5), ((a.z+b.z) * 0.5)			--returns the midpoint between two points
end

local function get_3D_midpoint(a,b)						--get_3D_midpoint(a,b)
	return ((a.x+b.x) * 0.5), ((a.y+b.y) * 0.5), ((a.z+b.z) * 0.5)			--returns the midpoint between two points
end

local function get_midpoint2(a,b, dist_metric)						--get_midpoint(a,b)

		-- local coord_x = ((a.x+b.x) * 0.5)
		-- local coord_z = ((a.z+b.z) * 0.5)					--returns the midpoint between two points
		-- local m_dx = (coord_x - a.x)
		-- local m_dz = (coord_z - a.z)
		-- local m_d = get_dist(m_dx, m_dz, dist_metric)

		-- --return {x = ((a.x+b.x) * 0.5), z = ((a.z+b.z) * 0.5)}				--returns the midpoint between two points
		-- return coord_x, coord_z, m_d, m_dx, m_dz

	local m_x = ((a.x+b.x) * 0.5)
	local m_z = ((a.z+b.z) * 0.5)					--returns the midpoint between two points
	local m_dist = get_dist((a.x - m_x), (a.z - m_z), dist_metric)
	local n_dist = get_dist((a.x - b.x), (a.z - b.z), dist_metric)
		-- local m_dz = (a.z - coord_z)
		-- local m_d = get_dist(m_dx, m_dz, dist_metric)
		-- local m_d = get_dist(m_dx, m_dz, dist_metric)

	-- return {x = ((a.x+b.x) * 0.5), z = ((a.z+b.z) * 0.5)}				--returns the midpoint between two points
	return m_x, m_z, m_dist, n_dist, n_x, n_z
end

local function get_nearest_midpoint_t(ppoints, pos, dist_type)
	
	if not pos then
		return
	end

	local d_type
	if not dist_type then
		d_type = dist_metric
	else
		d_type = dist_type
	end

	local c_midpoint
	local this_dist
	local last_dist
	local m_dist
	local c_z
	local c_x
	local c_dx
	local c_dz
	local c_si

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x-i_neighbor.m_x
		local t_z = pos.z-i_neighbor.m_z

		this_dist = gal.lib.metrics.get_distance(t_x, t_z, d_type)

		if last_dist then
			if last_dist >= this_dist then
				last_dist = this_dist
				c_midpoint = i
				--c_z =  i_neighbor.m_z
				--c_x = i_neighbor.m_x
				--c_dz = i_neighbor.cm_zd
				--c_dx = i_neighbor.cm_xd
				--c_si = i_neighbor.m_si
			end
		else
				last_dist = this_dist
				c_midpoint = i
				--c_z =  i_neighbor.m_z
				--c_x = i_neighbor.m_x
				--c_dz = i_neighbor.cm_zd
				--c_dx = i_neighbor.cm_xd
				--c_si = i_neighbor.m_si
		end
	end

	return c_midpoint

end

local function get_triangulation_2d(a,b,c)					--get_2d_triangulation(a,b,c)
	return ((a.x+b.x+c.x)/3), ((a.z+b.z+c.z)/3)				--returns the triangulated point between three points (average pos)
end

local function get_triangulation_3d(a,b,c)					--get_3d_triangulation(a,b,c)
	return ((a.x+b.x+c.x)/3), ((a.y+b.y+c.y)/3), ((a.z+b.z+c.z)/3)		--returns the 3D triangulated point between three points (average pos)
end

local function get_slope(a,b)
	local run = a.x-b.x
	local rise = a.z-b.z
	return (rise/run), rise, run
end
	
local function get_3d_slope(a,b)
	local h_run = a.x-b.x
	local h_rise = a.z-b.z
	local h_slope = h_rise / h_run
	local v_run = ((h_run * h_run) + (h_rise * h_rise))^0.5
	local v_rise = a.y-b.y
	local v_slope = v_rise / v_run

	return v_slope, v_rise, v_run, h_slope, h_rise, h_run
end
	
local function get_slope_inverse(a,b)
	local run = a.x-b.x
	local rise = a.z-b.z
	return ((run/rise) * -1), run, rise
end

local function get_trilinear_interpolation(a,b)

	local v000 = {x = a.x, y = a.y, z = a.z}
	local v100 = {x = b.x, y = a.y, z = a.z}
	local v010 = {x = a.x, y = b.y, z = a.z}
	local v001 = {x = a.x, y = a.y, z = b.z}
	local v101 = {x = b.x, y = a.y, z = b.z}
	local v011 = {x = a.x, y = b.y, z = b.z}
	local v110 = {x = b.x, y = b.y, z = a.z}
	local v111 = {x = b.x, y = b.y, z = b.z}

	local p000 = (1 - v000.x) * (1 - v000.y) * (1 - v000.z)
	local p100 = v100.x * (1 - v100.y) * (1 - v100.z)
	local p010 = (1 - v010.x) * v010.y * (1 - v010.z)
	local p001 = (1 - v001.x) * (1 - v001.y) * v001.z
	local p101 = v101.x * (1 - v101.y) * v101.z
	local p011 = (1 - v011.x) * v011.y * v011.z
	local p110 = v110.x * v110.y * (1 - v110.z)
	local p111 = v111.x * v111.y * v111.z

	return p000 + p100 + p010 + p001 + p101 + p011 + p110 + p111
end


local function lerp(noise_a, noise_b, n_mod)
	return noise_a * (1 - n_mod) + noise_b * n_mod
end

--local function steps(base,h)
local function steps(h)
	--local w = abs(base)
	local w = 0.5
	local k = floor(h / w)
	local f = (h - k * w) / w
	local s = min(2.0 * f, 1.0)
	return (k + s) * w
end

local function bias(noise, bias)
	return (noise / ((((1.0 / bias) - 2.0) * (1.0 - noise)) + 1.0))
end

local function gain(noise, gain)
	if noise < 0.5 then
		return bias(noise * 2.0, gain) / 2.0
	else
		return bias(noise * 2.0 - 1.0, 1.0 - gain) / 2.0 + 0.5
	end
end


--##Voronoi functions.  Nearest cell, Nearest Neighbor Midpoint, Cell Neighbors, load / save.
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
					-- if not mg_neighbors[thisidx] then
						-- mg_neighbors[thisidx] = {}
					-- end
					-- if not mg_neighbors[lastidx] then
						-- mg_neighbors[lastidx] = {}
					-- end
					-- if not mg_neighbors[thisidx][lastidx] then
						-- mg_neighbors[thisidx][lastidx] = {}
					-- end
					-- if not mg_neighbors[lastidx][thisidx] then
						-- mg_neighbors[lastidx][thisidx] = {}
					-- end
					-- local t_mid_x, t_mid_z = get_midpoint({x = thiscellx, z = thiscellz}, {x = lastcellx, z = lastcellz})
					-- mg_neighbors[thisidx][lastidx].m_x = t_mid_x
					-- mg_neighbors[thisidx][lastidx].m_z = t_mid_z
					-- mg_neighbors[thisidx][lastidx].n_x = lastcellx
					-- mg_neighbors[thisidx][lastidx].n_z = lastcellz
					-- mg_neighbors[lastidx][thisidx].m_x = t_mid_x
					-- mg_neighbors[lastidx][thisidx].m_z = t_mid_z
					-- mg_neighbors[lastidx][thisidx].n_x = thiscellx
					-- mg_neighbors[lastidx][thisidx].n_z = thiscellz
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

	return thisidx, thisdist, thiscellz, thiscellx

end

local function get_nearest_3D_cell(pos, tier)

	local thisidx
	local thiscellx
	local thiscelly
	local thiscellz
	local thisdist
	local lastidx
	local lastcellx
	local lastcelly
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
		
		local pointidx, pointz, pointy, pointx, pointtier = unpack(point)
		local dist_x = abs(pos.x-(tonumber(pointx) * mg_world_scale))
		local dist_y = abs(pos.y-(tonumber(pointy) * mg_world_scale))
		local dist_z = abs(pos.z-(tonumber(pointz) * mg_world_scale))

			--this = (max(dist_x, dist_z) + (dist_x + dist_z)) * 0.5
		--this = get_dist(dist_x,dist_z,dist_metric)
		this = get_3d_dist(dist_x,dist_y,dist_z,dist_metric)
			--this = ((dist_x * dist_x) + (dist_z * dist_z))^0.5

		if tonumber(pointtier) == tier then
	
			if last then
				if last > this then
					last = this
					thisidx = tonumber(pointidx)
					thiscellz = (tonumber(pointz) * mg_world_scale)
					thiscelly = (tonumber(pointy) * mg_world_scale)
					thiscellx = (tonumber(pointx) * mg_world_scale)
					thisdist = this
					lastidx = tonumber(pointidx)
					lastcellz = (tonumber(pointz) * mg_world_scale)
					lastcelly = (tonumber(pointy) * mg_world_scale)
					lastcellx = (tonumber(pointx) * mg_world_scale)
					lastdist = this
				elseif last == this then
					thisidx = tonumber(pointidx)
					thiscellz = (tonumber(pointz) * mg_world_scale)
					thiscelly = (tonumber(pointy) * mg_world_scale)
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
					local t_mid_x, t_mid_y, t_mid_z = get_3D_midpoint({x = thiscellx, y = thiscelly, z = thiscellz}, {x = lastcellx, y = lastcelly, z = lastcellz})
					mg_neighbors[thisidx][lastidx].m_x = t_mid_x
					mg_neighbors[thisidx][lastidx].m_y = t_mid_y
					mg_neighbors[thisidx][lastidx].m_z = t_mid_z
					mg_neighbors[thisidx][lastidx].n_x = lastcellx
					mg_neighbors[thisidx][lastidx].n_y = lastcelly
					mg_neighbors[thisidx][lastidx].n_z = lastcellz
					mg_neighbors[lastidx][thisidx].m_x = t_mid_x
					mg_neighbors[lastidx][thisidx].m_y = t_mid_y
					mg_neighbors[lastidx][thisidx].m_z = t_mid_z
					mg_neighbors[lastidx][thisidx].n_x = thiscellx
					mg_neighbors[lastidx][thisidx].n_y = thiscelly
					mg_neighbors[lastidx][thisidx].n_z = thiscellz
				end
			else
				last = this
				thisidx = tonumber(pointidx)
				thiscellz = (tonumber(pointz) * mg_world_scale)
				thiscelly = (tonumber(pointy) * mg_world_scale)
				thiscellx = (tonumber(pointx) * mg_world_scale)
				thisdist = this
				lastidx = tonumber(pointidx)
				lastcellz = (tonumber(pointz) * mg_world_scale)
				lastcelly = (tonumber(pointy) * mg_world_scale)
				lastcellx = (tonumber(pointx) * mg_world_scale)
				lastdist = this
			end
		end
	end

	return thisidx, thisdist, thiscellz, thiscelly, thiscellx

end

local function get_nearest_midpoint(pos, ppoints)

	if not pos then
		return
	end

	local c_midpoint
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.m_x
		local t_z = pos.z - i_neighbor.m_z

		this_dist = get_dist(t_x, t_z, dist_metric)

		if last_dist then
			if last_dist >= this_dist then
				last_dist = this_dist
				c_midpoint = i
			end
		else
				last_dist = this_dist
				c_midpoint = i
		end
	end

	return c_midpoint

end

local function get_nearest_neighbor(pos, ppoints)

	if not pos then
		return
	end

	local c_neighbor
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.n_x
		local t_z = pos.z - i_neighbor.n_z

		this_dist = get_dist(t_x, t_z, dist_metric)

		if last_dist then
			if last_dist >= this_dist then
				last_dist = this_dist
				c_neighbor = i
			end
		else
				last_dist = this_dist
				c_neighbor = i
		end
	end

	return c_neighbor

end

local function get_nearest_3D_neighbor(pos, ppoints)

	if not pos then
		return
	end

	local c_neighbor
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.n_x
		local t_y = pos.y - i_neighbor.n_y
		local t_z = pos.z - i_neighbor.n_z

		this_dist = get_3d_dist(t_x, t_y, t_z, dist_metric)

		if last_dist then
			if last_dist >= this_dist then
				last_dist = this_dist
				c_neighbor = i
			end
		else
				last_dist = this_dist
				c_neighbor = i
		end
	end

	return c_neighbor

end

local function get_farthest_neighbor(pos, ppoints)

	if not pos then
		return
	end

	local c_neighbor
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.n_x
		local t_z = pos.z - i_neighbor.n_z

		this_dist = get_dist(t_x, t_z, dist_metric)

		if last_dist then
			if last_dist <= this_dist then
				last_dist = this_dist
				c_neighbor = i
			end
		else
				last_dist = this_dist
				c_neighbor = i
		end
	end

	return c_neighbor

end

local function get_farthest_3D_neighbor(pos, ppoints)

	if not pos then
		return
	end

	local c_neighbor
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.n_x
		local t_y = pos.y - i_neighbor.n_y
		local t_z = pos.z - i_neighbor.n_z

		this_dist = get_3d_dist(t_x, t_y, t_z, dist_metric)

		if last_dist then
			if last_dist <= this_dist then
				last_dist = this_dist
				c_neighbor = i
			end
		else
				last_dist = this_dist
				c_neighbor = i
		end
	end

	return c_neighbor

end

local function get_nearest_edge(ppos, pcell, ppoints)

	if not ppos then
		return
	end

	local c_neighbor
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do


		this_dist = get_dist2line({x = pcell.x, z = pcell.z}, {x = i_neighbor.n_x, z = i_neighbor.n_z}, {x = ppos.x, z = ppos.z})

		if last_dist then
			if last_dist >= this_dist then
				last_dist = this_dist
				c_neighbor = i
			end
		else
				last_dist = this_dist
				c_neighbor = i
		end
	end

	return c_neighbor

end


local function get_cell_neighbors(cell_idx,cell_z,cell_x,cell_tier)

	local t_points = mg_points

	local t_neighbors = {}

	if mg_neighbors[cell_idx] then

		t_neighbors = mg_neighbors[cell_idx]

	else
	
	-- if not mg_neighbors[cell_idx] then
		-- mg_neighbors[cell_idx] = {}
	-- end

		mg_neighbors[cell_idx] = {}

		for i, i_point in ipairs(t_points) do

			local pointidx, pointz, pointx, pointtier = unpack(i_point)

			if cell_tier == pointtier then

				local t_mid_x, t_mid_z
				-- local t_cell
				local neighbor_add = false

				if tonumber(pointidx) ~= cell_idx then

					t_mid_x, t_mid_z = get_midpoint({x = (tonumber(pointx) * mg_world_scale), z = (tonumber(pointz) * mg_world_scale)}, {x = cell_x, z = cell_z})

					local t_cell, t_dist, t_z, t_x = get_nearest_cell({x = t_mid_x, z = t_mid_z}, cell_tier)

					--if (t_cell == pointidx) or (t_cell == cell_idx) or (mg_neighbors[cell_idx][t_cell]) then
					if (t_cell == tonumber(pointidx)) or (t_cell == cell_idx) then
						-- mg_neighbors[cell_idx][pointidx] = {}
						-- mg_neighbors[cell_idx][pointidx].m_z = t_mid_z
						-- mg_neighbors[cell_idx][pointidx].m_x = t_mid_x
						-- mg_neighbors[cell_idx][pointidx].n_z = (tonumber(pointz) * mg_world_scale)
						-- mg_neighbors[cell_idx][pointidx].n_x = (tonumber(pointx) * mg_world_scale)

						neighbor_add = true
					-- else
						-- if mg_neighbors[pointidx] then
							-- if mg_neighbors[pointidx][t_cell] and mg_neighbors[pointidx][cell_idx] then
								-- mg_neighbors[cell_idx][t_cell] = {}
								-- mg_neighbors[cell_idx][t_cell].m_z = t_mid_z
								-- mg_neighbors[cell_idx][t_cell].m_x = t_mid_x
								-- mg_neighbors[cell_idx][t_cell].n_z = (tonumber(t_z) * mg_world_scale)
								-- mg_neighbors[cell_idx][t_cell].n_x = (tonumber(t_x) * mg_world_scale)

								-- neighbor_add = true
							-- end
						-- end

						-- if mg_neighbors[t_cell] then
							-- if mg_neighbors[t_cell][pointidx] and mg_neighbors[t_cell][cell_idx] then
								-- mg_neighbors[cell_idx][t_cell] = {}
								-- mg_neighbors[cell_idx][t_cell].m_z = t_mid_z
								-- mg_neighbors[cell_idx][t_cell].m_x = t_mid_x
								-- mg_neighbors[cell_idx][t_cell].n_z = (tonumber(t_z) * mg_world_scale)
								-- mg_neighbors[cell_idx][t_cell].n_x = (tonumber(t_x) * mg_world_scale)
							
								-- neighbor_add = true
							-- end
						-- end
								-- if mg_neighbors[pointidx] then
									-- if (mg_neighbors[pointidx][t_cell] and mg_neighbors[pointidx][cell_idx]) then
										-- neighbor_add = true
									-- end
								-- end
									-- --if mg_neighbors[pointidx][t_cell] or (mg_neighbors[t_cell][pointidx] and mg_neighbors[t_cell][cell_idx]) then
									-- -- if mg_neighbors[t_cell] then
										-- -- if (mg_neighbors[t_cell][pointidx] or mg_neighbors[t_cell][cell_idx]) then
											-- -- --Find neighbors whose midpoint is in another neighboring cell.
											-- -- neighbor_add = true
										-- -- end
									-- -- end
									-- if mg_neighbors[t_cell] then
										-- if (mg_neighbors[t_cell][pointidx] or mg_neighbors[t_cell][cell_idx]) then
											-- neighbor_add = true
										-- end
									-- end
								-- if (t_cell == pointidx) then
								-- end
					end
				end

				if neighbor_add == true then

					mg_neighbors[cell_idx][tonumber(pointidx)] = {}
					mg_neighbors[cell_idx][tonumber(pointidx)].m_z = t_mid_z
					mg_neighbors[cell_idx][tonumber(pointidx)].m_x = t_mid_x
					mg_neighbors[cell_idx][tonumber(pointidx)].n_z = (tonumber(pointz) * mg_world_scale)
					mg_neighbors[cell_idx][tonumber(pointidx)].n_x = (tonumber(pointx) * mg_world_scale)

					t_neighbors = mg_neighbors[cell_idx]
				end
			end
		end
	-- t_neighbors = mg_neighbors[cell_idx]
	end

	return t_neighbors

end

local function get_cell_3D_neighbors(cell_idx,cell_z,cell_y,cell_x,cell_tier)

	local t_points = mg_points

	local t_neighbors = {}

	if mg_neighbors[cell_idx] then

		t_neighbors = mg_neighbors[cell_idx]

	else

		mg_neighbors[cell_idx] = {}

		for i, i_point in ipairs(t_points) do

			local pointidx, pointz, pointy, pointx, pointtier = unpack(i_point)

			if cell_tier == pointtier then

				local t_mid_x, t_mid_y, t_mid_z
				local t_cell
				local neighbor_add = false

				if i ~= cell_idx then

					t_mid_x, t_mid_y, t_mid_z = get_3D_midpoint({x = (tonumber(pointx) * mg_world_scale), y = (tonumber(pointy) * mg_world_scale), z = (tonumber(pointz) * mg_world_scale)}, {x = cell_x, y = cell_y, z = cell_z})

					t_cell = get_nearest_3D_cell({x = t_mid_x, y = t_mid_y, z = t_mid_z}, cell_tier)

					--if (t_cell == i) or (t_cell == cell_idx) or (mg_neighbors[cell_idx][t_cell]) then
					if (t_cell == i) or (t_cell == cell_idx) then
						neighbor_add = true
					end

				end

				if neighbor_add == true then

					mg_neighbors[cell_idx][pointidx] = {}
					mg_neighbors[cell_idx][pointidx].m_z = t_mid_z
					mg_neighbors[cell_idx][pointidx].m_y = t_mid_y
					mg_neighbors[cell_idx][pointidx].m_x = t_mid_x
					mg_neighbors[cell_idx][pointidx].n_z = (tonumber(pointz) * mg_world_scale)
					mg_neighbors[cell_idx][pointidx].n_y = (tonumber(pointy) * mg_world_scale)
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

local function save_worldpath(pobj, pfilename)
	local file = io.open(mg_earth.path_world.."/"..pfilename..".csv", "w")
	if file then
		file:write(pobj)
		file:close()
	end
end


function mg_earth.get_cell_centroid(ppoints)
	
		local avg_x = 0
		local avg_z = 0

		-- local n_cnt = #ppoints
		local n_cnt = 1

		for i, i_neighbor in pairs(ppoints) do
	
			avg_x = avg_x + i_neighbor.m_x
			avg_z = avg_z + i_neighbor.m_z
			
			n_cnt = n_cnt + 1
	
		end
	
		local c_ctr_x = avg_x / n_cnt
		local c_ctr_z = avg_z / n_cnt

		return c_ctr_z, c_ctr_x
	
	end

-- local new_points = ""
function mg_earth.voronoi_smoothing()

	print(os.clock())

	local new_points = {}
	
	for i_p, i_point in ipairs(mg_points) do

		local pointidx, pointz, pointx, pointtier = unpack(i_point)

		get_cell_neighbors(tonumber(pointidx), tonumber(pointz) * mg_world_scale, tonumber(pointx) * mg_world_scale, tonumber(pointtier))
		
		local new_pointz, new_pointx = mg_earth.get_cell_centroid(mg_neighbors[pointidx])

		new_points[i_p] = {tonumber(pointidx), tonumber(new_pointz), tonumber(new_pointx), tonumber(pointtier)}

	end

	-- local newpoints = minetest.serialize(new_points)

	-- save_worldpath(newpoints, p_file .. "_" .. tostring(mg_world_scale) .. "_" .. dist_metric .. "_NEW_POINTS")

	local newpoints = "#Cell_Index|Neighbor_Index|Midpoint_Zpos|Midpoint_Xpos|Neighbor_Zpos|Neighbor_Xpos\n"

	newpoints = newpoints .. "#I|Z|X|T\n"

	for i_c, i_cell in pairs(new_points) do

		local npointidx, npointz, npointx, npointtier = unpack(i_cell)

		newpoints = newpoints .. npointidx .. "|" .. npointz .. "|" .. npointx .. "|" .. npointtier .. "\n"

	end

	save_worldpath(newpoints, p_file .. "_" .. tostring(mg_world_scale) .. "_" .. dist_metric .. "_NEW_POINTS")

	print(os.clock())

end
--mg_earth.voronoi_smoothing()

function mg_earth.get_all_cell_neighbors()

	-- print(os.clock())

				-- local new_points = {}
	
	for i_p, i_point in ipairs(mg_points) do

		local pointidx, pointz, pointx, pointtier = unpack(i_point)

		get_cell_neighbors(tonumber(pointidx), tonumber(pointz) * mg_world_scale, tonumber(pointx) * mg_world_scale, tonumber(pointtier))
		
				-- local new_pointz, new_pointx = mg_earth.get_cell_centroid(mg_neighbors[pointidx])

				-- new_points[i_p] = {tonumber(pointidx), tonumber(new_pointz), tonumber(new_pointx), tonumber(pointtier)}

				-- local new_points = ""

				-- temp_neighbors = temp_neighbors .. i_c .. "|" .. i_n .. "|" .. i_neighbor.m_z .. "|" .. i_neighbor.m_x .. "|" .. i_neighbor.n_z .. "|" .. i_neighbor.n_x .. "\n"


	end

				-- local newpoints = minetest.serialize(new_points)

	-- local temp_neighbors = "#Cell_Index|Neighbor_Index|Midpoint_Zpos|Midpoint_Xpos|Neighbor_Zpos|Neighbor_Xpos\n"

	-- for i_c, i_cell in pairs(mg_neighbors) do

		-- temp_neighbors = temp_neighbors .. "#C_I|N_I|M_Z|M_X|N_Z|N_X\n"

		-- for i_n, i_neighbor in pairs(i_cell) do

			-- temp_neighbors = temp_neighbors .. i_c .. "|" .. i_n .. "|" .. i_neighbor.m_z .. "|" .. i_neighbor.m_x .. "|" .. i_neighbor.n_z .. "|" .. i_neighbor.n_x .. "\n"

		-- end

		-- temp_neighbors = temp_neighbors .. "#" .. "\n"

	-- end

	-- save_worldpath(newpoints, p_file .. "_" .. tostring(mg_world_scale) .. "_" .. dist_metric .. "_ALL_NEIGHBORS")

	-- print(os.clock())

end
mg_earth.get_all_cell_neighbors()


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

		minetest.log("[MOD] mg_earth: Voronoi Cell Neighbors loaded from file.")

	end
end
local function load_3D_neighbors(pfile)

	if not pfile or pfile == "" then
		return
	end

	local t_neighbors

	if (t_neighbors == nil) then
		t_neighbors = load_worldpath("|", pfile)
	end

	if not (t_neighbors == nil) then

		for i_p, p_neighbors in ipairs(t_neighbors) do
	
			local c_i, n_i, m_z, m_y, m_x, n_z, n_y, n_x = unpack(p_neighbors)

			if not (mg_neighbors[tonumber(c_i)]) then
				mg_neighbors[tonumber(c_i)] = {}
			end

			mg_neighbors[tonumber(c_i)][tonumber(n_i)] = {}
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].m_z = tonumber(m_z)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].m_y = tonumber(m_y)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].m_x = tonumber(m_x)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].n_z = tonumber(n_z)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].n_y = tonumber(n_y)
			mg_neighbors[tonumber(c_i)][tonumber(n_i)].n_x = tonumber(n_x)
	
		end

		minetest.log("[MOD] mg_earth: Voronoi Cell Neighbors loaded from file.")

	end
end

if mg_heightmap_select == "vPlanets" or mg_heightmap_select == "vRand3D" then
	load_3D_neighbors(n_file)
else
	load_neighbors(n_file)
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

	save_worldpath(temp_neighbors, pfile)

end

local function save_3D_neighbors(pfile)

	if not pfile or pfile == "" then
		return
	end

	local temp_neighbors = "#Cell_Index|Neighbor_Index|Midpoint_Zpos|Midpoint_Ypos|Midpoint_Xpos|Neighbor_Zpos|Neighbor_Ypos|Neighbor_Xpos\n"

	for i_c, i_cell in pairs(mg_neighbors) do

		temp_neighbors = temp_neighbors .. "#C_I|N_I|M_Z|M_Y|M_X|N_Z|N_Y|N_X\n"

		for i_n, i_neighbor in pairs(i_cell) do

			temp_neighbors = temp_neighbors .. i_c .. "|" .. i_n .. "|" .. i_neighbor.m_z .. "|" .. i_neighbor.m_y .. "|" .. i_neighbor.m_x .. "|" .. i_neighbor.n_z .. "|" .. i_neighbor.n_y .. "|" .. i_neighbor.n_x .. "\n"

		end

		temp_neighbors = temp_neighbors .. "#" .. "\n"

	end

	save_worldpath(temp_neighbors, pfile)

end


--##Biome functions.  Create table of content ids, determine biome, get name / altitude / ecosystem, get heat / humid scalars
local function update_biomes()

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
			mg_earth.biome_info[desc.name].b_dungeon = mg_earth.c_stone
			mg_earth.biome_info[desc.name].b_dungeon_alt = mg_earth.c_mossy
			mg_earth.biome_info[desc.name].b_dungeon_stair = mg_earth.c_brick
			mg_earth.biome_info[desc.name].b_node_dust = mg_earth.c_air
			mg_earth.biome_info[desc.name].vertical_blend = 0
			mg_earth.biome_info[desc.name].min_pos = {x=-31000, y=-31000, z=-31000}
			mg_earth.biome_info[desc.name].max_pos = {x=31000, y=31000, z=31000}
			mg_earth.biome_info[desc.name].b_miny = -31000
			mg_earth.biome_info[desc.name].b_maxy = 31000
			mg_earth.biome_info[desc.name].b_heat = 50
			mg_earth.biome_info[desc.name].b_humid = 50
		

			if desc.node_top and desc.node_top ~= "" then
				mg_earth.biome_info[desc.name].b_top = minetest.get_content_id(desc.node_top) or mg_earth.c_top
			end

			if desc.depth_top and desc.depth_top ~= "" then
				mg_earth.biome_info[desc.name].b_top_depth = desc.depth_top or 1
			end

			if desc.node_filler and desc.node_filler ~= "" then
				mg_earth.biome_info[desc.name].b_filler = minetest.get_content_id(desc.node_filler) or mg_earth.c_filler
			end

			if desc.depth_filler and desc.depth_filler ~= "" then
				mg_earth.biome_info[desc.name].b_filler_depth = desc.depth_filler or 4
			end

			if desc.node_stone and desc.node_stone ~= "" then
				mg_earth.biome_info[desc.name].b_stone = minetest.get_content_id(desc.node_stone) or mg_earth.c_stone
			end

			if desc.node_water_top and desc.node_water_top ~= "" then
				mg_earth.biome_info[desc.name].b_water_top = minetest.get_content_id(desc.node_water_top) or mg_earth.c_water
			end

			if desc.depth_water_top and desc.depth_water_top ~= "" then
				mg_earth.biome_info[desc.name].b_water_top_depth = desc.depth_water_top or 1
			end

			if desc.node_water and desc.node_water ~= "" then
				mg_earth.biome_info[desc.name].b_water = minetest.get_content_id(desc.node_water) or mg_earth.c_water
			end

			if desc.node_river_water and desc.node_river_water ~= "" then
				mg_earth.biome_info[desc.name].b_river = minetest.get_content_id(desc.node_river_water) or mg_earth.c_river
			end

			if desc.node_riverbed and desc.node_riverbed ~= "" then
				mg_earth.biome_info[desc.name].b_riverbed = minetest.get_content_id(desc.node_riverbed) or mg_earth.c_river_bed
			end

			if desc.depth_riverbed and desc.depth_riverbed ~= "" then
				mg_earth.biome_info[desc.name].b_riverbed_depth = desc.depth_riverbed or 2
			end

			if desc.node_cave_liquid and desc.node_cave_liquid ~= "" then
				-- mg_earth.biome_info[desc.name].b_cave_liquid = minetest.get_content_id(desc.node_cave_liquid[1]) or mg_earth.c_cave_liquid
				mg_earth.biome_info[desc.name].b_cave_liquid = minetest.get_content_id(desc.node_cave_liquid) or mg_earth.c_cave_liquid
			end

			if desc.node_dungeon and desc.node_dungeon ~= "" then
				mg_earth.biome_info[desc.name].b_dungeon = minetest.get_content_id(desc.node_dungeon) or mg_earth.c_dungeon
			end

			if desc.node_dungeon_alt and desc.node_dungeon_alt ~= "" then
				mg_earth.biome_info[desc.name].b_dungeon_alt = minetest.get_content_id(desc.node_dungeon_alt) or mg_earth.c_dungeon_alt
			end

--[[
			if desc.node_dungeon_stair and desc.node_dungeon_stair ~= "" then
				mg_earth.biome_info[desc.name].b_dungeon_stair = minetest.get_content_id(desc.node_dungeon_stair) or mg_earth.c_river
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
end


local function get_biome_altitude(y)

	local alt = ""

	if (y >= mg_earth.config.max_beach) and (y < mg_earth.config.max_coastal) then
		alt = "coastal"
	elseif (y >= mg_earth.config.max_coastal) and (y < mg_earth.config.max_lowland) then
		alt = "lowland"
	elseif (y >= mg_earth.config.max_lowland) and (y < mg_earth.config.max_shelf) then
		alt = "shelf"
	elseif (y >= mg_earth.config.max_shelf) and (y < mg_earth.config.max_highland) then
		alt = "highland"
	end

	return alt

end

local function calc_biome_from_noise(heat, humid, pos)
	local biome_closest = nil
	local biome_closest_blend = nil
	local dist_min = 31000
	local dist_min_blend = 31000

	for i, biome in pairs(mg_earth.biome_info) do
		local min_pos, max_pos = biome.min_pos, biome.max_pos
		if pos.y >= min_pos.y and pos.y <= max_pos.y+biome.vertical_blend
				and pos.x >= min_pos.x and pos.x <= max_pos.x
				and pos.z >= min_pos.z and pos.z <= max_pos.z then
			local d_heat = heat - biome.b_heat
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

	if biome_closest_blend and dist_min_blend <= dist_min
			and rng:next(0, biome_closest_blend.vertical_blend) >= pos.y - biome_closest_blend.max_pos.y then
		return biome_closest_blend.b_name
	end

	if biome_closest then
		return biome_closest.b_name
	end

	return

end

local function get_gal_biome_name(pheat,phumid,ppos)

	local t_heat, t_humid, t_altitude, t_name

	local m_top1 = 5
	local m_top2 = 35
	local m_top3 = 65
	local m_top4 = 95

	local m_biome1 = 25
	local m_biome2 = 50
	local m_biome3 = 75

	if pheat < m_top1 then
		t_heat = "cold"
	elseif pheat >= m_top1 and pheat < m_top2 then
		t_heat = "cool"
	elseif pheat >= m_top2 and pheat < m_top3 then
		t_heat = "temperate"
	elseif pheat >= m_top3 and pheat < m_top4 then
		t_heat = "warm"
	elseif pheat >= m_top4 then
		t_heat = "hot"
	else

	end

	if phumid < m_top1 then
		t_humid = "_arid"
	elseif phumid >= m_top1 and phumid < m_top2 then
		t_humid = "_semiarid"
	elseif phumid >= m_top2 and phumid < m_top3 then
		t_humid = "_temperate"
	elseif phumid >= m_top3 and phumid < m_top4 then
		t_humid = "_semihumid"
	elseif phumid >= m_top4 then
		t_humid = "_humid"
	else

	end

	if ppos.y < gal.mapgen.beach_depth then
		t_altitude = "_ocean"
	elseif ppos.y >= gal.mapgen.beach_depth and ppos.y < gal.mapgen.maxheight_beach then
		t_altitude = "_beach"
	elseif ppos.y >= gal.mapgen.maxheight_beach and ppos.y < gal.mapgen.maxheight_highland then
		t_altitude = ""
	elseif ppos.y >= gal.mapgen.maxheight_highland and ppos.y < gal.mapgen.maxheight_mountain then
		t_altitude = "_mountain"
	elseif ppos.y >= gal.mapgen.maxheight_mountain then
		t_altitude = "_strato"
	else
		t_altitude = ""
	end

	if t_heat and t_heat ~= "" and t_humid and t_humid ~= "" then
		t_name = t_heat .. t_humid .. t_altitude
	else
		if (t_heat == "hot") and (t_humid == "_humid") and (pheat > 90) and (phumid > 90) and (t_altitude == "_beach") then
			t_name = "hot_humid_swamp"
		elseif (t_heat == "hot") and (t_humid == "_semihumid") and (pheat > 90) and (phumid > 80) and (t_altitude == "_beach") then
			t_name = "hot_semihumid_swamp"
		elseif (t_heat == "warm") and (t_humid == "_humid") and (pheat > 80) and (phumid > 90) and (t_altitude == "_beach") then
			t_name = "warm_humid_swamp"
		elseif (t_heat == "temperate") and (t_humid == "_humid") and (pheat > 57) and (phumid > 90) and (t_altitude == "_beach") then
			t_name = "temperate_humid_swamp"
		else
			t_name = "temperate_temperate"
		end
	end

	if ppos.y >= -31000 and ppos.y < -20000 then
		t_name = "generic_mantle"
	elseif ppos.y >= -20000 and ppos.y < -15000 then
		t_name = "stone_basalt_01_layer"
	elseif ppos.y >= -15000 and ppos.y < -10000 then
		t_name = "stone_brown_layer"
	elseif ppos.y >= -10000 and ppos.y < -6000 then
		t_name = "stone_sand_layer"
	elseif ppos.y >= -6000 and ppos.y < -5000 then
		t_name = "desert_stone_layer"
	elseif ppos.y >= -5000 and ppos.y < -4000 then
		t_name = "desert_sandstone_layer"
	elseif ppos.y >= -4000 and ppos.y < -3000 then
		t_name = "generic_stone_limestone_01_layer"
	elseif ppos.y >= -3000 and ppos.y < -2000 then
		t_name = "generic_granite_layer"
	elseif ppos.y >= -2000 and ppos.y < gal.mapgen.ocean_depth then
		t_name = "generic_stone_layer"
	else
		
	end

	return t_name

end

local function get_heat_scalar(ppos)

	if mg_earth.config.use_heat_scalar == true then

		local t_z = abs(ppos.z)
		local t_heat = 50
		local t_heat_scale = 0.003
		local t_heat_mid = ((60000 * mg_world_scale) * 0.25) - (sin(ppos.x / (3000 * mg_world_scale)) * 5)
		local t_diff = t_heat_mid - t_z
		local t_map_scale = t_heat_scale / mg_world_scale

		return t_heat + (t_diff * t_map_scale)

	else
		return 0
	end

end

local function get_humid_scalar(ppos)

	if mg_earth.config.use_humid_scalar == true then

		local t_z = abs(ppos.z)
		local t_humid_rng_mid = 87
		local t_humid_mean = 50
		local t_latitude = ((60000 * mg_world_scale) * 0.062) - (sin(ppos.x / (3000 * mg_world_scale)) * 8)
		local t_diff = 0

		if t_z <= (t_latitude * 2) then
			local t_mid = t_latitude
			local t_scale = (((t_humid_rng_mid + t_humid_mean) / 2) * ((t_mid - t_z) / t_latitude))
			t_diff = t_humid_mean + t_scale
		elseif (t_z > (t_latitude * 2)) and (t_z <= (t_latitude * 4)) then
			local t_mid = t_latitude * 3
			local t_scale = (((t_humid_rng_mid + t_humid_mean) / 2) * ((t_mid - t_z) / t_latitude))
			t_diff = t_humid_mean - t_scale
		elseif (t_z > (t_latitude * 4)) then
			local t_mid = t_latitude * 5
			local t_scale = (((t_humid_rng_mid + t_humid_mean) / 2) * ((t_mid - t_z) / t_latitude))
			t_diff = t_humid_mean + t_scale
		end

		return t_diff

	else
		return 0
	end

end


--##Lakes mod by Sokomine
-- helper function for mark_min_max_height_in_mapchunk(..)
-- math_extrema: math.min for maxheight; math.max for minheight
-- populates the tables minheight and maxheight with data;
local mark_min_max_height_local = function(minp, maxp, heightmap, ax, az, i, chunksize, minheight, maxheight, direction)
	i = i+1;
	if( ax==minp.x or az==minp.z or ax==maxp.x or az==maxp.z) then
		minheight[i] = heightmap[i];
		maxheight[i] = heightmap[i];
	else
		if( not( minheight[i])) then
			minheight[i] = -100000;
		end
		if( not( maxheight[i])) then
			maxheight[i] =  100000;
		end

		local i_side = i-chunksize;
		local i_prev = i-1;
		local i_add  = -1;
		local swap_args = false;
		if( direction==-1 ) then
			i_side = i+chunksize;
			i_prev = i+1;
			i_add  = 1;
			swap_args = true;
		else
			direction = 1;
		end

		-- do for minheight (=search for hills)
		local hr = minheight[ i_side ];
		-- handle minheight
		-- compare minheight with the neighbour to the right or left
		if( hr and heightmap[i] and hr>minheight[i]) then
			minheight[i] = math.min(hr, heightmap[i]);
		end

		if( ((direction==1 and ax>minp.x) or (direction==-1 and ax<maxp.x))
		   -- has the neighbour before a higher minheight?
		   and minheight[ i_prev ]
		   and minheight[ i_prev ] > minheight[ i ]) then
			minheight[ i ] = math.min( minheight[ i_prev ], heightmap[i]);
		end
		hr = minheight[ i ];
		-- walk backward in that row and set all with a lower minheight but
		-- a sufficiently high height to the new minheight
		local n = 1;
		local i_run = i-n;
		while( hr
		   and ((direction==1 and (ax-n)>=minp.x) or (direction==-1 and (ax+n)<=maxp.x))
		   -- has the neighbour before a lower minheight?
	   and minheight[ i_run ]
		   and minheight[ i_run ] < hr
		   -- is the neighbour before heigh enough?
		   and (heightmap[ i_run ] >= hr or heightmap[ i_run ] > minheight[ i_run ])) do
			hr = math.min( hr, heightmap[ i_run ]);
			minheight[ i_run ] = hr;

			n = n+1;
			i_run = i_run + i_add;
		end

		-- same for maxheight (= search for holes)
		hr = maxheight[ i_side ];
		-- compare maxheight with the neighbour to the right or left
		if( hr and heightmap[i] and hr<maxheight[i]) then
			maxheight[i] = math.max(hr, heightmap[i]);
		end

		if( ((direction==1 and ax>minp.x) or (direction==-1 and ax<maxp.x))
		   -- has the neighbour before a higher maxheight?
		   and maxheight[ i_prev ]
		   and maxheight[ i_prev ] < maxheight[ i ]) then
			maxheight[ i ] = math.max( maxheight[ i_prev ], heightmap[i]);
		end
		hr = maxheight[ i ];
		-- walk backward in that row and set all with a lower maxheight but
		-- a sufficiently high height to the new maxheight
		local n = 1;
		local i_run = i-n;
		while( hr
		   and ((direction==1 and (ax-n)>=minp.x) or (direction==-1 and (ax+n)<=maxp.x))
		   -- has the neighbour before a lower maxheight?
		   and maxheight[ i_run ]
		   and maxheight[ i_run ] > hr
		   -- is the neighbour before heigh enough?
		   and (heightmap[ i_run ] <= hr or heightmap[ i_run ] < maxheight[ i_run ])) do
			hr = math.max( hr, heightmap[ i_run ]);
			maxheight[ i_run ] = hr;

			n = n+1;
			i_run = i_run + i_add;
		end
	end
end

-- detect places where nodes might be removed or added without changing the borders
-- of the mapchunk; afterwards, the landscape may be levelled, but one hill or hole
-- cannot yet be distinguished from the other;
-- more complex shapes may require multiple runs
-- Note: There is no general merging here (apart fromm the two runs) because MT maps are
--       usually very small-scale and there would be too many areas that may need merging.
local mark_min_max_height_in_mapchunk = function(minp, maxp, heightmap)
	local chunksize = maxp.x - minp.x + 1;
	local minheight = {}
	local maxheight = {}
	for j=1, 2 do
		local i = 0
		for az=minp.z,maxp.z do
		for ax=minp.x,maxp.x do
			-- fill minheight and maxheight with data whereever hills or holes are
			mark_min_max_height_local(minp, maxp, heightmap, ax, az, i, chunksize, minheight, maxheight, 1);
			i = i+1
		end
		end

		-- we keep i the way it is;
		i = i+1;
		-- the previous run could not cover all situations; check from the other side now
		for az=maxp.z,minp.z,-1 do
		for ax=maxp.x,minp.x,-1 do
			-- update minheight and maxheight for hills and holes; but this time, start from the
			-- opposite corner of the mapchunk in order to preserve what is needed there
			mark_min_max_height_local(minp, maxp, heightmap, ax, az, i, chunksize, minheight, maxheight, -1);
			i = i-1;
		end
		end
	end
	return {minheight = minheight, maxheight = maxheight};
end

-- helper function for mark_holes_and_hills_in_mapchunk(..)
local identify_individual_holes_or_hills = function( minp, maxp, ax, az, i, chunksize, markmap, merge_into, hole_counter, hole_data, h_real, h_max, condition)
	markmap[ i ] = 0;
	-- no hole or hill
	if( not( condition )) then
		return hole_counter;
	end
	local h_prev_z = markmap[ i-chunksize ];
	local h_prev_x = markmap[ i-1 ];
	local match_z = 0;
	local match_x = 0;
	-- if the node to the right (at z=z-1) is also part of a hole, then
	-- both nodes are part of the same hole
	if( az>minp.z and h_prev_z and h_prev_z > 0 ) then
		match_z = h_prev_z;
	end
	-- if the node before (at x=x-1) is also part of a hole, then both
	-- nodes are also part of the same hole
	if( ax>minp.x and h_prev_x and h_prev_x > 0 ) then
		match_x = h_prev_x;
	end

	-- continue the hole from z direction
	if(     match_z > 0 and match_x ==0) then
		markmap[ i ] = merge_into[ match_z ];
	-- continue the hole from x direction
	elseif( match_z ==0 and match_x > 0) then
		markmap[ i ] = merge_into[ match_x ];
	-- new hole at this place
	elseif( match_z ==0 and match_x ==0) then
		hole_counter = hole_counter + 1;
		merge_into[ hole_counter ] = hole_counter;
		markmap[ i ] = hole_counter;
	-- both are larger than 0 and diffrent - we need to merge
	else
		markmap[ i ] = merge_into[ match_z ];
		-- actually do the merge
		for k,v in ipairs(merge_into) do
			if( merge_into[ k ] == match_x ) then
				merge_into[ k ] = merge_into[ match_z ];
			end
		end
	end

	-- gather some statistical data in hole_data
	if( markmap[ i ]>0 ) then
		local id = markmap[ i ];
		-- height difference
		local ay = math.abs(h_max - h_real);
		if( not( hole_data[ id ])) then
			hole_data[ id ] = {
				minp = {x=ax, z=az, y=math.min(h_max, h_real)},
				maxp = {x=ax, z=az, y=math.max(h_max, h_real)},
				size = 1,
				volume = ay,
				};
		else
			-- the surface area is one larger now
			hole_data[ id ].size   = hole_data[ id ].size   + 1;
			-- the volume has also grown
			hole_data[ id ].volume = hole_data[ id ].volume + ay;
			if( ax < hole_data[ id ].minp.x ) then
				hole_data[ id ].minp.x = ax;
			end
			-- minimal and maximal dimensions may have changed
			hole_data[ id ].minp.x = math.min( ax, hole_data[ id ].minp.x );
			hole_data[ id ].maxp.x = math.max( ax, hole_data[ id ].maxp.x );
			hole_data[ id ].minp.z = math.min( az, hole_data[ id ].minp.z );
			hole_data[ id ].maxp.z = math.max( az, hole_data[ id ].maxp.z );
			hole_data[ id ].minp.y = math.min( ay, hole_data[ id ].minp.y );
			hole_data[ id ].maxp.y = math.max( ay, hole_data[ id ].maxp.y );
		end
	end
	return hole_counter;
end

-- helper function for mark_holes_and_hills_in_mapchunk(..)
-- works the same for hills and holes
local merge_if_same_hole_or_hill = function(hole_data, merge_into)
	local id2merged = {}
	local merged = {}
	local hole_counter = 1;
	-- we already know from merge_into that k needs to be merged into v
	for k,v in ipairs(merge_into) do
		-- we have not covered the merge target
		if( not( id2merged[ v ])) then
			id2merged[ v ] = hole_counter;
			hole_counter = hole_counter + 1;
			merged[ v ] = hole_data[ v ];
		-- another hole or hill has already been treated -> merge with new data needed
		else
			-- merge hole_data_merged
			merged[v].size   = merged[ v ].size   + hole_data[ k ].size;
			merged[v].volume = merged[ v ].volume + hole_data[ k ].volume;
			-- minimal and maximal dimensions may have changed
			merged[v].minp.x = math.min( merged[v].minp.x, hole_data[k].minp.x );
			merged[v].maxp.x = math.max( merged[v].maxp.x, hole_data[k].maxp.x );
			merged[v].minp.z = math.min( merged[v].minp.z, hole_data[k].minp.z );
			merged[v].maxp.z = math.max( merged[v].maxp.z, hole_data[k].maxp.z );
			merged[v].minp.y = math.min( merged[v].minp.y, hole_data[k].minp.y );
			merged[v].maxp.y = math.max( merged[v].maxp.y, hole_data[k].maxp.y );
		end
		id2merged[ k ] = id2merged[ v ];
	end
	return {id2merged=id2merged, merged=merged};
end

local mark_holes_and_hills_in_mapchunk = function( minp, maxp, heightmap, minheight, maxheight)
	local chunksize = maxp.x - minp.x + 1;
	-- distinguish the individual hills and holes from each other so that we may treat
	-- each one diffrently if so desired
	local holes_markmap = {}
	local hills_markmap = {}
	-- used to mark the individual holes on the markmap
	local hole_counter = 0;
	local hill_counter = 0;
	-- some holes will first be seen from diffrent directions and get diffrent IDs (=
	-- hole_counter) assigned; these need to be merged because they're the same
	local holes_merge_into = {};
	local hills_merge_into = {};
	-- store size, minp/maxp, max/min depth/height
	local hole_data = {};
	local hill_data = {};

	local i = 0
	for az=minp.z,maxp.z do
	for ax=minp.x,maxp.x do
		i = i+1;

		local h_real = heightmap[i];
		local h_min  = minheight[i];
		local h_max  = maxheight[i];
		-- do this for holes
		hole_counter = identify_individual_holes_or_hills( minp, maxp, ax, az, i, chunksize,
			holes_markmap, holes_merge_into, hole_counter, hole_data, h_real, h_min,
			-- h_max>0 because we do not want to create pools/fill land below sea level
			( h_max and h_real and h_max>h_real and h_max<maxp.y and h_max>minp.y and h_max>0));
		-- ..and for hills
		hill_counter = identify_individual_holes_or_hills( minp, maxp, ax, az, i, chunksize,
			hills_markmap, hills_merge_into, hill_counter, hill_data, h_real, h_max,
			-- the socket of individual hills may well lie below water level
			( h_min and h_real and h_min<h_real and h_min<maxp.y and h_min>minp.y and h_min>minp.y));
	end
	end

	-- a hole or hill might have been found from diffrent directions and thus
	-- might have gotten diffrent ids; merge them if they represent the same
	-- hole or hill
	local holes = merge_if_same_hole_or_hill(hole_data, holes_merge_into);
	local hills = merge_if_same_hole_or_hill(hill_data, hills_merge_into);

	return {holes = holes, holes_merge_into = holes_merge_into, holes_markmap = holes_markmap,
	        hills = hills, hills_merge_into = hills_merge_into, hills_markmap = hills_markmap};
end

-- create a (potential) new heightmap where all the hills we discovered are flattened and all
-- holes filled with something so that we get more flat terrain;
-- this function also adjusts
-- 	detected.hills.merged[id].target_height (set to the flattened value)
-- 	and detected.hills_markmap[i]  for easier access without having to go throuh
-- 	                               detected.hills_merge_into in the future
-- (same for holes)
local heightmap_with_hills_lowered_and_holes_filled = function( minp, maxp, heightmap, extrema, detected)
	local adjusted_heightmap = {}
	local chunksize = maxp.x - minp.x + 1;
	local i = 0
	for az=minp.z,maxp.z do
	for ax=minp.x,maxp.x do
		i = i+1;

		-- no changes at the borders of the mapchunk
		if( ax==minp.x or ax==maxp.x or az==minp.z or az==maxp.z) then
			adjusted_heightmap[i] = heightmap[i];
		else
			-- make sure it gets one value set
			adjusted_heightmap[i] = heightmap[i];

			-- is there a hill?
			local hill_id = detected.hills_markmap[i];
			if( hill_id and hill_id>0) then
				-- which hill are we dealing with?
				local id = detected.hills_merge_into[ hill_id ];
				local new_height = detected.hills.merged[id].target_height;
				if( not( new_height )) then
					-- target height: height if this hill would be removed completely
					new_height = minp.y-1;
				end
				new_height = math.max( new_height, extrema.minheight[i]);
				local id_hole_right = detected.holes_markmap[ i-chunksize ];
				if( id_hole_right and id_hole_right > 0) then
					new_height = math.max( new_height, detected.holes.merged[id_hole_right].target_height);
				end
				local id_hole_prev  = detected.holes_markmap[ i-1 ];
				if( id_hole_prev  and id_hole_prev > 0) then
					new_height = math.min( new_height, detected.holes.merged[id_hole_prev ].target_height);
				end
				detected.hills.merged[id].target_height = new_height;
				adjusted_heightmap[i] = new_height;
				-- store for later use
				detected.hills_markmap[i] = id;
			end

			-- is there a hole?
			local hole_id = detected.holes_markmap[i];
			if( hole_id and hole_id>0) then
				-- which hole are we dealing with?
				local id = detected.holes_merge_into[ hole_id ];
				local new_height = detected.holes.merged[id].target_height;
				if( not( new_height )) then
					-- target height: height if this hole would be filled completely
					new_height = maxp.y + 1;
				end
				new_height = math.min( new_height, extrema.maxheight[i]);
				-- is either the neighbour to the right or in the south a hill?
				-- we have processed that place already; thus we can be sure
				-- that this is an id that can be fed to detected.hills.merged
				-- directly
				local id_hill_right = detected.hills_markmap[ i-chunksize ];
				if( id_hill_right and id_hill_right > 0) then
					new_height = math.min( new_height, detected.hills.merged[id_hill_right].target_height);
				end
				local id_hill_prev  = detected.hills_markmap[ i-1 ];
				if( id_hill_prev  and id_hill_prev > 0) then
					new_height = math.min( new_height, detected.hills.merged[id_hill_prev ].target_height);
				end
				detected.holes.merged[id].target_height = new_height;
				adjusted_heightmap[i] = new_height;
				-- store for later use
				detected.holes_markmap[i] = id;
			end
		end
	end
	end
	return adjusted_heightmap;
end

local function get_lakes(minp, maxp)

	-- do the actual work of hill and hole detection
	local tl1 = minetest.get_us_time();
	-- find places where the land could be lowered or raised
	local extrema = mark_min_max_height_in_mapchunk(minp, maxp, mg_earth.heightmap);
	-- distinguish between individual holes and hills
	mg_earth.detected = mark_holes_and_hills_in_mapchunk( minp, maxp, mg_earth.heightmap, extrema.minheight, extrema.maxheight);
	-- flatten hills, fill holes (just virutal in adjusted_heightmap)
	local adjusted_heightmap = heightmap_with_hills_lowered_and_holes_filled( minp, maxp, mg_earth.heightmap, extrema, mg_earth.detected);
	local tl2 = minetest.get_us_time();
	print("Time elapsed: "..tostring( tl2-tl1 ));

	-- for now: fill each hole (no matter how big or tiny) with river water
	for id, data in pairs( mg_earth.detected.holes.merged ) do
		--detected.holes.merged[id].material = minetest.get_name_from_content_id(mg_earth.c_river);
		mg_earth.detected.holes.merged[id].material = mg_earth.c_river;
	end

end



--[[mg_earth.noise_handler = {}

-- These guards are here because 'minetest.get_perlin' isn't aviable at startup,
-- which is when the noise object is registered
-- and 'PerlinNoise()' doesn't take into acount the map seed
local function get_2d(noise, pos)
    if not noise.noise_obj then
        noise.noise_obj = minetest.get_perlin(noise.params)
    end
    -- switched around z and y as this is the usual use case
    return noise.noise_obj:get_2d({x = pos.x, y = pos.z, z = 0})
end

local function get_3d(noise, pos)
    if not noise.noise_obj then
        noise.noise_obj = minetest.get_perlin(noise.params)
    end
    return noise.noise_obj:get_3d(pos)
end

-- local function get_2d_map(noise, pos)
    -- if not noise.noise_obj then
        -- noise.noise_obj = minetest.get_perlin_map(noise.params)
    -- end
    -- -- switched around z and y as this is the usual use case
    -- return noise.noise_obj:get_2d_map({x = pos.x, y = pos.z, z = 0})
-- end

-- local function get_3d_map(noise, pos)
    -- if not noise.noise_obj then
        -- noise.noise_obj = minetest.get_perlin_map(noise.params)
    -- end
    -- return noise.noise_obj:get_3d_map(pos)
-- end

local function get_2d_map_flat(noise, minp)
--local function get_2d_flat(noise, minp)
    if not noise.noise_map_obj then
        noise.noise_map_obj = minetest.get_perlin_map(noise.params, noise.chunk_size)
    end
    -- switched around z and y as this is the usual use case
    --noise.noise_map_obj:get_2d_map_flat({x = minp.x, y = minp.z, z = 0}, noise.buffer_2d)
    noise.noise_map_obj:get_2d_map_flat({x = minp.x, y = minp.z, z = 0}, noise.buffer_2d)
    return noise.buffer_2d
end

local function get_3d_map_flat(noise, minp)
--local function get_3d_flat(noise, minp)
    if not noise.noise_map_obj then
        noise.noise_map_obj = minetest.get_perlin_map(noise.params, noise.chunk_size)
    end
    --noise.noise_map_obj:get_3d_map_flat(minp, noise.buffer_3d)
    noise.noise_map_obj:get_3d_map_flat(minp, noise.buffer_3d)
    return noise.buffer_3d
end


-- Returns a noise object which combines the capacity of those returned by
-- 'minetest.get_perlin' and 'minetest.get_perlin_map'
-- and automaticaly maintains buffer tables for better performance.

--function noise_handler.get_noise_object(params, chunk_size)
mg_earth.noise_handler.get_noise_object = function(params, chunk_size)
    local noise_object = {
        params = params,
        chunk_size = chunk_size or {x = 80, y = 80, z = 80},
        buffer_2d = {},
        buffer_3d = {},
        get_2d = get_2d,
        get_3d = get_3d,
        -- get_2d_map = get_2d_map,
        -- get_3d_map = get_3d_map,
        get_2d_map_flat = get_2d_map_flat,
        get_3d_map_flat = get_3d_map_flat,
        -- get_2d_flat = get_2d_flat,
        -- get_3d_flat = get_3d_flat,
    }

    return noise_object
end
--]]



function mg_earth.noisemap(pobj, i, minp, chulens)

	local obj = {}
	if pobj == nil then
		--local obj = obj or minetest.get_perlin_map(mg_earth.noise[i], chulens)
		--obj = obj or minetest.get_perlin_map(mg_earth.noise[i], chulens)
		obj = minetest.get_perlin_map(mg_earth.noise[i], chulens)
	else
		obj = pobj
	end
	if minp.z then
		return obj:get_3d_map_flat(minp)
	else
		return obj:get_2d_map_flat(minp)
	end
end

-- useful function to convert a 3D pos to 2D
function pos2d(pos)
	if type(pos) == "number" then
		return {x = pos, y = pos}
	elseif pos.z then
		return {x = pos.x, y = pos.z}
	else
		return {x = pos.x, y = pos.y}
	end
end



--##Heightmap functions.  v6, v7, v67, vIslands, vVoronoi, vEarth and master get_mg_heightmap.
local function get_terrain_height_cliffs(theight,z,x)

	local cheight = minetest.get_perlin(mg_earth.noise["np_cliffs"]):get_2d({x=x,y=z})

		-- cliffs
	local t_cliff = 0
	if theight > 1 and theight < mg_earth.config.cliffs_thresh then 
		local clifh = max(min(cheight,1),0) 
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			theight = theight + (mg_earth.config.cliffs_thresh - theight) * clifh * ((theight < 2) and theight - 1 or 1)
		end
	end
	return theight, t_cliff
end

local function get_terrain_base_cliffs(theight,z,x)

	-- local cliffs_thresh = floor((mg_earth.noise["np_2d_base"].scale) * 0.5)
	local cheight = minetest.get_perlin(mg_earth.noise["np_cliffs"]):get_2d({x=x,y=z})

		-- cliffs
	local t_cliff = 0
	if theight > 1 and theight < mg_earth.config.cliffs_thresh then 
		local clifh = max(min(cheight,1),0) 
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			theight = theight + (mg_earth.config.cliffs_thresh - theight) * clifh * ((theight < 2) and theight - 1 or 1)
		end
	end
	return theight, t_cliff
end

local function get_terrain_alt_cliffs(theight,z,x)

	local cliffs_thresh = floor((mg_earth.noise["np_2d_alt"].scale) * 0.5)
	local cheight = minetest.get_perlin(mg_earth.noise["np_cliffs"]):get_2d({x=x,y=z})

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

local function get_3d_height(z,y,x)

	--local n_y = minetest.get_perlin(np_2d):get_2d({x=x,y=z})
	--local n_y = minetest.get_perlin(np_3dterrain):get_2d({x=x,y=z})

	--local n_f = minetest.get_perlin(np_3dterrain):get_3d({x = x, y = (n_y + y), z = z})
	local n_f = minetest.get_perlin(np_3dterrain):get_3d({x = x, y = y, z = z})

	--local s_d = (1 - n_y) / (mg_density * mg_world_scale)
	local s_d = n_f - (n_y + y)
	--local n_t = n_f + s_d
	local n_t = n_f - s_d

	return n_t

end

local function get_3d_density(z,y,x)

	local n_f = minetest.get_perlin(np_3dterrain):get_3d({x = x, y = y, z = z})
	local s_d = (1 - y) / (mg_density * mg_world_scale)
	
	local n_t = n_f + s_d

	return n_t

end

local function get_v5_height(z,x)

	local factor = minetest.get_perlin(mg_earth.noise["np_v5_factor"]):get_2d({x=x,y=z})
	local height = minetest.get_perlin(mg_earth.noise["np_v5_height"]):get_2d({x=x,y=z})
	-- -- local ground = minetest.get_perlin(mg_earth.noise["np_v5_ground"]):get_3d({x=x,y=y,z=z})
	-- local ground = minetest.get_perlin(mg_earth.noise["np_v5_ground"]):get_3d({x=x,y=-31000,z=z})

	local f = 0.55 * factor
	if (f < 0.01) then
		f = 0.01
	elseif (f >= 1.0) then
		f = 1.6
	end

	local h = height

	-- if (ground * f) < (y - h) then
	
	-- end
	
	--return f, h, ground
	return f, h

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

	local terrain_base = minetest.get_perlin(mg_earth.noise["np_v6_base"]):get_2d({
			x = x + 0.5 * mg_earth.noise["np_v6_base"].spread.x,
			y = z + 0.5 * mg_earth.noise["np_v6_base"].spread.y})

	local terrain_higher = minetest.get_perlin(mg_earth.noise["np_v6_higher"]):get_2d({
			x = x + 0.5 * mg_earth.noise["np_v6_higher"].spread.x,
			y = z + 0.5 * mg_earth.noise["np_v6_higher"].spread.y})

	local steepness = minetest.get_perlin(mg_earth.noise["np_v6_steep"]):get_2d({
			x = x + 0.5 * mg_earth.noise["np_v6_steep"].spread.x,
			y = z + 0.5 * mg_earth.noise["np_v6_steep"].spread.y})

	local height_select = minetest.get_perlin(mg_earth.noise["np_v6_height"]):get_2d({
			x = x + 0.5 * mg_earth.noise["np_v6_height"].spread.x,
			y = z + 0.5 * mg_earth.noise["np_v6_height"].spread.y})

	return get_v6_base(terrain_base, terrain_higher, steepness, height_select) + 2 -- (Dust)
end

local function get_v7_height(z,x)

	local aterrain = 0

	local hselect = minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=x,y=z})
	local hselect = rangelim(hselect, 0, 1)

	local persist = minetest.get_perlin(mg_earth.noise["np_v7_persist"]):get_2d({x=x,y=z})

	mg_earth.noise["np_v7_base"].persistence = persist;
	local height_base = minetest.get_perlin(mg_earth.noise["np_v7_base"]):get_2d({x=x,y=z})

	mg_earth.noise["np_v7_alt"].persistence = persist;
	local height_alt = minetest.get_perlin(mg_earth.noise["np_v7_alt"]):get_2d({x=x,y=z})

	if (height_alt > height_base) then
		aterrain = floor(height_alt)
	else
		aterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
	end

	return aterrain
end

local function get_terrain_height(z,x)

	local tterrain = 0

	local hselect = minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=x,y=z})
	local hselect = rangelim(hselect, 0, 1)

	local persist = minetest.get_perlin(mg_earth.noise["np_v7_persist"]):get_2d({x=x,y=z})

	mg_earth.noise["np_v7_base"].persistence = persist;
	local height_base = minetest.get_perlin(mg_earth.noise["np_v7_base"]):get_2d({x=x,y=z})

	mg_earth.noise["np_v7_alt"].persistence = persist;
	local height_alt = minetest.get_perlin(mg_earth.noise["np_v7_alt"]):get_2d({x=x,y=z})

	if (height_alt > height_base) then
		tterrain = floor(height_alt)
	else
		tterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
	end

	local cliffs_thresh = floor((mg_earth.noise["np_v7_alt"].scale) * 0.5)
	local cheight = minetest.get_perlin(mg_earth.noise["np_cliffs"]):get_2d({x=x,y=z})
	
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

local function get_carp_noise(z,x)

	--local n_base = minetest.get_perlin(mg_earth.noise["np_carp_base"]):get_2d({x=x,y=z})
	--local n_fill = minetest.get_perlin(mg_earth.noise["np_carp_filler_depth"]):get_2d({x=x,y=z})
	
	local n_terrain_step = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_hills = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_theight1 = minetest.get_perlin(mg_earth.noise["np_carp_height1"]):get_2d({x=x,y=z})
	local n_theight2 = minetest.get_perlin(mg_earth.noise["np_carp_height2"]):get_2d({x=x,y=z})
	local n_theight3 = minetest.get_perlin(mg_earth.noise["np_carp_height3"]):get_2d({x=x,y=z})
	local n_theight4 = minetest.get_perlin(mg_earth.noise["np_carp_height4"]):get_2d({x=x,y=z})
	local n_hills = minetest.get_perlin(mg_earth.noise["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth.noise["np_carp_mnt_step"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth.noise["np_carp_mnt_ridge"]):get_2d({x=x,y=z})
	
	local hill_mnt = n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills
	local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))

	local step_mnt =  n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)

	local n_mnt_var = abs(minetest.get_perlin(mg_earth.noise["np_carp_mnt_var"]):get_3d({x=x,y=-31000,z=z}))

	local com1, com2, com3, com4
	com1 = lerp(n_theight1, n_theight2, n_mnt_var)
	com2 = lerp(n_theight3, n_theight4, n_mnt_var)
	com3 = lerp(n_theight3, n_theight2, n_mnt_var)
	com4 = lerp(n_theight1, n_theight4, n_mnt_var)
	local hilliness = max(min(com1,com2),min(com3,com4))

	local hills = hill_mnt * hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = hills + ridged_mountains + step_mountains

	local surface_level = 12 + mountains

	return surface_level

end

local function get_carp_height(z,y,x,nfill)

	local grad_wl = 1 - mg_water_level;
	local y_terrain_height = -31000

	--local n_base = minetest.get_perlin(mg_earth.noise["np_carp_base"]):get_2d({x=x,y=z})
	--local n_fill = minetest.get_perlin(mg_earth.noise["np_carp_filler_depth"]):get_2d({x=x,y=z})
	
	local n_terrain_step = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_hills = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_theight1 = minetest.get_perlin(mg_earth.noise["np_carp_height1"]):get_2d({x=x,y=z})
	local n_theight2 = minetest.get_perlin(mg_earth.noise["np_carp_height2"]):get_2d({x=x,y=z})
	local n_theight3 = minetest.get_perlin(mg_earth.noise["np_carp_height3"]):get_2d({x=x,y=z})
	local n_theight4 = minetest.get_perlin(mg_earth.noise["np_carp_height4"]):get_2d({x=x,y=z})
	local n_hills = minetest.get_perlin(mg_earth.noise["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth.noise["np_carp_mnt_step"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth.noise["np_carp_mnt_ridge"]):get_2d({x=x,y=z})
	
	local hill_mnt = n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills
	local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))
	local step_mnt =  n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)

	local n_mnt_var = abs(nfill)

	local com1, com2, com3, com4
	com1 = lerp(n_theight1, n_theight2, n_mnt_var)
	com2 = lerp(n_theight3, n_theight4, n_mnt_var)
	com3 = lerp(n_theight3, n_theight2, n_mnt_var)
	com4 = lerp(n_theight1, n_theight4, n_mnt_var)
	local hilliness = max(min(com1,com2),min(com3,com4))

	local hills = hill_mnt * hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = hills + ridged_mountains + step_mountains

	local grad
	if (y < mg_water_level) then
		grad = grad_wl + (mg_water_level - y) * 3
	else
		grad = 1 - y
	end

	local surface_level = 12 + mountains + grad

	return surface_level

end

--local function get_carp_vals(z,x,i2d)
local function get_carp_vals(z,x)

	local grad_wl = 1 - mg_water_level;
	local y_terrain_height = -31000

	--local n_base = minetest.get_perlin(mg_earth.noise["np_carp_base"]):get_2d({x=x,y=z})
	--local n_fill = minetest.get_perlin(mg_earth.noise["np_carp_filler_depth"]):get_2d({x=x,y=z})
	
	local n_terrain_step = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_hills = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth.noise["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_theight1 = minetest.get_perlin(mg_earth.noise["np_carp_height1"]):get_2d({x=x,y=z})
	local n_theight2 = minetest.get_perlin(mg_earth.noise["np_carp_height2"]):get_2d({x=x,y=z})
	local n_theight3 = minetest.get_perlin(mg_earth.noise["np_carp_height3"]):get_2d({x=x,y=z})
	local n_theight4 = minetest.get_perlin(mg_earth.noise["np_carp_height4"]):get_2d({x=x,y=z})
	local n_hills = minetest.get_perlin(mg_earth.noise["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth.noise["np_carp_mnt_step"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth.noise["np_carp_mnt_ridge"]):get_2d({x=x,y=z})
	
	local hill_mnt = n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills
	local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))
	local step_mnt =  n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)

	-- mg_earth.height1[i2d] = n_theight1
	-- mg_earth.height2[i2d] = n_theight2
	-- mg_earth.height3[i2d] = n_theight3
	-- mg_earth.height4[i2d] = n_theight4
	-- mg_earth.hill_mnt[i2d] = hill_mnt
	-- mg_earth.ridge_mnt[i2d] = ridge_mnt
	-- mg_earth.step_mnt[i2d] = step_mnt

	-- local n_mnt_var = abs(minetest.get_perlin(mg_earth.noise["np_carp_mnt_var"]):get_3d({x=x,y=-31000,z=z}))

	-- local com1, com2, com3, com4
	-- com1 = lerp(n_theight1, n_theight2, n_mnt_var)
	-- com2 = lerp(n_theight3, n_theight4, n_mnt_var)
	-- com3 = lerp(n_theight3, n_theight2, n_mnt_var)
	-- com4 = lerp(n_theight1, n_theight4, n_mnt_var)
	-- local hilliness = max(min(com1,com2),min(com3,com4))

	-- local hills = hill_mnt * hilliness
	-- local ridged_mountains = ridge_mnt * hilliness
	-- local step_mountains = step_mnt * hilliness

	-- local mountains = hills + ridged_mountains + step_mountains

	-- local surface_level = 12 + mountains

	-- return surface_level
	return n_theight1, n_theight2, n_theight3, n_theight4, hill_mnt, ridge_mnt, step_mnt

end

local function get_cust_height(z,x)

	local v6_height = get_v6_height(z,x)
	--local v7_height = get_v7_height(z,x)
	local vI_height, cliff_height = get_terrain_height(z,x)
	
	local surface_level = vI_height
	
	return surface_level, cliff_height

end

local function get_diamondsquare_height(z,x)

	diasq.create(width, height, f)

end

local function get_valleys_height(z,x,i2d)

	-- local r_terrain = 0

	-- Check if in a river channel
	local v_rivers = minetest.get_perlin(mg_earth.noise["np_val_river"]):get_2d({x=x,y=z})
	local abs_rivers = abs(v_rivers)

	local valley    = minetest.get_perlin(mg_earth.noise["np_val_depth"]):get_2d({x=x,y=z})
	local valley_d  = valley * valley
	local base      = valley_d + minetest.get_perlin(mg_earth.noise["np_val_terrain"]):get_2d({x=x,y=z})
	local river     = abs_rivers - mg_earth.config.river_size_factor
	local tv        = max(river / minetest.get_perlin(mg_earth.noise["np_val_profile"]):get_2d({x=x,y=z}), 0)
	local valley_h  = valley_d * (1 - math.exp(-tv * tv))
	local surface_y = base + valley_h
	local slope     = valley_h * minetest.get_perlin(mg_earth.noise["np_val_slope"]):get_2d({x=x,y=z})

	mg_earth.surfacemap[i2d] = surface_y
	mg_earth.slopemap[i2d] = slope

--# 2D Generation
	local n_fill = minetest.get_perlin(mg_earth.noise["np_val_fill"]):get_3d({x=x,y=surface_y,z=z})

	local surface_delta = n_fill - surface_y;
	local density = slope * n_fill - surface_delta;

	local river_course = 31000
	if abs_rivers <= mg_earth.config.river_size_factor then
		-- TODO: Add riverbed calculation
		river_course = abs_rivers
	end

	-- if density <= 0 then
		-- r_terrain = density
	-- else
		-- r_terrain = surface_y
	-- end

	return density, river_course
	--return surface_y, river_course
	--return density

end

--local function get_valleys3D_height(z,y,x,nfill,i2d)
--local function get_valleys3D_height(z,y,x,i2d)
local function get_valleys3D_height(z,x)

	-- Check if in a river channel
	local v_rivers = minetest.get_perlin(mg_earth.noise["np_val_river"]):get_2d({x=x,y=z})
	local abs_rivers = abs(v_rivers)

	local valley    = minetest.get_perlin(mg_earth.noise["np_val_depth"]):get_2d({x=x,y=z})
	local valley_d  = valley * valley
	local base      = valley_d + minetest.get_perlin(mg_earth.noise["np_val_terrain"]):get_2d({x=x,y=z})
	local river     = abs_rivers - mg_earth.config.river_size_factor
	local tv        = max(river / minetest.get_perlin(mg_earth.noise["np_val_profile"]):get_2d({x=x,y=z}), 0)
	local valley_h  = valley_d * (1 - math.exp(-tv * tv))
	local surface_y = base + valley_h
	local slope     = valley_h * minetest.get_perlin(mg_earth.noise["np_val_slope"]):get_2d({x=x,y=z})

	-- mg_earth.surfacemap[i2d] = surface_y
	-- mg_earth.slopemap[i2d] = slope

-- -- --# 2D Generation
	-- local n_fill = minetest.get_perlin(mg_earth.noise["np_val_fill"]):get_3d({x=x,y=y,z=z})
	-- -- local n_fill = nfill

	-- local surface_delta = n_fill - surface_y;
	-- local density = slope * n_fill - surface_delta;

	local river_course = 31000
	if abs_rivers <= mg_earth.config.river_size_factor then
		-- TODO: Add riverbed calculation
		river_course = abs_rivers
	end

	-- return density, river_course
	-- --return surface_y, river_course
	-- --return density
	
	return surface_y, slope, river_course

end

local function get_mg_heightmap(ppos,nheat,nhumid, i2d)

	-- -- if mg_heightmap_select == "v3D" or mg_heightmap_select == "vCarp3D" or mg_heightmap_select == "vValleys3D" then
	-- if mg_heightmap_select == "v3D" or mg_heightmap_select == "vCarp3D" then
		-- return
	-- end

	local r_y = mg_earth.config.mg_flat_height
	local r_c = 0
	
	local mp_y = 0
	local mpheight = 0
	
	local vheight = 0
	local nheight = 0
	local n_c = 0

	mg_earth.valleymap[i2d] = -31000
	mg_earth.rivermap[i2d] = -31000
	mg_earth.riverpath[i2d] = 0
	mg_earth.lfmap[i2d] = -31000
	mg_earth.lfpath[i2d] = 0
	mg_earth.rfmap[i2d] = -31000
	mg_earth.rfpath[i2d] = 0


	--if mg_heightmap_select == "vRand3D" or mg_heightmap_select == "vPlanets" then
	if mg_heightmap_select == "vRand2D" then

		local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 1)
		get_cell_neighbors(m_idx, m_z, m_x, 1)
		local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 2)
		get_cell_neighbors(p_idx, p_z, p_x, 2)

		-- local m_idx, m_dist, m_z, m_y, m_x = get_nearest_cell({x = ppos.x, x = ppos.x, z = ppos.z}, 1)
		-- get_cell_neighbors(m_idx, m_z, m_x, 1)
		-- local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 2)
		-- get_cell_neighbors(p_idx, p_z, p_x, 2)

		mg_earth.cellmap[i2d] = {m=m_idx,p=p_idx}

	end

	if mg_heightmap_select == "vEarth" or mg_heightmap_select == "vVoronoi" or mg_heightmap_select == "vVoronoiPlus" then

		local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 1)
		-- get_cell_neighbors(m_idx, m_z, m_x, 1)
		local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 2)
		-- get_cell_neighbors(p_idx, p_z, p_x, 2)

		local m_n = mg_neighbors[m_idx]
		local m_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, m_n)
		local p_n = mg_neighbors[p_idx]
		local p_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, p_n)

		mg_earth.cellmap[i2d] = {m=m_idx,p=p_idx}

-- ## TECTONIC UPLIFT
		local t = {}
		local use_tectonics = "default"		--"all", "only", "alt", "default" (or blank),

		if mg_earth.settings.voronoi_file == 1  then
			if m_idx >= 1 and m_idx <= 7 then
				t = mg_earth.tectonic_plates["c_northamerica"]
			elseif m_idx >= 8 and m_idx <= 11 then
				t = mg_earth.tectonic_plates["c_southamerica"]
			elseif m_idx >= 12 and m_idx <= 16 then
				t = mg_earth.tectonic_plates["c_europe"]
			elseif m_idx >= 17 and m_idx <= 25 then
				t = mg_earth.tectonic_plates["c_asia"]
			elseif m_idx >= 26 and m_idx <= 30 then
				t = mg_earth.tectonic_plates["c_africa"]
			elseif m_idx == 31 then
				t = mg_earth.tectonic_plates["c_australia"]
			else

			end

			t.dist = get_dist((t.x - ppos.x), (t.z - ppos.z), dist_metric)
			t.t2e_dist = get_dist((t.x - p_n[p_ni].m_x), (t.z - p_n[p_ni].m_z), dist_metric)
			t.dir, t.comp = get_direction_to_pos({x = t.x, z = t.z},{x = ppos.x, z = ppos.z})

			--local t_n = t.neighbors
			--local t_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, t_n)
			--local t_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, t.neighbors)

		else
			use_tectonics = "default"
		end

		--Distance from cell center point to nearest neighbor cell center point.
		local p2n_dist = get_dist((p_x - p_n[p_ni].n_x), (p_z - p_n[p_ni].n_z), dist_metric)
		--Distance between cell center point and nearest edge
		local m2e_dist = get_dist((m_x - p_n[p_ni].m_x), (m_z - p_n[p_ni].m_z), dist_metric)
		local p2e_dist = get_dist((p_x - p_n[p_ni].m_x), (p_z - p_n[p_ni].m_z), dist_metric)

		--Distance to line drawn from cell center point to neighbor cell center point.
		local n2pe_dist = get_dist2line({x = p_x, z = p_z}, {x = p_n[p_ni].n_x, z = p_n[p_ni].n_z}, {x = ppos.x, z = ppos.z})
		--Return inverse slope of line drawn from cell center point to nearest neighbor cell center point.  Returns slope of line drawn by edge.
		--Direction to cell nearest neighbor.
		local me_dir, me_comp = get_direction_to_pos({x = m_x, z = m_z},{x = m_n[m_ni].m_x, z = m_n[m_ni].m_z})
		local pe_dir, pe_comp = get_direction_to_pos({x = p_x, z = p_z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})
		local dir_pos_to_midpoint, comp_pos_to_midpoint = get_direction_to_pos({x = ppos.x, z = ppos.z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})
		--local e_slope = get_slope_inverse({x = p_x, z = p_z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})
		local p2e_slope = get_slope({x = p_x, z = p_z},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})
		local e_slope = get_slope_inverse({x = p_x, z = p_z},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})

	--Headwater Pos			--Triangulate from Voronoi Cell Center, Nearest Neighbor Midpoint, and Point 400 meters along the edge, (downstream)
	--Pos of fork / main stem convergence

		local p2e_midpoint_x, p2e_midpoint_z = get_midpoint({x = p_x, z = p_z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})

		local p2e_dir_to_half, p2e_comp_to_half = get_direction_to_pos({x = p2e_midpoint_x, z = p2e_midpoint_z}, {x = ppos.x, z = ppos.z})

		local p2e_mid_dir_to_cell, p2e_mid_comp_to_cell = get_direction_to_pos({x = p_x, z = p_z},{x = p2e_midpoint_x, z = p2e_midpoint_z})
		local p2e_mid_dir_to_edge, p2e_mid_comp_to_edge = get_direction_to_pos({x = p_n[p_ni].m_x, z = p_n[p_ni].m_z},{x = p2e_midpoint_x, z = p2e_midpoint_z})

		-- local lf_x = (p2e_midpoint_x - ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.x))
		-- --local lf_x = (p2e_midpoint_x - (p2e_dist * 0.5))
		-- local lf_x = (p2e_midpoint_x - (p2e_dist * 0.5))
		local lf_x = p2e_midpoint_x - (p2e_dist * 0.5)
		-- local lf_z = (p2e_midpoint_z - ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.z))
		-- --local lf_z = (p2e_midpoint_z - (p2e_dist * 0.5))
		-- local lf_z = lf_x * e_slope
		local lf_z = p2e_midpoint_z - ((p2e_dist * 0.5) * e_slope)
		-- local rf_x = (p2e_midpoint_x + ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.x))
		-- --local rf_x = (p2e_midpoint_x + (p2e_dist * 0.5))
		-- local rf_x = (p2e_midpoint_x + (p2e_dist * 0.5))
		local rf_x = p2e_midpoint_x + (p2e_dist * 0.5)
		-- local rf_z = (p2e_midpoint_z + ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.z))
		-- --local rf_z = (p2e_midpoint_z + (p2e_dist * 0.5))
		-- local rf_z = rf_x * e_slope
		local rf_z = p2e_midpoint_z + ((p2e_dist * 0.5) * e_slope)

		-- local lc_x = (p_n[p_ni].m_x - ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.x))
		-- --local lc_x = (p_n[p_ni].m_x - (p2e_dist * 0.5))
		-- local lc_x = (p_n[p_ni].m_x - (p2e_dist * 0.5))
		local lc_x = p_n[p_ni].m_x - (p2e_dist * 0.5)
		-- local lc_z = (p_n[p_ni].m_z - ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.z))
		-- --local lc_z = (p_n[p_ni].m_z - (p2e_dist * 0.5))
		-- local lc_z = lc_x * e_slope
		local lc_z = p_n[p_ni].m_z - ((p2e_dist * 0.5) * e_slope)
		-- local rc_x = (p_n[p_ni].m_x + ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.x))
		-- --local rc_x = (p_n[p_ni].m_x + (p2e_dist * 0.5))
		-- local rc_x = (p_n[p_ni].m_x + (p2e_dist * 0.5))
		local rc_x = p_n[p_ni].m_x + (p2e_dist * 0.5)
		-- local rc_z = (p_n[p_ni].m_z + ((p2e_dist * 0.5) * p2e_mid_dir_to_cell.z))
		-- --local rc_z = (p_n[p_ni].m_z + (p2e_dist * 0.5))
		-- local rc_z = rc_x * e_slope
		local rc_z = p_n[p_ni].m_z + ((p2e_dist * 0.5) * e_slope)

		local t_valley_size = min(mg_earth.config.mg_valley_size, max(0,(n2pe_dist / mg_earth.config.mg_river_size)))
		local t_valley_scale = max(0,(min(mg_earth.config.mg_valley_size, max(1,(n2pe_dist / mg_earth.config.mg_river_size))) / mg_earth.config.mg_valley_size))

		local n_river_jitter = minetest.get_perlin(mg_earth.noise["np_river_jitter"]):get_2d({x = ppos.x, y = ppos.z})

		local t_sin = 0
		local lf_sin = 0
		-- local lf_sin = n_river_jitter
		local rf_sin = 0
		-- local rf_sin = n_river_jitter

		if (e_slope >= -1) and (e_slope <= 1) then
			t_sin = ((t_valley_size * 0.3) * sin(n2pe_dist * 0.008) + n_river_jitter) * pe_dir.z
		else
			t_sin = ((t_valley_size * 0.3) * sin(n2pe_dist * 0.008) + n_river_jitter) * pe_dir.x
		end

		local lf_slope = get_slope({x = lf_x, z = lf_z},{x = lc_x, z = lc_z})
		local rf_slope = get_slope({x = rf_x, z = rf_z},{x = rc_x, z = rc_z})

	--Length of fork
			-- local f2e_len = get_dist((f_x - c_x), (f_z - c_z), dist_metric)
		-- local lf2pe_len = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = lf_x, z = lf_z})
		local lf_len = get_dist((lf_x - lc_x), (lf_z - lc_z), dist_metric)
		-- local rf2pe_len = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = rf_x, z = rf_z})
		local rf_len = get_dist((rf_x - rc_x), (rf_z - rc_z), dist_metric)
	--Distance along fork to main stream (voronoi cell edge)
		-- --local f2pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = f_x, z = f_z})
		-- local lf2pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = ppos.x, z = ppos.z})
		-- local lf2pe_dist = get_dist2endline_inverse({x = lf_x, z = lf_z}, {x = lc_x, z = lc_z}, {x = ppos.x, z = ppos.z})
		local lf2pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = lf_x, z = lf_z})
		-- local rf2pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = ppos.x, z = ppos.z})
		-- local rf2pe_dist = get_dist2endline_inverse({x = rf_x, z = rf_z}, {x = rc_x, z = rc_z}, {x = ppos.x, z = ppos.z})
		local rf2pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = rf_x, z = rf_z})

		local lf_dist = get_dist((lf_x - ppos.x), (lf_z - ppos.z), dist_metric)
		local rf_dist = get_dist((rf_x - ppos.x), (rf_z - ppos.z), dist_metric)

		local lf_valley_size = min(mg_earth.config.mg_valley_size, max(0,(lf_dist / mg_earth.config.mg_river_size)))
		local rf_valley_size = min(mg_earth.config.mg_valley_size, max(0,(rf_dist / mg_earth.config.mg_river_size)))

		local lf_valley_scale = max(0,(min(mg_earth.config.mg_valley_size, max(1,(lf_dist / mg_earth.config.mg_river_size))) / mg_earth.config.mg_valley_size))
		local rf_valley_scale = max(0,(min(mg_earth.config.mg_valley_size, max(1,(rf_dist / mg_earth.config.mg_river_size))) / mg_earth.config.mg_valley_size))

		if (lf_slope >= -1) and (lf_slope <= 1) then
			lf_sin = n_river_jitter * p2e_dir_to_half.z
			-- lf_sin = (lf_valley_size + n_river_jitter) * p2e_dir_to_half.z
		else
			lf_sin = n_river_jitter * p2e_dir_to_half.x
			-- lf_sin = (lf_valley_size + n_river_jitter) * p2e_dir_to_half.x
		end

		if (rf_slope >= -1) and (rf_slope <= 1) then
			rf_sin = n_river_jitter * p2e_dir_to_half.z
			-- rf_sin = (rf_valley_size + n_river_jitter) * p2e_dir_to_half.z
		else
			rf_sin = n_river_jitter * p2e_dir_to_half.x
			-- rf_sin = (rf_valley_size + n_river_jitter) * p2e_dir_to_half.x
		end


		--Distance to cell edge
		local pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = ppos.x, z = ppos.z})

	--Distance to fork
		-- --local fe_dist = get_dist2line({x = f_x, z = f_z}, {x = c_x, z = c_z}, {x = ppos.x, z = ppos.z})
		-- local lfe_dist = get_dist2line({x = (lf_x - lf_sin), z = (lf_z - lf_sin)}, {x = lc_x, z = lc_z}, {x = ppos.x, z = ppos.z})
		local lfe_dist = get_dist2line({x = (lf_x - lf_sin), z = (lf_z - lf_sin)}, {x = lc_x, z = lc_z}, {x = ppos.x, z = ppos.z})
		-- local rfe_dist = get_dist2line({x = (rf_x - rf_sin), z = (rf_z - rf_sin)}, {x = rc_x, z = rc_z}, {x = ppos.x, z = ppos.z})
		local rfe_dist = get_dist2line({x = (rf_x - rf_sin), z = (rf_z - rf_sin)}, {x = rc_x, z = rc_z}, {x = ppos.x, z = ppos.z})


		--local vcontinental = ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
		local vcontinental = 0
		--local vbase = (mg_base_height * 1.4) - ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
		local vbase = 0

		local mpcontinental = 0
		local mpbase = 0

		if use_tectonics == "all" then

			vcontinental = ((t.dist * mg_earth.config.v_tscale) + (m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			vbase = (mg_base_height * 1.4) - ((t.dist * mg_earth.config.v_tscale) + (m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			mpcontinental = ((t.t2e_dist * mg_earth.config.v_tscale) + (m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
			mpbase = (mg_base_height * 1.4) - ((t.t2e_dist * mg_earth.config.v_tscale) + (m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))

		elseif use_tectonics == "only" then

			vcontinental = (t.dist * mg_earth.config.v_tscale)
			vbase = (mg_base_height * 1.4) - (t.dist * mg_earth.config.v_tscale)
			mpcontinental = (t.t2e_dist * mg_earth.config.v_tscale)
			mpbase = (mg_base_height * 1.4) - (t.t2e_dist * mg_earth.config.v_tscale)

		elseif use_tectonics == "alt" then

			vcontinental = ((t.dist * mg_earth.config.v_tscale) + (p_dist * mg_earth.config.v_pscale))
			vbase = (mg_base_height * 1.4) - ((t.dist * mg_earth.config.v_tscale) + (p_dist * mg_earth.config.v_pscale))
			mpcontinental = ((t.t2e_dist * mg_earth.config.v_tscale) + (p2e_dist * mg_earth.config.v_pscale))
			mpbase = (mg_base_height * 1.4) - ((t.t2e_dist * mg_earth.config.v_tscale) + (p2e_dist * mg_earth.config.v_pscale))

		else

			-- vcontinental = ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			-- -- vcontinental = ((m_dist + p_dist) * mg_earth.config.v_pscale)
			-- -- vbase = (mg_base_height * 1.4) - ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			-- vbase = (mg_base_height * 1.4) - vcontinental
					-- -- vbase = (mg_base_height * 1.25) - ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
					-- -- vbase = mg_base_height - ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			-- mpcontinental = ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
			-- -- mpcontinental = ((m2e_dist + p2e_dist) * mg_earth.config.v_pscale)
			-- -- mpbase = (mg_base_height * 1.4) - ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
			-- mpbase = (mg_base_height * 1.4) - mpcontinental
					-- -- mpbase = (mg_base_height * 1.25) - ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
					-- -- mpbase = mg_base_height - ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))


			vcontinental = ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			vbase = (mg_base_height * 1.4) - vcontinental
			mpcontinental = ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
			mpbase = (mg_base_height * 1.4) - mpcontinental



		end
		
		-- local valt = (vbase / vcontinental) * (mg_world_scale / 0.01)
			-- -- local valt = (vbase / (mg_base_height * 1.4)) * ((mg_world_scale / 0.01) * ((mg_base_height * 1.4) * (mg_world_scale / 0.01)))
		-- -- local valt = ((vbase / (mg_base_height * 1.4)) * (mg_base_height * 1.4))
		-- -- local valt = (vbase / (mg_base_height * 1.4)) * (mg_world_scale / 0.01)
		-- local mpalt = (mpbase / mpcontinental) * (mg_world_scale / 0.01)
			-- -- local mpalt = (mpbase / (mg_base_height * 1.4)) * ((mg_world_scale / 0.01) * ((mg_base_height * 1.4) * (mg_world_scale / 0.01)))
		-- -- local mpalt = ((mpbase / (mg_base_height * 1.4)) * (mg_base_height * 1.4))
		-- -- local mpalt = (mpbase / (mg_base_height * 1.4)) * (mg_world_scale / 0.01)


		local valt = (vbase / vcontinental) * (mg_world_scale / 0.01)
		-- -- local valt = (((mg_base_height * 1.4) / vcontinental) * (mg_base_height * 1.4)) * mg_world_scale
		-- -- local valt = ((mg_base_height * 1.4) / vcontinental) * (mg_world_scale / 0.01)
		-- -- local valt = (((mg_base_height * 1.4) / vcontinental) * (mg_base_height * 1.4)) / ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
		-- -- local valt = ((mg_base_height * 1.4) * (mg_base_height * 1.4)) / (m_dist + p_dist)
		-- -- local valt = ((mg_base_height * 1.4) * (mg_base_height * 1.4)) / ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
		-- -- local valt = (((mg_base_height * 1.4) * (mg_base_height * 1.4)) / (m_dist + p_dist)) * vcontinental
		-- -- local valt = (((mg_base_height * 1.4) * (mg_base_height * 1.4)) / ((m_dist + p_dist) * vcontinental)) * (mg_world_scale / 0.01)
		-- -- local valt = (((mg_base_height * 1.4) / vcontinental) * (mg_base_height * 1.4))
		-- local valt = (((mg_base_height * 1.4) / vcontinental) * (mg_base_height * 1.4)) * 0.1
		-- -- local valt = (mg_base_height * 1.4) - ((m_dist + p_dist) / (mg_base_height * 1.4))
		-- -- local valt = (mg_base_height * 1.4) / (m_dist + p_dist)
		-- -- local valt = (mg_base_height * 1.4) / ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
		-- -- local valt = (mg_base_height * 1.4) - ((m_dist + p_dist) / (mg_base_height * 1.4))
		local mpalt = (mpbase / mpcontinental) * (mg_world_scale / 0.01)
		-- -- local mpalt = (((mg_base_height * 1.4) / mpcontinental) * (mg_base_height * 1.4)) * mg_world_scale
		-- -- local mpalt = ((mg_base_height * 1.4) / mpcontinental) * (mg_world_scale / 0.01)
		-- -- local mpalt = (((mg_base_height * 1.4) / mpcontinental) * (mg_base_height * 1.4)) / ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
		-- -- local mpalt = ((mg_base_height * 1.4) * (mg_base_height * 1.4)) / (m2e_dist + p2e_dist)
		-- -- local mpalt = ((mg_base_height * 1.4) * (mg_base_height * 1.4)) / ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
		-- -- local mpalt = (((mg_base_height * 1.4) * (mg_base_height * 1.4)) / (m2e_dist + p2e_dist)) * mpcontinental
		-- -- local mpalt = (((mg_base_height * 1.4) * (mg_base_height * 1.4)) / ((m2e_dist + p2e_dist) * mpcontinental)) * (mg_world_scale / 0.01)
		-- -- local mpalt = (((mg_base_height * 1.4) / mpcontinental) * (mg_base_height * 1.4))
		-- local mpalt = (((mg_base_height * 1.4) / mpcontinental) * (mg_base_height * 1.4)) * 0.1
		-- -- local mpalt = (mg_base_height * 1.4) - ((m2e_dist + p2e_dist) / (mg_base_height * 1.4))
		-- -- local mpalt = (mg_base_height * 1.4) / (m2e_dist + p2e_dist)
		-- -- local mpalt = (mg_base_height * 1.4) / ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
		-- -- local mpalt = (mg_base_height * 1.4) - ((m2e_dist + p2e_dist) / (mg_base_height * 1.4))

		
		local vterrain = (vbase * 0.1) + (valt * 0.35)
		-- -- local vterrain = (vbase * 0.2) + (((vbase / vcontinental) * (mg_world_scale / 0.01)) * 0.45) + valt
		-- local vterrain = (((vbase / vcontinental) * (mg_world_scale / 0.01)) * 0.45) + (valt * 0.45)
		-- -- local vterrain = valt
		local mpterrain = (mpbase * 0.1) + (mpalt * 0.35)
		-- -- local mpterrain = (mpbase * 0.2) + (((mpbase / mpcontinental) * (mg_world_scale / 0.01)) * 0.45) + mpalt
		-- local mpterrain = (((mpbase / mpcontinental) * (mg_world_scale / 0.01)) * 0.45) + (mpalt * 0.45)
		-- -- local mpterrain = mpalt

		-- -- -- mg_villages works better with flatter terrain.  Use with 2d noise
		-- local vterrain = (vbase * 0.1) + (valt * 0.25)
		-- local mpterrain = (mpbase * 0.1) + (mpalt * 0.25)

		-- if mg_heightmap_select == "vEarth" or mg_heightmap_select == "vVoronoiPlus" then
			vheight = vterrain
			mpheight = mpterrain
		-- else
			-- -- vheight = vbase
			-- vheight = vbase
			-- -- mpheight = mpbase
			-- mpheight = mpbase
		-- end

		r_y = vheight
		mp_y = mpheight




		if mg_heightmap_select == "vEarth" then

			local v7_height = get_v7_height(ppos.z,ppos.x)

			local d_humid = 0
			if nhumid < 50 then
				d_humid = (get_v6_height(ppos.z,ppos.x) * ((50 - nhumid) / 50))
			end
			local v6_height = d_humid * 0.5

			if mg_noise_select == "vFill" then
				local n_h = minetest.get_perlin(mg_earth.noise["np_fill"]):get_2d({x = ppos.x, y = ppos.z})
				nheight = n_h + n_h
				n_c = 0
			end

			if mg_noise_select == "v2d" then
				-- local n_h = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z}) + abs(v2d_base_min_height)
				local n_h = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z})
								-- local n_h = 0
							-- nheight, n_c = get_terrain_height_cliffs(n_h,ppos.z,ppos.x)
								-- n_h, n_c = get_terrain_height_cliffs(minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z}),ppos.z,ppos.x)
								-- nheight = n_h + abs(v2d_base_min_height)
							-- local n_h = 0
							-- n_h, n_c = get_terrain_height_cliffs(minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z}),ppos.z,ppos.x)
							-- nheight = n_h * 0.25
				

				-- nheight, n_c = get_terrain_height_cliffs(minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z}),ppos.z,ppos.x)
				-- nheight = v2d_base_max_height * ((n_h + abs(v2d_base_min_height)) / v2d_base_rng)
				-- n_c = 0


				local v7_noise_scale = min(1.0, max(0.3,abs(vheight / (mg_base_height * 0.65))))
				local v6_noise_scale = min(1.0, max(0.25,abs(vheight / (mg_base_height * 0.5))))
				local n_terrain = 0

				-- n_terrain, n_c = get_terrain_height_cliffs((n_h + abs(v2d_base_min_height)),ppos.z,ppos.x)
				n_terrain, n_c = get_terrain_height_cliffs(n_h,ppos.z,ppos.x)
				
				nheight = (n_terrain * v7_noise_scale) + (v6_height * v6_noise_scale)
				
			end

			if mg_noise_select == "v6" then
				nheight = get_v6_height(ppos.z,ppos.x)
			end

			if mg_noise_select == "v67" then
				nheight = v7_height + v6_height
			end

			if mg_noise_select == "v7" then
				nheight = v7_height
			end

			if mg_noise_select == "vCarp" then
				nheight = get_carp_noise(ppos.z,ppos.x)
			end

			if mg_noise_select == "v6Carp" then
				nheight = get_carp_noise(ppos.z,ppos.x) + v6_height
			end

			if mg_noise_select == "v67Carp" then
				nheight = get_carp_noise(ppos.z,ppos.x) + get_terrain_height(ppos.z,ppos.x) + v6_height
			end

			if mg_noise_select == "v7Carp" then
				nheight = get_carp_noise(ppos.z,ppos.x) + get_terrain_height(ppos.z,ppos.x)
			end

			if mg_noise_select == "vCarpIslands" then
				nheight, n_c = get_terrain_height_cliffs(get_carp_noise(ppos.z,ppos.x),ppos.z,ppos.x)
			end

			if mg_noise_select == "v6CarpIslands" then
				local c_h, c_c = get_terrain_height_cliffs(get_carp_noise(ppos.z,ppos.x),ppos.z,ppos.x)
				nheight = c_h + v6_height
				n_c = c_c
			end

			if mg_noise_select == "v67CarpIslands" then
				local c_h, c_c = get_terrain_height_cliffs(get_carp_noise(ppos.z,ppos.x),ppos.z,ppos.x)
				local i_h, i_c = get_terrain_height(ppos.z,ppos.x)
				nheight = (c_h * 0.2) + i_h + v6_height
				n_c = c_c + i_c
			end

			if mg_noise_select == "vCust" then

				local aterrain = 0
				local ncliffs = 0

				local v7_noise_scale = min(1.0, max(0.3,abs(vheight / (mg_base_height * 0.65))))
				local v6_noise_scale = min(1.0, max(0.25,abs(vheight / (mg_base_height * 0.5))))

				local hselect = minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=ppos.x,y=ppos.z})
				local hselect = rangelim(hselect, 0, 1)
				local persist = minetest.get_perlin(mg_earth.noise["np_v7_persist"]):get_2d({x=ppos.x,y=ppos.z})

				mg_earth.noise["np_2d_base"].persistence = persist;
				mg_earth.noise["np_2d_alt"].persistence = persist;

				local height_base = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z})
				local height_alt = minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z})

				if (height_base > height_alt) then
					-- aterrain = floor(height_base)
					aterrain = floor(height_base) * v7_noise_scale
				else
					-- aterrain = floor((height_alt * hselect) + (height_base * (1 - hselect)))
					aterrain = (floor((height_alt * hselect) + (height_base * (1 - hselect)))) * v7_noise_scale
				end

				local h_y, h_c = get_terrain_height_cliffs(aterrain,ppos.z,ppos.x)

				nheight,ncliffs = get_terrain_height_cliffs((h_y + (v6_height * v6_noise_scale)),ppos.z,ppos.x)
				n_c = h_c + ncliffs

			end

			if mg_noise_select == "vDev_01" then
				local aterrain = 0

				local hselect = minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=ppos.x,y=ppos.z})
				local hselect = rangelim(hselect, 0, 1)
				local persist = minetest.get_perlin(mg_earth.noise["np_v7_persist"]):get_2d({x=ppos.x,y=ppos.z})

				mg_earth.noise["np_2d_base"].persistence = persist;
				mg_earth.noise["np_2d_alt"].persistence = persist;

				local height_base = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z})
				-- local height_base = v2d_base_max_height * ((minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z}) + abs(v2d_base_min_height)) / v2d_base_rng)
				local height_alt = minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z})
				-- local height_alt = v2d_alt_max_height * ((minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z}) + abs(v2d_alt_min_height)) / v2d_alt_rng)

				-- local b_y, b_c = get_terrain_base_cliffs(height_base,ppos.z,ppos.x)
				-- local a_y, a_c = get_terrain_alt_cliffs(height_alt,ppos.z,ppos.x)
				-- if (b_y > a_y) then
					-- aterrain = floor(b_y)
				-- else
					-- aterrain = floor((a_y * hselect) + (b_y * (1 - hselect)))
				-- end
				if (height_base > height_alt) then
					aterrain = floor(height_base)
				else
					aterrain = floor((height_alt * hselect) + (height_base * (1 - hselect)))
				end

				local h_y, h_c = get_terrain_height_cliffs(aterrain,ppos.z,ppos.x)
							-- -- nheight = h_y + v6_height
							-- -- -- nheight = h_y
							-- -- n_c = max(max(a_c,b_c),h_c)
						-- nheight = h_y
						-- n_c = h_c
				local v7_noise_scale = min(1.0, max(0.3,abs(vheight / (mg_base_height * 0.5))))
				local v6_noise_scale = min(1.0, max(0.25,abs(vheight / (mg_base_height * 0.5))))
				local ncliffs = 0
				nheight,ncliffs = get_terrain_height_cliffs(((h_y * v7_noise_scale) + (v6_height * v6_noise_scale)),ppos.z,ppos.x)
				n_c = h_c + ncliffs
			end

			if mg_noise_select == "vIslands" then
				local n_h = 0
				-- local v7_base_min_height = min_height(mg_earth.noise["np_v7_base"])
				n_h, n_c = get_terrain_height(ppos.z,ppos.x)
				-- nheight = (n_h + abs(v7_base_min_height * 0.25))
				nheight = n_h
			end

			if mg_noise_select == "v67Islands" then
				local i_h, i_c = get_terrain_height(ppos.z,ppos.x)
				local v7_noise_scale = min(1.0, max(0.3,abs(vheight / (mg_base_height * 0.5))))
				local v6_noise_scale = min(1.0, max(0.25,abs(vheight / (mg_base_height * 0.5))))
				-- nheight = (i_h + v6_height) * 0.3
				nheight = get_terrain_height_cliffs(((i_h * v7_noise_scale) + (v6_height * v6_noise_scale)),ppos.z,ppos.x)
				-- nheight = (i_h + v6_height)
				n_c = i_c
			end

			if mg_noise_select == "v67Valleys" then
				local v_y, v_c = get_valleys_height(ppos.z,ppos.x,i2d)
				nheight = v7_height + v6_height + (v_y * -1)
			end

			if mg_noise_select == "vValleys" then
				local v_y, v_c = get_valleys_height(ppos.z,ppos.x,i2d)
				nheight = v_y * -1
			end

			if mg_noise_select == "v3D" then

							-- local y_3d = mg_earth.heightmap[i2d]

							-- nheight = y_3d
							
							-- mg_earth.heightmap2d[i2d] = vheight


				local aterrain = 0

				local hselect = minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=ppos.x,y=ppos.z})
				local hselect = rangelim(hselect, 0, 1)

				local persist = minetest.get_perlin(mg_earth.noise["np_v7_persist"]):get_2d({x=ppos.x,y=ppos.z})

				mg_earth.noise["np_2d_base"].persistence = persist;
				mg_earth.noise["np_2d_alt"].persistence = persist;

				local height_base = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z})
				local height_alt = minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z})

				local b_y, b_c = get_terrain_base_cliffs(height_base,ppos.z,ppos.x)
				local a_y, a_c = get_terrain_alt_cliffs(height_alt,ppos.z,ppos.x)

				if (b_y > a_y) then
					aterrain = floor(b_y)
				else
					aterrain = floor((a_y * hselect) + (b_y * (1 - hselect)))
				end

				local h_y, h_c = get_terrain_height_cliffs(aterrain,ppos.z,ppos.x)
				nheight = h_y + v6_height
				n_c = max(max(a_c,b_c),h_c)
			end

			-- local bterrain = 0

			if mg_earth.config.mg_rivers_enabled then

							-- local tn_h = nheight * (max(0,(p2e_dist - p_dist)) / p2e_dist)
						-- local tn_h = (nheight / max(1,(p_dist * 0.004)))
						--local tn_h = 0
				-- local tn_h = nheight * ((min((mg_earth.config.mg_valley_size * 2),max(pe_dist, (mg_earth.config.mg_valley_size + 1))) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
				local tn_h = nheight * ((min((t_valley_size * 2),max(pe_dist, (t_valley_size + 1))) - t_valley_size) / t_valley_size)
					-- local tn_h = nheight


				-- if (pe_dist <= (mg_earth.config.mg_valley_size * 2)) and (pe_dist > mg_earth.config.mg_valley_size) then
					-- tn_h = nheight * ((pe_dist - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
				-- elseif (pe_dist <= mg_earth.config.mg_valley_size) then
					-- tn_h = nheight * (1 / (mg_earth.config.mg_valley_size - pe_dist))
				-- else
					-- tn_h = nheight
				-- end


				-- local bterrain = 0
				-- local bterrain = vheight + tn_h												--parabolic decrease from parent cell center
				local bterrain = vheight + tn_h


				--local v_rise = t_valley_size
				if (pe_dist <= t_valley_size) then
					--tn_h = nheight * ((pe_dist - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					tn_h = nheight * ((min((mg_earth.config.mg_valley_size * 2),max(pe_dist, (mg_earth.config.mg_valley_size + 1))) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					local val_grad = (1 / max(1, (t_valley_size - max(0,min(pe_dist, t_valley_size)))))
					bterrain = vheight + (tn_h * val_grad)
				end
--[[
				--local v_rise = lf_valley_size
				if (lfe_dist <= lf_valley_size) then
						-- tn_h = nheight * ((lfe_dist - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					-- tn_h = nheight * ((min((mg_earth.config.mg_valley_size * 2),max(lfe_dist, (mg_earth.config.mg_valley_size + 1))) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					tn_h = nheight * ((min(mg_earth.config.mg_valley_size,max(lfe_dist, (mg_earth.config.mg_valley_size + 1))) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
						-- tn_h = nheight * ((min((mg_earth.config.mg_valley_size + 1),lfe_dist) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					local val_grad = (1 / max(1, (lf_valley_size - max(0,min(lfe_dist, lf_valley_size)))))
					bterrain = vheight + (tn_h * val_grad)
				end

				--local v_rise = rf_valley_size
				if (rfe_dist <= rf_valley_size) then
						-- tn_h = nheight * ((rfe_dist - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					-- tn_h = nheight * ((min((mg_earth.config.mg_valley_size * 2),max(rfe_dist, (mg_earth.config.mg_valley_size + 1))) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					tn_h = nheight * ((min(mg_earth.config.mg_valley_size,max(rfe_dist, (mg_earth.config.mg_valley_size + 1))) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
						-- tn_h = nheight * ((min((mg_earth.config.mg_valley_size + 1),rfe_dist) - mg_earth.config.mg_valley_size) / mg_earth.config.mg_valley_size)
					local val_grad = (1 / max(1, (rf_valley_size - max(0,min(rfe_dist, rf_valley_size)))))
					bterrain = vheight + (tn_h * val_grad)
				end
--]]

				-- if bterrain > 10 then
					-- r_y = bterrain * 0.1
				-- else
					r_y = bterrain
				-- end
					-- r_y = bterrain

			else

				local bterrain = vheight + nheight

				-- if bterrain > 10 then
					-- r_y = bterrain * 0.1
				-- else
					r_y = bterrain
				-- end
					-- r_y = vheight + nheight
					-- r_y = bterrain

			end

			-- r_y = bterrain

		end

		if mg_earth.config.mg_rivers_enabled then
			if r_y >= 0 then

				local terrain_scalar_inv = (max(0,((250 * mg_world_scale) - r_y)) / (250 * mg_world_scale))
				local r_size = mg_earth.config.mg_river_size * terrain_scalar_inv

				if n2pe_dist >= ((r_y + mg_earth.config.mg_valley_size) - r_size) then
					local t_river_size = mg_earth.config.mg_river_size * t_valley_scale
					mg_earth.rivermap[i2d] = pe_dist
					mg_earth.riverpath[i2d] = t_river_size
					mg_earth.valleymap[i2d] = (mg_earth.config.mg_river_size - pe_dist) * t_valley_scale

				end
--[[
				if (lf2pe_dist >= pe_dist) then
					local lf_river_size = mg_earth.config.mg_river_size * lf_valley_scale
					-- if lfe_dist >= 0 and lfe_dist < lf_river_size then
					if lfe_dist <= pe_dist and lfe_dist < lf_river_size then
						mg_earth.rivermap[i2d] = lfe_dist
						mg_earth.riverpath[i2d] = lf_river_size
						mg_earth.valleymap[i2d] = (mg_earth.config.mg_river_size - lfe_dist) * lf_valley_scale
					end
				end
				if (rf2pe_dist >= pe_dist) then
					local rf_river_size = mg_earth.config.mg_river_size * rf_valley_scale
					-- if rfe_dist >= 0 and rfe_dist < rf_river_size then
					if rfe_dist <= pe_dist and rfe_dist < rf_river_size then
						mg_earth.rivermap[i2d] = rfe_dist
						mg_earth.riverpath[i2d] = rf_river_size
						mg_earth.valleymap[i2d] = (mg_earth.config.mg_river_size - rfe_dist) * rf_valley_scale
					end
				end
--]]

		
				-- --DEBUG VALUES CHECK
				-- debug_this = tostring(p_idx)
				-- if debug_this ~= debug_last then
					-- -- print("---------------------------------------------------")
					-- -- print("------------------VORNONOI-------------------------")
					-- -- print("---------------------------------------------------")
					-- -- print("MASTER:        " .. m_idx .. ":     X:  " .. m_x .. ",  Z:  " .. m_z .. ".        COMPASS:  " .. me_comp .. ".")
					-- -- print("PARENT:        " .. p_idx .. ":     X:  " .. p_x .. ",  Z:  " .. p_z .. ".        COMPASS:  " .. pe_comp .. ".")
					-- -- print("MIDPOINT:      " .. p_idx .. " - " .. p_ni .. ":     X:  " .. p_n[p_ni].m_x .. ",  Z:  " .. p_n[p_ni].m_z .. ".        COMPASS:  " .. comp_pos_to_midpoint .. ".")
					-- -- print("NEIGHBOR:      " .. p_ni .. ":     X:  " .. p_n[p_ni].n_x .. ",  Z:  " .. p_n[p_ni].n_z .. ".        COMPASS:  " .. pe_comp .. ".")
					-- -- print("CONTINENT:     " .. t.name .. ".    X:  " .. t.x .. ",  Z:  " .. t.z .. ".        COMPASS:  " .. t.comp .. ".")
					-- -- print("---------------------------------------------------")
					-- -- print("------------------FORK SPR-------------------------")
					-- -- print("---------------------------------------------------")
					-- -- print("LF X:  " .. lf_x .. ".      LF Z:  " .. lf_z .. ".")
					-- -- print("RF X:  " .. rf_x .. ".      RF Z:  " .. rf_z .. ".")
					-- -- print("---------------------------------------------------")
					-- -- print("------------------RIV CONF-------------------------")
					-- -- print("---------------------------------------------------")
					-- -- print("LC X:  " .. lc_x .. ".      LC Z:  " .. lc_z .. ".")
					-- -- print("RC X:  " .. rc_x .. ".      RC Z:  " .. rc_z .. ".")
					-- -- print("---------------------------------------------------")
						-- -- local v_info = ""
						-- -- v_info = v_info .. "---------------------------------------------------\n"
						-- -- v_info = v_info .. "------------------VORNONOI-------------------------\n"
						-- -- v_info = v_info .. "---------------------------------------------------\n"
						-- -- v_info = v_info .. "MASTER:        " .. m_idx .. ":     X:  " .. m_x .. ",  Z:  " .. m_z .. ".        COMPASS:  " .. me_comp .. ".\n"
						-- -- v_info = v_info .. "PARENT:        " .. p_idx .. ":     X:  " .. p_x .. ",  Z:  " .. p_z .. ".        COMPASS:  " .. pe_comp .. ".\n"
						-- -- v_info = v_info .. "MIDPOINT:      " .. p_idx .. " - " .. p_ni .. ":     X:  " .. p_n[p_ni].m_x .. ",  Z:  " .. p_n[p_ni].m_z .. ".        COMPASS:  " .. comp_pos_to_midpoint .. ".\n"
						-- -- v_info = v_info .. "NEIGHBOR:      " .. p_ni .. ":     X:  " .. p_n[p_ni].n_x .. ",  Z:  " .. p_n[p_ni].n_z .. ".        COMPASS:  " .. pe_comp .. ".\n"
						-- -- v_info = v_info .. "CONTINENT:     " .. t.name .. ".    X:  " .. t.x .. ",  Z:  " .. t.z .. ".        COMPASS:  " .. t.comp .. ".\n"
						-- -- v_info = v_info .. "---------------------------------------------------\n"
						-- -- v_info = v_info .. "------------------FORK SPR-------------------------\n"
						-- -- v_info = v_info .. "---------------------------------------------------\n"
						-- -- v_info = v_info .. "LF X:  " .. lf_x .. ".      LF Z:  " .. lf_z .. ".\n"
						-- -- v_info = v_info .. "RF X:  " .. rf_x .. ".      RF Z:  " .. rf_z .. ".\n"
						-- -- v_info = v_info .. "---------------------------------------------------\n"
						-- -- v_info = v_info .. "------------------RIV CONF-------------------------\n"
						-- -- v_info = v_info .. "---------------------------------------------------\n"
						-- -- v_info = v_info .. "LC X:  " .. lc_x .. ".      LC Z:  " .. lc_z .. ".\n"
						-- -- v_info = v_info .. "RC X:  " .. rc_x .. ".      RC Z:  " .. rc_z .. ".\n"
						-- -- v_info = v_info .. "---------------------------------------------------"
					-- --	print("DEBUG_THIS:    " .. debug_this .. ".               DEBUG_LAST:     " .. debug_last .. ".")
					-- debug_last = debug_this
						-- -- print(v_info)
						-- --minetest.log(v_info)
				-- end

			end
		end

	end

	if mg_heightmap_select == "v6" or mg_heightmap_select == "v7" or mg_heightmap_select == "v67" or mg_heightmap_select == "vIslands" then

		local v6_height = 0
		local v7_height = 0


		if mg_heightmap_select == "v6" or mg_heightmap_select == "v67" then
			v6_height = get_v6_height(ppos.z,ppos.x)
		end

		if mg_heightmap_select == "v7" or mg_heightmap_select == "v67" or mg_heightmap_select == "vIslands" then
			v7_height = get_v7_height(ppos.z,ppos.x)
		end

		if mg_heightmap_select == "v67" then
				local d_humid = 0
				if nhumid < 50 then
					d_humid = (get_v6_height(ppos.z,ppos.x) * ((50 - nhumid) / 50))
				end
				v6_height = d_humid * 0.5
		end

		if mg_heightmap_select == "v6" then
			nheight = v6_height
		elseif mg_heightmap_select == "v7" or mg_heightmap_select == "vIslands" then
			nheight = v7_height
		elseif mg_heightmap_select == "v67" then
			nheight = v7_height + v6_height
		else
			nheight = v7_height + v6_height
		end
	end

	if mg_heightmap_select == "v6" or mg_heightmap_select == "v7" or mg_heightmap_select == "v67" or mg_heightmap_select == "vIslands" then

		mg_earth.config.mg_rivers_enabled = false
		
	end

	if mg_heightmap_select == "vIslands" then
		local bterrain = vheight + nheight
		r_y, r_c = get_terrain_height_cliffs(bterrain,ppos.z,ppos.x)
	end
	
	if mg_heightmap_select == "v3dNoise" then

		local n_f = minetest.get_perlin(np_3dterrain):get_3d({x = ppos.x, y = 0, z = ppos.z})
		local s_d = 1 / (mg_density * mg_world_scale)
		local n_t = n_f + s_d

		nheight = (mg_base_height * 0.25) * n_t

		local bterrain = vheight + nheight
		r_y = bterrain

	end
	
	if mg_heightmap_select == "vFill" then
		local n_h = minetest.get_perlin(mg_earth.noise["np_fill"]):get_2d({x = ppos.x, y = ppos.z})
		r_y = n_h + n_h
		r_c = 0
	end

	if mg_heightmap_select == "vDev_01" then

				local aterrain = 0

				local hselect = minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=ppos.x,y=ppos.z})
				local hselect = rangelim(hselect, 0, 1)
				local persist = minetest.get_perlin(mg_earth.noise["np_v7_persist"]):get_2d({x=ppos.x,y=ppos.z})

				mg_earth.noise["np_2d_alt"].persistence = persist;
				mg_earth.noise["np_2d_base"].persistence = persist;
				mg_earth.noise["np_2d_peak"].persistence = persist;

				mg_earth.noise["np_2d_alt"].lacunarity = 2 + (persist * 0.1);
				mg_earth.noise["np_2d_base"].lacunarity = 2 + (persist * 0.1);
				mg_earth.noise["np_2d_peak"].lacunarity = 2 + (persist * 0.1);

				local height_base = minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z})
				local height_alt = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z})

				local height_peak = minetest.get_perlin(mg_earth.noise["np_2d_peak"]):get_2d({x=ppos.x,y=ppos.z})


				local h_alt = floor(height_alt)
				local h_base = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 50)
				-- local h_rd_max = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 34)
				-- local h_rd_min = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 35)
				if (h_alt > h_base) then
					aterrain = h_alt
				else
					aterrain = h_base
				end

				-- -- if ((h_alt <= h_rd_min) and (h_alt >= h_rd_max)) and ((aterrain > 2) and (aterrain < 20)) then
				-- if ((h_alt == h_rd_max) or (h_alt == h_rd_min)) and ((aterrain > 2) and (aterrain < 20)) then
					-- mg_earth.roadmap[i2d] = aterrain
				-- else
					-- mg_earth.roadmap[i2d] = -31000
				-- end


				local h_y, h_c = get_terrain_height_cliffs(aterrain,ppos.z,ppos.x)
				local d_humid = 0
				if nhumid < 50 then
					d_humid = (get_v6_height(ppos.z,ppos.x) * ((50 - nhumid) / 50))
				end
				local v6_height = d_humid * 0.5


				-- local taper_height_min = 8
				-- local taper_height = max(0,min(1,(max(0,min(taper_height_min,h_y)) / taper_height_min)))

				-- r_y = (r_y * r_y) / v7_alt_max_height
				r_y,r_c = get_terrain_height_cliffs((h_y + v6_height),ppos.z,ppos.x)
				-- r_y = h_y
				-- r_c = h_c

	end

	if mg_heightmap_select == "vDev_02" then

				local aterrain = 0

				local hselect = minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=ppos.x,y=ppos.z})
				local hselect = rangelim(hselect, 0, 1)
				local persist = minetest.get_perlin(mg_earth.noise["np_v7_persist"]):get_2d({x=ppos.x,y=ppos.z})

				mg_earth.noise["np_v7_alt"].persistence = persist;
				mg_earth.noise["np_v7_base"].persistence = persist;
				mg_earth.noise["np_v7_peak"].persistence = persist;

				mg_earth.noise["np_v7_alt"].lacunarity = 2 + (persist * 0.1);
				mg_earth.noise["np_v7_base"].lacunarity = 2 + (persist * 0.1);
				mg_earth.noise["np_v7_peak"].lacunarity = 2 + (persist * 0.1);

				-- local height_base = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z})
				local height_base = minetest.get_perlin(mg_earth.noise["np_v7_base"]):get_2d({x=ppos.x,y=ppos.z})
				-- local height_base = v2d_base_max_height * ((minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z}) + abs(v2d_base_min_height)) / v2d_base_rng)
				-- local height_alt = minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z})
				local height_alt = minetest.get_perlin(mg_earth.noise["np_v7_alt"]):get_2d({x=ppos.x,y=ppos.z})
				-- local height_alt = v2d_alt_max_height * ((minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z}) + abs(v2d_alt_min_height)) / v2d_alt_rng)

				local height_peak = minetest.get_perlin(mg_earth.noise["np_v7_peak"]):get_2d({x=ppos.x,y=ppos.z})

				-- local b_y, b_c = get_terrain_base_cliffs(height_base,ppos.z,ppos.x)
				-- local a_y, a_c = get_terrain_alt_cliffs(height_alt,ppos.z,ppos.x)
				-- if (b_y > a_y) then
					-- aterrain = floor(b_y)
				-- else
					-- aterrain = floor((a_y * hselect) + (b_y * (1 - hselect)))
				-- end


				-- if (height_alt > height_base) then
					-- aterrain = floor(height_alt)
				-- else
					-- if (height_base > height_peak) then
						-- aterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
					-- else
						-- -- -- aterrain = floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect)))))
						-- -- -- -- aterrain = floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect)))
						-- aterrain = floor((height_peak * hselect) + (height_base * (1 - hselect)))
					-- end
					-- -- -- aterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
				-- end


				-- aterrain = floor(height_alt)
				local h_alt = floor(height_alt)
				local h_base = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 50)
				local h_rd_max = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 40)
				local h_rd_min = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 42)
				if (h_alt > h_base) then
					aterrain = h_alt
				else
					aterrain = h_base
				end
				-- if (height_base > height_peak) then
					-- -- -- aterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
					-- -- -- aterrain = floor(height_alt)
				-- else
					-- -- -- aterrain = floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect)))))
					-- aterrain = max(floor(height_alt),(floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 50))
					-- -- aterrain = floor((height_peak * hselect) + (height_alt * (1 - hselect)))
					-- -- aterrain = floor((height_peak * hselect) + (height_alt * (1 - hselect)))
				-- end


				if ((h_alt <= h_rd_min) and (h_alt >= h_rd_max)) and ((aterrain > 2) and (aterrain < 20)) then
					mg_earth.roadmap[i2d] = aterrain
				else
					mg_earth.roadmap[i2d] = -31000
				end


				local h_y, h_c = get_terrain_height_cliffs(aterrain,ppos.z,ppos.x)
				-- local v6_height = get_v6_height(ppos.z,ppos.x)
				local d_humid = 0
				if nhumid < 50 then
					d_humid = (get_v6_height(ppos.z,ppos.x) * ((50 - nhumid) / 50))
				end
				local v6_height = d_humid * 0.5


				local taper_height_min = 8
				local taper_height = max(0,min(1,(max(0,min(taper_height_min,h_y)) / taper_height_min)))
				-- local v6_noise_scale = max(0,min(1,taper_height))

				-- r_y,r_c = get_terrain_height_cliffs((h_y + (v6_height * v6_noise_scale)),ppos.z,ppos.x)
				r_y,r_c = get_terrain_height_cliffs((h_y + v6_height),ppos.z,ppos.x)

	end

	if mg_heightmap_select == "v2dNoise" then


		-- r_y = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z})
		r_y, r_c = get_terrain_height_cliffs(minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z}),ppos.z,ppos.x)

	end
	
	if mg_heightmap_select == "v6" or mg_heightmap_select == "v7" or mg_heightmap_select == "v67" then
		local bterrain = vheight + nheight
		r_y = bterrain
	end
	
	if mg_heightmap_select == "vCarp2D" then
		r_y = get_carp_noise(ppos.z,ppos.x)
	end
	
	-- if mg_heightmap_select == "vCarp3D" then
		-- r_y = get_carp_vals(ppos.z,ppos.x,i2d)
	-- end
	
	--if mg_heightmap_select == "vValleys" or mg_heightmap_select == "vValleys3D" then
	if mg_heightmap_select == "vValleys" then

		-- mg_earth.surfacemap = {}
		-- mg_earth.slopemap = {}
		-- mg_earth.valleysrivermap = {}

		r_y, r_c = get_valleys_height(ppos.z,ppos.x,i2d)

		mg_earth.valleysrivermap[i2d] = r_c
		r_c = 0
	end

	if mg_heightmap_select == "v3D" then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			r_y = h_y
		else
			r_y = t_y
		end
				-- r_y = t_y
	end

	if mg_heightmap_select == "vStraight3D" then

		-- r_y = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z})
		-- r_c = 0

		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			r_y = h_y
		else
			r_y = t_y
		end
	end

	if mg_heightmap_select == "v5" then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			r_y = h_y
		else
			r_y = t_y
		end

		-- local factor, height = get_v5_height(ppos.z,ppos.x)

		-- mg_earth.v5_factormap[i2d] = factor
		-- mg_earth.v5_heightmap[i2d] = height

	end

	if mg_heightmap_select == "vCarp3D" then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			r_y = h_y
		else
			r_y = t_y
		end
				-- r_y = t_y
	end

	if mg_heightmap_select == "vDiaSqr" then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			r_y = h_y
		else
			r_y = t_y
		end
				-- r_y = t_y
	end

	if mg_heightmap_select == "vValleys3D" then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			r_y = h_y
		else
			r_y = t_y
		end
	end

	return r_y, (r_c + n_c)

end

local function init_3D_voronoi(z,y,x)

	local m = {}
	-- local p = {}

	m.m_idx, m.m_dist, m.m_z, m.m_y, m.m_x = get_nearest_3D_cell({x = x, y = y, z = z}, 1)
	get_cell_neighbors(m.m_idx, m.m_z, m.m_y, m.m_x, 1)
	-- p.p_idx, p.p_dist, p.p_z, p.p_y, p.p_x = get_nearest_3D_cell({x = x, y = y, z = z}, 2)
	-- get_cell_neighbors(p.p_idx, p.p_z, p.p_y, p.p_x, 2)

end




--local function make_boulder(psize,pos,area,data,c_stone)
local function make_boulder(pos,area,data,form,c_stone)

	local psize = {}
	local chunk_center_rand = {}
	local dist_metric = ""
	local chunk_idx = 5
	local h_x,h_y,h_z

	if form == "boulder" then
		psize = {
			x = 20,
			y = 20,
			z = 20,
		}
		dist_metric = "cm"
		chunk_idx = 5
		h_x = (psize.x / 2)
		h_y = (psize.y / 2)
		h_z = (psize.z / 2)
		chunk_center_rand = {
			x = h_x + math.random(-2,2),
			y = h_y + math.random(-3,1),
			z = h_z + math.random(-2,2),
		}
	elseif form == "flat" then
		psize = {
			x = 20,
			y = 10,
			z = 20,
		}
		dist_metric = "m"
		chunk_idx = 5
		h_x = (psize.x / 2)
		h_y = (psize.y / 2)
		h_z = (psize.z / 2)
		chunk_center_rand = {
			x = h_x + math.random(-2,2),
			y = h_y + math.random(-2,1),
			z = h_z + math.random(-2,2),
		}
	elseif form == "hoodoo" then
		psize = {
			x = 15,
			y = 30,
			z = 15,
		}
		dist_metric = "m"
		chunk_idx = 5
		h_x = (psize.x / 2)
		h_y = (psize.y / 2)
		h_z = (psize.z / 2)
		chunk_center_rand = {
			x = h_x + math.random(-2,2),
			y = h_y + math.random(-4,0),
			z = h_z + math.random(-2,2),
		}
	else
		psize = {
			x = 10,
			y = 10,
			z = 10,
		}
		dist_metric = "c"
		chunk_idx = 5
		h_x = (psize.x / 2)
		h_y = (psize.y / 2)
		h_z = (psize.z / 2)
		chunk_center_rand = {
			x = h_x + math.random(-2,2),
			y = h_y + math.random(-2,0),
			z = h_z + math.random(-2,2),
		}
	end

	local chunk_points = {
		--{x=1,						y=1,						z=1},
		--{x=(psize.x),				y=1,						z=1},
		{x=h_x,						y=h_y,						z=1},
		{x=1,						y=(psize.y),				z=1},
		{x=(psize.x),				y=(psize.y),				z=1},
		--{x=h_x,					y=1,						z=h_z},
		{x=1,						y=h_y,						z=h_z},
		{x=(chunk_center_rand.x),	y=(chunk_center_rand.y),	z=(chunk_center_rand.z)},
		{x=(psize.x),				y=h_y,						z=h_z},
		{x=h_x,						y=(psize.y),				z=h_z},
		--{x=1,						y=1,						z=(psize.z)},
		--{x=(psize.x),				y=1,						z=(psize.z)},
		{x=h_x,						y=h_y,						z=(psize.z)},
		{x=1,						y=(psize.y),				z=(psize.z)},
		{x=(psize.x),				y=(psize.y),				z=(psize.z)},
	}

	for i_x = 1, psize.x do
		for i_y = 1, psize.y do
			for i_z = 1, psize.z do
				local thisidx
				local thisdist
				local last
				local this
				for i, point in ipairs(chunk_points) do
				
					this = get_3d_dist((i_x - point.x),(i_y - point.y),(i_z - point.z),dist_metric)

					if last then
						if last > this then
							last = this
							thisidx = i
							thisdist = this
						elseif last == this then
							thisidx = i
							thisdist = this
						end
					else
						last = this
						thisidx = i
						thisdist = this
					end
				end

				if thisidx == chunk_idx then
				
					local c_x = i_x - h_x
					local c_y = i_y - h_y
					local c_z = i_z - h_z
				
					local vi = area:index(pos.x+c_x, pos.y+c_y, pos.z+c_z)
					data[vi] = c_stone
				end
				
			end
		end
	end
	
end

local function make_road(minp, maxp, area, data)

	if minp.y > 0 or maxp.y < 0 then
		return
	end

	nobj_bridge_column = nobj_bridge_column or minetest.get_perlin_map(mg_earth.noise["np_bridge_column"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
	local nvals_bridge_column = nobj_bridge_column:get2dMap_flat({x = minp.x, y = minp.z}, nbuf_bridge_column)

	local i2d = 1

	for z = minp.z, maxp.z do

		for x = minp.x, maxp.x do

			local t_height = mg_earth.heightmap[i2d]

			local t_biome				= mg_earth.biomemap[i2d]
			local t_top					= mg_earth.c_top
			local t_filler				= mg_earth.c_filler
			local t_stone				= mg_earth.c_stone
			t_top						= mg_earth.biome_info[t_biome].b_top or mg_earth.c_top
			t_filler					= mg_earth.biome_info[t_biome].b_filler or mg_earth.c_filler
			t_stone						= mg_earth.biome_info[t_biome].b_stone or mg_earth.c_stone
			local t_heat				= mg_earth.biome_info[t_biome].b_heat
			local t_humid				= mg_earth.biome_info[t_biome].b_humid

					-- local ty_blend_scale = min(1, (max(mg_earth.config.mg_road_max_height,t_height) - mg_earth.config.mg_road_max_height) / mg_earth.config.mg_road_max_height)
					-- -- local ty_blend_scale = min(1, (max((mg_earth.config.mg_road_max_height * 0.5),t_height) - (mg_earth.config.mg_road_max_height * 0.5)) / (mg_earth.config.mg_road_max_height * 0.5))
			local ty_additive = (max(mg_earth.config.mg_road_max_height,t_height) - mg_earth.config.mg_road_max_height) / mg_earth.config.mg_road_max_height
			local sin_scale = (100 * ((mg_earth.config.mg_road_max_height * 0.5) / max((mg_earth.config.mg_road_max_height * 0.5),t_height))) / 100

					-- local tblend = 0.5 + HSAMP * ((t_height * ty_blend_scale) - 0.5)
			local tblend = 0.5 + HSAMP * (sin_scale - 0.5)
			tblend = min(max(tblend, 0), 1)

			--Find the nearest grid line, create a sine wave along the perpendicular axis.
			local x_i, x_f = modf(x / mg_earth.config.mg_road_grid)
			local z_i, z_f = modf(z / mg_earth.config.mg_road_grid)
			
			local x_line, z_line, x_sin, z_sin
			if (x_f > -0.5) and (x_f < 0.5) then
				x_line = x_i * mg_earth.config.mg_road_grid
			else
				if x >= 0 then
					x_line = (x_i + 1) * mg_earth.config.mg_road_grid
				else
					x_line = (x_i - 1) * mg_earth.config.mg_road_grid
				end
			end
			if (z_f > -0.5) and (z_f < 0.5) then
				z_line = z_i * mg_earth.config.mg_road_grid
			else
				if z >= 0 then
					z_line = (z_i + 1) * mg_earth.config.mg_road_grid
				else
					z_line = (z_i - 1) * mg_earth.config.mg_road_grid
				end
			end

			local x_n, x_p, z_n, z_p
			local xsn_t, xsp_t, zsn_t, zsp_t
			local xs_t_diff, zs_t_diff
			local xs_slope_dir, zs_slope_dir
			local x_dist, z_dist
			local stride = (maxp.x - minp.x + 1)

			--Get terrain height values along x and z axis, at +/- 10, +/-5 and +/-2 meters.
			if x > (minp.x + 1) then
				x_n = 2
			elseif x == (minp.x + 1) then
				x_n = 1
			else
				x_n = 0
			end
			if x < (maxp.x - 1) then
				x_p = 2
			elseif x == (maxp.x - 1) then
				x_p = 1
			else
				x_p = 0
			end
			if z > (minp.z + 1) then
				z_n = 2
			elseif z == (minp.z + 1) then
				z_n = 1
			else
				z_n = 0
			end
			if z < (maxp.z - 1) then
				z_p = 2
			elseif z == (maxp.z - 1) then
				z_p = 1
			else
				z_p = 0
			end

			xsn_t = get_mg_heightmap({x = (x - 2), y = 0, z = z}, t_heat, t_humid, i2d)
			xsp_t = get_mg_heightmap({x = (x + 2), y = 0, z = z}, t_heat, t_humid, i2d)
			zsn_t = get_mg_heightmap({x = x, y = 0, z = (z - 2)}, t_heat, t_humid, i2d)
			zsp_t = get_mg_heightmap({x = x, y = 0, z = (z + 2)}, t_heat, t_humid, i2d)

			if xsn_t >= xsp_t then
				xs_slope_dir = 1
			else
				xs_slope_dir = -1
			end
			if zsn_t >= zsp_t then
				zs_slope_dir = 1
			else
				zs_slope_dir = -1
			end

			xs_t_diff = abs(xsp_t - xsn_t) * xs_slope_dir
			zs_t_diff = abs(zsp_t - zsn_t) * zs_slope_dir

			local t_rd_sin_a = mg_earth.config.mg_road_sin_amp
			local t_rd_sin_f = mg_earth.config.mg_road_sin_freq

					-- x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a)
			x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a) + zs_t_diff
					-- z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a)
			z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a) + xs_t_diff

			x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 4}, {x = (t_height * sin_scale), z = 2})
			z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 4, z = zsp_t}, {x = 2, z = (t_height * sin_scale)})

			--Determine height of roadway
			local theight_alt, t_height_base, tlevel, pathy
			local dist_to_x_road, dist_to_z_road

			if t_height >= mg_earth.config.mg_road_terrain_min_height then
				dist_to_x_road = abs((x_line - x_sin) - x)
				dist_to_z_road = abs((z_line - z_sin) - z)
			else
				dist_to_x_road = -31000
				dist_to_z_road = -31000
			end

			mg_earth.roadmap[i2d]		= -31000
			mg_earth.roadheight[i2d]	= -31000
			mg_earth.roaddirmap[i2d]	= 0
			
			local road_height
			if (dist_to_x_road >= 0) and (dist_to_x_road <= mg_earth.config.mg_road_size) then
						-- theight_alt = floor(lerp((lerp(t_height, max(mg_earth.config.mg_road_min_height,min((t_height * ty_blend_scale),(mg_earth.config.mg_road_max_height + ty_additive))), 0.5)), z_dist, 0.5))
						-- theight_alt = floor(lerp((t_height * ty_blend_scale), max(mg_earth.config.mg_road_min_height,min(z_dist,(mg_earth.config.mg_road_max_height + ty_additive))), 0.5))
						-- theight_alt = t_height * sin_scale
				theight_alt = z_dist
						-- t_height_base = t_height
				t_height_base = t_height * sin_scale
				tlevel = floor(t_height_base * tblend + theight_alt * (1 - tblend))
				road_height = tlevel + mg_earth.config.mg_road_min_height
						-- road_height = tlevel
				mg_earth.roadmap[i2d] = dist_to_x_road
				mg_earth.roadheight[i2d] = road_height
				mg_earth.roaddirmap[i2d] = 1
			end
			if (dist_to_z_road >= 0) and (dist_to_z_road <= mg_earth.config.mg_road_size) then
						-- theight_alt = floor(lerp((lerp(t_height, max(mg_earth.config.mg_road_min_height,min((t_height * ty_blend_scale),(mg_earth.config.mg_road_max_height + ty_additive))), 0.5)), x_dist, 0.5))
						-- theight_alt = floor(lerp((t_height * ty_blend_scale), max(mg_earth.config.mg_road_min_height,min(x_dist,(mg_earth.config.mg_road_max_height + ty_additive))), 0.5))
						-- theight_alt = t_height * sin_scale
				theight_alt = x_dist
						-- t_height_base = t_height
				t_height_base = t_height * sin_scale
				tlevel = floor(t_height_base * tblend + theight_alt * (1 - tblend))
				road_height = tlevel + mg_earth.config.mg_road_min_height
						-- road_height = tlevel
				mg_earth.roadmap[i2d] = dist_to_z_road
				mg_earth.roadheight[i2d] = road_height
				mg_earth.roaddirmap[i2d] = 2
			end

			if mg_earth.roadheight[i2d] > -31000 then

				pathy = min(max(road_height, mg_earth.config.mg_road_min_height), (mg_earth.config.mg_road_max_height + ty_additive))

				if (pathy >= mg_earth.config.mg_street_min_height) and (pathy <= (mg_earth.config.mg_street_max_height + ty_additive)) then

					local abscol = abs(nvals_bridge_column[i2d])

					-- scan disk 5 nodes above path
					local tunnel = false
					local excatop
					for zz = z - z_n, z + z_p do
						local vi = area:index(x - x_n, pathy + 5, zz)
						for xx = x - x_n, x + x_p do
							local nodid = data[vi]
							if (nodid == mg_earth.c_stone) or (nodid == mg_earth.c_destone) or (nodid == mg_earth.c_sastone) or (nodid == mg_earth.c_ice) then
								tunnel = true
							end
							vi = vi + 1
						end
					end
					if tunnel then
						excatop = pathy + 6
					else
						excatop = maxp.y
					end
					-- place path node brush
					local vi = area:index(x - x_n, pathy, z - z_n)
					if data[vi] ~= mg_earth.c_wood then
						data[vi] = mg_earth.c_stairne
					end
					for iter = 1, 3 do
						vi = vi + 1
						if data[vi] ~= mg_earth.c_wood then
							data[vi] = mg_earth.c_stairn
						end
					end
					vi = vi + 1
					if data[vi] ~= mg_earth.c_wood then
						data[vi] = mg_earth.c_stairnw
					end
					for zz = z - 1, z + 1 do
						local vi = area:index(x - x_n, pathy, zz)
						if data[vi] ~= mg_earth.c_wood then
							data[vi] = mg_earth.c_staire
						end
						for iter = 1, 3 do
							vi = vi + 1
							data[vi] = mg_earth.c_wood
						end
						vi = vi + 1
						if data[vi] ~= mg_earth.c_wood then
							data[vi] = mg_earth.c_stairw
						end
					end
					local vi = area:index(x - x_n, pathy, z + z_p)
					if data[vi] ~= mg_earth.c_wood then
						data[vi] = mg_earth.c_stairse
					end
					for iter = 1, 3 do
						vi = vi + 1
						if data[vi] ~= mg_earth.c_wood then
							data[vi] = mg_earth.c_stairs
						end
					end
					vi = vi + 1
					if data[vi] ~= mg_earth.c_wood then
						data[vi] = mg_earth.c_stairsw
					end
					-- bridge understructure
					for zz = z - 1, z + 1 do
						local vi = area:index(x - 1, pathy - 1, zz)
						for xx = x - 1, x + 1 do
							local nodid = data[vi]
							if nodid ~= mg_earth.c_stone
									and nodid ~= mg_earth.c_destone
									and nodid ~= mg_earth.c_sastone then		
								data[vi] = mg_earth.c_column
							end
							vi = vi + 1
						end
					end
					local vi = area:index(x, pathy - 2, z)
					data[vi] = mg_earth.c_column
					-- bridge columns
					if (abscol < 0.3) then
						for xx = x - 1, x + 1, 2 do
						for zz = z - 1, z + 1, 2 do
							local vi = area:index(xx, pathy - 2, zz)
							-- for y = pathy - 2, minp.y, -1 do
							for y = pathy - 2, t_height, -1 do
								local nodid = data[vi]
								if nodid == mg_earth.c_stone
										or nodid == mg_earth.c_destone
										or nodid == mg_earth.c_sastone then
									break
								else
									data[vi] = mg_earth.c_column
								end
								vi = vi - ((maxp.x - minp.x + 1) + 32)
							end
						end
						end
					end
					-- excavate above path
					local det_destone = false
					local det_sastone = false
					local det_ice = false
					for y = pathy + 1, excatop do
						for zz = z - z_n, z + z_p do
							local vi = area:index(x - x_n, y, zz)
							for xx = x - x_n, x + x_p do
								local nodid = data[vi]
								if nodid == mg_earth.c_destone then
									det_destone = true
								elseif nodid == mg_earth.c_sastone then
									det_sastone = true
								elseif nodid == mg_earth.c_ice then
									det_ice = true
								end
								if tunnel and y == excatop then -- tunnel ceiling
									if nodid ~= mg_earth.c_air
											and nodid ~= mg_earth.c_ignore
											and nodid ~= mg_earth.c_meselamp then
										if (abs(zz - z) == 2
												or abs(xx - x) == 2)
												and random() <= 0.2 then
											data[vi] = mg_earth.c_meselamp
										elseif det_destone then
											data[vi] = mg_earth.c_destone
										elseif det_sastone then
											data[vi] = mg_earth.c_sastone
										elseif det_ice then
											data[vi] = mg_earth.c_ice
										else
											data[vi] = mg_earth.c_stone
										end
									end
								elseif y <= pathy + 5 then
									if nodid ~= mg_earth.c_wood
											and nodid ~= mg_earth.c_stairn
											and nodid ~= mg_earth.c_stairs
											and nodid ~= mg_earth.c_staire
											and nodid ~= mg_earth.c_stairw
											and nodid ~= mg_earth.c_stairne
											and nodid ~= mg_earth.c_stairnw
											and nodid ~= mg_earth.c_stairse
											and nodid ~= mg_earth.c_stairsw then
										data[vi] = mg_earth.c_air
									end
								elseif nodid == mg_earth.c_tree
										or nodid == mg_earth.c_leaves
										or nodid == mg_earth.c_apple
										or nodid == mg_earth.c_jungletree
										or nodid == mg_earth.c_jungleleaves
										or nodid == mg_earth.c_pinetree
										or nodid == mg_earth.c_pineneedles
										or nodid == mg_earth.c_snow
										or nodid == mg_earth.c_acaciatree
										or nodid == mg_earth.c_acacialeaves
										or nodid == mg_earth.c_aspentree
										or nodid == mg_earth.c_aspenleaves then
									data[vi] = mg_earth.c_air
								end
								vi = vi + 1
							end
						end
					end
				end
			end

			i2d = i2d + 1
		end
	end
	

end

local function make_street(minp, maxp, area, data)

	nobj_bridge_column = nobj_bridge_column or minetest.get_perlin_map(mg_earth.noise["np_bridge_column"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
	local nvals_bridge_column = nobj_bridge_column:get2dMap_flat({x = minp.x, y = minp.z}, nbuf_bridge_column)

	local i2d = 1

	for z = minp.z, maxp.z do

		for x = minp.x, maxp.x do

			local t_height = mg_earth.heightmap[i2d]

			if minp.y > t_height or maxp.y < 0 then
				return
			end

			local t_biome				= mg_earth.biomemap[i2d]
			local t_top					= mg_earth.c_top
			local t_filler				= mg_earth.c_filler
			local t_stone				= mg_earth.c_stone
			t_top						= mg_earth.biome_info[t_biome].b_top or mg_earth.c_top
			t_filler					= mg_earth.biome_info[t_biome].b_filler or mg_earth.c_filler
			t_stone						= mg_earth.biome_info[t_biome].b_stone or mg_earth.c_stone
			local t_heat				= mg_earth.biome_info[t_biome].b_heat
			local t_humid				= mg_earth.biome_info[t_biome].b_humid

					-- local ty_blend_scale = min(1, (max(mg_earth.config.mg_street_max_height,t_height) - mg_earth.config.mg_street_max_height) / mg_earth.config.mg_street_max_height)
					-- -- local ty_blend_scale = min(1, (max((mg_earth.config.mg_street_max_height * 0.5),t_height) - (mg_earth.config.mg_street_max_height * 0.5)) / (mg_earth.config.mg_street_max_height * 0.5))
					-- -- local ty_blend_scale = (mg_earth.config.mg_street_max_height * 0.5) / max((mg_earth.config.mg_street_max_height * 0.5),t_height)
					-- -- local ty_additive = (max(mg_earth.config.mg_street_max_height,t_height) - mg_earth.config.mg_street_max_height) / mg_earth.config.mg_street_max_height
			local ty_additive = (max((mg_earth.config.mg_street_max_height * 0.5),t_height) - (mg_earth.config.mg_street_max_height * 0.5)) / (mg_earth.config.mg_street_max_height * 0.5)
			local sin_scale = (100 * ((mg_earth.config.mg_street_max_height * 0.5) / max((mg_earth.config.mg_street_max_height * 0.5),t_height))) / 100
					-- local sin_scale = (mg_earth.config.mg_street_max_height * 0.5) / max((mg_earth.config.mg_street_max_height * 0.5),t_height)

					-- local tblend = 0.5 + HSAMP * ((t_height * ty_blend_scale) - 0.5)
					-- local tblend = 0.5 + HSAMP * ((t_height * sin_scale) - 0.5)
			local tblend = 0.5 + HSAMP * (sin_scale - 0.5)
					-- local tblend = 0.5 + HSAMP * (t_height - 0.5)
			tblend = min(max(tblend, 0), 1)

			--Find the nearest grid line, create a sine wave along the perpendicular axis.
			local x_i, x_f = modf(x / mg_earth.config.mg_street_grid)
			local z_i, z_f = modf(z / mg_earth.config.mg_street_grid)
			
			local x_line, z_line, x_sin, z_sin
			if (x_f > -0.5) and (x_f < 0.5) then
				x_line = x_i * mg_earth.config.mg_street_grid
			else
				if x >= 0 then
					x_line = (x_i + 1) * mg_earth.config.mg_street_grid
				else
					x_line = (x_i - 1) * mg_earth.config.mg_street_grid
				end
			end
			if (z_f > -0.5) and (z_f < 0.5) then
				z_line = z_i * mg_earth.config.mg_street_grid
			else
				if z >= 0 then
					z_line = (z_i + 1) * mg_earth.config.mg_street_grid
				else
					z_line = (z_i - 1) * mg_earth.config.mg_street_grid
				end
			end

			local x_n, x_p, z_n, z_p
			local xsn_t, xsp_t, zsn_t, zsp_t
			local xs_t_diff, zs_t_diff
			local xs_slope_dir, zs_slope_dir
			local x_dist, z_dist
			local stride = (maxp.x - minp.x + 1)

			--Get terrain height values along x and z axis, at +/- 10, +/-5 and +/-2 meters.
			if x > (minp.x + 4) then
				x_n = 5
			elseif x == (minp.x + 4) then
				x_n = 4
			elseif x == (minp.x + 3) then
				x_n = 3
			elseif x == (minp.x + 2) then
				x_n = 2
			elseif x == (minp.x + 1) then
				x_n = 1
			else
				x_n = 0
			end
			if x < (maxp.x - 4) then
				x_p = 5
			elseif x == (maxp.x - 4) then
				x_p = 4
			elseif x == (maxp.x - 3) then
				x_p = 3
			elseif x == (maxp.x - 2) then
				x_p = 2
			elseif x == (maxp.x - 1) then
				x_p = 1
			else
				x_p = 0
			end
			if z > (minp.z + 4) then
				z_n = 5
			elseif z == (minp.z + 4) then
				z_n = 4
			elseif z == (minp.z + 3) then
				z_n = 3
			elseif z == (minp.z + 2) then
				z_n = 2
			elseif z == (minp.z + 1) then
				z_n = 1
			else
				z_n = 0
			end
			if z < (maxp.z - 4) then
				z_p = 5
			elseif z == (maxp.z - 4) then
				z_p = 4
			elseif z == (maxp.z - 3) then
				z_p = 3
			elseif z == (maxp.z - 2) then
				z_p = 2
			elseif z == (maxp.z - 1) then
				z_p = 1
			else
				z_p = 0
			end

--[[
			if x > (minp.x + 1) then
				x_n = 2
			elseif x == (minp.x + 1) then
				x_n = 1
			else
				x_n = 0
			end
			if x < (maxp.x - 1) then
				x_p = 2
			elseif x == (maxp.x - 1) then
				x_p = 1
			else
				x_p = 0
			end
			if z > (minp.z + 1) then
				z_n = 2
			elseif z == (minp.z + 1) then
				z_n = 1
			else
				z_n = 0
			end
			if z < (maxp.z - 1) then
				z_p = 2
			elseif z == (maxp.z - 1) then
				z_p = 1
			else
				z_p = 0
			end

			-- xn_t = mg_earth.heightmap[i2d - x_n]
			-- xp_t = mg_earth.heightmap[i2d + x_p]
			-- zn_t = mg_earth.heightmap[i2d - (stride * z_n)]
			-- zp_t = mg_earth.heightmap[i2d + (stride * z_p)]
--]]

			xsn_t = get_mg_heightmap({x = (x - 5), y = 0, z = z}, t_heat, t_humid, i2d)
			xsp_t = get_mg_heightmap({x = (x + 4), y = 0, z = z}, t_heat, t_humid, i2d)
			zsn_t = get_mg_heightmap({x = x, y = 0, z = (z - 5)}, t_heat, t_humid, i2d)
			zsp_t = get_mg_heightmap({x = x, y = 0, z = (z + 4)}, t_heat, t_humid, i2d)

			if xsn_t >= xsp_t then
				xs_slope_dir = 1
			else
				xs_slope_dir = -1
			end
			if zsn_t >= zsp_t then
				zs_slope_dir = 1
			else
				zs_slope_dir = -1
			end

			xs_t_diff = abs(xsp_t - xsn_t) * xs_slope_dir
			zs_t_diff = abs(zsp_t - zsn_t) * zs_slope_dir

			local t_rd_sin_a = mg_earth.config.mg_street_sin_amp
			local t_rd_sin_f = mg_earth.config.mg_street_sin_freq

			x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a) + zs_t_diff
			z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a) + xs_t_diff

			x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 10}, {x = (t_height * sin_scale), z = 5})
			z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 10, z = zsp_t}, {x = 5, z = (t_height * sin_scale)})

			--Determine height of streetway
			local theight_alt, t_height_base, tlevel, pathy
			local dist_to_x_street, dist_to_z_street

			if t_height >= mg_earth.config.mg_street_terrain_min_height then
				dist_to_x_street = abs((x_line - x_sin) - x)
				dist_to_z_street = abs((z_line - z_sin) - z)
			else
				dist_to_x_street = -31000
				dist_to_z_street = -31000
			end

			mg_earth.streetmap[i2d]		= -31000
			mg_earth.streetheight[i2d]	= -31000
			mg_earth.streetdirmap[i2d]	= 0
			
			local street_height
			if (dist_to_x_street >= 0) and (dist_to_x_street <= mg_earth.config.mg_street_size) then
						-- theight_alt = floor(lerp((lerp(t_height, max(mg_earth.config.mg_street_min_height,min((t_height * ty_blend_scale),(mg_earth.config.mg_street_max_height + ty_additive))), 0.5)), z_dist, 0.5))
						-- theight_alt = floor(lerp(t_height, max(mg_earth.config.mg_street_min_height,min((t_height * ty_blend_scale),(mg_earth.config.mg_street_max_height + ty_additive))), 0.5))
						-- theight_alt = floor(lerp((lerp(t_height, z_dist, 0.5)), max(mg_earth.config.mg_street_min_height,min((t_height * ty_blend_scale),(mg_earth.config.mg_street_max_height + ty_additive))), 0.5))
						-- theight_alt = floor(lerp((lerp(t_height, max(mg_earth.config.mg_street_min_height,min((t_height * ty_blend_scale),(mg_earth.config.mg_street_max_height + ty_additive))), 0.5)), z_dist, 0.5))
						-- theight_alt = floor(lerp((t_height * ty_blend_scale), max(mg_earth.config.mg_street_min_height,min((t_height * ty_blend_scale),(mg_earth.config.mg_street_max_height + ty_additive))), 0.5))
						-- theight_alt = floor(lerp((t_height * ty_blend_scale), max(mg_earth.config.mg_street_min_height,min((t_height * ty_blend_scale), mg_earth.config.mg_street_max_height)), 0.5))
						-- theight_alt = (t_height * ty_blend_scale)
						-- theight_alt = z_dist * sin_scale
				theight_alt = z_dist

				t_height_base = t_height * sin_scale
						-- t_height_base = (t_height * ty_blend_scale)
						-- t_height_base = (t_height * sin_scale)

				tlevel = floor(t_height_base * tblend + theight_alt * (1 - tblend))

				street_height = tlevel + mg_earth.config.mg_street_min_height
						-- street_height = tlevel

				mg_earth.streetmap[i2d] = dist_to_x_street
				mg_earth.streetheight[i2d] = street_height
				mg_earth.streetdirmap[i2d] = 1
			end
			if (dist_to_z_street >= 0) and (dist_to_z_street <= mg_earth.config.mg_street_size) then
						-- theight_alt = floor(lerp((lerp(t_height, max(mg_earth.config.mg_street_min_height, min((t_height * ty_blend_scale), (mg_earth.config.mg_street_max_height + ty_additive))), 0.5)), x_dist, 0.5))
						-- theight_alt = floor(lerp(t_height, max(mg_earth.config.mg_street_min_height, min((t_height * ty_blend_scale), (mg_earth.config.mg_street_max_height + ty_additive))), 0.5))
						-- theight_alt = floor(lerp((lerp(t_height, x_dist, 0.5)), max(mg_earth.config.mg_street_min_height, min((t_height * ty_blend_scale), (mg_earth.config.mg_street_max_height + ty_additive))), 0.5))
						-- theight_alt = floor(lerp((lerp(t_height, max(mg_earth.config.mg_street_min_height, min((t_height * ty_blend_scale), (mg_earth.config.mg_street_max_height + ty_additive))), 0.5)), x_dist, 0.5))
						-- theight_alt = floor(lerp((t_height * ty_blend_scale), max(mg_earth.config.mg_street_min_height, min((t_height * ty_blend_scale), (mg_earth.config.mg_street_max_height + ty_additive))), 0.5))
						-- theight_alt = floor(lerp((t_height * ty_blend_scale), max(mg_earth.config.mg_street_min_height, min((t_height * ty_blend_scale), mg_earth.config.mg_street_max_height)), 0.5))
						-- theight_alt = (t_height * ty_blend_scale)
						-- theight_alt = x_dist * sin_scale
				theight_alt = x_dist

				t_height_base = t_height * sin_scale
						-- t_height_base = (t_height * ty_blend_scale)
						-- t_height_base = (t_height * sin_scale)

				tlevel = floor(t_height_base * tblend + theight_alt * (1 - tblend))

				street_height = tlevel + mg_earth.config.mg_street_min_height
						-- street_height = tlevel

				mg_earth.streetmap[i2d] = dist_to_z_street
				mg_earth.streetheight[i2d] = street_height
				mg_earth.streetdirmap[i2d] = 2
			end

			if mg_earth.streetheight[i2d] > -31000 then

				-- pathy = min(max(street_height, mg_earth.config.mg_street_min_height), (mg_earth.config.mg_street_max_height + ty_additive))
				-- pathy = min(max(street_height, mg_earth.config.mg_street_min_height), mg_earth.config.mg_street_max_height)
				pathy = street_height

				-- if (pathy >= mg_earth.config.mg_street_min_height) and (pathy <= (mg_earth.config.mg_street_max_height + ty_additive)) then
				-- if (pathy >= mg_earth.config.mg_street_min_height) and (pathy <= mg_earth.config.mg_street_max_height) then
				if (pathy >= mg_earth.config.mg_street_min_height) then
					local abscol = abs(nvals_bridge_column[i2d])

					-- scan disk 5 nodes above path
					local tunnel = false
					local excatop

					for zz = z - z_n, z + z_p do
						local vi = area:index(x - x_n, pathy + 5, zz)
						for xx = x - x_n, x + x_p do
							local nodid = data[vi]
							if nodid == mg_earth.c_stone
									or nodid == mg_earth.c_destone
									or nodid == mg_earth.c_sastone
									or nodid == mg_earth.c_ice then
								tunnel = true
							end
							vi = vi + 1
						end
					end

					if tunnel then
						excatop = pathy + 6
					else
						excatop = maxp.y
					end
					-- place path node brush
					local vi = area:index(x, pathy, z)
					data[vi] = mg_earth.c_roadwhite

					for k = -4, 4 do
						local vi = area:index(x - 4, pathy, z + k)
						for i = -4, 4 do
							local radsq = (math.abs(i)) ^ 2 + (math.abs(k)) ^ 2
							if radsq <= 13 then
								local nodid = data[vi]
								if nodid ~= mg_earth.c_roadwhite then
									data[vi] = mg_earth.c_roadblack
								end
							elseif radsq <= 25 then
								local nodid = data[vi]
								if nodid ~= mg_earth.c_roadblack
										and nodid ~= mg_earth.c_roadwhite then
									data[vi] = mg_earth.c_roadslab
								end
							end
							vi = vi + 1
						end
					end
					-- foundations or bridge structure
					for k = -4, 4 do
						local vi = area:index(x - 4, pathy - 1, z + k)
						for i = -4, 4 do
							local radsq = (math.abs(i)) ^ 2 + (math.abs(k)) ^ 2
							if radsq <= 25 then
								local nodid = data[vi]
								if nodid ~= mg_earth.c_roadblack
										and nodid ~= mg_earth.c_roadwhite
										and nodid ~= mg_earth.c_roadslab then
									data[vi] = mg_earth.c_concrete
								end
							end
							if radsq <= 2 then
								local viu = vi - ((maxp.x - minp.x + 1) + 32)
								local nodid = data[viu]
								if nodid ~= mg_earth.c_roadblack
										and nodid ~= mg_earth.c_roadwhite
										and nodid ~= mg_earth.c_roadslab then
									data[viu] = mg_earth.c_concrete
								end
							end
							vi = vi + 1
						end
					end
					-- bridge columns
					if math.random() <= 0.0625 then
						for xx = x - 1, x + 1 do
						for zz = z - 1, z + 1 do
							local vi = area:index(xx, pathy - 3, zz)
							-- for y = pathy - 3, y0 - 16, -1 do
							for y = pathy - 3, t_height - 16, -1 do
								local nodid = data[vi]
								if nodid == mg_earth.c_stone
										or nodid == mg_earth.c_destone
										or nodid == mg_earth.c_sastone then
									break
								else
									data[vi] = mg_earth.c_concrete
								end
								vi = vi - ((maxp.x - minp.x + 1) + 32)
							end
						end
						end
					end
					-- excavate above path
					for y = pathy + 1, excatop do
						for zz = z - 4, z + 4 do
							local vi = area:index(x - 4, y, zz)
							for xx = x - 4, x + 4 do
								local nodid = data[vi]
								if tunnel and y == excatop then -- tunnel ceiling
									if nodid ~= mg_earth.c_air
											and nodid ~= mg_earth.c_ignore
											and nodid ~= mg_earth.c_meselamp then
										if (math.abs(zz - z) == 4
												or math.abs(xx - x) == 4)
												and math.random() <= 0.2 then
											data[vi] = mg_earth.c_meselamp
										else
											data[vi] = mg_earth.c_concrete
										end
									end
								elseif y <= pathy + 5 then
									if nodid ~= mg_earth.c_roadblack
											and nodid ~= mg_earth.c_roadslab
											and nodid ~= mg_earth.c_roadwhite then
										data[vi] = mg_earth.c_air
									end
								elseif nodid == mg_earth.c_tree
										or nodid == mg_earth.c_leaves
										or nodid == mg_earth.c_apple
										or nodid == mg_earth.c_jungletree
										or nodid == mg_earth.c_jungleleaves
										or nodid == mg_earth.c_pinetree
										or nodid == mg_earth.c_pineneedles
										or nodid == mg_earth.c_snow
										or nodid == mg_earth.c_acaciatree
										or nodid == mg_earth.c_acacialeaves
										or nodid == mg_earth.c_aspentree
										or nodid == mg_earth.c_aspenleaves then
									data[vi] = mg_earth.c_air
								end
								vi = vi + 1
							end
						end
					end
				end
			end

			i2d = i2d + 1
		end
	end
	

end

local function make_lower(minp, maxp, area, data)

	nobj_bridge_column = nobj_bridge_column or minetest.get_perlin_map(mg_earth.noise["np_bridge_column"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
	local nvals_bridge_column = nobj_bridge_column:get2dMap_flat({x = minp.x, y = minp.z}, nbuf_bridge_column)

	-- local emerlen = (maxp.x - minp.x + 1) + 32

	local i2d = 1

	for z = minp.z, maxp.z do

		for x = minp.x, maxp.x do

			local t_height = mg_earth.heightmap[i2d]

			local t_biome				= mg_earth.biomemap[i2d]
			local t_top					= mg_earth.c_top
			local t_filler				= mg_earth.c_filler
			local t_stone				= mg_earth.c_stone
			t_top						= mg_earth.biome_info[t_biome].b_top or mg_earth.c_top
			t_filler					= mg_earth.biome_info[t_biome].b_filler or mg_earth.c_filler
			t_stone						= mg_earth.biome_info[t_biome].b_stone or mg_earth.c_stone
			local t_heat				= mg_earth.biome_info[t_biome].b_heat
			local t_humid				= mg_earth.biome_info[t_biome].b_humid

			local tblend_scale = 1 / max(1,(max((mg_earth.config.mg_street_max_height * 0.5),t_height) - (mg_earth.config.mg_street_max_height * 0.5)))
			local ty_additive = (max(mg_earth.config.mg_street_max_height,t_height) - mg_earth.config.mg_street_max_height) / mg_earth.config.mg_street_max_height
			local sin_scale = (mg_earth.config.mg_street_max_height * 0.5) / max((mg_earth.config.mg_street_max_height * 0.5),t_height)

			local tblend = 0.5 + HSAMP * ((t_height * tblend_scale) - 0.5)
			tblend = min(max(tblend, 0), 1)


			--Find the nearest grid line, create a sine wave along the perpendicular axis.
			local x_i, x_f = modf(x / mg_earth.config.mg_street_grid)
			local z_i, z_f = modf(z / mg_earth.config.mg_street_grid)
			
			local x_line, z_line, x_sin, z_sin
			if (x_f > -0.5) and (x_f < 0.5) then
				x_line = x_i * mg_earth.config.mg_street_grid
			else
				if x >= 0 then
					x_line = (x_i + 1) * mg_earth.config.mg_street_grid
				else
					x_line = (x_i - 1) * mg_earth.config.mg_street_grid
				end
			end
			if (z_f > -0.5) and (z_f < 0.5) then
				z_line = z_i * mg_earth.config.mg_street_grid
			else
				if z >= 0 then
					z_line = (z_i + 1) * mg_earth.config.mg_street_grid
				else
					z_line = (z_i - 1) * mg_earth.config.mg_street_grid
				end
			end

			-- if x_f > (mg_earth.config.mg_street_size / mg_earth.config.mg_street_grid) then
				-- return
			-- end

			local t_rd_sin_a = mg_earth.config.mg_street_sin_amp - t_height
			local t_rd_sin_f = mg_earth.config.mg_street_sin_freq

			x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a)
			-- x_sin = 0
			z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a)
			-- z_sin = 0


			local x_n, x_p, z_n, z_p, xs_n, xs_p, zs_n, zs_p, xn_dist, xp_dist, zn_dist, zp_dist
			local xn_t, xp_t, zn_t, zp_t, x_t_diff, z_t_diff
			local xsn_t, xsp_t, zsn_t, zsp_t, xs_t_diff, zs_t_diff
			local x_slope, z_slope, xs_slope, zs_slope
			local x_slope_dir, z_slope_dir
			local xs_slope_dir, zs_slope_dir
			local stride = (maxp.x - minp.x + 1)

			--Get terrain height values along x and z axis, at +/- 10, +/-5 and +/-2 meters.
			if x > (minp.x + 4) then
				x_n = 5
			elseif x == (minp.x + 4) then
				x_n = 4
			elseif x == (minp.x + 3) then
				x_n = 3
			elseif x == (minp.x + 2) then
				x_n = 2
			elseif x == (minp.x + 1) then
				x_n = 1
			else
				x_n = 0
			end
			if x < (maxp.x - 4) then
				x_p = 5
			elseif x == (maxp.x - 4) then
				x_p = 4
			elseif x == (maxp.x - 3) then
				x_p = 3
			elseif x == (maxp.x - 2) then
				x_p = 2
			elseif x == (maxp.x - 1) then
				x_p = 1
			else
				x_p = 0
			end
			if z > (minp.z + 4) then
				z_n = 5
			elseif z == (minp.z + 4) then
				z_n = 4
			elseif z == (minp.z + 3) then
				z_n = 3
			elseif z == (minp.z + 2) then
				z_n = 2
			elseif z == (minp.z + 1) then
				z_n = 1
			else
				z_n = 0
			end
			if z < (maxp.z - 4) then
				z_p = 5
			elseif z == (maxp.z - 4) then
				z_p = 4
			elseif z == (maxp.z - 3) then
				z_p = 3
			elseif z == (maxp.z - 2) then
				z_p = 2
			elseif z == (maxp.z - 1) then
				z_p = 1
			else
				z_p = 0
			end

--[[			if x > (minp.x + 1) then
				x_n = 2
			elseif x == (minp.x + 1) then
				x_n = 1
			else
				x_n = 0
			end
			if x < (maxp.x - 1) then
				x_p = 2
			elseif x == (maxp.x - 1) then
				x_p = 1
			else
				x_p = 0
			end
			if z > (minp.z + 1) then
				z_n = 2
			elseif z == (minp.z + 1) then
				z_n = 1
			else
				z_n = 0
			end
			if z < (maxp.z - 1) then
				z_p = 2
			elseif z == (maxp.z - 1) then
				z_p = 1
			else
				z_p = 0
			end--]]

			-- xn_t = mg_earth.heightmap[i2d - x_n]
			-- xp_t = mg_earth.heightmap[i2d + x_p]
			-- zn_t = mg_earth.heightmap[i2d - (stride * z_n)]
			-- zp_t = mg_earth.heightmap[i2d + (stride * z_p)]

			xsn_t = get_mg_heightmap({x = ((x - x_sin) - 2), y = 0, z = z}, t_heat, t_humid, i2d)
			xsp_t = get_mg_heightmap({x = ((x - x_sin) + 2), y = 0, z = z}, t_heat, t_humid, i2d)
			zsn_t = get_mg_heightmap({x = x, y = 0, z = ((z - z_sin) - 2)}, t_heat, t_humid, i2d)
			zsp_t = get_mg_heightmap({x = x, y = 0, z = ((z - z_sin) + 2)}, t_heat, t_humid, i2d)

--[[			if xn_t > xp_t then
				x_slope_dir = 1
			elseif xn_t < xp_t then
				x_slope_dir = -1
			else
				x_slope_dir = 0
			end
			if zn_t > zp_t then
				z_slope_dir = 1
			elseif zn_t < zp_t then
				z_slope_dir = -1
			else
				z_slope_dir = 0
			end--]]
			if xsn_t >= xsp_t then
				xs_slope_dir = 1
			else
				xs_slope_dir = -1
			end
			if zsn_t >= zsp_t then
				zs_slope_dir = 1
			else
				zs_slope_dir = -1
			end


			-- x_t_diff = xp_t - xn_t
			-- z_t_diff = zp_t - zn_t

			-- -- xs_t_diff = abs(xsp_t - xsn_t)
			xs_t_diff = abs(xsp_t - xsn_t) * xs_slope_dir
			-- -- zs_t_diff = abs(zsp_t - zsn_t)
			zs_t_diff = abs(zsp_t - zsn_t) * zs_slope_dir

			-- -- x_slope = (xs_t_diff / 10) * xs_slope_dir
			-- -- x_slope = xs_t_diff / 10
			-- x_slope = x_t_diff / 5
			-- -- z_slope = (zs_t_diff / 10) * zs_slope_dir
			-- -- z_slope = zs_t_diff / 10
			-- z_slope = z_t_diff / 5

			xs_slope = xs_t_diff / 5
			zs_slope = zs_t_diff / 5


			-- x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 19}, {x = t_height, z = 10})
			x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 4}, {x = t_height, z = 2})
			-- z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 19, z = zsp_t}, {x = 10, z = t_height})
			z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 4, z = zsp_t}, {x = 2, z = t_height})



			--Determine height of streetway
			-- local theight_alt = lerp((t_height * tblend_scale),max(mg_earth.config.mg_street_min_height,min(t_height,(mg_earth.config.mg_street_max_height + ty_additive))),0.5)
			-- local t_height_base = t_height
			-- local tlevel = floor(t_height_base * tblend + theight_alt * (1 - tblend))
			-- local pathy = min(max(tlevel, mg_earth.config.mg_street_min_height), mg_earth.config.mg_street_max_height)

			local theight_alt, t_height_base, tlevel, pathy
			local dist_to_x_street, dist_to_z_street

			-- if (t_height >= mg_earth.config.mg_street_terrain_min_height) and (tlevel <= (mg_earth.config.mg_street_max_height + ty_additive)) then
			if t_height >= mg_earth.config.mg_street_terrain_min_height then
				dist_to_x_street = abs((x_line - x_sin) - x)
				dist_to_z_street = abs((z_line - z_sin) - z)
			else
				dist_to_x_street = -31000
				dist_to_z_street = -31000
			end

			mg_earth.streetmap[i2d]		= -31000
			mg_earth.streetheight[i2d]	= -31000
			mg_earth.streetdirmap[i2d]	= 0
			
			local street_height
			-- if (dist_to_z_street >= 0) and (dist_to_z_street <= (mg_earth.config.mg_street_max_height + ty_additive)) then
			if (dist_to_x_street >= 0) and (dist_to_x_street <= mg_earth.config.mg_street_size) then
						-- theight_alt = lerp((t_height * tblend_scale), max(mg_earth.config.mg_street_min_height,min(((t_height * zs_slope) * tblend_scale),(mg_earth.config.mg_street_max_height + ty_additive))), 0.5)
				theight_alt = lerp((t_height * tblend_scale), max(mg_earth.config.mg_street_min_height,min((t_height * tblend_scale),(mg_earth.config.mg_street_max_height + ty_additive))), 0.5)
						-- theight_alt = lerp((t_height * tblend_scale), max(mg_earth.config.mg_street_min_height,min(z_dist,(mg_earth.config.mg_street_max_height + ty_additive))), 0.5)
				t_height_base = t_height
				tlevel = floor(t_height_base * tblend + theight_alt * (1 - tblend))
				street_height = tlevel
				-- if (tlevel >= mg_earth.config.mg_street_terrain_min_height) and (tlevel <= ((mg_earth.config.mg_street_max_height + ty_additive) + ty_additive)) then
				-- if (street_height >= mg_earth.config.mg_street_terrain_min_height) and (street_height <= (mg_earth.config.mg_street_max_height + ty_additive)) then
				-- if (street_height >= mg_earth.config.mg_street_terrain_min_height) and (street_height <= t_height) then
				if (street_height >= mg_earth.config.mg_street_terrain_min_height) and (street_height <= (mg_earth.config.mg_street_max_height + ty_additive)) then
					mg_earth.streetmap[i2d] = dist_to_x_street
					mg_earth.streetheight[i2d] = street_height
					mg_earth.streetdirmap[i2d] = 1
				end
			end
			if (dist_to_z_street >= 0) and (dist_to_z_street <= mg_earth.config.mg_street_size) then
						-- theight_alt = lerp((t_height * tblend_scale), max(mg_earth.config.mg_street_min_height, min(((t_height * xs_slope) * tblend_scale), (mg_earth.config.mg_street_max_height + ty_additive))), 0.5)
				theight_alt = lerp((t_height * tblend_scale), max(mg_earth.config.mg_street_min_height, min((t_height * tblend_scale), (mg_earth.config.mg_street_max_height + ty_additive))), 0.5)
						-- theight_alt = lerp((t_height * tblend_scale), max(mg_earth.config.mg_street_min_height, min(x_dist, (mg_earth.config.mg_street_max_height + ty_additive))), 0.5)
				t_height_base = t_height
				tlevel = floor(t_height_base * tblend + theight_alt * (1 - tblend))
				street_height = tlevel
				-- if (tlevel >= mg_earth.config.mg_street_terrain_min_height) and (tlevel <= (mg_earth.config.mg_street_max_height + ty_additive)) then
				-- if (street_height >= mg_earth.config.mg_street_terrain_min_height) and (street_height <= (mg_earth.config.mg_street_max_height + ty_additive)) then
				-- if (street_height >= mg_earth.config.mg_street_terrain_min_height) and (street_height <= t_height) then
				if (street_height >= mg_earth.config.mg_street_terrain_min_height) and (street_height <= (mg_earth.config.mg_street_max_height + ty_additive)) then
					mg_earth.streetmap[i2d] = dist_to_z_street
					mg_earth.streetheight[i2d] = street_height
					mg_earth.streetdirmap[i2d] = 2
				end
			end

			if mg_earth.streetheight[i2d] > -31000 then

				pathy = min(max(street_height, mg_earth.config.mg_street_min_height), (mg_earth.config.mg_street_max_height + ty_additive))

				-- if x >= minp.x and z >= minp.z then
					local abscol = abs(nvals_bridge_column[i2d])

					if (mg_earth.streetheight[i2d] >= mg_earth.config.mg_street_terrain_min_height) and (mg_earth.streetheight[i2d] <= t_height) then

						-- scan disk 5 nodes above path
						local tunnel = false
						local excatop

						for zz = z - z_n, z + z_p do
							local vi = area:index(x - x_n, pathy + 5, zz)
							for xx = x - x_n, x + x_p do
								local nodid = data[vi]
								if nodid == mg_earth.c_stone
										or nodid == mg_earth.c_destone
										or nodid == mg_earth.c_sastone
										or nodid == mg_earth.c_ice then
									tunnel = true
								end
								vi = vi + 1
							end
						end

						if tunnel then
							excatop = pathy + 5
						else
							excatop = y1
						end
						-- place path node brush
						local vi = area:index(x, pathy, z)
						data[vi] = mg_earth.c_roadwhite

						for k = -4, 4 do
							local vi = area:index(x - 4, pathy, z + k)
							for i = -4, 4 do
								local radsq = (math.abs(i)) ^ 2 + (math.abs(k)) ^ 2
								if radsq <= 13 then
									local nodid = data[vi]
									if nodid ~= mg_earth.c_roadwhite then
										data[vi] = mg_earth.c_roadblack
									end
								elseif radsq <= 25 then
									local nodid = data[vi]
									if nodid ~= mg_earth.c_roadblack
											and nodid ~= mg_earth.c_roadwhite then
										data[vi] = mg_earth.c_roadslab
									end
								end
								vi = vi + 1
							end
						end
						-- foundations or bridge structure
						for k = -4, 4 do
							local vi = area:index(x - 4, pathy - 1, z + k)
							for i = -4, 4 do
								local radsq = (math.abs(i)) ^ 2 + (math.abs(k)) ^ 2
								if radsq <= 25 then
									local nodid = data[vi]
									if nodid ~= mg_earth.c_roadblack
											and nodid ~= mg_earth.c_roadwhite
											and nodid ~= mg_earth.c_roadslab then
										data[vi] = c_concrete
									end
								end
								if radsq <= 2 then
									local viu = vi - emerlen
									local nodid = data[viu]
									if nodid ~= mg_earth.c_roadblack
											and nodid ~= mg_earth.c_roadwhite
											and nodid ~= mg_earth.c_roadslab then
										data[viu] = mg_earth.c_concrete
									end
								end
								vi = vi + 1
							end
						end
						-- bridge columns
						if math.random() <= 0.0625 then
							for xx = x - 1, x + 1 do
							for zz = z - 1, z + 1 do
								local vi = area:index(xx, pathy - 3, zz)
								for y = pathy - 3, y0 - 16, -1 do
									local nodid = data[vi]
									if nodid == mg_earth.c_stone
											or nodid == mg_earth.c_destone
											or nodid == mg_earth.c_sastone then
										break
									else
										data[vi] = mg_earth.c_concrete
									end
									vi = vi - emerlen
								end
							end
							end
						end
						-- excavate above path
						for y = pathy + 1, excatop do
							for zz = z - 4, z + 4 do
								local vi = area:index(x - 4, y, zz)
								for xx = x - 4, x + 4 do
									local nodid = data[vi]
									if tunnel and y == excatop then -- tunnel ceiling
										if nodid ~= mg_earth.c_air
												and nodid ~= mg_earth.c_ignore
												and nodid ~= mg_earth.c_meselamp then
											if (math.abs(zz - z) == 4
													or math.abs(xx - x) == 4)
													and math.random() <= 0.2 then
												data[vi] = mg_earth.c_meselamp
											else
												data[vi] = mg_earth.c_concrete
											end
										end
									elseif y <= pathy + 5 then
										if nodid ~= mg_earth.c_roadblack
												and nodid ~= mg_earth.c_roadslab
												and nodid ~= mg_earth.c_roadwhite then
											data[vi] = mg_earth.c_air
										end
									elseif nodid == mg_earth.c_tree
											or nodid == mg_earth.c_leaves
											or nodid == mg_earth.c_apple
											or nodid == mg_earth.c_jungletree
											or nodid == mg_earth.c_jungleleaves
											or nodid == mg_earth.c_pinetree
											or nodid == mg_earth.c_pineneedles
											or nodid == mg_earth.c_snow
											or nodid == mg_earth.c_acaciatree
											or nodid == mg_earth.c_acacialeaves
											or nodid == mg_earth.c_aspentree
											or nodid == mg_earth.c_aspenleaves then
										data[vi] = mg_earth.c_air
									end
									vi = vi + 1
								end
							end
						end
					end
				-- end
			end

			i2d = i2d + 1
		end
	end
	

end




--##Chatcommands functions.  Emerge functions.
minetest.register_chatcommand("load_area", {
 	params = "x1 y1 z1 x2 y2 z2",
 	description = "Generate map in a square box from pos1(x1,y1,z1) to pos2(x2,y2,z2)./nUsage:  /load_area x1 y1 z1 x2 y2 z2",
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

	minetest.load_area(pos1, pos2)
	-- minetest.emerge_area(pos1, pos2, function(blockpos, action, remaining)
		-- local dt = math.floor((minetest.get_us_time() - start_time) / 1000)
		-- local block = (blockpos.x * 16)..","..(blockpos.y * 16)..","..(blockpos.z * 16)
		-- local info = "(mapgen-"..remaining.."-"..dt.."ms) "
		-- if action==core.EMERGE_GENERATED then
			-- minetest.chat_send_player(name, info.."Generated new block at "..block)
			-- --minetest.get_player_by_name(name):send_mapblock({x=(blockpos.x * 16),y=(blockpos.y * 16),z=(blockpos.z * 16)})
		-- elseif (action==core.EMERGE_CANCELLED) or (action==core.EMERGE_ERRORED) then
			-- minetest.chat_send_player(name, info.."Block at "..block.." did not emerge")
		-- else
			-- --minetest.chat_send_player(name, "(mapgen-"..remaining.."-"..dt.."s) Visited block at "..(blockpos.x)..","..(blockpos.y)..","..(blockpos.z))
		-- end
	
		-- if remaining<=0 then
			-- minetest.chat_send_player(name, "(mapgen-"..dt.."ms) Generation done.")
		-- end
	-- end

	-- local end_time = minetest.get_us_time()
	local dt = math.floor((minetest.get_us_time() - start_time) / 1000)
	minetest.chat_send_player(name, "(load_area - "..dt.."ms).")

end
})

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

mg_earth.mapgen_times = {
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


--local nobj_val_fill = mg_earth.noise_handler.get_noise_object(mg_earth.noise["np_val_fill"], {x = 80, y = 80, z = 80})

local function generate_2dNoise_map(minp, maxp, seed)

	if mg_heightmap_select == "v5" then

		mg_earth.v5_factormap = {}
		mg_earth.v5_heightmap = {}

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local factor, height = get_v5_height(z,x)

				mg_earth.v5_factormap[index2d] = factor
				mg_earth.v5_heightmap[index2d] = height

				-- ground = minetest.get_perlin(mg_earth.noise["np_v5_ground"]):get_3d({x=x,y=-31000,z=z})

						-- -- if (ground * factor) >= (y - height) then
						-- if (ground * factor) >= (y - height) then
							-- mg_earth.heightmap[index2d] = y
						-- end

				-- mg_earth.heightmap[index2d] = (ground * factor) + height

				index2d = index2d + 1

			end
		end

	end

	if mg_heightmap_select == "vCarp3D" then

		mg_earth.carpmap = {}

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local n_t1, n_t2, n_t3, n_t4, h_mnt, r_mnt, s_mnt = get_carp_vals(z,x)

				-- mg_earth.height1[index2d] = n_theight1
				-- mg_earth.height2[index2d] = n_theight2
				-- mg_earth.height3[index2d] = n_theight3
				-- mg_earth.height4[index2d] = n_theight4
				-- mg_earth.hill_mnt[index2d] = hill_mnt
				-- mg_earth.ridge_mnt[index2d] = ridge_mnt
				-- mg_earth.step_mnt[index2d] = step_mnt

				local carpvals = {
					n_theight1 = n_t1,
					n_theight2 = n_t2,
					n_theight3 = n_t3,
					n_theight4 = n_t4,
					hill_mnt = h_mnt,
					ridge_mnt = r_mnt,
					step_mnt = s_mnt,
				}

				mg_earth.carpmap[index2d] = carpvals

				local n_mnt_var = abs(minetest.get_perlin(mg_earth.noise["np_carp_mnt_var"]):get_3d({x=x,y=-31000,z=z}))

				local com1, com2, com3, com4
				com1 = lerp(n_t1, n_t2, n_mnt_var)
				com2 = lerp(n_t3, n_t4, n_mnt_var)
				com3 = lerp(n_t3, n_t2, n_mnt_var)
				com4 = lerp(n_t1, n_t4, n_mnt_var)
				local hilliness = max(min(com1,com2),min(com3,com4))

				local hills = h_mnt * hilliness
				local ridged_mountains = r_mnt * hilliness
				local step_mountains = s_mnt * hilliness

				local mountains = hills + ridged_mountains + step_mountains

				local surface_level = 12 + mountains

				mg_earth.heightmap[index2d] = surface_level

				index2d = index2d + 1

			end
		end

	end

	if mg_heightmap_select == "vDiaSqr" then
	
		--local ds_map = diasq.create(maxp.x - minp.x + 1, maxp.x - minp.x + 1)
		local ds_map = mg_earth.diasq.create(maxp.x - minp.x, maxp.x - minp.x)

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				mg_earth.heightmap[index2d] = ds_map[z][x]

				index2d = index2d + 1

			end
		end

	end

	if mg_heightmap_select == "vValleys3D" then

		-- mg_earth.surfacemap = {}
		-- mg_earth.slopemap = {}
		-- mg_earth.valleysrivermap = {}

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local surface_y, slope, river_course = get_valleys3D_height(z,x)

			-- --# 2D Generation
				local n_fill = minetest.get_perlin(mg_earth.noise["np_val_fill"]):get_3d({x=x,y=surface_y,z=z})

				local surface_delta = n_fill - surface_y;
				local density = slope * n_fill - surface_delta;

				mg_earth.heightmap[index2d] = density
				mg_earth.surfacemap[index2d] = surface_y
				mg_earth.slopemap[index2d] = slope
				mg_earth.valleysrivermap[index2d] = river_course

				index2d = index2d + 1

			end
		end

	end

end

local function generate_3dNoise_map(minp, maxp, seed)

	if mg_world_scale == 1 then

		-- local nobj_cave1 = nil
		-- local nbuf_cave1 = {}
		-- local nobj_cave2 = nil
		-- local nbuf_cave2 = {}

		--local nobj = mg_earth.noise_handler.get_noise_object(np, chunk_size)

		if mg_earth.settings.enable_caves then
			nobj_cave1 = nobj_cave1 or minetest.get_perlin_map(mg_earth.noise["np_cave1"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cave1 = nobj_cave1:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			nobj_cave2 = nobj_cave2 or minetest.get_perlin_map(mg_earth.noise["np_cave2"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cave2 = nobj_cave2:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			-- -- local nobj_cave1 = mg_earth.noise_handler.get_noise_object("np_cave1", {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nbuf_cave1 = nobj_cave1.get_3d_map(minp)
			-- -- local nobj_cave1 = mg_earth.noise_handler.get_noise_object("np_cave1", {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nbuf_cave2 = nobj_cave1.get_3d_map(minp)

			-- nbuf_cave1 = mg_earth.noisemap(nobj_cave1, mg_earth.noise["np_cave1"], minp3d, csize)
			-- nbuf_cave2 = mg_earth.noisemap(nobj_cave2, mg_earth.noise["np_cave2"], minp3d, csize)

		end

		if mg_earth.settings.enable_caverns then
			nobj_cavern1 = nobj_cavern1 or minetest.get_perlin_map(mg_earth.noise["np_cavern1"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cavern1 = nobj_cavern1:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			nobj_cavern2 = nobj_cavern2 or minetest.get_perlin_map(mg_earth.noise["np_cavern2"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cavern2 = nobj_cavern2:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			nobj_wave = nobj_wave or minetest.get_perlin_map(mg_earth.noise["np_wave"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_wave = nobj_wave:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			-- nobj_cavebiome = nobj_cavebiome or minetest.get_perlin_map(mg_earth.noise["np_cave_biome"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
			-- nbuf_cavebiome = nobj_cavebiome:get_2d_map({x = minp.x, y = minp.z})
			-- -- local nobj_cavern1 = mg_earth.noise_handler.get_noise_object("np_cavern1", {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nbuf_cavern1 = nobj_cavern1.get_3d_map(minp)
			-- -- local nobj_cavern2 = mg_earth.noise_handler.get_noise_object("np_cavern2", {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nbuf_cavern2 = nobj_cavern2.get_3d_map(minp)
			-- -- local nobj_wave = mg_earth.noise_handler.get_noise_object("np_wave", {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nbuf_wave = nobj_wave.get_3d_map(minp)
			-- -- -- nbuf_cavebiome = mg_earth.noise_handler.get_noise_object("np_cave_biome", {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
		end

		if mg_noise_select == "v3D" then

			nobj_3d_noise = nobj_3d_noise or minetest.get_perlin_map(mg_earth.noise["np_3d_noise"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_3d_noise = nobj_3d_noise:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

			-- nbuf_3dterrain = mg_earth.noisemap(nobj_3dterrain, mg_earth.noise["np_3dterrain"], minp3d, csize)

		end

		if mg_heightmap_select == "vStraight3D" then

			nobj_3dterrain = nobj_3dterrain or minetest.get_perlin_map(mg_earth.noise["np_3dterrain"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_3dterrain = nobj_3dterrain:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

		end

		if mg_heightmap_select == "v3D" then

			nobj_3dterrain = nobj_3dterrain or minetest.get_perlin_map(mg_earth.noise["np_3dterrain"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_3dterrain = nobj_3dterrain:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

			-- nbuf_3dterrain = mg_earth.noisemap(nobj_3dterrain, mg_earth.noise["np_3dterrain"], minp3d, csize)

		end

		if mg_heightmap_select == "vCarp3D" then
			nobj_carp_mnt_var = nobj_carp_mnt_var or minetest.get_perlin_map(mg_earth.noise["np_carp_mnt_var"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_carp_mnt_var = nobj_carp_mnt_var:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

			-- nbuf_carp_mnt_var = mg_earth.noisemap(nobj_carp_mnt_var, mg_earth.noise["np_carp_mnt_var"], minp3d, csize)

		end

		if mg_heightmap_select == "v5" then
			nobj_v5_ground = nobj_v5_ground or minetest.get_perlin_map(mg_earth.noise["np_v5_ground"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_v5_ground = nobj_v5_ground:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			-- -- local nobj_v5_ground = mg_earth.noise_handler.get_noise_object(mg_earth.noise["np_v5_ground"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nbuf_v5_ground = nobj_v5_ground.get_3d_map(minp)

			-- nbuf_v5_ground = mg_earth.noisemap(nobj_v5_ground, mg_earth.noise["np_v5_ground"], minp3d, csize)

		end

		if mg_heightmap_select == "vValleys3D" then
			nobj_val_fill = nobj_val_fill or minetest.get_perlin_map(mg_earth.noise["np_val_fill"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_val_fill = nobj_val_fill:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			-- --local nobj_val_fill = mg_earth.noise_handler.get_noise_object(mg_earth.noise["np_val_fill"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nobj_val_fill = mg_earth.noise_handler.get_noise_object(mg_earth.noise["np_val_fill"], {x = 80, y = 80, z = 80})
			-- --local nbuf_val_fill = nobj_val_fill.get_3d(minp)

			-- nbuf_val_fill = mg_earth.noisemap(nobj_val_fill, mg_earth.noise["np_val_fill"], minp, csize)

		end

	end


	if mg_noise_select == "v3D" then

		mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local n_f = 0
					
					--if mg_world_scale == 1 then
					--	n_f = nbuf_3d_noise[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					--else
						n_f = minetest.get_perlin(mg_earth.noise["np_3d_noise"]):get_3d({x = x, y = y, z = z})
					--end
					
					-- local density = (n_f + ((1 - y) / (v3d_noise_density * mg_world_scale)))

					--mg_earth.densitymap[index3d] = density
					mg_earth.densitymap[index3d] = n_f
							-- --mg_earth.densitymap[index3d] = (n_f + ((1 - y) / (mg_density * mg_world_scale)))

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	if mg_heightmap_select == "v3D" then

		mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local n_f = 0
					
					if mg_world_scale == 1 then
						n_f = nbuf_3dterrain[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_f = minetest.get_perlin(mg_earth.noise["np_3dterrain"]):get_3d({x = x, y = y, z = z})
					end
					
					local density = (n_f + ((1 - y) / (mg_density * mg_world_scale)))

					if density > 0 then
					--if (density + (2.0 - max(0,min(1,taper_height)))) <= 0 then
						--if (n_f + ((1 - y) / (mg_density * mg_world_scale))) > 0 then
						mg_earth.heightmap[index2d] = y
					end
					
					mg_earth.densitymap[index3d] = density
					--mg_earth.densitymap[index3d] = (n_f + ((1 - y) / (mg_density * mg_world_scale)))

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	if mg_heightmap_select == "vCarp3D" then

		mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local grad_wl = 1 - mg_water_level;
					local y_terrain_height = -31000

					-- n_theight1 = mg_earth.height1[index2d]
					-- n_theight2 = mg_earth.height2[index2d]
					-- n_theight3 = mg_earth.height3[index2d]
					-- n_theight4 = mg_earth.height4[index2d]
					-- hill_mnt = mg_earth.hill_mnt[index2d]
					-- ridge_mnt = mg_earth.ridge_mnt[index2d]
					-- step_mnt = mg_earth.step_mnt[index2d]

					local n_theight1 = mg_earth.carpmap[index2d].n_theight1
					local n_theight2 = mg_earth.carpmap[index2d].n_theight2
					local n_theight3 = mg_earth.carpmap[index2d].n_theight3
					local n_theight4 = mg_earth.carpmap[index2d].n_theight4
					local hill_mnt = mg_earth.carpmap[index2d].hill_mnt
					local ridge_mnt = mg_earth.carpmap[index2d].ridge_mnt
					local step_mnt = mg_earth.carpmap[index2d].step_mnt

					--local n_mnt_var = abs(minetest.get_perlin(mg_earth.noise["np_carp_mnt_var"]):get_3d({x=x,y=y,z=z}))
					local n_mnt_var = 0
					
					if mg_world_scale == 1 then
						n_mnt_var = nbuf_carp_mnt_var[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_mnt_var = minetest.get_perlin(mg_earth.noise["np_carp_mnt_var"]):get_3d({x = x, y = y, z = z})
					end
					

					local com1, com2, com3, com4
					com1 = lerp(n_theight1, n_theight2, n_mnt_var)
					com2 = lerp(n_theight3, n_theight4, n_mnt_var)
					com3 = lerp(n_theight3, n_theight2, n_mnt_var)
					com4 = lerp(n_theight1, n_theight4, n_mnt_var)
					local hilliness = max(min(com1,com2),min(com3,com4))

					local hills = hill_mnt * hilliness
					local ridged_mountains = ridge_mnt * hilliness
					local step_mountains = step_mnt * hilliness

					local mountains = hills + ridged_mountains + step_mountains

					local grad
					if (y < mg_water_level) then
						grad = grad_wl + (mg_water_level - y) * 3
					else
						grad = 1 - y
					end

					local surface_level = 12 + mountains + grad

					--mg_earth.heightmap[index2d] = surface_level

					mg_earth.densitymap[index3d] = n_mnt_var

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	if mg_heightmap_select == "vStraight3D" then

		mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local n_3d_val = 0

					if mg_world_scale == 1 then
						n_3d_val = nbuf_3dterrain[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_3d_val = minetest.get_perlin(mg_earth.noise["np_3dterrain"]):get_3d({x=x,y=y,z=z})
					end

					if n_3d_val <= 0 then
						mg_earth.heightmap[index2d] = y
					end

					mg_earth.densitymap[index3d] = n_3d_val

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	if mg_heightmap_select == "v5" then

		mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do
				
					-- if mg_world_scale == 1 then
						-- mg_earth.densitymap[index3d] = nbuf_v5_ground[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					-- else
						-- mg_earth.densitymap[index3d] = minetest.get_perlin(mg_earth.noise["np_v5_ground"]):get_3d({x=x,y=y,z=z})
					-- end


--					local t_y = mg_earth.heightmap[index2d]

					local factor = mg_earth.v5_factormap[index2d]
					local height = mg_earth.v5_heightmap[index2d]
					local ground = 0
					
					if mg_world_scale == 1 then
						ground = nbuf_v5_ground[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						ground = minetest.get_perlin(mg_earth.noise["np_v5_ground"]):get_3d({x=x,y=y,z=z})
					end
					
					local density = ((ground * factor) + height)

						-- -- if (ground * factor) >= (y - height) then
						-- --if (ground * factor) >= y then
						-- -- if ((ground * factor) + height) >= y then
					if density >= y then
						-- -- -- if y > t_y then
							-- -- mg_earth.heightmap[index2d] = y
						-- -- -- end
						mg_earth.heightmap[index2d] = y
						mg_earth.densitymap[index3d] = true
					else
						mg_earth.densitymap[index3d] = false
					end
						-- -- -- if (ground * factor) < (y - height) then
							-- -- if (y <= mg_water_level) then
							
							-- -- else
							
							-- -- end
						-- -- else
							-- -- mg_earth.heightmap[index2d] = y
							-- -- --mg_earth.heightmap[index2d] = (ground * factor)
						-- -- end

					-- mg_earth.densitymap[index3d] = ground

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end

	end

	if mg_heightmap_select == "vValleys3D" then

		mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		-- local n_fill_vals = nobj_val_fill.get_3d_map_flat(minp)

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do


					local n_fill = 0
					--local n_fill = nobj_val_fill.get_3d_map(minp)
					-- local n_fill = n_fill_vals[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]
					--local n_fill = n_fill_vals[index3d]
					-- local h_m = mg_earth.heightmap[index2d]
					
					if mg_world_scale == 1 then
						n_fill = nbuf_val_fill[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_fill = minetest.get_perlin(mg_earth.noise["np_val_fill"]):get_3d({x=x,y=y,z=z})
					end

					--local surface_delta = n_fill - mg_earth.surfacemap[index2d]
					-- local surface_delta_n = n_fill - mg_earth.surfacemap[index2d]
					--local surface_delta = y - mg_earth.surfacemap[index2d]
					local surface_delta_y = y - mg_earth.surfacemap[index2d]

					-- local density_n = mg_earth.slopemap[index2d] * n_fill - surface_delta_n
					local density_y = mg_earth.slopemap[index2d] * n_fill - surface_delta_y
					-- local density = max(density_n,density_y)

							-- if density > 0 then
								-- -- mg_earth.heightmap[index2d] = y
								-- mg_earth.heightmap[index2d] = y + 1
								-- -- mg_earth.heightmap[index2d] = density
							-- end
							-- if density_n > 0 then
								-- -- mg_earth.heightmap[index2d] = y
								-- -- mg_earth.heightmap[index2d] = y + 1
								-- -- mg_earth.heightmap[index2d] = density
								-- mg_earth.heightmap[index2d] = density_n
							-- end
							-- if density_y > 0 then
								-- --if (y + 1) > h_m then
	-- --							if y > h_m then
									-- -- mg_earth.heightmap[index2d] = y
									-- -- mg_earth.heightmap[index2d] = y + 1
									-- -- mg_earth.heightmap[index2d] = density
									-- mg_earth.heightmap[index2d] = density_y
	-- --							end
							-- end
							-- mg_earth.heightmap[index2d] = density
							-- mg_earth.heightmap[index2d] = density_n
							--mg_earth.heightmap[index2d] = density_y
					--mg_earth.heightmap[index2d] = density_y + h_m		--TRY THIS LINE NEXT??? 20220402
					
					-- mg_earth.densitymap[index3d] = density
					-- mg_earth.densitymap[index3d] = density_n
					mg_earth.densitymap[index3d] = density_y

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end

	end

	if mg_earth.config.mg_caves_enabled then

		mg_earth.cave1map = {}
		mg_earth.cave2map = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					if mg_world_scale == 1 then
						mg_earth.cave1map[index3d] = nbuf_cave1[z-minp.z+1][y-minp.y+1][x-minp.x+1]
						mg_earth.cave2map[index3d] = nbuf_cave2[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						mg_earth.cave1map[index3d] = minetest.get_perlin(mg_earth.noise["np_cave1"]):get_3d({x = x, y = y, z = z})
						mg_earth.cave2map[index3d] = minetest.get_perlin(mg_earth.noise["np_cave2"]):get_3d({x = x, y = y, z = z})
					end


					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end

	end

	if mg_earth.config.mg_caverns_enabled then

		mg_earth.cavern1map = {}
		mg_earth.cavern2map = {}
		mg_earth.cavernwavemap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					if mg_world_scale == 1 then
						mg_earth.cavern1map[index3d] = nbuf_cavern1[z-minp.z+1][y-minp.y+1][x-minp.x+1]
						mg_earth.cavern2map[index3d] = nbuf_cavern2[z-minp.z+1][y-minp.y+1][x-minp.x+1]
						mg_earth.cavernwavemap[index3d] = nbuf_wave[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						mg_earth.cavern1map[index3d] = minetest.get_perlin(mg_earth.noise["np_cavern1"]):get_3d({x = x, y = y, z = z})
						mg_earth.cavern2map[index3d] = minetest.get_perlin(mg_earth.noise["np_cavern2"]):get_3d({x = x, y = y, z = z})
						mg_earth.cavernwavemap[index3d] = minetest.get_perlin(mg_earth.noise["np_wave"]):get_3d({x = x, y = y, z = z})
					end

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	-- if  then
		-- init_3D_voronoi()
	-- end

end


local function generate_2d_map(minp, maxp, seed, area)

	local alt = {
		mean	= 0,
		min		= -31000,
		max		= 31000,
	}

	mg_earth.center_of_chunk = {
		x = (maxp.x - ((maxp.x - minp.x + 1) / 2)),
		y = (maxp.y - ((maxp.x - minp.x + 1) / 2)),
		z = (maxp.z - ((maxp.x - minp.x + 1) / 2)),
	}

	mg_earth.chunk_center_rand = {
		x = (maxp.x - ((maxp.x - minp.x + 1) / 2)) + (20 - math.random(40)),
		y = (maxp.y - ((maxp.x - minp.x + 1) / 2)) + (20 - math.random(40)),
		z = (maxp.z - ((maxp.x - minp.x + 1) / 2)) + (20 - math.random(40)),
	}

	mg_earth.chunk_points = {
		{x=minp.x,							y=minp.y,							z=minp.z},
		{x=mg_earth.center_of_chunk.x,		y=minp.y,							z=minp.z},
		{x=maxp.x,							y=minp.y,							z=minp.z},
		{x=minp.x,							y=mg_earth.center_of_chunk.y,		z=minp.z},
		{x=mg_earth.center_of_chunk.x,		y=mg_earth.center_of_chunk.y,		z=minp.z},
		{x=maxp.x,							y=mg_earth.center_of_chunk.y,		z=minp.z},
		{x=minp.x,							y=maxp.y,							z=minp.z},
		{x=mg_earth.center_of_chunk.x,		y=maxp.y,							z=minp.z},
		{x=maxp.x,							y=maxp.y,							z=minp.z},
		{x=minp.x,							y=minp.y,							z=mg_earth.center_of_chunk.z},
		{x=mg_earth.center_of_chunk.x,		y=minp.y,							z=mg_earth.center_of_chunk.z},
		{x=maxp.x,							y=minp.y,							z=mg_earth.center_of_chunk.z},
		{x=minp.x,							y=mg_earth.center_of_chunk.y,		z=mg_earth.center_of_chunk.z},
		{x=mg_earth.center_of_chunk.x,		y=mg_earth.center_of_chunk.y,		z=mg_earth.center_of_chunk.z},
		{x=maxp.x,							y=mg_earth.center_of_chunk.y,		z=mg_earth.center_of_chunk.z},
		{x=minp.x,							y=maxp.y,							z=mg_earth.center_of_chunk.z},
		{x=mg_earth.center_of_chunk.x,		y=maxp.y,							z=mg_earth.center_of_chunk.z},
		{x=maxp.x,							y=maxp.y,							z=mg_earth.center_of_chunk.z},
		{x=minp.x,							y=minp.y,							z=maxp.z},
		{x=mg_earth.center_of_chunk.x,		y=minp.y,							z=maxp.z},
		{x=maxp.x,							y=minp.y,							z=maxp.z},
		{x=minp.x,							y=mg_earth.center_of_chunk.y,		z=maxp.z},
		{x=mg_earth.center_of_chunk.x,		y=mg_earth.center_of_chunk.y,		z=maxp.z},
		{x=maxp.x,							y=mg_earth.center_of_chunk.y,		z=maxp.z},
		{x=minp.x,							y=maxp.y,							z=maxp.z},
		{x=mg_earth.center_of_chunk.x,		y=maxp.y,							z=maxp.z},
		{x=maxp.x,							y=maxp.y,							z=maxp.z},
	}

	--2D HEIGHTMAP GENERATION

	local index2d = 1

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do

			local nheat = get_heat_scalar({x=x,y=0,z=z}) + nbuf_heatmap[z-minp.z+1][x-minp.x+1] + nbuf_heatblend[z-minp.z+1][x-minp.x+1]
			local nhumid = get_humid_scalar({x=x,y=0,z=z}) + nbuf_humiditymap[z-minp.z+1][x-minp.x+1] + nbuf_humidityblend[z-minp.z+1][x-minp.x+1]
			mg_earth.fillmap[index2d] = minetest.get_perlin(mg_earth.noise["np_fill"]):get_2d({x=x,y=z})

			local t_y
			local t_c = 0

			if minetest.get_mapgen_setting("mg_name") == "singlenode" then
				if mg_heightmap_select == "v3D" or mg_heightmap_select == "v5" or mg_heightmap_select == "vCarp3D" or mg_heightmap_select == "vStraight3D" or mg_heightmap_select == "vValleys3D" then
					local alt_y = mg_earth.heightmap[index2d]
					if alt_y then
						t_y = alt_y
					else
						t_y = minp.y - 1
					end
					mg_earth.heightmap[index2d] = t_y
					mg_earth.cliffmap[index2d] = t_c
				else
					t_y, t_c = get_mg_heightmap({x=x,y=0,z=z},nheat,nhumid,index2d)
					mg_earth.heightmap[index2d] = t_y
					mg_earth.cliffmap[index2d] = t_c
				end
			else
				local hm = minetest.get_mapgen_object("heightmap")
				-- local v_y, v_c = get_valleys_height(z,x,index2d)
				-- local nheight = get_terrain_height(z,x) + ((get_v6_height(z,x) * ((50 - nhumid) / 50)) * 0.5) + (v_y * -1)
				-- t_y = max(hm[index2d], nheight)
				t_y = hm[index2d]
				mg_earth.heightmap[index2d] = t_y
				mg_earth.cliffmap[index2d] = 0
			end


			local nbiome_name = calc_biome_from_noise(nheat,nhumid,{x=x,y=t_y,z=z})
			if not nbiome_name or nbiome_name == "" then
				local nbiome_data = minetest.get_biome_data({x=x,y=t_y,z=z})
				nbiome_name = minetest.get_biome_name(nbiome_data.biome)
			end
			mg_earth.biomemap[index2d] = nbiome_name

			if mg_earth.config.mg_ecosystems then
				local soil_type_idx, soil_idx, top_type_idx, top_idx = gal.get_ecosystem({x = x, y = t_y, z = z},nbiome_name)
				mg_earth.eco_map[index2d] = {soil_type_idx, soil_idx, top_type_idx, top_idx}
			end

			mg_earth.hh_mod[index2d] = min(0,(nheat - nhumid)) * mg_world_scale

			if mg_earth.config.mg_paths then

				-- local HSAMP = 0.025 -- Height select amplitude.
					-- local ty_scale = 1 / (max(1,(max(12,t_y) - 12)) * 0.5)
				local tblend_scale = 1 / max(1,(max((mg_earth.config.mg_path_max_height * 0.5),t_y) - (mg_earth.config.mg_path_max_height * 0.5)))
					-- local ty_scale = (max(20,t_y) - 20) / 20
					-- local ty_scale = (20 - t_y) / 20
					-- local ty_scale = max(1, ((t_y - 20) / 20))
					-- local ty_scale = ((t_y - 20) / t_y)
					-- local ty_scale = (t_y - 20) / 6
				-- local ty_additive = (max(mg_earth.config.mg_path_max_height,t_y) - mg_earth.config.mg_path_max_height) / mg_earth.config.mg_path_max_height
					-- local ty_scale = 20 / max(20, t_y)
				local ty_additive = min(1, (max(mg_earth.config.mg_street_max_height,t_y) - mg_earth.config.mg_street_max_height) / mg_earth.config.mg_street_max_height)
					-- local sin_scale = (mg_earth.config.mg_street_max_height * 0.5) / max((mg_earth.config.mg_street_max_height * 0.5),t_height)
				-- local sin_scale = (mg_earth.config.mg_path_max_height * 0.5) / max((mg_earth.config.mg_path_max_height * 0.5),t_y)
				local sin_scale = (100 * ((mg_earth.config.mg_street_max_height * 0.5) / max((mg_earth.config.mg_street_max_height * 0.5),t_y))) / 100

				-- local tblend = 0.5 + HSAMP * (minetest.get_perlin(mg_earth.noise["np_v7_height"]):get_2d({x=x,y=z}) - 0.5)
				local tblend = 0.5 + HSAMP * ((t_y * tblend_scale) - 0.5)
				-- local tblend = 0.5 + HSAMP * (t_y - 0.5)
				tblend = math.min(math.max(tblend, 0), 1)

								-- local tlevel = math.floor((t_y * tblend) + (t_y * (1 - tblend)))
						-- local tlevel = math.floor(t_y * tblend + ((t_y * ty_scale) + ty_additive) * (1 - tblend))
						-- local tlevel = math.floor(t_y * tblend + (t_y * ty_scale) * (1 - tblend))
						-- local tlevel = math.floor(t_y * tblend + (t_y * ty_scale) * (1 - tblend))
						-- local tlevel = math.floor(t_y * tblend + (t_y * 0.357) * (1 - tblend))
						-- local tlevel = math.floor(t_y * tblend + (min((20 + ty_additive),t_y)) * (1 - tblend))
						-- local tlevel = math.floor((min((20 + ty_additive),t_y)) * tblend + (min((20 + ty_additive),(t_y * 0.357))) * (1 - tblend))
				-- local tlevel = math.floor((min((mg_earth.config.mg_path_max_height + ty_additive),t_y)) * tblend + min(t_y, (min((mg_earth.config.mg_path_max_height + ty_additive),(t_y * tblend_scale)))) * (1 - tblend))
				-- local tlevel = math.floor(t_y * tblend + (math.min((mg_earth.config.mg_path_max_height + ty_additive),(t_y * tblend_scale))) * (1 - tblend))
				local tlevel = math.floor(t_y * tblend + (lerp((mg_earth.config.mg_path_max_height + ty_additive),(t_y * tblend_scale),0.5)) * (1 - tblend))
					-- local tlevel = math.floor((min((mg_earth.config.mg_path_max_height + ty_additive),t_y)) * tblend + (min((mg_earth.config.mg_path_max_height + ty_additive),(t_y * tblend_scale))) * (1 - tblend))
					-- local tlevel = math.floor(t_y * tblend + (mg_earth.config.mg_path_max_height + ty_additive) * (1 - tblend))
								-- local tlevel = math.floor((t_y * tblend) + (lerp(0, t_y, ty_scale) * (1 - tblend)))
								-- local tlevel = math.floor((t_y * tblend) + floor(lerp(0, t_y, tblend) * (1 - tblend)))
								-- local tlevel = math.floor((t_y * tblend) + lerp(0, t_y, tblend) * (1 - tblend))
								-- local tlevel = math.floor((t_y * tblend) + floor(lerp(0, t_y, ty_scale) * (1 - tblend)))
										-- local tlevel = math.floor((t_y * tblend) + (lerp(mg_earth.config.max_beach, t_y, ty_scale) * (1 - tblend)))
										-- local tlevel = math.floor((t_y * tblend) + (t_y * (1 - tblend)))

						-- local n_rd = minetest.get_perlin(mg_earth.noise["np_path"]):get_2d({x = x, y = z})

				local x_i, x_f = math.modf(x / mg_earth.config.mg_path_grid)
				local z_i, z_f = math.modf(z / mg_earth.config.mg_path_grid)

						-- local x_line = 0
						-- local z_line = 0

						-- -- local x_sin = (sin(z * 0.01) * mg_path_sin) + ((t_y + n_rd) * sin_scale)
						-- local x_sin = (sin(z * mg_earth.config.mg_path_sin_amp) * mg_earth.config.mg_path_sin_amp) + (t_y * sin_scale)
						-- -- local x_sin = (sin(z * 0.01) * mg_path_sin)
						-- -- local z_sin = (sin(x * 0.01) * mg_path_sin) + ((t_y + n_rd) * sin_scale)
						-- local z_sin = (sin(x * mg_earth.config.mg_path_sin_amp) * mg_earth.config.mg_path_sin_amp) + (t_y * sin_scale)
						-- -- local z_sin = (sin(x * 0.01) * mg_path_sin)

				local x_line, z_line, x_sin, z_sin
				local dist_to_x_path, dist_to_z_path

				-- local t_rd_sin_a = mg_earth.config.mg_path_sin_amp - t_y
				local t_rd_sin_a = mg_earth.config.mg_path_sin_amp
				-- local t_rd_sin_f = mg_earth.config.mg_path_sin_freq + (t_rd_sin_a * 0.0001)
				local t_rd_sin_f = mg_earth.config.mg_path_sin_freq

				if (x_f >= -0.5) and (x_f <= 0.5) then
					x_line = x_i * mg_earth.config.mg_path_grid
					x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a) + (t_y * sin_scale)
					-- x_sin = 0
					dist_to_x_path = abs((x_line - x_sin) - x)
				else
					if x >= 0 then
						x_line = (x_i + 1) * mg_earth.config.mg_path_grid
						x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a) + (t_y * sin_scale)
						-- x_sin = 0
						dist_to_x_path = abs((x_line - x_sin) - x)
					else
						x_line = (x_i - 1) * mg_earth.config.mg_path_grid
						x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a) + (t_y * sin_scale)
						-- x_sin = 0
						dist_to_x_path = abs((x_line - x_sin) - x)
					end
				end
				if (z_f >= -0.5) and (z_f <= 0.5) then
					z_line = z_i * mg_earth.config.mg_path_grid
					z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a) + (t_y * sin_scale)
					-- z_sin = 0
					dist_to_z_path = abs((z_line - z_sin) - z)
				else
					if z >= 0 then
						z_line = (z_i + 1) * mg_earth.config.mg_path_grid
						z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a) + (t_y * sin_scale)
						-- z_sin = 0
						dist_to_z_path = abs((z_line - z_sin) - z)
					else
						z_line = (z_i - 1) * mg_earth.config.mg_path_grid
						z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a) + (t_y * sin_scale)
						-- z_sin = 0
						dist_to_z_path = abs((z_line - z_sin) - z)
					end
				end
				
						-- local x_line_dir, x_line_comp = get_direction_to_pos({x = x, z = z},{x = x_line, z = z})
						-- local z_line_dir, z_line_comp = get_direction_to_pos({x = x, z = z},{x = x, z = z_line})

				mg_earth.pathmap[index2d] = -31000


				if (dist_to_x_path >= 0) and (dist_to_x_path <= mg_earth.config.mg_path_size) then
					mg_earth.pathmap[index2d] = dist_to_x_path
					mg_earth.pathheight[index2d] = tlevel
					mg_earth.pathdirmap[index2d] = 1
				end
				if (dist_to_z_path >= 0) and (dist_to_z_path <= mg_earth.config.mg_path_size) then
					mg_earth.pathmap[index2d] = dist_to_z_path
					mg_earth.pathheight[index2d] = tlevel
					mg_earth.pathdirmap[index2d] = 2
				end

			end

			if z == minp.z then
				if x == minp.x then
					mg_earth.chunk_terrain["SW"]		= {x=minp.x,						y=t_y,		z=minp.z}
				elseif x == mg_earth.center_of_chunk.x then
					mg_earth.chunk_terrain["S"]			= {x=mg_earth.center_of_chunk.x,	y=t_y,		z=minp.z}
				elseif x == maxp.x then
					mg_earth.chunk_terrain["SE"]		= {x=maxp.x,						y=t_y,		z=minp.z}
				end
			elseif z == mg_earth.center_of_chunk.z then
				if x == minp.x then
					mg_earth.chunk_terrain["W"]			= {x=minp.x,						y=t_y,		z=mg_earth.center_of_chunk.z}
				elseif x == mg_earth.center_of_chunk.x then
					mg_earth.chunk_terrain["C"]			= {x=mg_earth.center_of_chunk.x,	y=t_y,		z=mg_earth.center_of_chunk.z}
				elseif x == maxp.x then
					mg_earth.chunk_terrain["E"]			= {x=maxp.x,						y=t_y,		z=mg_earth.center_of_chunk.z}
				end
			elseif z == maxp.z then
				if x == minp.x then
					mg_earth.chunk_terrain["NW"]		= {x=minp.x,						y=t_y,		z=maxp.z}
				elseif x == mg_earth.center_of_chunk.x then
					mg_earth.chunk_terrain["N"]			= {x=mg_earth.center_of_chunk.x,	y=t_y,		z=maxp.z}
				elseif x == maxp.x then
					mg_earth.chunk_terrain["NE"]		= {x=maxp.x,						y=t_y,		z=maxp.z}
				end
			end

--## MEAN, MIN, MAX ALTITUDES
			alt.mean = alt.mean + t_y
			if alt.min == -31000 then
				alt.min = t_y
			else
				if alt.min > t_y then
					alt.min = t_y
				end
				-- min_alt = min(t_y,min_alt)
			end
			if alt.max == 31000 then
				alt.max = t_y
			else
				if alt.max < t_y then
					alt.max = t_y
				end
				-- max_alt = max(t_y,max_alt)
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

			index2d = index2d + 1

		end
		--end
	end

	mg_earth.chunk_mean_altitude = alt.mean / ((maxp.x - minp.x) * (maxp.z - minp.z))
	mg_earth.chunk_min_altitude = alt.min
	mg_earth.chunk_max_altitude = alt.max
	mg_earth.chunk_rng_altitude = alt.max - alt.min
	mg_earth.chunk_altitude_variance = (min(((alt.mean - alt.min) / (alt.max - alt.min)), ((alt.max - alt.mean) / (alt.max - alt.min))) / 0.5)

	if mg_earth.config.mg_lakes_enabled then
		get_lakes(minp, maxp)
	end
	
end

local function generate_3d_map(minp, maxp, seed)



end

local function generate_2d_roads(minp, maxp, area, data)

	if mg_earth.config.mg_roads == true then
		make_road(minp, maxp, area, data)
	end

	if mg_earth.config.mg_streets == true then
		make_street(minp, maxp, area, data)
	end

end


local data = {}

local function generate_map(minp, maxp, seed)

	-- Start time of mapchunk generation.
	local mg_timer = {}
	mg_timer["start"] = os.clock()

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local x_stride = area.xstride
	local y_stride = area.ystride -- Tip : the ystride of a VoxelArea is the number to add to the array index to get the index of the position above. It's faster because it avoids to completely recalculate the index.
	local z_stride = area.zstride

	--local csize = vector.add(vector.subtract(maxp, minp), 1)
	local chunk_size_half = abs((maxp.x - minp.x + 1) * 0.5)

	nobj_heatmap = nobj_heatmap or minetest.get_perlin_map(mg_earth.noise["np_heat"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_heatmap = nobj_heatmap:get_2d_map({x = minp.x, y = minp.z})

	nobj_heatblend = nobj_heatblend or minetest.get_perlin_map(mg_earth.noise["np_heat_blend"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_heatblend = nobj_heatblend:get_2d_map({x = minp.x, y = minp.z})

	nobj_humiditymap = nobj_humiditymap or minetest.get_perlin_map(mg_earth.noise["np_humid"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_humiditymap = nobj_humiditymap:get_2d_map({x = minp.x, y = minp.z})

	nobj_humidityblend = nobj_humidityblend or minetest.get_perlin_map(mg_earth.noise["np_humid_blend"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_humidityblend = nobj_humidityblend:get_2d_map({x = minp.x, y = minp.z})

	local r_schem = mg_earth.road_schem_3x1

	local write = false

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	mg_timer["preparation"] = os.clock()

	local chunk_rand = math.random(5,20)
	local chunk_rand_x = (20 - math.random(40))
	local chunk_rand_y = (20 - math.random(40))
	
	local boulder_form_types = {
		"boulder",
		"flat",
		"hoodoo",
		"none",
	}

	local index2d = 1
	local index3d = 1

----------------------------------------------------------------------
	generate_2dNoise_map(minp, maxp, seed)
----------------------------------------------------------------------


----------------------------------------------------------------------
	generate_3dNoise_map(minp, maxp, seed)
----------------------------------------------------------------------

	mg_timer["loop3D"] = os.clock()

	--2D HEIGHTMAP GENERATION
	index2d = 1
	index3d = 1

----------------------------------------------------------------------
	generate_2d_map(minp, maxp, seed, area)
----------------------------------------------------------------------

	
	mg_timer["loop2D"] = os.clock()
	print("Time elapsed: "..tostring( mg_timer["loop2D"] - mg_timer["loop3D"] ));

	index2d = 1
	index3d = 1
	-- y_terrain_height = -31000

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do

				local ivm = area:index(x, y, z)
				local ai = area:index(x,y+1,z) --above index
				local bi = area:index(x,y-1,z) --below index
				-- local xn = a:index(x-3,y,z) --below index
				-- local xp = a:index(x+3,y,z) --below index
				-- local zn = a:index(x,y,z-3) --below index
				-- local zp = a:index(x,y,z+3) --below index

				local write_3d = true
				--local write_3d = false

				local t_height				= mg_earth.heightmap[index2d]
				local t_biome				= mg_earth.biomemap[index2d]
				local t_eco					= mg_earth.eco_map[index2d]
				-- local t_river_map			= mg_earth.valleysrivermap[index2d] or (mg_earth.config.river_size_factor + 1)
				-- local t_river_map			= mg_earth.valleysrivermap[index2d]
				-- local t_river_map			= mg_earth.rivermap[index2d]
				local t_road				= mg_earth.roadmap[index2d]
				local t_road_height			= mg_earth.roadheight[index2d]
				local t_road_dir			= mg_earth.roaddirmap[index2d]
				local t_path				= mg_earth.pathmap[index2d]
				local t_path_height			= mg_earth.pathheight[index2d]
				local t_path_dir			= mg_earth.pathdirmap[index2d]

				local t_filldepth			= 4 + mg_earth.fillmap[index2d]
				local t_filldepth			= 4
				local t_top_depth			= 1
				local t_water_top_depth		= 1
				local t_riverbed_depth		= mg_earth.config.mg_river_size

				local t_ignore				= mg_earth.c_ignore
				local t_air					= mg_earth.c_air

				local t_top					= mg_earth.c_top
				local t_filler				= mg_earth.c_filler
				local t_stone				= mg_earth.c_stone
				local t_water				= mg_earth.c_water
				local t_water_top			= mg_earth.c_water_top
				local t_river				= mg_earth.c_river
				local t_riverbed			= mg_earth.c_river_bed

				local t_cave_liquid			= mg_earth.c_cave_liquid
				local t_dungeon				= mg_earth.c_dungeon
				local t_dungeon_alt			= mg_earth.c_dungeon_alt
				--local t_dungeon_stair				= mg_earth.c_brick

				local t_node				= t_ignore
				if data[ivm] == t_air then
					t_node					= t_air
				end

				t_stone						= mg_earth.biome_info[t_biome].b_stone or mg_earth.c_stone
				t_filler					= mg_earth.biome_info[t_biome].b_filler or mg_earth.c_filler
				t_top						= mg_earth.biome_info[t_biome].b_top or mg_earth.c_top
				t_water						= mg_earth.biome_info[t_biome].b_water or mg_earth.c_water
				t_water_top					= mg_earth.biome_info[t_biome].b_water_top or mg_earth.c_water_top
				t_water_top_depth			= mg_earth.biome_info[t_biome].b_water_top_depth or 1
				t_river						= mg_earth.biome_info[t_biome].b_river or mg_earth.c_river
				t_riverbed					= mg_earth.biome_info[t_biome].b_riverbed or mg_earth.c_river_bed
				t_riverbed_depth			= mg_earth.biome_info[t_biome].b_riverbed_depth or mg_earth.config.mg_river_size
				t_cave_liquid				= mg_earth.biome_info[t_biome].b_cave_liquid or mg_earth.c_cave_liquid
				t_dungeon					= mg_earth.biome_info[t_biome].b_dungeon or mg_earth.c_dungeon
				t_dungeon_alt				= mg_earth.biome_info[t_biome].b_dungeon_alt or mg_earth.c_dungeon_alt
				--t_dungeon_stair				= mg_earth.biome_info[t_biome].b_dungeon_stair

				local t_stone_height		= (t_height - (t_filldepth + t_top_depth))
				local t_fill_height			= (t_height - t_top_depth)


				if mg_earth.config.mg_ecosystems then

					if string.find(t_biome, "humid") or string.find(t_biome, "_temperate") or string.find(t_biome, "arid") then

						local t_alt = gal.get_altitude_zone({x = x, y = t_height, z = z})
						local soil_type_idx, soil_idx, top_type_idx, top_idx = unpack(t_eco)
						if gal.ecosystems[t_biome] then
							t_top, t_filler, t_stone = gal.get_ecosystem_data(t_biome, t_alt, soil_type_idx, soil_idx, top_type_idx, top_idx)
						end

					end

				end

				if mg_earth.cliffmap[index2d] > 0 then
					t_filler				= t_stone
				end

				if t_height > (mg_earth.config.max_highland + mg_earth.hh_mod[index2d]) then
					t_filler				= t_stone
					t_top					= t_stone
					--t_water					= t_water
					t_river					= mg_earth.c_ice
				end

				if t_height > (mg_earth.config.max_mountain + mg_earth.hh_mod[index2d]) then
					t_filler				= t_stone
					t_top					= mg_earth.c_snow
					t_water					= mg_earth.c_ice
					t_river					= mg_earth.c_ice
				end

				if mg_earth.config.mg_rivers_enabled then
					if mg_heightmap_select == "vEarth" or mg_heightmap_select == "vVoronoi" or mg_heightmap_select == "vVoronoiPlus" then
						local r_map = mg_earth.rivermap[index2d]
						local r_path = mg_earth.riverpath[index2d]
						local lf_map = mg_earth.lfmap[index2d]
						local lf_path = mg_earth.lfpath[index2d]
						local rf_map = mg_earth.rfmap[index2d]
						local rf_path = mg_earth.rfpath[index2d]
						if ((r_map >= 0) and (r_map <= r_path)) then
							if y >= (-mg_earth.valleymap[index2d] * 0.2) then
								--if (y >= ((t_height - ((t_filldepth + t_top_depth) * 2)) + r_map)) and (y < t_height) then
								if (y >= (t_height - mg_earth.valleymap[index2d])) and (y < t_height) then
									t_filler = t_river
									t_top = t_air
								else
									t_filler = t_riverbed
									t_top = t_riverbed
								end
							end
						end
					end

					if mg_heightmap_select == "vValleys" or mg_heightmap_select == "vValleys3D" then
					-- if mg_heightmap_select == "vValleys" then

						local t_river_map			= mg_earth.valleysrivermap[index2d]

						mg_earth.config.river_size_factor = (mg_earth.config.mg_river_size - (mg_earth.heightmap[index2d] / (40 * mg_world_scale))) / 100

						if t_river_map <= mg_earth.config.river_size_factor then
							if mg_earth.heightmap[index2d] >= (mg_water_level -1) then
								t_filldepth = t_riverbed_depth - (mg_earth.heightmap[index2d] / (75 * mg_world_scale))
							end
						end

						if y >= t_stone_height and y < t_fill_height then
							if t_river_map <= mg_earth.config.river_size_factor then
								if y > (mg_water_level - 1) then
									if y >= (mg_earth.heightmap[index2d] - ((t_filldepth - (t_riverbed_depth * 0.5)) + t_top_depth)) and y < (mg_earth.heightmap[index2d] - t_top_depth) then
										t_filler = t_river
									else
										t_filler = t_riverbed
									end
									if t_river_map >= (mg_earth.config.river_size_factor * 0.7) then
										t_filler = t_riverbed
									end
								end
							end
						elseif y >= t_fill_height and y <= mg_earth.heightmap[index2d] then
							if t_river_map <= mg_earth.config.river_size_factor then
								if y > mg_water_level then
									t_top = t_air
								else
									t_top = t_water
								end
							end
						end

					end

				end

				if mg_earth.config.mg_lakes_enabled then
					-- is there a hole?
					if( mg_earth.detected.holes_markmap[index2d] and mg_earth.detected.holes_markmap[index2d]>0) then
						if t_height <= mg_earth.detected.holes.merged[mg_earth.detected.holes_merge_into[mg_earth.detected.holes_markmap[index2d]]].target_height then
							t_filler = t_riverbed
							t_top = t_river
						end
					end
				end

				if mg_noise_select == "vStraight3D" then

					write_3d = false

					if mg_earth.densitymap[index3d] <= 0 then
						write_3d = true
					end
				end

				if mg_heightmap_select =="v5" then

					-- write_3d = false

					local density = mg_earth.densitymap[index3d]

					if density == false then
						-- write_3d = true
						write_3d = false
					end

					-- local factor = mg_earth.v5_factormap[index2d]
					-- local height = mg_earth.v5_heightmap[index2d]
					-- local ground = mg_earth.densitymap[index3d]

					-- if ((ground * factor) + height) >= y then
						-- write_3d = true
					-- end

									-- local den = mg_earth.densitymap[index3d]

									-- if den > 0 then -- If solid
										-- write_3d = true
									-- elseif y <= mg_water_level then
										-- if t_height <= mg_water_level then
											-- write_3d = true
										-- end
									-- end
				end

				if mg_heightmap_select == "vValleys3D" then

					write_3d = false
					
					local den = mg_earth.densitymap[index3d]

					if den > 0 then -- If solid
						write_3d = true
					elseif y <= mg_water_level then
						if t_height <= mg_water_level then
							write_3d = true
						end
					end
				end

				if mg_earth.config.mg_paths then

					if t_path >= 0 then

						local x_n, x_p, z_n, z_p
						local stride = (maxp.x - minp.x + 1)

						if x > (minp.x + 1) then
							if mg_earth.pathmap[index2d - 2] >= 0 then
								x_n = mg_earth.pathheight[index2d - 2]
							elseif mg_earth.pathmap[index2d - 1] >= 0 then
								x_n = mg_earth.pathheight[index2d - 1]
							else
								x_n = mg_earth.pathheight[index2d]
							end
						elseif x == (minp.x + 1) then
							if mg_earth.pathmap[index2d - 1] >= 0 then
								x_n = mg_earth.pathheight[index2d - 1]
							else
								x_n = mg_earth.pathheight[index2d]
							end
						else
							x_n = mg_earth.pathheight[index2d]
						end
						if x < (maxp.x - 1) then
							if mg_earth.pathmap[index2d + 2] >= 0 then
								x_p = mg_earth.pathheight[index2d + 2]
							elseif mg_earth.pathmap[index2d + 1] >= 0 then
								x_p = mg_earth.pathheight[index2d + 1]
							else
								x_p = mg_earth.pathheight[index2d]
							end
						elseif x == (maxp.x - 1) then
							if mg_earth.pathmap[index2d + 1] >= 0 then
								x_p = mg_earth.pathheight[index2d + 1]
							else
								x_p = mg_earth.pathheight[index2d]
							end
						else
							x_p = mg_earth.pathheight[index2d]
						end
						if z > (minp.z + 1) then
							if mg_earth.pathmap[index2d - (stride * 2)] >= 0 then
								z_n = mg_earth.pathheight[index2d - (stride * 2)]
							elseif mg_earth.pathmap[index2d - stride] >= 0 then
								z_n = mg_earth.pathheight[index2d - stride]
							else
								z_n = mg_earth.pathheight[index2d]
							end
						elseif z == (minp.z + 1) then
							if mg_earth.pathmap[index2d - stride] >= 0 then
								z_n = mg_earth.pathheight[index2d - stride]
							else
								z_n = mg_earth.pathheight[index2d]
							end
						else
							z_n = mg_earth.pathheight[index2d]
						end
						if z < (maxp.z - 1) then
							if mg_earth.pathmap[index2d + (stride * 2)] >= 0 then
								z_p = mg_earth.pathheight[index2d + (stride * 2)]
							elseif mg_earth.pathmap[index2d + stride] >= 0 then
								z_p = mg_earth.pathheight[index2d + stride]
							else
								z_p = mg_earth.pathheight[index2d]
							end
						elseif z == (maxp.z - 1) then
							if mg_earth.pathmap[index2d + stride] >= 0 then
								z_p = mg_earth.pathheight[index2d + stride]
							else
								z_p = mg_earth.pathheight[index2d]
							end
						else
							z_p = mg_earth.pathheight[index2d]
						end

						local x_height = floor(lerp(x_n, x_p, 0))
						local z_height = floor(lerp(z_n, z_p, 0))

						local new_height_choices = {
							floor((x_height + x_height) * 0.5),
							floor((z_height + z_height) * 0.5),
						}
						local new_height = new_height_choices[t_path_dir]

						t_path_height = new_height
						-- t_path_height = floor(lerp(x_height, z_height, 0))
						mg_earth.pathheight[index2d] = t_path_height

						if (t_height <= t_path_height) then
							if (t_height >= mg_earth.config.max_beach) then
								t_top = mg_earth.c_path
										-- if mg_earth.config.mg_rivers_enabled then
											-- if (mg_earth.rivermap[index2d] <= (mg_earth.riverpath[index2d]) + 1) then
												-- t_top = t_air
											-- else
												-- t_top = mg_earth.c_path
											-- end
										-- else
											-- t_top = mg_earth.c_path
										-- end
								if mg_earth.config.mg_rivers_enabled then
									if (mg_earth.rivermap[index2d] <= (mg_earth.riverpath[index2d]) + 1) then
										t_top = t_air
									end
								end
							end
						end
					end
				end

				if write_3d == true then
					if y < t_stone_height then
						t_node = t_stone
					elseif y >= t_stone_height and y < t_fill_height then
						t_node = t_filler
					elseif y >= t_fill_height and y <= t_height then
						t_node = t_top
					elseif y > t_height and y <= mg_water_level then
						--Water Level (Sea Level)
						if y > (mg_water_level - t_water_top_depth) then
							t_node = t_water_top
						else
							t_node = t_water
						end
					end
				end

				if mg_earth.config.mg_paths then
					if (t_path >= 0) then		-- and not mg_earth.config.mg_rivers_enabled
						if (t_height > t_path_height) and (y <= t_height) then
							if (t_height >= mg_earth.config.max_beach) then
								if y == t_path_height then
									t_node = mg_earth.c_path
									if mg_earth.config.mg_rivers_enabled then
										if (mg_earth.rivermap[index2d] <= (mg_earth.riverpath[index2d]) + 1) then
											t_node = t_air
										end
									end
								end
								if y == (t_path_height + ((mg_earth.config.mg_path_size * 2) + 1)) then
									t_node = mg_earth.c_path_sup
								end
								if (y > t_path_height) and (y < (t_path_height + ((mg_earth.config.mg_path_size * 2) + 1))) then
									t_node = t_air
									-- if (t_path > (mg_earth.config.mg_path_size + 1)) and (t_path < ((mg_earth.config.mg_path_size + 1) + 2)) then
										-- t_node = mg_earth.c_path_sup
									-- end
								end
								-- if (y > t_path_height) and (y < (t_path_height + (mg_earth.config.mg_path_size * 2))) then
									-- t_node = t_air
								-- end
							end
						end							
					end
				end


				if mg_earth.config.mg_boulders then
					if y == t_height then
						if (data[bi] == t_top or data[bi] == t_filler or data[bi] == t_stone) and (data[bi] ~= t_water_top or data[bi] ~= t_water and data[bi] ~= t_air or data[bi] ~= t_ignore) then
							-- local ch_dist_x = abs(mg_earth.center_of_chunk.x - x)
							-- local ch_dist_z = abs(mg_earth.center_of_chunk.z - z)
							-- if (y == t_height) and (((chunk_size_half / 2) > ch_dist_x) and ((chunk_size_half / 2) > ch_dist_z)) then
							-- if (y == t_height) then
								if math.random(100000) <= 1 then
									-- local boulder_form = boulder_form_types[math.random(1,4)]
									make_boulder({x=x,y=y,z=z},area,data,"flat",t_stone)
									-- make_boulder({x=x,y=t_height,z=z},area,data,boulder_form,t_stone)
								end
							-- end
						end
					end
				end

				if mg_earth.config.mg_caves_enabled then

					-- if mg_earth.config.mg_rivers_enabled and (mg_earth.rivermap[index2d] > mg_earth.config.mg_valley_size) then

						local taper_height_min = 8
						local taper_height = max(0,min(1,(max(0,min(taper_height_min,(t_height - y))) / taper_height_min)))

						local cave_1 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height))
						local cave_2 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height))

						if mg_earth.config.mg_rivers_enabled then
							local taper_river_min = mg_earth.config.mg_river_size
							local taper_river = max(0,min(1,(max(0,min(taper_river_min,(mg_earth.rivermap[index2d] + taper_river_min))) / taper_river_min)))

							cave_1 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height)) * max(0,min(1,taper_river))
							cave_2 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height)) * max(0,min(1,taper_river))
						end


							---- if (cave_1 * cave_2) > mg_cave_width then
							----if (cave_1 * cave_2) > (mg_cave_thresh / mg_cave_width) then
							-- if (cave_1 * cave_2) > 9.65 then
							--if (cave_1 + cave_2) > 9.65 then
							--if (cave_1 * mg_cave_width) == (cave_2 * mg_cave_width) then
							--if (cave_1 * mg_cave_width) > (cave_2 * mg_cave_width) then
						-- if ((cave_1 * mg_cave_width) + (cave_2 * mg_cave_width)) > mg_cave_thresh then
						-- if ((cave_1 * cave_2) * mg_cave_width) > mg_cave_thresh then
						if ((cave_1 + cave_2) * mg_cave_width) > mg_cave_thresh then
							--if cave_1 == cave_2 then
							if t_height < mg_water_level then
								if y <= mg_water_level then
									if y > (mg_water_level - t_water_top_depth) then
										t_node = t_water_top
									else
										t_node = t_water
									end
								else
									t_node = t_ignore
								end
							else
								t_node = t_ignore
							end
							if (write_3d == false) and (y <= mg_water_level) and ((t_node == t_ignore) or (t_node == t_air)) then
								t_node = t_water
							end


							--ceiling
							if (data[bi] == t_air or data[bi] == t_ignore) and t_node == t_stone then --ceiling
								-- t_node = t_dungeon
								if math.random() < 0.01 then
									-- t_node = t_dungeon_alt
									t_node = t_dungeon
								end
							end
							--ground
							if data[bi] == t_stone and (t_node == t_air or t_node == t_ignore) then --ground
								-- data[bi] = t_dungeon
								if math.random() < 0.01 then
									-- data[bi] = t_dungeon_alt
									data[bi] = t_dungeon
								end
							end
						end

					-- end

				end

				if mg_earth.config.mg_caverns_enabled then
					if (y <= t_height) then

						local tcave1
						local tcave2

						local yblmax1 = t_height - BLEND * 1.5

						if y < yblmin then
							tcave1 = mg_cave_thresh1 + ((yblmin - y) / BLEND) ^ 2
							tcave2 = mg_cave_thresh2 + ((yblmin - y) / BLEND) ^ 2
						elseif y > yblmax1 then
							tcave1 = mg_cave_thresh1 + ((y - yblmax1) / BLEND) ^ 2
							tcave2 = mg_cave_thresh2 + ((y - yblmax2) / BLEND) ^ 2
						elseif y > yblmax2 then
							tcave1 = mg_cave_thresh1 + ((y - yblmax1) / BLEND) ^ 2
							tcave2 = mg_cave_thresh2 + ((y - yblmax2) / BLEND) ^ 2
						else
							tcave1 = mg_cave_thresh1
							tcave2 = mg_cave_thresh2
						end

						local ncavern1 = mg_earth.cavern1map[index3d]
						local ncavern2 = mg_earth.cavern2map[index3d]
						local nwave = mg_earth.cavernwavemap[index3d]

						if (ncavern1 + nwave)/2 > tcave1 then --if node falls within cave threshold
							t_node = t_ignore
						end
						if (ncavern2 + nwave)/2 > tcave2 then --if node falls within cave threshold
							t_node = t_cave_liquid
						end

						--ceiling
						if (data[bi] == t_air or data[bi] == t_ignore) and t_node == t_stone then --ceiling
							t_node = t_dungeon
							if math.random() < 0.01 then
								t_node = t_dungeon_alt
							end
						end
						--ground
						if data[bi] == t_stone and (t_node == t_air or t_node == t_ignore) then --ground
							data[bi] = t_dungeon
							if math.random() < 0.01 then
								data[bi] = t_dungeon_alt
							end
						end
					end
				end
			
				if mg_heightmap_select == "vSpheres" or mg_heightmap_select == "vCubes" or mg_heightmap_select == "vDiamonds" or mg_heightmap_select == "vPlanetoids" or mg_heightmap_select == "vPlanets" or mg_heightmap_select == "vSolarSystem" or mg_heightmap_select == "vVoronoiCell" or mg_heightmap_select == "vRand3D" then

					if mg_heightmap_select == "vSpheres" or mg_heightmap_select == "vCubes" or mg_heightmap_select == "vDiamonds" then

						local platform = 0
						if mg_heightmap_select == "vSpheres" then
							--euclidean
							platform = (((x - mg_earth.chunk_center_rand.x) * (x - mg_earth.chunk_center_rand.x)) + ((y - mg_earth.chunk_center_rand.y) * (y - mg_earth.chunk_center_rand.y)) + ((z - mg_earth.chunk_center_rand.z) * (z - mg_earth.chunk_center_rand.z)))^0.5
						end

						if mg_heightmap_select == "vDiamonds" then
							--manhattan
							platform = (abs(x-mg_earth.chunk_center_rand.x) + abs(y-mg_earth.chunk_center_rand.y) + abs(z-mg_earth.chunk_center_rand.z))
						end

						if mg_heightmap_select == "vCubes" then
							--chebyshev
							platform = (max(abs(x-mg_earth.chunk_center_rand.x), max(abs(y-mg_earth.chunk_center_rand.y), abs(z-mg_earth.chunk_center_rand.z))))
						end

						if platform <= chunk_rand then
							if y == (10 + chunk_rand) then
								t_node = t_top
							elseif y < (10 + chunk_rand) and y >= (5 + chunk_rand) then
								t_node = t_filler
							elseif y < (5 + chunk_rand) and y >= (-15 + chunk_rand) then
								t_node = t_stone
							end
						else
							t_node = t_ignore
						end
					end

					if mg_heightmap_select == "vPlanetoids" then
						local platform = (((x - mg_earth.chunk_center_rand.x) * (x - mg_earth.chunk_center_rand.x)) + ((y - mg_earth.chunk_center_rand.y) * (y - mg_earth.chunk_center_rand.y)) + ((z - mg_earth.chunk_center_rand.z) * (z - mg_earth.chunk_center_rand.z)))^0.5
						if platform <= chunk_rand and platform >= (chunk_rand - 1) then
							t_node = t_top
						elseif platform < (chunk_rand - 1) and platform >= ((chunk_rand - 1) - t_filldepth) then
							t_node = t_filler
						elseif platform < ((chunk_rand - 1) - t_filldepth) then
							t_node = t_stone
						else
							t_node = t_ignore
						end
					end

					if mg_heightmap_select == "vPlanets" then
					
						local m = {}

						m.m_idx, m.m_dist, m.m_z, m.m_y, m.m_x = get_nearest_3D_cell({x = x, y = y, z = z}, 1)
						get_cell_3D_neighbors(m.m_idx, m.m_z, m.m_y, m.m_x, 1)

						local m_n = mg_neighbors[m.m_idx]
						local m_ni = get_farthest_3D_neighbor({x = m.m_x, y = m.m_y, z = m.m_z}, m_n)

						local m2e_dist = get_3d_dist((m.m_x - m_n[m_ni].n_x), (m.m_y - m_n[m_ni].n_y), (m.m_z - m_n[m_ni].n_z), "e") * 0.1

						--MASTER CELLS
						local platform = get_3d_dist((x - m.m_x),(y - m.m_y),(z - m.m_z),"e")

						if platform <= m2e_dist and platform >= (m2e_dist - 1) then
							t_node = t_top
						elseif platform < (m2e_dist - 1) and platform >= ((m2e_dist - 1) - t_filldepth) then
							t_node = t_filler
						elseif platform < ((m2e_dist - 1) - t_filldepth) then
							t_node = t_stone
						else
							t_node = t_ignore
						end

					end

					if mg_heightmap_select == "vSolarSystem" then
					
						local m = {}

						m.m_idx, m.m_dist, m.m_z, m.m_y, m.m_x = get_nearest_3D_cell({x = x, y = y, z = z}, 1)
							-- get_cell_3D_neighbors(m.m_idx, m.m_z, m.m_y, m.m_x, 1)

							-- local m_n = mg_neighbors[m.m_idx]
							-- local m_ni = get_farthest_3D_neighbor({x = m.m_x, y = m.m_y, z = m.m_z}, m_n)

						-- --MASTER CELLS
						local orbital_dist = get_3d_dist((x - m.m_x),(y - m.m_y),(z - m.m_z),"e")
							-- local m2e_dist = get_3d_dist((m.m_x - m_n[m_ni].n_x), (m.m_y - m_n[m_ni].n_y), (m.m_z - m_n[m_ni].n_z), "e") * 0.1
						local planet_size = 0
						local m2e_dist = 0
						local ring_size = 0
						local ring_gap = 0
						local moon_orbit = 0
						
--[[
						local platform = 0
						local m2e_dist = 0

						if (get_3d_dist((x - (mg_points[1][4]) * mg_world_scale),(y - 0),(z - (mg_points[1][2] * mg_world_scale)),"e") <= (4320 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[1][4] * mg_world_scale)),(y - 0),(z - (mg_points[1][2] * mg_world_scale)),"e")
							m2e_dist = (4320 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[2][4] * mg_world_scale)),(y - 0),(z - (mg_points[2][2] * mg_world_scale)),"e") <= (20 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[2][4] * mg_world_scale)),(y - 0),(z - (mg_points[2][2] * mg_world_scale)),"e")
							m2e_dist = (20 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[3][4] * mg_world_scale)),(y - 0),(z - (mg_points[3][2] * mg_world_scale)),"e") <= (60 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[3][4] * mg_world_scale)),(y - 0),(z - (mg_points[3][2] * mg_world_scale)),"e")
							m2e_dist = (60 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[4][4] * mg_world_scale)),(y - 0),(z - (mg_points[4][2] * mg_world_scale)),"e") <= (70 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[4][4] * mg_world_scale)),(y - 0),(z - (mg_points[4][2] * mg_world_scale)),"e")
							m2e_dist = (70 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[5][4] * mg_world_scale)),(y - 0),(z - (mg_points[5][2] * mg_world_scale)),"e") <= (40 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[5][4] * mg_world_scale)),(y - 0),(z - (mg_points[5][2] * mg_world_scale)),"e")
							m2e_dist = (40 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[6][4] * mg_world_scale)),(y - 0),(z - (mg_points[6][2] * mg_world_scale)),"e") <= (710 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[6][4] * mg_world_scale)),(y - 0),(z - (mg_points[6][2] * mg_world_scale)),"e")
							m2e_dist = (710 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[7][4] * mg_world_scale)),(y - 0),(z - (mg_points[7][2] * mg_world_scale)),"e") <= (580 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[7][4] * mg_world_scale)),(y - 0),(z - (mg_points[7][2] * mg_world_scale)),"e")
							m2e_dist = (580 * mg_world_scale)
							if (y == 0) then
								if (get_3d_dist((x - (mg_points[7][4] * mg_world_scale)),(y - 0),(z - (mg_points[7][2] * mg_world_scale)),"e") >= (680 * mg_world_scale)) and (get_3d_dist((x - (mg_points[7][4] * mg_world_scale)),(y - 0),(z - (mg_points[7][2] * mg_world_scale)),"e") <= (860 * mg_world_scale)) then
									platform = get_3d_dist((x - (mg_points[7][4] * mg_world_scale)),(y - 0),(z - (mg_points[7][2] * mg_world_scale)),"e")
									m2e_dist = (platform * mg_world_scale)
								end
							end
						end
						
						if (get_3d_dist((x - (mg_points[8][4] * mg_world_scale)),(y - 0),(z - (mg_points[8][2] * mg_world_scale)),"e") <= (250 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[8][4] * mg_world_scale)),(y - 0),(z - (mg_points[8][2] * mg_world_scale)),"e")
							m2e_dist = (250 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[9][4] * mg_world_scale)),(y - 0),(z - (mg_points[9][2] * mg_world_scale)),"e") <= (240 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[9][4] * mg_world_scale)),(y - 0),(z - (mg_points[9][2] * mg_world_scale)),"e")
							m2e_dist = (240 * mg_world_scale)
						end
						
						if (get_3d_dist((x - (mg_points[10][4] * mg_world_scale)),(y - 0),(z - (mg_points[10][2] * mg_world_scale)),"e") <= (10 * mg_world_scale)) then
							platform = get_3d_dist((x - (mg_points[10][4] * mg_world_scale)),(y - 0),(z - (mg_points[10][2] * mg_world_scale)),"e")
							m2e_dist = (10 * mg_world_scale)
						end
--]]
--
						if m.m_idx == 1 then
							planet_size = 432
							t_top = mg_earth.c_sun
						elseif m.m_idx == 2 then
							planet_size = 2
							t_top = mg_earth.c_mercury
							if get_3d_dist((x - (mg_points[1][4]) * mg_world_scale),(y - 0),(z - (mg_points[1][2] * mg_world_scale)),"e") <= 432 then
								planet_size = 432
								t_top = mg_earth.c_sun
							end
						elseif m.m_idx == 3 then
							planet_size = 6
							t_top = mg_earth.c_venus
						elseif m.m_idx == 4 then
							planet_size = 7
							t_top = mg_earth.c_earth
						elseif m.m_idx == 5 then
							planet_size = 4
							t_top = mg_earth.c_mars
						elseif m.m_idx == 6 then
							planet_size = 71
							t_top = mg_earth.c_jupiter
						elseif m.m_idx == 7 then
							planet_size = 58
							t_top = mg_earth.c_saturn
							-- if (y >= -1) and (y <= 1) then
								-- if (orbital_dist >= 68) and (orbital_dist <= 86) then
									-- planet_size = (orbital_dist * mg_world_scale)
									-- t_top = mg_earth.c_saturn_rings
								-- end
							-- end
							ring_size = 48
							ring_gap = 12
						elseif m.m_idx == 8 then
							planet_size = 25
							t_top = mg_earth.c_uranus
						elseif m.m_idx == 9 then
							planet_size = 24
							t_top = mg_earth.c_neptune
						elseif m.m_idx == 10 then
							planet_size = 1
							t_top = mg_earth.c_pluto
						end
--

						if orbital_dist <= (ring_size + ring_gap + planet_size) and orbital_dist >= (ring_gap + planet_size) then
							if (y > -1) and (y < 1) then
								t_node = mg_earth.c_saturn_rings
							else
								t_node = t_ignore
							end
						elseif orbital_dist < (ring_gap + planet_size) and orbital_dist >= planet_size then
							t_node = t_ignore
						elseif orbital_dist < planet_size and orbital_dist >= (planet_size - 1) then
							t_node = t_top
						elseif orbital_dist < (planet_size - 1) and orbital_dist >= ((planet_size - 1) - t_filldepth) then
							t_node = t_filler
						elseif orbital_dist < ((planet_size - 1) - t_filldepth) then
							t_node = t_stone
						else
							t_node = t_ignore
						end

					end

					if mg_heightmap_select == "vVoronoiCell" then

						if y < 32 then

							local chunk_points = {
								{x=mg_earth.chunk_points[1].x,			y=mg_earth.chunk_points[1].y,		z=mg_earth.chunk_points[1].z},
								{x=mg_earth.chunk_points[3].x,			y=mg_earth.chunk_points[3].y,		z=mg_earth.chunk_points[3].z},
								{x=mg_earth.chunk_points[5].x,			y=mg_earth.chunk_points[5].y,		z=mg_earth.chunk_points[5].z},
								{x=mg_earth.chunk_points[7].x,			y=mg_earth.chunk_points[7].y,		z=mg_earth.chunk_points[7].z},
								{x=mg_earth.chunk_points[9].x,			y=mg_earth.chunk_points[9].y,		z=mg_earth.chunk_points[9].z},
								{x=mg_earth.chunk_points[11].x,			y=mg_earth.chunk_points[11].y,		z=mg_earth.chunk_points[11].z},
								{x=mg_earth.chunk_points[13].x,			y=mg_earth.chunk_points[13].y,		z=mg_earth.chunk_points[13].z},
								{x=mg_earth.chunk_center_rand.x,		y=mg_earth.chunk_center_rand.y,		z=mg_earth.chunk_center_rand.z},
								{x=mg_earth.chunk_points[15].x,			y=mg_earth.chunk_points[15].y,		z=mg_earth.chunk_points[15].z},
								{x=mg_earth.chunk_points[17].x,			y=mg_earth.chunk_points[17].y,		z=mg_earth.chunk_points[17].z},
								{x=mg_earth.chunk_points[19].x,			y=mg_earth.chunk_points[19].y,		z=mg_earth.chunk_points[19].z},
								{x=mg_earth.chunk_points[21].x,			y=mg_earth.chunk_points[21].y,		z=mg_earth.chunk_points[21].z},
								{x=mg_earth.chunk_points[23].x,			y=mg_earth.chunk_points[23].y,		z=mg_earth.chunk_points[23].z},
								{x=mg_earth.chunk_points[25].x,			y=mg_earth.chunk_points[25].y,		z=mg_earth.chunk_points[25].z},
								{x=mg_earth.chunk_points[27].x,			y=mg_earth.chunk_points[27].y,		z=mg_earth.chunk_points[27].z},
							}

							local thisidx
							local thisdist
							local last
							local this
							for i, point in ipairs(chunk_points) do
							
								this = get_3d_dist((x - point.x),(y - point.y),(z - point.z),dist_metric)

								if last then
									if last > this then
										last = this
										thisidx = i
										thisdist = this
									elseif last == this then
										thisidx = i
										thisdist = this
									end
								else
									last = this
									thisidx = i
									thisdist = this
								end
							end

							if thisidx == 8 then
								if y == (10 + chunk_rand) then
									t_node = t_top
								elseif y < (10 + chunk_rand) and y >= (5 + chunk_rand) then
									t_node = t_filler
								elseif y < (5 + chunk_rand) then
									t_node = t_stone
								else
									t_node = t_ignore
								end
							else
								t_node = t_ignore
							end
						end
					end

					if mg_heightmap_select == "vRand2D" then

						-- t_node = t_ignore
						
						-- local n = {}

										-- --n["n_2d_base"] = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_2d({x = x, y = z})
										-- -- n["n_2d_alt"] = minetest.get_perlin(mg_earth.noise["np_2d_alt"]):get_2d({x = x, y = z})
										-- -- n["n_2d_sin"] = minetest.get_perlin(mg_earth.noise["np_2d_sin"]):get_2d({x = x, y = z})
										-- --mg_earth.chunk_terrain["C"] = {x=mg_earth.center_of_chunk.x,	y=t_y,		z=mg_earth.center_of_chunk.z}

						local m = {}
						m["m_idx"], m["m_z"], m["m_x"], m["m_t"] = unpack(mg_points[mg_earth.cellmap[index2d].m])
						local p = {}
						p["p_idx"], p["p_z"], p["p_x"], p["p_t"] = unpack(mg_points[mg_earth.cellmap[index2d].p])
								-- -- -- p["p_idx"], p["p_dist"], p["p_z"], p["p_x"] = get_nearest_cell({x = x, z = z}, 2)
								-- -- -- get_cell_neighbors(p.p_idx, p.p_z, p.p_x, 2)
						
						
								-- m["m_dist"] = get_dist(((m.m_x * mg_world_scale) - x), ((m.m_z * mg_world_scale) - z), dist_metric)
								-- p["p_dist"] = get_dist(((p.p_x * mg_world_scale) - x), ((p.p_z * mg_world_scale) - z), dist_metric)
						
						
								-- local m_n = mg_neighbors[m.m_idx]
								-- --local m_ni = get_farthest_neighbor({x = m.m_x, z = m.m_z}, m_n)
								-- local m_ni = get_nearest_neighbor({x = x, z = z}, m_n)
								-- local p_n = mg_neighbors[p.p_idx]
								-- local p_ni = get_nearest_neighbor({x = x, z = z}, p_n)
						

						local d = {}

								-- d["me_dist"] = get_dist2endline_inverse({x = (m.m_x * mg_world_scale), z = (m.m_z * mg_world_scale)}, {x = m_n[m_ni].m_x, z = m_n[m_ni].m_z}, {x = x, z = z})
								-- d["pe_dist"] = get_dist2endline_inverse({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = x, z = z})
						d["mn_dist"] = get_dist2endline_inverse({x = (m.m_x * mg_world_scale), z = (m.m_z * mg_world_scale)}, {x = m_n[m_ni].m_x, z = m_n[m_ni].m_z}, {x = x, z = z})
						d["pn_dist"] = get_dist2endline_inverse({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = x, z = z})
								-- -- d["p2e_dist"] = get_dist(((p.p_x * mg_world_scale) - p_n[p_ni].m_x), ((p.p_z * mg_world_scale) - p_n[p_ni].m_z), dist_metric)
								-- -- d["n2pe_dist"] = get_dist2line({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)}, {x = p_n[p_ni].n_x, z = p_n[p_ni].n_z}, {x = x, z = z})
								-- -- d["pe_dir"], d["pe_comp"] = get_direction_to_pos({x = x, z = z},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})
								-- -- d["e_slope"] = get_slope_inverse({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})


										-- d["pe_dist"] = get_dist2endline_inverse({x = -100, z = -100}, {x = 100, z = 100}, {x = x, z = z})
										-- d["p2e_dist"] = get_dist((-100 - 100), (-100 - 100), "e")
										-- d["n2pe_dist"] = get_dist2line({x = -100, z = -100}, {x = 100, z = 100}, {x = x, z = z})
										-- d["pe_dir"], d["pe_comp"] = get_direction_to_pos({x = x, z = z},{x = 100, z = 100})
										-- d["e_slope"] = get_slope_inverse({x = -100, z = -100},{x = 100, z = 100})


										--d["n2pe_dist"] = get_dist2line({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)}, {x = p_n[p_ni].n_x, z = p_n[p_ni].n_z}, {x = x, z = z})


						if y == 5 then
							-- t_node = t_top
							if d.mn_dist < 2 then
								t_node = t_stone
							end
							if d.pn_dist < 2 then
								t_node = t_filler
							end
							if m.m_dist < 1 then
								t_node = t_stone
								-- if (data[bi] == t_top or data[bi] == t_filler or data[bi] == t_stone) and (data[bi] ~= t_water_top or data[bi] ~= t_water and data[bi] ~= t_air or data[bi] ~= t_ignore) then
									-- make_boulder({x=x,y=y,z=z},a,data,"flat",t_stone)
								-- end
							end
							if p.p_dist < 1 then
								t_node = t_filler
								-- if (data[bi] == t_top or data[bi] == t_filler or data[bi] == t_stone) and (data[bi] ~= t_water_top or data[bi] ~= t_water and data[bi] ~= t_air or data[bi] ~= t_ignore) then
									-- make_boulder({x=x,y=y,z=z},a,data,"flat",t_filler)
								-- end
							end
						end


													-- if (y > (5 - (t_filldepth + t_top_depth))) and (y <= (5 - t_top_depth)) then
														-- t_node = t_filler
													-- end
													-- if (y <= (5 - (t_filldepth + t_top_depth))) then
														-- t_node = t_stone
													-- end


															-- --v2d_base_max_height = max_height(mg_earth.noise["np_2d_base"])
															-- --local n_f = minetest.get_perlin(mg_earth.noise["np_2d_base"]):get_3d({x = x, y = y, z = z})
													-- local n_f = minetest.get_perlin(np_3dterrain):get_3d({x = x, y = y, z = z})
														-- --if (n_f + ((1 - y) / mg_density)) <= 0 then
													-- if n_f == 0 then
														-- -- t_node = t_ignore
														-- t_node = t_stone
													-- else
														-- -- t_node = t_stone
														-- t_node = t_ignore
													-- end

													-- if y <= n.n_2d_base then
														-- -- -- if sin(x) > sin(z) then
															-- -- -- -- t_node = t_ignore
															-- -- -- t_node = t_stone
														-- -- -- end
														-- t_node = t_stone
														-- -- if d.pe_dist <= mg_earth.config.mg_river_size then
															-- -- t_node = t_top
														-- -- end
													-- elseif y == n.n_2d_base then
														-- t_node = t_top
													-- end
													

													-- if y == 1 then
														-- if sin(x) > sin(z) then
															-- t_node = t_stone
														-- end
														-- if z < ((x) * 10) then
															-- t_node = t_stone
														-- end
														-- if sin(x + z) <= n["n_2d_base"] then
															-- t_node = t_stone
														-- end
													-- end
													

													-- local n_f = minetest.get_perlin(np_3dterrain):get_3d({x = x, y = y, z = z})
													-- if n_f == 0 then
														-- t_node = t_stone
													-- else
														-- t_node = t_ignore
													-- end

					end

					if mg_heightmap_select == "vRand3D" then

						local n_2d_val = minetest.get_perlin(mg_earth.noise["np_3dterrain"]):get_2d({x = x, y = z})
						local n_3d_val = minetest.get_perlin(mg_earth.noise["np_3dterrain"]):get_3d({x=x,y=y,z=z})

						if n_3d_val <= 0 then
							if y <= mg_water_level then
								if y > (mg_water_level - t_water_top_depth) then
									t_node = t_water_top
								else
									t_node = t_water
								end
							else
								t_node = t_ignore
							end
						end
					end

					if mg_heightmap_select == "vRand3D_01" then

						t_node = t_ignore

						local m = {}
						local p = {}

						m.m_idx, m.m_dist, m.m_z, m.m_y, m.m_x = get_nearest_3D_cell({x = x, y = y, z = z}, 1)
						get_cell_3D_neighbors(m.m_idx, m.m_z, m.m_y, m.m_x, 1)
						-- p.p_idx, p.p_dist, p.p_z, p.p_y, p.p_x = get_nearest_3D_cell({x = x, y = y, z = z}, 2)
						-- get_cell_3D_neighbors(p.p_idx, p.pz, p.p_y, p.p_x, 2)

						-- m.m_n = mg_neighbors[m.m_idx]
						-- m.m_ni = get_nearest_3D_neighbor({x = m.m_x, y = m.m_y, z = m.m_z}, m.m_n)
						-- p.p_n = mg_neighbors[p.p_idx]
						-- p.p_ni = get_nearest_3D_neighbor({x = p.p_x, y = p.p_y, z = p.p_z}, p.p_n)


						-- local vcontinental = ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
						local vcontinental = (m.m_dist * mg_earth.config.v_cscale)
						-- local vbase = (mg_base_height * 1.4) - ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
						local vbase = (mg_base_height * 1.4) - (m.m_dist * mg_earth.config.v_cscale)
						local valt = (vbase / vcontinental) * (mg_world_scale / 0.01)
						local vterrain = (vbase * 0.3) + (valt * 0.35)

						-- local d = {}
						-- d["mn_dist"] = get_3d_dist((m.m_x - m.m_n[m.m_ni].n_x), (m.m_y - m.m_n[m.m_ni].n_y), (m.m_z - m.m_n[m.m_ni].n_z), dist_metric) * 0.1
						-- d["pn_dist"] = get_3d_dist((p.p_x - p.p_n[p.p_ni].n_x), (p.p_y - p.p_n[p.p_ni].n_y), (p.p_z - p.p_n[p.p_ni].n_z), dist_metric) * 0.1

								-- d["me_dist"] = get_dist2endline_inverse({x = (m.m_x * mg_world_scale), z = (m.m_z * mg_world_scale)}, {x = m_n[m_ni].m_x, z = m_n[m_ni].m_z}, {x = x, z = z})
								-- d["pe_dist"] = get_dist2endline_inverse({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = x, z = z})
								-- -- d["p2e_dist"] = get_dist(((p.p_x * mg_world_scale) - p_n[p_ni].m_x), ((p.p_z * mg_world_scale) - p_n[p_ni].m_z), dist_metric)
								-- -- d["n2pe_dist"] = get_dist2line({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)}, {x = p_n[p_ni].n_x, z = p_n[p_ni].n_z}, {x = x, z = z})
								-- -- d["pe_dir"], d["pe_comp"] = get_direction_to_pos({x = x, z = z},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})
								-- -- d["e_slope"] = get_slope_inverse({x = (p.p_x * mg_world_scale), z = (p.p_z * mg_world_scale)},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})

						if y < vterrain then
							if (y <= (vterrain - 6)) then
								t_node = t_stone
							end
							if (y > (vterrain - 6)) and (y < (vterrain - 1)) then
								t_node = t_filler
							end
							if (y > (vterrain - 1)) then
								t_node = t_top
							end
							if (y < mg_water_level) then
								t_node = t_water
							end
						end

						-- if y == 5 then
							-- t_node = t_top
							-- if d.mn_dist < 2 then
								-- t_node = t_stone
							-- end
							-- if d.pn_dist < 2 then
								-- t_node = t_filler
							-- end
							-- if m.m_dist < 1 then
								-- t_node = t_stone
								-- -- if (data[bi] == t_top or data[bi] == t_filler or data[bi] == t_stone) and (data[bi] ~= t_water_top or data[bi] ~= t_water and data[bi] ~= t_air or data[bi] ~= t_ignore) then
									-- -- make_boulder({x=x,y=y,z=z},a,data,"flat",t_stone)
								-- -- end
							-- end
							-- if p.p_dist < 1 then
								-- t_node = t_filler
								-- -- if (data[bi] == t_top or data[bi] == t_filler or data[bi] == t_stone) and (data[bi] ~= t_water_top or data[bi] ~= t_water and data[bi] ~= t_air or data[bi] ~= t_ignore) then
									-- -- make_boulder({x=x,y=y,z=z},a,data,"flat",t_filler)
								-- -- end
							-- end
						-- end

					end

				end
				
				if mg_noise_select == "v3D" or mg_heightmap_select == "v3D" or mg_heightmap_select == "v5" or mg_heightmap_select == "vValleys3D" or mg_heightmap_select == "vStraight3D" then

					if mg_noise_select == "v3D" then

									--local n_f = 0

									-- if mg_world_scale == 1 then
										-- n_f = nbuf_3dterrain[z-minp.z+1][y-minp.y+1][x-minp.x+1]
									-- else
										-- n_f = minetest.get_perlin(np_3dterrain):get_3d({x = x, y = y, z = z})
									-- end

									-- local taper_min = (t_height - 4)
									-- local taper = 0

									-- taper = max(0,min(1,(max(0,min(4,(t_height - y))) / 4)))
									-- -- * max(0,min(1,taper))
									
									--local taper = (t_height - 8) / 8)
--						local taper = sin(min(0,max(4,abs(t_height - y))))

						local taper_height_min = 8
						local taper_height = max(0,min(1,(max(0,min(taper_height_min,((t_height + (taper_height_min * 0.5)) - y))) / taper_height_min)))
						-- * max(0,min(1,taper_height))

									--local density = mg_earth.densitymap[index3d] * (1 - max(0,min(1,taper)))
									-- local density = mg_earth.densitymap[index3d] * max(0,min(1,taper))
									--local density = mg_earth.densitymap[index3d] + (1 - taper)
									-- local density = mg_earth.densitymap[index3d] + taper


						local n_f = mg_earth.densitymap[index3d]

						local density = (n_f + ((1 - y) / (v3d_noise_density * mg_world_scale)))
									-- local density = (n_f + ((1 - (y + taper)) / (v3d_noise_density * mg_world_scale)))
									-- local density = (n_f + (t_height - taper)) / (v3d_noise_density * mg_world_scale)
									--local density = (n_f + (t_height - y)) / (v3d_noise_density * mg_world_scale)
--						local density = (n_f + taper) / (v3d_noise_density * mg_world_scale)

--						if density <= 0 then
--						if (density + (1.5 - max(0,min(1,taper_height)))) <= 0 then
						if (density + (2.0 - max(0,min(1,taper_height)))) <= 0 then
--						if (density + (t_height - max(0,min(1,taper_height)))) <= 0 then
							if t_height < (mg_water_level + 1) then
								if y <= mg_water_level then
									if y > (mg_water_level - t_water_top_depth) then
										t_node = t_water_top
									else
										t_node = t_water
									end
								else
									t_node = t_ignore
								end
							else
								t_node = t_ignore
							end

								-- if (write_3d == false) and (y <= mg_water_level) and ((t_node == t_ignore) or (t_node == t_air)) then
									-- t_node = t_water
								-- end

								-- if y <= mg_water_level then
									-- if y > (mg_water_level - t_water_top_depth) then
										-- t_node = t_water_top
									-- else
										-- t_node = t_water
									-- end
								-- else
									-- --if abs(t_height - y) < 8 then
										-- t_node = t_ignore
									-- --end
								-- end
						end
					end

					if mg_heightmap_select == "v3D" then

						local density = mg_earth.densitymap[index3d]

						if density <= 0 then
							if y <= mg_water_level then
								if y > (mg_water_level - t_water_top_depth) then
									t_node = t_water_top
								else
									t_node = t_water
								end
							else
								t_node = t_ignore
							end
						end
					end

					if mg_noise_select == "vStraight3D" then

						if mg_earth.densitymap[index3d] <= 0 then
							if y <= mg_water_level then
								if y > (mg_water_level - t_water_top_depth) then
									t_node = t_water_top
								else
									t_node = t_water
								end
							else
								t_node = t_ignore
							end
						end
					end

					if mg_heightmap_select =="v5" then

						-- local factor = mg_earth.v5_factormap[index2d]
						-- local height = mg_earth.v5_heightmap[index2d]
						-- local ground = mg_earth.densitymap[index3d]
						
						-- if ((ground * factor) + height) <= y then
							-- if y <= mg_water_level then
								-- if y > (mg_water_level - t_water_top_depth) then
									-- t_node = t_water_top
								-- else
									-- t_node = t_water
								-- end
							-- else
								-- t_node = t_ignore
							-- end
						-- end


												-- local factor = mg_earth.v5_factormap[index2d]
												-- local height = mg_earth.v5_heightmap[index2d]
												-- local ground = mg_earth.densitymap[index3d]
						local density = mg_earth.densitymap[index3d]

						if density == false then
							if y <= mg_water_level then
								if y > (mg_water_level - t_water_top_depth) then
									t_node = t_water_top
								else
									t_node = t_water
								end
							else
								t_node = t_ignore
							end
						end
												-- if ((ground * factor) + height) < y then
													-- if (y <= mg_water_level) then
														-- if y > t_height and y <= mg_water_level then
															-- --Water Level (Sea Level)
															-- if y > (mg_water_level - t_water_top_depth) then
																-- t_node = t_water_top
															-- else
																-- t_node = t_water
															-- end
														-- end
													-- else
														-- t_node = t_air
													-- end
												-- else
													-- if y < t_stone_height then
														-- t_node = t_stone
													-- elseif y >= t_stone_height and y < t_fill_height then
														-- t_node = t_filler
													-- elseif y >= t_fill_height and y <= t_height then
														-- t_node = t_top
													-- end
												-- end

														-- if (y <= mg_water_level) then
															-- if y > t_height and y <= mg_water_level then
																-- --Water Level (Sea Level)
																-- if y > (mg_water_level - t_water_top_depth) then
																	-- t_node = t_water_top
																-- else
																	-- t_node = t_water
																-- end
															-- end
														-- -- else
															-- -- t_node = t_ignore
														-- end

														-- if (write_3d == false) and (y <= mg_water_level) and ((t_node == t_ignore) or (t_node == t_air)) then
															-- -- t_node = t_water
															-- if y > (mg_water_level - t_water_top_depth) then
																-- t_node = t_water_top
															-- else
																-- t_node = t_water
															-- end
														-- end
					end

					if mg_heightmap_select == "vValleys3D" then
					
						if (write_3d == false) and (y <= mg_water_level) and ((t_node == t_ignore) or (t_node == t_air)) then
							t_node = t_water
						end


						-- if write_3d == true then
							-- if y < (theight - (fill_depth + top_depth)) then
								-- t_node = t_stone
							-- elseif y >= (theight - (fill_depth + top_depth)) and y < (theight - top_depth) then
								-- if t_rivermap <= mg_earth.config.river_size_factor then
									-- if y > (mg_valleys3d.water_level - 1) then
										-- if y >= (theight - ((fill_depth - (t_riverbed_depth * 0.5)) + top_depth)) and y < (theight - top_depth) then
											-- t_filler = t_river
										-- else
											-- t_filler = t_riverbed
										-- end
										-- if t_rivermap >= (mg_earth.config.river_size_factor * 0.7) then
											-- t_filler = t_mud
										-- end
									-- end
								-- end
								-- t_node = t_filler
							-- elseif y >= (theight - top_depth) and y <= theight then
								-- if t_rivermap <= mg_earth.config.river_size_factor then
									-- if y > mg_valleys3d.water_level then
										-- t_top = t_air
									-- else
										-- t_top = t_water
									-- end
								-- end
								-- t_node = t_top
							-- elseif y > theight and y <= mg_valleys3d.water_level then
							-- --Water Level (Sea Level)
								-- t_node = t_water
							-- end
						-- end


					end

				end

				data[ivm] = t_node

				index2d = index2d + 1
				index3d = index3d + 1

				write = true

			end
			index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
		end
		index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
	end

	generate_2d_roads(minp, maxp, area, data)

	mg_timer["mainloop"] = os.clock()

	if write then
		vm:set_data(data)
	end

	mg_timer["setdata"] = os.clock()
	
	if write then

		minetest.generate_ores(vm,minp,maxp)
		minetest.generate_decorations(vm,minp,maxp)
			
		vm:set_lighting({day = 0, night = 0})
		vm:calc_lighting()
		vm:update_liquids()
	end

	mg_timer["liquid_lighting"] = os.clock()

	if write then
		vm:write_to_map()
	end

	mg_timer["write"] = os.clock()

	-- Print generation time of this mapchunk.
	--local chugent = math.ceil((os.clock() - mg_timer["start"]) * 1000)
	--print(("[mg_earth] Generating from %s to %s"):format(minetest.pos_to_string(minp), minetest.pos_to_string(maxp)) .. "  :  " .. chugent .. " ms")
	print(("[mg_earth] Generating from %s to %s"):format(minetest.pos_to_string(minp), minetest.pos_to_string(maxp)) .. "  :  " .. math.ceil((os.clock() - mg_timer["start"]) * 1000) .. " ms")
	--print("[mg_earth] Mapchunk generation time " .. chugent .. " ms")

	table.insert(mg_earth.mapgen_times.noisemaps, 0)
	table.insert(mg_earth.mapgen_times.preparation,  mg_timer["preparation"] - mg_timer["start"])
	table.insert(mg_earth.mapgen_times.loop3d, mg_timer["loop3D"] -  mg_timer["preparation"])
	table.insert(mg_earth.mapgen_times.loop2d, mg_timer["loop2D"] - mg_timer["loop3D"])
	table.insert(mg_earth.mapgen_times.mainloop, mg_timer["mainloop"] - mg_timer["loop2D"])
	table.insert(mg_earth.mapgen_times.setdata, mg_timer["setdata"] - mg_timer["mainloop"])
	table.insert(mg_earth.mapgen_times.liquid_lighting, mg_timer["liquid_lighting"] - mg_timer["setdata"])
	table.insert(mg_earth.mapgen_times.writing, mg_timer["write"] - mg_timer["liquid_lighting"])
	table.insert(mg_earth.mapgen_times.make_chunk, mg_timer["write"] - mg_timer["start"])

	-- Deal with memory issues. This, of course, is supposed to be automatic.
	--local mem = math.floor(collectgarbage("count")/1024)
	local mem = math.floor(collectgarbage("count")/1000)

	if mem > 1000 then
	-- if math.floor(collectgarbage("count")/500) > 500 then
		print("mg_earth is manually collecting garbage as memory use has exceeded 1000K.")
		collectgarbage("collect")
	end

end


minetest.register_on_generated(generate_map)


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


	--save_neighbors(n_file)
	if mg_heightmap_select == "vPlanets" then
		save_3D_neighbors(n_file)
	else
		save_neighbors(n_file)
	end

	
	if #mg_earth.mapgen_times.make_chunk == 0 then
		return
	end

	--local average, standard_dev
	local average
	minetest.log("mg_earth lua Mapgen Times:")

	average = mean(mg_earth.mapgen_times.noisemaps)
	minetest.log("  noisemaps: - - - - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.preparation)
	minetest.log("  preparation: - - - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.loop2d)
	minetest.log(" 2D Noise loops: - - - - - - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.loop3d)
	minetest.log(" 3D Noise loops: - - - - - - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.mainloop)
	minetest.log(" Main Render loops: - - - - - - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.setdata)
	minetest.log("  writing: - - - - - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.liquid_lighting)
	minetest.log("  liquid_lighting: - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.writing)
	minetest.log("  writing: - - - - - - - - - - - - - - - -  "..average)

	average = mean(mg_earth.mapgen_times.make_chunk)
	minetest.log("  makeChunk: - - - - - - - - - - - - - - -  "..average)

end)


minetest.register_on_mods_loaded(function()

	update_biomes()

end)

minetest.log("[MOD] mg_earth:  Successfully loaded.")




