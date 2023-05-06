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


--Localized math functions for convenience and performance.
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


mg_earth.enabled = minetest.settings:get_bool("mg_earth.enabled") or true
-- mg_earth.enabled = minetest.settings:get_bool("mg_earth.enabled") or false
if mg_earth.enabled == false then
	return
end


mg_earth.settings = {
	mg_world_scale				= tonumber(minetest.settings:get("mg_earth.settings.mg_world_scale"))				or 1.0,
	mg_base_height				= tonumber(minetest.settings:get("mg_earth.settings.mg_base_height"))				or 300,
	sea_level					= tonumber(minetest.settings:get("mg_earth.settings.sea_level"))					or 1,
	flat_height					= tonumber(minetest.settings:get("mg_earth.settings.flat_height"))					or 5,
	rivers						= {
		enable					= minetest.settings:get_bool("mg_earth.settings.rivers.enable")						or false,
		width					= tonumber(minetest.settings:get("mg_earth.settings.rivers.width"))					or 20,
	},
	caves						= {
		enable					= minetest.settings:get_bool("mg_earth.settings.caves.enable")						or false,
		width					= tonumber(minetest.settings:get("mg_earth.settings.caves.width"))					or 0.08,
		thresh					= tonumber(minetest.settings:get("mg_earth.settings.caves.thresh"))					or 1.0,			-- Cave threshold: 1 = small rare caves,
	},
	caverns						= {
		enable					= minetest.settings:get_bool("mg_earth.settings.caverns.enable")					or false,
		thresh1					= tonumber(minetest.settings:get("mg_earth.settings.caverns.thresh1"))				or 0.9,			-- Cave threshold: 1 = small rare caves,
		thresh2					= tonumber(minetest.settings:get("mg_earth.settings.caverns.thresh2"))				or 0.6,		-- 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume.
		YMIN					= tonumber(minetest.settings:get("mg_earth.settings.caverns.YMIN"))					or -31000, -- Cave realm limits
		YMAX1					= tonumber(minetest.settings:get("mg_earth.settings.caverns.YMAX1"))				or -64,
		YMAX2					= tonumber(minetest.settings:get("mg_earth.settings.caverns.YMAX2"))				or -64,
		BLEND					= tonumber(minetest.settings:get("mg_earth.settings.caverns.BLEND"))				or 128,		-- Cave blend distance near YMIN, YMAX
	},
	enable_lakes				= minetest.settings:get_bool("mg_earth.settings.enable_lakes")						or false,
	enable_boulders				= minetest.settings:get_bool("mg_earth.settings.enable_boulders")					or true,
	streets						= {
		enable					= minetest.settings:get_bool("mg_earth.settings.streets.enable")					or true,
		width					= tonumber(minetest.settings:get("mg_earth.settings.streets.width"))				or 1,
		path_additive			= tonumber(minetest.settings:get("mg_earth.settings.streets.path_additive"))		or 4,
		sin_amplitude			= tonumber(minetest.settings:get("mg_earth.settings.streets.sin_amplitude"))		or 50,
		sin_frequency			= tonumber(minetest.settings:get("mg_earth.settings.streets.sin_frequency"))		or 0.01,
		grid_width				= tonumber(minetest.settings:get("mg_earth.settings.streets.grid_width"))			or 1000,
		min_height				= tonumber(minetest.settings:get("mg_earth.settings.streets.min_height"))			or 2,
		max_height				= tonumber(minetest.settings:get("mg_earth.settings.streets.max_height"))			or 300,	--300
		terrain_min_height		= tonumber(minetest.settings:get("mg_earth.settings.streets.terrain_min_height"))	or -2,
	},
	roads						= {
		enable					= minetest.settings:get_bool("mg_earth.settings.roads.enable")						or true,
		width					= tonumber(minetest.settings:get("mg_earth.settings.roads.width"))					or 1,
		path_additive			= tonumber(minetest.settings:get("mg_earth.settings.roads.path_additive"))			or 4,
		sin_amplitude			= tonumber(minetest.settings:get("mg_earth.settings.roads.sin_amplitude"))			or 32,
		sin_frequency			= tonumber(minetest.settings:get("mg_earth.settings.roads.sin_frequency"))			or 0.02,
		grid_width				= tonumber(minetest.settings:get("mg_earth.settings.roads.grid_width"))				or 500,
		min_height				= tonumber(minetest.settings:get("mg_earth.settings.roads.min_height"))				or 2,
		max_height				= tonumber(minetest.settings:get("mg_earth.settings.roads.max_height"))				or 300,	--300
		terrain_min_height		= tonumber(minetest.settings:get("mg_earth.settings.roads.terrain_min_height"))		or -2,
	},
	paths						= {
		enable					= minetest.settings:get_bool("mg_earth.settings.paths.enable")						or true,
		width					= tonumber(minetest.settings:get("mg_earth.settings.paths.width"))					or 2,
		path_additive			= tonumber(minetest.settings:get("mg_earth.settings.paths.path_additive"))			or 4,
		sin_amplitude			= tonumber(minetest.settings:get("mg_earth.settings.paths.sin_amplitude"))			or 25,
		sin_frequency			= tonumber(minetest.settings:get("mg_earth.settings.paths.sin_frequency"))			or 0.025,
		grid_width				= tonumber(minetest.settings:get("mg_earth.settings.paths.grid_width"))				or 250,
		min_height				= tonumber(minetest.settings:get("mg_earth.settings.paths.min_height"))				or 4,
		max_height				= tonumber(minetest.settings:get("mg_earth.settings.paths.max_height"))				or 300,	--200
		terrain_min_height		= tonumber(minetest.settings:get("mg_earth.settings.paths.terrain_min_height"))		or -2,
	},
	cities						= {
		enable					= minetest.settings:get_bool("mg_earth.settings.cities.enable")						or true,
		style					= tonumber(minetest.settings:get("mg_earth.settings.cities.style"))					or 3,
	},
	heat_scalar					= minetest.settings:get_bool("mg_earth.settings.enable_heat_scalar")				or false,
	humidity_scalar				= minetest.settings:get_bool("mg_earth.settings.enable_humidity_scalar")			or false,
	enable_3d_ver				= minetest.settings:get_bool("mg_earth.settings.enable_3d_ver")						or false,
	enable_vEarth				= minetest.settings:get_bool("mg_earth.settings.enable_vEarth")						or false,
	enable_vEarthSimple			= minetest.settings:get_bool("mg_earth.settings.enable_vEarthSimple")				or false,
	enable_v3D					= minetest.settings:get_bool("mg_earth.settings.enable_v3D")						or false,
	enable_v5					= minetest.settings:get_bool("mg_earth.settings.enable_v5")							or false,
	enable_v6					= minetest.settings:get_bool("mg_earth.settings.enable_v6")							or false,
	enable_v7					= minetest.settings:get_bool("mg_earth.settings.enable_v7")							or false,
	enable_vCarp				= minetest.settings:get_bool("mg_earth.settings.enable_vCarp")						or false,
	enable_vDiaSqr				= minetest.settings:get_bool("mg_earth.settings.enable_vDiaSqr")					or false,
	enable_vIslands				= minetest.settings:get_bool("mg_earth.settings.enable_vIslands")					or true,
	enable_vLargeIslands		= minetest.settings:get_bool("mg_earth.settings.enable_vLargeIslands")				or false,
	enable_vNatural				= minetest.settings:get_bool("mg_earth.settings.enable_vNatural")					or false,
	enable_vAltNatural			= minetest.settings:get_bool("mg_earth.settings.enable_vAltNatural")				or false,
	enable_vValleys				= minetest.settings:get_bool("mg_earth.settings.enable_vValleys")					or false,
	enable_v2d_noise			= minetest.settings:get_bool("mg_earth.settings.enable_v2d_noise")					or false,
	enable_v3d_noise			= minetest.settings:get_bool("mg_earth.settings.enable_v3d_noise")					or false,
	enable_cliffs				= minetest.settings:get_bool("mg_earth.settings.enable_cliffs")						or false,
	-- enable_carpathia			= minetest.settings:get_bool("mg_earth.settings.enable_carpathia")					or false,
	enable_carp_mount			= minetest.settings:get_bool("mg_earth.settings.enable_carp_mount")					or false,
	-- enable_carp_mount			= 																					   false,
	enable_carp_smooth			= minetest.settings:get_bool("mg_earth.settings.enable_carp_smooth")				or false,
	-- enable_carp_smooth			= 																					   false,
	enable_voronoi				= minetest.settings:get_bool("mg_earth.settings.enable_voronoi")					or false,
	enable_v6_scalar			= minetest.settings:get_bool("mg_earth.settings.enable_v6_scalar")					or false,
	enable_heightmap_select		= minetest.settings:get_bool("mg_earth.settings.enable_heightmap_select")			or false,
	enable_builtin_heightmap	= minetest.settings:get_bool("mg_earth.settings.enable_builtin_heightmap")			or false,
	enable_vDev					= minetest.settings:get_bool("mg_earth.settings.enable_vDev")						or false,
	enable_vDev3D				= minetest.settings:get_bool("mg_earth.settings.enable_vDev3D")						or false,
	enable_singlenode_heightmap	= minetest.settings:get_bool("mg_earth.settings.enable_singlenode_heightmap")		or false,
	-- Options: 1-8.  Default = 1.  See table 'mg_heightmap_select_options' below for description.
	-- 1 = vFlat, 2 = vSpheres, 3 = vCubes, 4 = vDiamonds, 5 = vVoronoiCell, 6 = vTubes, 7 = vPlanetoids, 8 = vPlanets, 9 = vSolarSystem
	heightmap					= tonumber(minetest.settings:get("mg_earth.settings.heightmap"))					or 1,
	-- Options: 1-4.  Default = 4.  1 = chebyshev, 2 = euclidean, 3 = manhattan, 4 = (chebyshev + manthattan) / 2
	voronoi_distance			= tonumber(minetest.settings:get("mg_earth.settings.voronoi_distance"))				or 3,
--[[	--manual seed options.		The named seeds below were used during dev, but were interesting enough to include.  The names were entered in the menu, and these resulted.
	--Default					= Terraria
	--		Terraria			= "16096304901732432682",
	--			Terraria mix	= "17324326821609630490"
	--			Ariaterr		= "17324326821609630490",
	--		TheIsleOfSodor		= "4866059420164947791",
	--			Sodor mix		= "1649477914866059420"
	--		TheGardenOfEden		= "9#####",
	--		GardenOfEden		= "1779####",
	--		Eden				= "4093201477345457311",
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
	--		Other Names:		Hyboria,Sedna,Aramaea,Amarys,Valeria--]]
	seed						= minetest.settings:get("mg_earth.settings.seed")									or 16096304901732432682,
	--voronoi_file				= minetest.settings:get("mg_earth.voronoi_file") or "points_earth",
	--voronoi_file				= "points_earth",					--		"points_dev_isle",
	voronoi_file				= tonumber(minetest.settings:get("mg_earth.settings.voronoi_file"))					or 1,
	--voronoi_neighbor_file_suf	= minetest.settings:get("mg_earth.voronoi_neighbor_file_suf") or "neighbors",
	voronoi_neighbor_file_suf	= "neighbors",

	noise						= {
--v3D Noise
		np_3dterrain			= minetest.settings:get_np_group("mg_earth.np_3dterrain")		or {offset=0,scale=1,spread={x=384,y=192,z=384},seed=5934,octaves=5,persist=0.5,lacunarity=2.11,},

--v5 Noises
		np_v5_fill_depth		= minetest.settings:get_np_group("mg_earth.np_v5_fill_depth")	or {offset=0,scale=1,spread={x=150,y=150,z=150},seed=261,octaves=4,persist=0.7,lacunarity=2,},
		np_v5_factor			= minetest.settings:get_np_group("mg_earth.np_v5_factor")		or {offset=0,scale=1,spread={x=250,y=250,z=250},seed=920381,octaves=3,persist=0.45,lacunarity=2,},
		np_v5_height			= minetest.settings:get_np_group("mg_earth.np_v5_height")		or {offset=0,scale=10,spread={x=250,y=250,z=250},seed=84174,octaves=4,persist=0.5,lacunarity=2,},
		np_v5_ground			= minetest.settings:get_np_group("mg_earth.np_v5_ground")		or {offset=0,scale=40,spread={x=80,y=80,z=80},seed=983240,octaves=4,persist=0.55,lacunarity=2,},

--v6 Noises
		np_v6_base				= minetest.settings:get_np_group("mg_earth.np_v6_base")			or {offset=-4,scale=20,spread={x=250,y=250,z=250},seed=82341,octaves=5,persist=0.6,lacunarity=2,},
		np_v6_higher			= minetest.settings:get_np_group("mg_earth.np_v6_higher")		or {offset=20,scale=16,spread={x=500,y=500,z=500},seed=85039,octaves=5,persist=0.6,lacunarity=2,},
		np_v6_steep				= minetest.settings:get_np_group("mg_earth.np_v6_steep")		or {offset=0.85,scale=0.5,spread={x=125,y=125,z=125},seed=-932,octaves=5,persist=0.7,lacunarity=2,},
		np_v6_height			= minetest.settings:get_np_group("mg_earth.np_v6_height")		or {offset=0,scale=1,spread={x=250,y=250,z=250},seed=4213,octaves=5,persist=0.69,lacunarity=2,},

--v7 Noises
		np_v7_alt				= minetest.settings:get_np_group("mg_earth.np_v7_alt")			or {offset=-4,scale=25,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_v7_base				= minetest.settings:get_np_group("mg_earth.np_v7_base")			or {offset=-4,scale=70,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_v7_height			= minetest.settings:get_np_group("mg_earth.np_v7_height")		or {offset=0.5,scale=1,spread={x=500,y=500,z=500},seed=4213,octaves=7,persist=0.6,lacunarity=2,},
		np_v7_persist			= minetest.settings:get_np_group("mg_earth.np_v7_persist")		or {offset=0.6,scale=0.1,spread={x=2000,y=2000,z=2000},seed=539,octaves=3,persist=0.6,lacunarity=2,},

--vCarpathian Noises
		np_carp_base			= minetest.settings:get_np_group("mg_earth.np_carp_base")			or {offset = 1, scale = 1, spread = {x = 8192, y = 8192, z = 8192}, seed = 211, octaves = 6, persist = 0.8, lacunarity = 0.5},
		np_carp_filler_depth	= minetest.settings:get_np_group("mg_earth.np_carp_filler_depth")	or {offset = 0, scale = 1, spread = {x = 512, y = 512, z = 512}, seed = 261, octaves = 3, persist = 0.7, lacunarity = 2},
		np_carp_terrain_step	= minetest.settings:get_np_group("mg_earth.np_carp_terrain_step")	or {offset = 1, scale = 1, spread = {x = 1889, y = 1889, z = 1889}, seed = 4157, octaves = 5, persist = 0.5, lacunarity = 2},
		np_carp_terrain_hills	= minetest.settings:get_np_group("mg_earth.np_carp_terrain_hills")	or {offset = 1, scale = 1, spread = {x = 1301, y = 1301, z = 1301}, seed = 1692, octaves = 5, persist = 0.5, lacunarity = 2},
		np_carp_terrain_ridge	= minetest.settings:get_np_group("mg_earth.np_carp_terrain_ridge")	or {offset = 1, scale = 1, spread = {x = 1889, y = 1889, z = 1889}, seed = 3568, octaves = 5, persist = 0.5, lacunarity = 2},
		np_carp_height1			= minetest.settings:get_np_group("mg_earth.np_carp_height1")		or {offset = 0, scale = 5, spread = {x = 251, y = 251, z = 251}, seed = 9613, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
		np_carp_height2			= minetest.settings:get_np_group("mg_earth.np_carp_height2")		or {offset = 0, scale = 5, spread = {x = 383, y = 383, z = 383}, seed = 1949, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
		np_carp_height3			= minetest.settings:get_np_group("mg_earth.np_carp_height3")		or {offset = 0, scale = 5, spread = {x = 509, y = 509, z = 509}, seed = 3211, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
		np_carp_height4			= minetest.settings:get_np_group("mg_earth.np_carp_height4")		or {offset = 0, scale = 5, spread = {x = 631, y = 631, z = 631}, seed = 1583, octaves = 5, persist = 0.5, lacunarity = 2, flags = "eased"},
		np_carp_hills			= minetest.settings:get_np_group("mg_earth.np_carp_hills")			or {offset = 0, scale = 3, spread = {x = 257, y = 257, z = 257}, seed = 6604, octaves = 6, persist = 0.5, lacunarity = 2},
		np_carp_mnt_step		= minetest.settings:get_np_group("mg_earth.np_carp_mnt_step")		or {offset = 0, scale = 8, spread = {x = 509, y = 509, z = 509}, seed = 2590, octaves = 6, persist = 0.6, lacunarity = 2},
		np_carp_mnt_ridge		= minetest.settings:get_np_group("mg_earth.np_carp_mnt_ridge")		or {offset = 0, scale = 12, spread = {x = 743, y = 743, z = 743}, seed = 5520, octaves = 6, persist = 0.7, lacunarity = 2},
		np_carp_mnt_var			= minetest.settings:get_np_group("mg_earth.np_carp_mnt_var")		or {offset = 0, scale = 1, spread = {x = 499, y = 499, z = 499}, seed = 2490, octaves = 5, persist = 0.55, lacunarity = 2},

--vEarth Noises.   River jitter and 2d Sine Wave.
		np_river_jitter			= minetest.settings:get_np_group("mg_earth.np_river_jitter")	or {offset=0,scale=50,spread={x=512,y=512,z=512},seed=513337,octaves=7,persist=0.6,lacunarity=2.11,},
		np_2d_sin				= minetest.settings:get_np_group("mg_earth.np_2d_sin")			or {offset=0,scale=1.2,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		-- --np_2d_sin			= minetest.settings:get_np_group("mg_earth.np_2d_sin")			or {offset=0,scale=1.2,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.3,lacunarity=2,},

--vIslands Noises
		np_vislands_alt			= minetest.settings:get_np_group("mg_earth.np_islands_alt")		or {offset=-4,scale=25,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vislands_base		= minetest.settings:get_np_group("mg_earth.np_islands_base")	or {offset=-4,scale=70,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vislands_height		= minetest.settings:get_np_group("mg_earth.np_islands_height")	or {offset=0.5,scale=1,spread={x=500,y=500,z=500},seed=4213,octaves=7,persist=0.6,lacunarity=2,},
		np_vislands_persist		= minetest.settings:get_np_group("mg_earth.np_islands_persist")	or {offset=0.6,scale=0.1,spread={x=2000,y=2000,z=2000},seed=539,octaves=3,persist=0.6,lacunarity=2,},

--vLargeIslands Noises
		np_vlargeislands_base	= minetest.settings:get_np_group("mg_earth.np_largeislands_base")	or {offset=-4,scale=25,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vlargeislands_alt	= minetest.settings:get_np_group("mg_earth.np_largeislands_alt")	or {offset=-4,scale=70,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vlargeislands_peak	= minetest.settings:get_np_group("mg_earth.np_largeislands_peak")	or {offset=-4,scale=105,spread={x=1200,y=1200,z=1200},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vlargeislands_height	= minetest.settings:get_np_group("mg_earth.np_largeislands_height")	or {offset=0.5,scale=1,spread={x=500,y=500,z=500},seed=4213,octaves=7,persist=0.6,lacunarity=2,},
		np_vlargeislands_persist= minetest.settings:get_np_group("mg_earth.np_largeislands_persist")or {offset=0.6,scale=0.1,spread={x=2000,y=2000,z=2000},seed=539,octaves=3,persist=0.6,lacunarity=2,},

--vNatural Noises
		np_vnatural_base			= minetest.settings:get_np_group("mg_earth.np_vnatural_base")	or {offset=-4,scale=25,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vnatural_alt				= minetest.settings:get_np_group("mg_earth.np_vnatural_alt")	or {offset=-4,scale=70,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vnatural_mount			= minetest.settings:get_np_group("mg_earth.np_vnatural_mount")	or {offset=-4,scale=105,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vnatural_peak			= minetest.settings:get_np_group("mg_earth.np_vnatural_peak")	or {offset=-4,scale=140,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},
		np_vnatural_height			= minetest.settings:get_np_group("mg_earth.np_vnatural_height")	or {offset=0.5,scale=1,spread={x=500,y=500,z=500},seed=4213,octaves=7,persist=0.6,lacunarity=2,},
		np_vnatural_persist			= minetest.settings:get_np_group("mg_earth.np_vnatural_persist")or {offset=0.6,scale=0.1,spread={x=2000,y=2000,z=2000},seed=539,octaves=3,persist=0.6,lacunarity=2,},
		np_vnatural_terrain_step	= minetest.settings:get_np_group("mg_earth.np_vnatural_terrain_step")	or {offset = 1, scale = 1, spread = {x = 1889, y = 1889, z = 1889}, seed = 4157, octaves = 5, persist = 0.5, lacunarity = 2},
		np_vnatural_terrain_hills	= minetest.settings:get_np_group("mg_earth.np_vnatural_terrain_hills")	or {offset = 1, scale = 1, spread = {x = 1301, y = 1301, z = 1301}, seed = 1692, octaves = 5, persist = 0.5, lacunarity = 2},
		np_vnatural_terrain_ridge	= minetest.settings:get_np_group("mg_earth.np_vnatural_terrain_ridge")	or {offset = 1, scale = 1, spread = {x = 1889, y = 1889, z = 1889}, seed = 3568, octaves = 5, persist = 0.5, lacunarity = 2},
		np_vnatural_hills			= minetest.settings:get_np_group("mg_earth.np_vnatural_hills")			or {offset = 0, scale = 3, spread = {x = 257, y = 257, z = 257}, seed = 6604, octaves = 6, persist = 0.5, lacunarity = 2},
		np_vnatural_mnt_step		= minetest.settings:get_np_group("mg_earth.np_vnatural_mnt_step")		or {offset = 0, scale = 8, spread = {x = 509, y = 509, z = 509}, seed = 2590, octaves = 6, persist = 0.6, lacunarity = 2},
		np_vnatural_mnt_ridge		= minetest.settings:get_np_group("mg_earth.np_vnatural_mnt_ridge")		or {offset = 0, scale = 12, spread = {x = 743, y = 743, z = 743}, seed = 5520, octaves = 6, persist = 0.7, lacunarity = 2},
		np_vnatural_mnt_var			= minetest.settings:get_np_group("mg_earth.np_vnatural_mnt_var")		or {offset = 0, scale = 1, spread = {x = 499, y = 499, z = 499}, seed = 2490, octaves = 5, persist = 0.55, lacunarity = 2},

--vValleys Noises
		np_val_terrain			= minetest.settings:get_np_group("mg_earth.np_val_terrain")		or {offset=-10,scale=50,spread={x=1024,y=1024,z=1024},seed=5202,octaves=6,persist=0.4,lacunarity=2,},
		np_val_river			= minetest.settings:get_np_group("mg_earth.np_val_river")		or {offset=0,scale=1,spread={x=256,y=256,z=256},seed=-6050,octaves=5,persist=0.6,lacunarity=2,},
		np_val_depth			= minetest.settings:get_np_group("mg_earth.np_val_depth")		or {offset=5,scale=4,spread={x=512,y=512,z=512},seed=-1914,octaves=1,persist=1,lacunarity=2,},
		np_val_profile			= minetest.settings:get_np_group("mg_earth.np_val_profile")		or {offset=0.6,scale=0.5,spread={x=512,y=512,z=512},seed=777,octaves=1,persist=1,lacunarity=2,},
		np_val_slope			= minetest.settings:get_np_group("mg_earth.np_val_slope")		or {offset=0.5,scale=0.5,spread={x=128,y=128,z=128},seed=746,octaves=1,persist=1,lacunarity=2,},
		np_val_fill				= minetest.settings:get_np_group("mg_earth.np_val_fill")		or {offset=0,scale=1,spread={x=256,y=512,z=256},seed=1993,octaves=6,persist=0.8,lacunarity=2,},

--v2d Noise
		np_2d_base				= minetest.settings:get_np_group("mg_earth.np_2d_base")			or {offset=-4,scale=25,spread={x=600,y=600,z=600},seed=5934,octaves=7,persist=0.6,lacunarity=2.05,},

--v3d Noise
		np_3d_noise				= minetest.settings:get_np_group("mg_earth.np_3d_noise")		or {offset=0,scale=64,spread={x=(384),y=(192),z=(384)},seed=5934,octaves=5,persist=0.5,lacunarity=2},

--Cave / Cavern Noises
		np_cave1				= minetest.settings:get_np_group("mg_earth.np_cave1")			or {offset=0,scale=12,spread={x=61,y=61,z=61},seed=52534,octaves=3,persist=0.5,lacunarity=2,},
		np_cave2				= minetest.settings:get_np_group("mg_earth.np_cave2")			or {offset=0,scale=12,spread={x=67,y=67,z=67},seed=10325,octaves=3,persist=0.5,lacunarity=2,},
		np_cavern1				= minetest.settings:get_np_group("mg_earth.np_cavern1")			or {offset=0,scale=1,spread={x=192,y=96,z=192},seed=59033,octaves=5,persist=0.5,lacunarity=2,},
		np_cavern2				= minetest.settings:get_np_group("mg_earth.np_cavern2")			or {offset=0,scale=1,spread={x=768,y=256,z=768},seed=10325,octaves=6,persist=0.63,lacunarity=2,},
		np_wave					= minetest.settings:get_np_group("mg_earth.np_wave")			or {offset=0,scale=1,spread={x=256,y=256,z=256},seed=-400000000089,octaves=3,persist=0.67,lacunarity=2,},


--Road Noises
		-- NOTE:  np_grid_road same seed as np_grid_base for similar structre but smoother
		np_bridge_column		= minetest.settings:get_np_group("mg_earth.np_bridge_column")	or {offset=0,scale=1,spread={x=8,y=8,z=8},seed=1728833,octaves=3,persist=2,lacunarity=2},
		np_grid_base			= minetest.settings:get_np_group("mg_earth.np_grid_base")		or {offset=0,scale=1,spread={x=512,y=512,z=512},seed=5934,octaves=6,persist=0.6,lacunarity=2},
		np_grid_city			= minetest.settings:get_np_group("mg_earth.np_grid_city")		or {offset=0,scale=1,spread={x=256,y=256,z=256},seed=3166616,octaves=5,persist=0.5,lacunarity=2},
		np_grid_road			= minetest.settings:get_np_group("mg_earth.np_grid_road")		or {offset=0,scale=1,spread={x=512,y=512,z=512},seed=5934,octaves=5,persist=0.5,lacunarity=2,},
		np_road					= minetest.settings:get_np_group("mg_earth.np_road")			or {offset=0,scale=31000,spread={x=256,y=256,z=256},seed=8675309,octaves=1,persist=0.5,lacunarity=2,flags="defaults,absvalue",},
		np_road_jitter			= minetest.settings:get_np_group("mg_earth.np_road_jitter")		or {offset=0,scale=20,spread={x=256,y=256,z=256},seed=8675309,octaves=7,persist=0.6,lacunarity=2,flags="defaults,absvalue",},

--Cliff Noise
		np_cliffs				= minetest.settings:get_np_group("mg_earth.np_cliffs")			or {offset=0,scale=0.72,spread={x=180,y=180,z=180},seed=82735,octaves=5,persist=0.5,lacunarity=2.15,},

--Fill Noise
		np_fill					= minetest.settings:get_np_group("mg_earth.np_fill")			or {offset=0,scale=1.2,spread={x=150,y=150,z=150},seed=261,octaves=3,persist=0.7,lacunarity=2,},

--Sine Wave Noise
		np_sin					= minetest.settings:get_np_group("mg_earth.np_sin")				or {offset=0,scale=1.2,spread={x=512,y=512,z=512},seed=513337,octaves=5,persist=0.5,lacunarity=2,flags="defaults, absvalue",},

	},
}

--THE FOLLOWING SETTINGS CAN BE CHANGED VIA THE MAIN MENU
minetest.set_mapgen_setting("seed", mg_earth.settings.seed, true)
minetest.set_mapgen_setting("mg_flags", "nocaves, nodungeons, light, decorations, biomes, ores", true)

mg_earth.mg_seed = minetest.get_mapgen_setting("seed")

mg_earth.config = {}

--World Scale:  Supported values range from 0.01 to 1.0.  This scales the voronoi cells and noise values.
local mg_world_scale						= max(0.01,min(10,mg_earth.settings.mg_world_scale))

--This value is multiplied by 1.4 or added to max v7 noise height.  From this total, cell distance is then subtracted.
local mg_base_height						= max(0,min(500,mg_earth.settings.mg_base_height)) * mg_world_scale

--Sets the water level used by the mapgen.  This should / could use map_meta value, but that is less controllable.
local mg_water_level						= max(-31000,min(31000,mg_earth.settings.sea_level))
mg_earth.water_level						= max(-31000,min(31000,mg_earth.settings.sea_level))

--Sets the height of the flat mapgen
mg_earth.config.mg_flat_height				= max(-31000,min(31000,mg_earth.settings.flat_height))

--Enables voronoi rivers.  Valleys are naturally formed at the edges of voronoi cells in this mapgen.  This turns those edges into rivers.
mg_earth.config.rivers						= {
	enable									= mg_earth.settings.rivers.enable,
	--Sets the max width of rivers.  Needs work.
	width									= max(2,min(40,mg_earth.settings.rivers.width)) * mg_world_scale,
}

--Enables cave generation.
mg_earth.config.caves						= {
	enable									= mg_earth.settings.caves.enable,
	width									= max(0.01,min(1.0,mg_earth.settings.caves.width)),
	thresh									= max(0.0,min(1.0,mg_earth.settings.caves.thresh)),
}

--Enables cavern generation.
mg_earth.config.caverns						= {
	enable									= mg_earth.settings.caverns.enable,
	thresh1									= max(0.0,min(1.0,mg_earth.settings.caverns.thresh1)),
	thresh2									= max(0.0,min(1.0,mg_earth.settings.caverns.thresh2)),
	YMIN									= max(-31000,min(31000,mg_earth.settings.caverns.YMIN)),
	YMAX1									= max(-31000,min(31000,mg_earth.settings.caverns.YMAX1)),
	YMAX2									= max(-31000,min(31000,mg_earth.settings.caverns.YMAX2)),
	BLEND									= max(96,min(160,mg_earth.settings.caverns.BLEND)),
}
mg_earth.config.caverns.yblmin				= mg_earth.config.caverns.YMIN + mg_earth.config.caverns.BLEND * 1.5
--mg_earth.config.caverns.yblmax1				= mg_earth.config.caverns.YMAX1 - mg_earth.config.caverns.BLEND * 1.5
mg_earth.config.caverns.yblmax2				= mg_earth.config.caverns.YMAX2 - mg_earth.config.caverns.BLEND * 1.5

--Enables lake generation.
mg_earth.config.mg_lakes_enabled			= mg_earth.settings.enable_lakes

--Boulders
mg_earth.config.mg_boulders					= mg_earth.settings.enable_boulders

mg_earth.path_additives = {
	"jitter",
	"terrain",
	"ta_diff",
	"jitter_ta_diff",
	"sine_wave",
	"sine_jitter",
	"sine_terrain",
	"sine_terrain_jitter",
}
--Streets
mg_earth.config.streets						= {
	enable									= mg_earth.settings.streets.enable,
	width									= max(1,min(1,mg_earth.settings.streets.width)),
	path_additive							= mg_earth.path_additives[max(1,min(8,mg_earth.settings.streets.path_additive))],
	sin_amp									= max(0,min(100,mg_earth.settings.streets.sin_amplitude)),
	sin_freq								= max(0.0,min(1.0,mg_earth.settings.streets.sin_frequency)),
	grid_width								= max(0,min(4000,mg_earth.settings.streets.grid_width)),
	min_height								= max(1,min(10,mg_earth.settings.streets.min_height)) * mg_world_scale,
	max_height								= max(11,min(300,mg_earth.settings.streets.max_height)) * mg_world_scale,
	terrain_min_height						= max(-31000,min(31000,mg_earth.settings.streets.terrain_min_height)) * mg_world_scale,
}

--Roads
mg_earth.config.roads						= {
	enable									= mg_earth.settings.roads.enable,
	width									= max(1,min(1,mg_earth.settings.roads.width)),
	path_additive							= mg_earth.path_additives[max(1,min(8,mg_earth.settings.roads.path_additive))],
	sin_amp									= max(0,min(100,mg_earth.settings.roads.sin_amplitude)),
	sin_freq								= max(0.0,min(1.0,mg_earth.settings.roads.sin_frequency)),
	grid_width								= max(0,min(2000,mg_earth.settings.roads.grid_width)),
	min_height								= max(1,min(10,mg_earth.settings.roads.min_height)) * mg_world_scale,
	max_height								= max(11,min(300,mg_earth.settings.roads.max_height)) * mg_world_scale,
	-- max_height							= mg_base_height * 0.1,
	terrain_min_height						= max(-31000,min(31000,mg_earth.settings.roads.terrain_min_height)) * mg_world_scale,
}

--Paths
mg_earth.config.paths						= {
	enable									= mg_earth.settings.paths.enable,
	width									= max(2,min(8,mg_earth.settings.paths.width)),
	path_additive							= mg_earth.path_additives[max(1,min(8,mg_earth.settings.paths.path_additive))],
	sin_amp									= max(0,min(100,mg_earth.settings.paths.sin_amplitude)),
	sin_freq								= max(0.0,min(1.0,mg_earth.settings.paths.sin_frequency)),
	grid_width								= max(0,min(1000,mg_earth.settings.paths.grid_width)),
	min_height								= max(1,min(10,mg_earth.settings.paths.min_height)) * mg_world_scale,
	max_height								= max(11,min(300,mg_earth.settings.paths.max_height)) * mg_world_scale,
	terrain_min_height						= max(-31000,min(31000,mg_earth.settings.paths.terrain_min_height)) * mg_world_scale,
}


mg_earth.city_styles = {
	"path",
	"gravel",
	"road",
	"street",
}
--City Grid
mg_earth.config.city						= {
	enable									= mg_earth.settings.cities.enable,
	-- enable									= true,
	style									= mg_earth.city_styles[max(1,min(4,mg_earth.settings.cities.style))],
	-- style									= "road",				--OPTIONS: "path", "gravel", "road", "street"
}


mg_earth.config.diasq_size = 2048

-- Controls maximum steepness of paths.
mg_earth.config.height_select_amplitude = 0.025


--Sets whether to use true earth like heat distribution.  Hot equator, cold polar regions.
mg_earth.config.use_heat_scalar				= mg_earth.settings.heat_scalar
--Sets whether to use rudimentary earthlike humidity distribution.  Some latitudes appear to carry more moisture than others.
mg_earth.config.use_humid_scalar			= mg_earth.settings.humidity_scalar

--Heightmap generation method options.
mg_earth.mg_heightmap_select_options = {
	"vFlat",			--1
	"vSpheres",			--2
	"vCubes",			--3
	"vDiamonds",		--4
	"vVoronoiCell",		--5
	"vTubes",			--6
	"vPlanetoids",		--7
	"vPlanets",			--8
	"vSolarSystem",		--9
}
local mg_heightmap_select					= mg_earth.mg_heightmap_select_options[max(1,min(9,mg_earth.settings.heightmap))]


--Allowed options: c, e, m, cm.		These stand for Chebyshev, Euclidean, Manhattan, and Chebyshev Manhattan.  They determine the type of voronoi
--cell that is produced.  Chebyshev produces square cells.  Euclidean produces circular cells.  Manhattan produces diamond cells.
mg_earth.dist_metrics = {
	"c",
	"e",
	"m",
	"cm",
}
mg_earth.config.dist_metric					= mg_earth.dist_metrics[max(1,min(4,mg_earth.settings.voronoi_distance))]


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

p_file = voronoi_point_files[max(1,min(9,mg_earth.settings.voronoi_file))]

if mg_heightmap_select == "vPlanets" or mg_heightmap_select == "vRand3D" then
	p_file									= voronoi_point_files[2]
end

if mg_heightmap_select == "vSolarSystem" then
	p_file									= voronoi_point_files[3]
end

--The following is the name of a file that is created on shutdown of all voronoi cells and their respective neighboring cells.  A unique file is created based on mg_world_scale.
	--n_file = p_file .. "_" .. mg_earth.settings.voronoi_neighbor_file_suf .. ""
n_file = p_file .. "_" .. tostring(mg_world_scale) .. "_" .. mg_earth.config.dist_metric .. "_" .. mg_earth.settings.voronoi_neighbor_file_suf .. ""


local mg_points = dofile(mg_earth.path .. "/point_sets/" .. p_file .. ".lua")
local mg_neighbors = {}

mg_earth.mg_points = mg_points


mg_earth.config.enable_3d_ver				=  mg_earth.settings.enable_3d_ver
mg_earth.config.enable_vEarth				=  mg_earth.settings.enable_vEarth
mg_earth.config.enable_vEarthSimple			=  mg_earth.settings.enable_vEarthSimple
mg_earth.config.enable_v3D					=  mg_earth.settings.enable_v3D
mg_earth.config.enable_v5					=  mg_earth.settings.enable_v5
mg_earth.config.enable_v6					=  mg_earth.settings.enable_v6
mg_earth.config.enable_v7					=  mg_earth.settings.enable_v7
mg_earth.config.enable_vCarp				=  mg_earth.settings.enable_vCarp
mg_earth.config.enable_vDiaSqr				=  mg_earth.settings.enable_vDiaSqr
mg_earth.config.enable_vIslands				=  mg_earth.settings.enable_vIslands
mg_earth.config.enable_vLargeIslands		=  mg_earth.settings.enable_vLargeIslands
mg_earth.config.enable_vNatural				=  mg_earth.settings.enable_vNatural
mg_earth.config.enable_vAltNatural			=  mg_earth.settings.enable_vAltNatural
mg_earth.config.enable_vValleys				=  mg_earth.settings.enable_vValleys
mg_earth.config.enable_v2d_noise			=  mg_earth.settings.enable_v2d_noise
mg_earth.config.enable_v3d_noise			=  mg_earth.settings.enable_v3d_noise
mg_earth.config.enable_heightmap			=  mg_earth.settings.enable_heightmap_select
mg_earth.config.enable_builtin_heightmap	=  mg_earth.settings.enable_builtin_heightmap
mg_earth.config.enable_singlenode_heightmap	=  mg_earth.settings.enable_singlenode_heightmap
mg_earth.config.enable_vDev					=  mg_earth.settings.enable_vDev
mg_earth.config.enable_vDev3D				=  mg_earth.settings.enable_vDev3D
mg_earth.config.enable_cliffs				=  mg_earth.settings.enable_cliffs
-- mg_earth.config.enable_carpathia			=  mg_earth.settings.enable_carpathia
mg_earth.config.enable_carp_mount			=  mg_earth.settings.enable_carp_mount
mg_earth.config.enable_carp_smooth			=  mg_earth.settings.enable_carp_smooth
mg_earth.config.enable_voronoi				=  mg_earth.settings.enable_voronoi
mg_earth.config.enable_v6_scalar			=  mg_earth.settings.enable_v6_scalar


--The following section are possible additional user exposed settings.

--Determines percentage of base voronoi terrain, alt voronoi terrain, and noise terrain values that are then added together.
local noise_blend							= 0.65

--Determines density value used by 3D terrain generation
mg_earth.config.terrain_density				= 128

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

mg_earth.boulder_form_types = {
	"berg",
	"none",
	"flat",
	"boulder",
	"hoodoo",
	"mesa",
}

if (mg_world_scale < 1.0) and (mg_world_scale >= 0.1) then
	-- mg_earth.config.rivers.width				= 5
	mg_earth.config.caves.enable				= false
	mg_earth.config.caverns.enable				= false
	mg_earth.config.mg_lakes_enabled			= false
elseif mg_world_scale < 0.1 then
	mg_earth.config.rivers.enable				= false
	mg_earth.config.caves.enable				= false
	mg_earth.config.caverns.enable				= false
	mg_earth.config.mg_lakes_enabled			= false
	mg_earth.config.paths.enable				= false
	mg_earth.config.roads.enable				= false
	mg_earth.config.streets.enable				= false
	mg_earth.config.city.enable					= false
end

if mg_earth.config.enable_v3D == true then

	-- mg_earth.config.rivers.enable				= false
	mg_earth.config.caves.enable				= false
	mg_earth.config.caverns.enable				= false
	mg_earth.config.mg_lakes_enabled			= false

end

if mg_earth.config.enable_vDiaSqr == true then

	dofile(mg_earth.path_mod.."/heightmap.lua")					--WORKING MAPGEN with and without biomes

	mg_earth.diasq_buf = mg_earth.diasq.create(mg_earth.config.diasq_size, mg_earth.config.diasq_size)

end

if ((mg_earth.config.enable_vEarth == false) and (mg_earth.config.enable_vValleys == false)) then
	mg_earth.config.rivers.enable			= false
end

if mg_earth.config.enable_vValleys == true then
	-- mg_earth.config.rivers.enable			= true
	--mg_earth.config.rivers.width				= mg_earth.settings.river_width
	mg_earth.config.rivers.width				= 5
end

--Enables use of gal provided ecosystems.  Disables ecosystems for all other biome related mods.
mg_earth.config.mg_ecosystems					= false

--Voronoi distance scalars
mg_earth.config.v_tscale = 0.02
mg_earth.config.v_cscale = 0.05
mg_earth.config.v_pscale = 0.1
-- local v_mscale = 0.125


--Tube variables
mg_earth.config.tube_radius = 10
mg_earth.config.tube_wall_density = 2


--Sets the max width of valley formation.  Also needs refining.
--mg_earth.config.mg_valley_size			= mg_earth.config.rivers.width * mg_earth.config.rivers.width
mg_earth.config.mg_valley_size				= mg_earth.config.rivers.width * 5

mg_earth.config.river_size_factor			= mg_earth.config.rivers.width / 100

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

mg_earth.default							= minetest.global_exists("default")
mg_earth.mcl_core							= minetest.global_exists("mcl_core")
mg_earth.mcl_sounds							= minetest.global_exists("mcl_sounds")
mg_earth.gal								= minetest.global_exists("gal")
mg_earth.nodes_nature						= minetest.global_exists("nodes_nature")
mg_earth.mapgen_rivers						= minetest.global_exists("mapgen_rivers")

if mg_earth.gal then
	mg_world_scale							= gal.mapgen.mg_world_scale
	mg_water_level							= gal.mapgen.water_level
	mg_base_height							= gal.mapgen.mg_base_height
	if gal.config.enable_biomes == true then
		mg_earth.config.gal_biomes			= true
		if gal.config.enable_ecosystems == true then
			mg_earth.config.mg_ecosystems	= true
		end
	end
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

if mg_earth.config.enable_singlenode_heightmap == true then
	if mg_earth.mapgen_rivers == true then
		mg_earth.config.rivers.enable			= true
	end
end

mg_earth.c_air								= minetest.get_content_id("air")
mg_earth.c_ignore							= minetest.get_content_id("ignore")

if mg_earth.default == true then
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

	mg_earth.c_path							= minetest.get_content_id("default:dry_dirt")
	if mg_earth.config.city.style == "gravel" then
		mg_earth.c_path							= minetest.get_content_id("default:gravel")
	end
	mg_earth.c_road							= minetest.get_content_id("default:cobble")
	mg_earth.c_road_sup						= minetest.get_content_id("default:stone_block")
	mg_earth.c_lamp							= minetest.get_content_id("default:meselamp")
elseif mg_earth.mcl_core == true then
	mg_earth.c_top							= minetest.get_content_id("mcl_core:dirt_with_grass")
	mg_earth.c_filler						= minetest.get_content_id("mcl_core:dirt")
	mg_earth.c_stone						= minetest.get_content_id("mcl_core:stone")
	mg_earth.c_water						= minetest.get_content_id("mcl_core:water_source")
	mg_earth.c_water_top					= minetest.get_content_id("mcl_core:water_source")
	mg_earth.c_river						= minetest.get_content_id("mcl_core:water_source")
	--mg_earth.c_river_bed					= minetest.get_content_id("default:gravel")
	--mg_earth.c_river_bed					= minetest.get_content_id("default:dirt")
	mg_earth.c_river_bed					= minetest.get_content_id("mcl_core:sand")

	mg_earth.c_cave_liquid					= minetest.get_content_id("mcl_core:lava_source")
	mg_earth.c_dungeon						= minetest.get_content_id("mcl_core:cobble")
	mg_earth.c_dungeon_alt					= minetest.get_content_id("mcl_core:mossycobble")

	mg_earth.c_snow							= minetest.get_content_id("mcl_core:snowblock")
	mg_earth.c_ice							= minetest.get_content_id("mcl_core:ice")

	mg_earth.c_path							= minetest.get_content_id("mcl_core:coarse_dirt")
	if mg_earth.config.city.style == "gravel" then
		mg_earth.c_path							= minetest.get_content_id("mcl_core:gravel")
	end
	mg_earth.c_road							= minetest.get_content_id("mcl_core:cobble")
	mg_earth.c_road_sup						= minetest.get_content_id("mcl_core:stone")
	mg_earth.c_lamp							= minetest.get_content_id("mcl_nether:glowstone")
end

if mg_earth.gal == true then
	if gal.config.enable_biomes == true then
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
		mg_earth.c_path							= minetest.get_content_id("gal:dirt_dry")
		if mg_earth.config.city.style == "gravel" then
			mg_earth.c_path							= minetest.get_content_id("gal:stone_gravel")
		end
		mg_earth.c_road							= minetest.get_content_id("gal:dirt_with_stone_cobble")
		mg_earth.c_road_sup						= minetest.get_content_id("gal:stone_brick")
		mg_earth.c_lamp							= minetest.get_content_id("gal:lamp")
	end
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
	elseif mg_earth.mcl_core then
		mg_earth.c_sun							= minetest.get_content_id("mcl_nether:glowstone")
		mg_earth.c_mercury						= minetest.get_content_id("mcl_core:stone")
		mg_earth.c_venus						= minetest.get_content_id("mcl_core:wood")
		mg_earth.c_earth						= minetest.get_content_id("mcl_core:diamondblock")
		mg_earth.c_mars							= minetest.get_content_id("mcl_core:acaciawood")
		mg_earth.c_jupiter						= minetest.get_content_id("mcl_nether:magma")
		mg_earth.c_saturn						= minetest.get_content_id("mcl_end:end_stone")
		mg_earth.c_saturn_rings					= minetest.get_content_id("mcl_core:glass")
		mg_earth.c_uranus						= minetest.get_content_id("mcl_copper:block")
		mg_earth.c_neptune						= minetest.get_content_id("mcl_core:ice")
		mg_earth.c_pluto						= minetest.get_content_id("mcl_colorblocks:hardened_clay_yellow")
	end
end


mg_earth.heightmap = {}
				-- mg_earth.heightmap2d = {}
mg_earth.heightmap_3d_flat = {}
mg_earth.biomemap = {}
mg_earth.biome_info = {}
mg_earth.hh_mod = {}
mg_earth.cliffmap = {}
				-- mg_earth.cliffterrainmap = {}
mg_earth.fillmap = {}

if mg_earth.config.mg_ecosystems == true then
	mg_earth.eco_map = {}
		-- mg_earth.eco_fill = {}
		-- mg_earth.eco_top = {}
end

if mg_earth.config.enable_singlenode_heightmap == true then
	if mg_earth.mapgen_rivers == true then
		mg_earth.lakemap = {}
		mg_earth.rivermap = {}
	end
end

if mg_earth.config.enable_vEarth == true then
	mg_earth.cellmap = {}
	mg_earth.edgemap = {}
		-- local mg_voronoimap = {}
	if mg_earth.config.rivers.enable == true then
		mg_earth.valleymap = {}
		mg_earth.rivermap = {}
		mg_earth.riverpath = {}
		mg_earth.lfmap = {}
		mg_earth.lfpath = {}
		mg_earth.rfmap = {}
		mg_earth.rfpath = {}
	end
end

if mg_earth.config.enable_voronoi == true then
	mg_earth.cellmap = {}
	mg_earth.edgemap = {}
end

if mg_earth.config.enable_v5 == true then
	mg_earth.v5_filldepthmap = {}
	mg_earth.v5_factormap = {}
	mg_earth.v5_heightmap = {}
	mg_earth.v5_groundmap = {}
	-- mg_earth.v5_density_options = {
		-- "air",
		-- "stone",
		-- "water"
	-- }
end

if (mg_earth.config.enable_vCarp == true) and (mg_earth.config.enable_3d_ver == true) then
	mg_earth.carpmap = {}
		-- -- mg_earth.height1 = {}
		-- -- mg_earth.height2 = {}
		-- -- mg_earth.height3 = {}
		-- -- mg_earth.height4 = {}
		-- -- mg_earth.hill_mnt = {}
		-- -- mg_earth.ridge_mnt = {}
		-- -- mg_earth.step_mnt = {}
end

if mg_earth.config.enable_vValleys == true then
	if mg_earth.config.enable_3d_ver == true then
		mg_earth.surfacemap = {}
		mg_earth.slopemap = {}
	end
	if mg_earth.config.rivers.enable == true then
		mg_earth.valleysrivermap = {}
	end
end

if (mg_earth.config.enable_v3D == true) or (mg_earth.config.enable_v5 == true) or ((mg_earth.config.enable_3d_ver == true) and ((mg_earth.config.enable_vCarp == true) or (mg_earth.config.enable_vValleys == true))) then
	mg_earth.densitymap = {}
end

if (mg_earth.config.streets.enable) == true or (mg_earth.config.city.enable == true and mg_earth.config.city.style == "street") then
	mg_earth.streetmap = {}
	mg_earth.streetheight = {}
	mg_earth.streetdirmap = {}
end

if (mg_earth.config.roads.enable) == true or (mg_earth.config.city.enable == true and mg_earth.config.city.style == "road") then
	mg_earth.roadmap = {}
	mg_earth.roadheight = {}
	mg_earth.roaddirmap = {}
end

if mg_earth.config.city.enable == true then
	mg_earth.citymap = {}
	-- mg_earth.cityplotmap = {}
end

if mg_earth.config.paths.enable == true then
	mg_earth.pathmap = {}
	mg_earth.pathheight = {}
	mg_earth.pathdirmap = {}
end

if mg_earth.config.mg_lakes_enabled == true then
	mg_earth.detected = {}
end

if mg_earth.config.caves.enable == true then
	mg_earth.cave1map = {}
	mg_earth.cave2map = {}
end

if mg_earth.config.caverns.enable == true then
	mg_earth.cavern1map = {}
	mg_earth.cavern2map = {}
	mg_earth.cavernwavemap = {}
end

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

local nobj_3dterrain = nil
local nbuf_3dterrain = {}

local nobj_v5_ground = nil
local nbuf_v5_ground = {}

local nobj_carp_mnt_var = nil
local nbuf_carp_mnt_var = {}

local nobj_val_fill = nil
local nbuf_val_fill = {}

local nobj_3d_noise = nil
local nbuf_3d_noise = {}

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
-- local nobj_cavebiome = nil
-- local nbuf_cavebiome = {}

-- local nobj_grid_base = nil
-- local nbuf_grid_base = {}
-- local nobj_grid_road = nil
-- local nbuf_grid_road = {}
local nobj_grid_city = nil
local nbuf_grid_city = {}
local nobj_bridge_column = nil
local nbuf_bridge_column = {}
-- local nbuf_bridge_column

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
	-- mg_noise_humid_scale = 12.5
end

--v3D Noise
if mg_earth.config.enable_v3D == true then
	mg_earth["np_3dterrain"] = {
		--flags = ""
		lacunarity = mg_earth.settings.noise.np_3dterrain.lacunarity,
		offset = mg_earth.settings.noise.np_3dterrain.offset,
		scale = mg_earth.settings.noise.np_3dterrain.scale,
		spread = {x = (mg_earth.settings.noise.np_3dterrain.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_3dterrain.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_3dterrain.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_3dterrain.seed,
		octaves = mg_earth.settings.noise.np_3dterrain.octaves,
		persist = mg_earth.settings.noise.np_3dterrain.persist,
	}
end

--vEarth Noises
if mg_earth.config.enable_vEarth == true then
	if mg_earth.config.rivers.enable == true then
--River Jitter
		mg_earth["np_river_jitter"] = {
			--flags = "defaults, absvalue",
			offset = mg_earth.settings.noise.np_river_jitter.offset * mg_world_scale,
			scale = mg_earth.settings.noise.np_river_jitter.scale * mg_world_scale,
			spread = {x = (mg_earth.settings.noise.np_river_jitter.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_river_jitter.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_river_jitter.spread.z * mg_world_scale)},
			seed = mg_earth.settings.noise.np_river_jitter.seed,
			octaves = mg_earth.settings.noise.np_river_jitter.octaves,
			persist = mg_earth.settings.noise.np_river_jitter.persist,
			lacunarity = mg_earth.settings.noise.np_river_jitter.lacunarity,
		}
	end
--2d Sine Wave
	mg_earth["np_2d_sin"] = {
		offset = mg_earth.settings.noise.np_2d_sin.offset,
		scale = mg_earth.settings.noise.np_2d_sin.scale,
		spread = {x = (mg_earth.settings.noise.np_2d_sin.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_2d_sin.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_2d_sin.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_2d_sin.seed,
		octaves = mg_earth.settings.noise.np_2d_sin.octaves,
		persist = mg_earth.settings.noise.np_2d_sin.persist,
		lacunarity = mg_earth.settings.noise.np_2d_sin.lacunarity,
	}
end

--v5 Noises
if mg_earth.config.enable_v5 == true then
	mg_earth["np_v5_fill_depth"] = {
		offset=0,
		scale=1,
		spread={x=150,y=150,z=150},
		seed=261,
		octaves=4,
		persist=0.7,
		lacunarity=2,
	}
	mg_earth["np_v5_factor"] = {
		offset=0,
		scale=1,
		spread={x=250,y=250,z=250},
		seed=920381,
		octaves=3,
		persist=0.45,
		lacunarity=2,
	}
	mg_earth["np_v5_height"] = {
		offset=0,
		scale=10,
		spread={x=250,y=250,z=250},
		seed=84174,
		octaves=4,
		persist=0.5,
		lacunarity=2,
	}
	mg_earth["np_v5_ground"] = {
		offset=0,
		scale=40,
		spread={x=80,y=80,z=80},
		seed=983240,
		octaves=4,
		persist=0.55,
		lacunarity=2,
	}
end

--v6 Noises
if mg_earth.config.enable_v6 == true then
	mg_earth["np_v6_base"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v6_base.lacunarity,
		offset = mg_earth.settings.noise.np_v6_base.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_v6_base.scale * mg_world_scale,
		spread = {x = (mg_earth.settings.noise.np_v6_base.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v6_base.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v6_base.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_v6_base.seed,
		octaves = mg_earth.settings.noise.np_v6_base.octaves,
		persist = mg_earth.settings.noise.np_v6_base.persist,
	}
	mg_earth["np_v6_higher"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v6_higher.lacunarity,
		offset = mg_earth.settings.noise.np_v6_higher.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_v6_higher.scale * mg_world_scale,
		spread = {x = (mg_earth.settings.noise.np_v6_higher.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v6_higher.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v6_higher.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_v6_higher.seed,
		octaves = mg_earth.settings.noise.np_v6_higher.octaves,
		persist = mg_earth.settings.noise.np_v6_higher.persist,
	}
	mg_earth["np_v6_steep"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v6_steep.lacunarity,
		offset = mg_earth.settings.noise.np_v6_steep.offset,
		scale = mg_earth.settings.noise.np_v6_steep.scale,
		spread = {x = (mg_earth.settings.noise.np_v6_steep.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v6_steep.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v6_steep.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_v6_steep.seed,
		octaves = mg_earth.settings.noise.np_v6_steep.octaves,
		persist = mg_earth.settings.noise.np_v6_steep.persist,
	}
	mg_earth["np_v6_height"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v6_height.lacunarity,
		offset = mg_earth.settings.noise.np_v6_height.offset,
		scale = mg_earth.settings.noise.np_v6_height.scale,
		spread = {x = (mg_earth.settings.noise.np_v6_height.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v6_height.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v6_height.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_v6_height.seed,
		octaves = mg_earth.settings.noise.np_v6_height.octaves,
		persist = mg_earth.settings.noise.np_v6_height.persist,
	}
end

--v7 Noises
if mg_earth.config.enable_v7 == true then
	mg_earth["np_v7_alt"] = {
		--flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v7_alt.lacunarity,
		offset = mg_earth.settings.noise.np_v7_alt.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_v7_alt.scale * mg_world_scale,
		seed = mg_earth.settings.noise.np_v7_alt.seed,
		spread = {x = (mg_earth.settings.noise.np_v7_alt.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v7_alt.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v7_alt.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_v7_alt.octaves,
		persist = mg_earth.settings.noise.np_v7_alt.persist,
	}
	mg_earth["np_v7_base"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v7_base.lacunarity,
		offset = mg_earth.settings.noise.np_v7_base.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_v7_base.scale * mg_world_scale,
		--seed = 82341,
		seed = mg_earth.settings.noise.np_v7_base.seed,
		spread = {x = (mg_earth.settings.noise.np_v7_base.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v7_base.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v7_base.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_v7_base.octaves,
		persist = mg_earth.settings.noise.np_v7_base.persist,
	}
	mg_earth["np_v7_height"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v7_height.lacunarity,
		offset = mg_earth.settings.noise.np_v7_height.offset,
		scale = mg_earth.settings.noise.np_v7_height.scale,
		spread = {x = (mg_earth.settings.noise.np_v7_height.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v7_height.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v7_height.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_v7_height.seed,
		octaves = mg_earth.settings.noise.np_v7_height.octaves,
		persist = mg_earth.settings.noise.np_v7_height.persist,
	}
	mg_earth["np_v7_persist"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_v7_persist.lacunarity,
		offset = mg_earth.settings.noise.np_v7_persist.offset,
		scale = mg_earth.settings.noise.np_v7_persist.scale,
		spread = {x = (mg_earth.settings.noise.np_v7_persist.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_v7_persist.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_v7_persist.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_v7_persist.seed,
		octaves = mg_earth.settings.noise.np_v7_persist.octaves,
		persist = mg_earth.settings.noise.np_v7_persist.persist,
	}
end

--vCarpathian Noises
if (mg_earth.config.enable_vCarp == true) then

	-- Terrain height noises  2D
	mg_earth["np_carp_height1"] = {
		offset = 0,
		scale = 5,
		spread = {x = 251, y = 251, z = 251},
		seed = 9613,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}
	mg_earth["np_carp_height2"] = {
		offset = 0,
		scale = 5,
		spread = {x = 383, y = 383, z = 383},
		seed = 1949,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}
	mg_earth["np_carp_height3"] = {
		offset = 0,
		scale = 5,
		spread = {x = 509, y = 509, z = 509},
		seed = 3211,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}
	mg_earth["np_carp_height4"] = {
		offset = 0,
		scale = 5,
		spread = {x = 631, y = 631, z = 631},
		seed = 1583,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2,
		flags = "eased"
	}

	-- Hill/mountain noise modifier, influences mountains for overhangs 3D
	mg_earth["np_carp_mnt_var"] = {
		offset = 0,
		scale = 1,
		spread = {x = 499, y = 499, z = 499},
		seed = 2490,
		octaves = 5,
		persist = 0.55,
		lacunarity = 2
	}

end

if (mg_earth.config.enable_vCarp == true) or (mg_earth.config.enable_carp_mount == true) or (mg_earth.config.enable_carp_smooth == true) or (mg_earth.config.enable_carpathia == true) then

	-- Terrain feature noise  2D
	mg_earth["np_carp_terrain_step"] = {
		offset = 1,
		scale = 1,
		spread = {x = 1889, y = 1889, z = 1889},
		seed = 4157,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2
	}
	mg_earth["np_carp_terrain_hills"] = {
		offset = 1,
		scale = 1,
		spread = {x = 1301, y = 1301, z = 1301},
		seed = 1692,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2
	}
	mg_earth["np_carp_terrain_ridge"] = {
		offset = 1,
		scale = 1,
		spread = {x = 1889, y = 1889, z = 1889},
		seed = 3568,
		octaves = 5,
		persist = 0.5,
		lacunarity = 2
	}

	-- Hill and mountain noise, large  2D
	mg_earth["np_carp_hills"] = {
		offset = 0,
		scale = 3,
		spread = {x = 257, y = 257, z = 257},
		seed = 6604,
		octaves = 6,
		persist = 0.5,
		lacunarity = 2
	}
	mg_earth["np_carp_mnt_step"] = {
		offset = 0,
		scale = 8,
		spread = {x = 509, y = 509, z = 509},
		seed = 2590,
		octaves = 6,
		persist = 0.6,
		lacunarity = 2
	}
	mg_earth["np_carp_mnt_ridge"] = {
		offset = 0,
		scale = 12,
		spread = {x = 743, y = 743, z = 743},
		seed = 5520,
		octaves = 6,
		persist = 0.7,
		lacunarity = 2
	}

end

--vIslands Noises
if mg_earth.config.enable_vIslands == true then
	mg_earth["np_vislands_base"] = {
		--flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vislands_base.lacunarity,
		offset = mg_earth.settings.noise.np_vislands_base.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_vislands_base.scale * mg_world_scale,
		seed = mg_earth.settings.noise.np_vislands_base.seed,
		spread = {x = (mg_earth.settings.noise.np_vislands_base.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vislands_base.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vislands_base.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_vislands_base.octaves,
		persist = mg_earth.settings.noise.np_vislands_base.persist,
	}
	mg_earth["np_vislands_alt"] = {
		offset = (mg_earth.settings.noise.np_vislands_alt.offset * mg_world_scale),
		scale = (mg_earth.settings.noise.np_vislands_alt.scale * mg_world_scale),
		spread = {x = (mg_earth.settings.noise.np_vislands_alt.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vislands_alt.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vislands_alt.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vislands_alt.seed,
		octaves = mg_earth.settings.noise.np_vislands_alt.octaves,
		persist = mg_earth.settings.noise.np_vislands_alt.persist,
		lacunarity = mg_earth.settings.noise.np_vislands_alt.lacunarity,
	}
	mg_earth["np_vislands_height"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vislands_height.lacunarity,
		offset = mg_earth.settings.noise.np_vislands_height.offset,
		scale = mg_earth.settings.noise.np_vislands_height.scale,
		spread = {x = (mg_earth.settings.noise.np_vislands_height.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vislands_height.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vislands_height.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vislands_height.seed,
		octaves = mg_earth.settings.noise.np_vislands_height.octaves,
		persist = mg_earth.settings.noise.np_vislands_height.persist,
	}
	mg_earth["np_vislands_persist"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vislands_persist.lacunarity,
		offset = mg_earth.settings.noise.np_vislands_persist.offset,
		scale = mg_earth.settings.noise.np_vislands_persist.scale,
		spread = {x = (mg_earth.settings.noise.np_vislands_persist.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vislands_persist.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vislands_persist.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vislands_persist.seed,
		octaves = mg_earth.settings.noise.np_vislands_persist.octaves,
		persist = mg_earth.settings.noise.np_vislands_persist.persist,
	}
end

--vLargeIslands Noises
if (mg_earth.config.enable_vLargeIslands == true) or (mg_earth.config.enable_vDev == true) then
	mg_earth["np_vlargeislands_base"] = {
		--flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vlargeislands_base.lacunarity,
		offset = mg_earth.settings.noise.np_vlargeislands_base.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_vlargeislands_base.scale * mg_world_scale,
		seed = mg_earth.settings.noise.np_vlargeislands_base.seed,
		spread = {x = (mg_earth.settings.noise.np_vlargeislands_base.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vlargeislands_base.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vlargeislands_base.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_vlargeislands_base.octaves,
		persist = mg_earth.settings.noise.np_vlargeislands_base.persist,
	}
	mg_earth["np_vlargeislands_alt"] = {
		offset = (mg_earth.settings.noise.np_vlargeislands_alt.offset * mg_world_scale),
		scale = (mg_earth.settings.noise.np_vlargeislands_alt.scale * mg_world_scale),
		spread = {x = (mg_earth.settings.noise.np_vlargeislands_alt.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vlargeislands_alt.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vlargeislands_alt.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vlargeislands_alt.seed,
		octaves = mg_earth.settings.noise.np_vlargeislands_alt.octaves,
		persist = mg_earth.settings.noise.np_vlargeislands_alt.persist,
		lacunarity = mg_earth.settings.noise.np_vlargeislands_alt.lacunarity,
	}
	mg_earth["np_vlargeislands_peak"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vlargeislands_peak.lacunarity,
		offset = mg_earth.settings.noise.np_vlargeislands_peak.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_vlargeislands_peak.scale * mg_world_scale,
		--seed = 82341,
		seed = mg_earth.settings.noise.np_vlargeislands_peak.seed,
		spread = {x = (mg_earth.settings.noise.np_vlargeislands_peak.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vlargeislands_peak.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vlargeislands_peak.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_vlargeislands_peak.octaves,
		persist = mg_earth.settings.noise.np_vlargeislands_peak.persist,
	}
	mg_earth["np_vlargeislands_height"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vlargeislands_height.lacunarity,
		offset = mg_earth.settings.noise.np_vlargeislands_height.offset,
		scale = mg_earth.settings.noise.np_vlargeislands_height.scale,
		spread = {x = (mg_earth.settings.noise.np_vlargeislands_height.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vlargeislands_height.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vlargeislands_height.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vlargeislands_height.seed,
		octaves = mg_earth.settings.noise.np_vlargeislands_height.octaves,
		persist = mg_earth.settings.noise.np_vlargeislands_height.persist,
	}
	mg_earth["np_vlargeislands_persist"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vlargeislands_persist.lacunarity,
		offset = mg_earth.settings.noise.np_vlargeislands_persist.offset,
		scale = mg_earth.settings.noise.np_vlargeislands_persist.scale,
		spread = {x = (mg_earth.settings.noise.np_vlargeislands_persist.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vlargeislands_persist.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vlargeislands_persist.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vlargeislands_persist.seed,
		octaves = mg_earth.settings.noise.np_vlargeislands_persist.octaves,
		persist = mg_earth.settings.noise.np_vlargeislands_persist.persist,
	}
end

--vNatural Noises
if (mg_earth.config.enable_vNatural == true) or (mg_earth.config.enable_vAltNatural == true) then
	mg_earth["np_vnatural_base"] = {
		--flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vnatural_base.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_base.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_vnatural_base.scale * mg_world_scale,
		seed = mg_earth.settings.noise.np_vnatural_base.seed,
		spread = {x = (mg_earth.settings.noise.np_vnatural_base.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_base.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_base.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_vnatural_base.octaves,
		persist = mg_earth.settings.noise.np_vnatural_base.persist,
	}
--[[	mg_earth["np_vnatural_alt"] = {
		offset = (mg_earth.settings.noise.np_vnatural_alt.offset * mg_world_scale),
		scale = (mg_earth.settings.noise.np_vnatural_alt.scale * mg_world_scale),
		spread = {x = (mg_earth.settings.noise.np_vnatural_alt.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_alt.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_alt.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_alt.seed,
		octaves = mg_earth.settings.noise.np_vnatural_alt.octaves,
		persist = mg_earth.settings.noise.np_vnatural_alt.persist,
		lacunarity = mg_earth.settings.noise.np_vnatural_alt.lacunarity,
	}--]]
--[[	mg_earth["np_vnatural_mount"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vnatural_mount.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_mount.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_vnatural_mount.scale * mg_world_scale,
		--seed = 82341,
		seed = mg_earth.settings.noise.np_vnatural_mount.seed,
		spread = {x = (mg_earth.settings.noise.np_vnatural_mount.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_mount.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_mount.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_vnatural_mount.octaves,
		persist = mg_earth.settings.noise.np_vnatural_mount.persist,
	}--]]
--[[	mg_earth["np_vnatural_peak"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vnatural_peak.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_peak.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_vnatural_peak.scale * mg_world_scale,
		--seed = 82341,
		seed = mg_earth.settings.noise.np_vnatural_peak.seed,
		spread = {x = (mg_earth.settings.noise.np_vnatural_peak.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_peak.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_peak.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_vnatural_peak.octaves,
		persist = mg_earth.settings.noise.np_vnatural_peak.persist,
	}--]]
--[[	mg_earth["np_vnatural_height"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vnatural_height.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_height.offset,
		scale = mg_earth.settings.noise.np_vnatural_height.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_height.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_height.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_height.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_height.seed,
		octaves = mg_earth.settings.noise.np_vnatural_height.octaves,
		persist = mg_earth.settings.noise.np_vnatural_height.persist,
	}--]]
	mg_earth["np_vnatural_persist"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_vnatural_persist.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_persist.offset,
		scale = mg_earth.settings.noise.np_vnatural_persist.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_persist.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_persist.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_persist.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_persist.seed,
		octaves = mg_earth.settings.noise.np_vnatural_persist.octaves,
		persist = mg_earth.settings.noise.np_vnatural_persist.persist,
	}
	-- Terrain feature noise  2D
	mg_earth["np_vnatural_terrain_step"] = {
		lacunarity = mg_earth.settings.noise.np_vnatural_terrain_step.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_terrain_step.offset,
		scale = mg_earth.settings.noise.np_vnatural_terrain_step.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_terrain_step.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_terrain_step.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_terrain_step.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_terrain_step.seed,
		octaves = mg_earth.settings.noise.np_vnatural_terrain_step.octaves,
		persist = mg_earth.settings.noise.np_vnatural_terrain_step.persist,
	}
	mg_earth["np_vnatural_terrain_hills"] = {
		lacunarity = mg_earth.settings.noise.np_vnatural_terrain_hills.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_terrain_hills.offset,
		scale = mg_earth.settings.noise.np_vnatural_terrain_hills.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_terrain_hills.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_terrain_hills.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_terrain_hills.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_terrain_hills.seed,
		octaves = mg_earth.settings.noise.np_vnatural_terrain_hills.octaves,
		persist = mg_earth.settings.noise.np_vnatural_terrain_hills.persist,
	}
	mg_earth["np_vnatural_terrain_ridge"] = {
		lacunarity = mg_earth.settings.noise.np_vnatural_terrain_ridge.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_terrain_ridge.offset,
		scale = mg_earth.settings.noise.np_vnatural_terrain_ridge.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_terrain_ridge.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_terrain_ridge.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_terrain_ridge.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_terrain_ridge.seed,
		octaves = mg_earth.settings.noise.np_vnatural_terrain_ridge.octaves,
		persist = mg_earth.settings.noise.np_vnatural_terrain_ridge.persist,
	}
	-- Hill and mountain noise, large  2D
	mg_earth["np_vnatural_hills"] = {
		lacunarity = mg_earth.settings.noise.np_vnatural_hills.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_hills.offset,
		scale = mg_earth.settings.noise.np_vnatural_hills.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_hills.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_hills.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_hills.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_hills.seed,
		octaves = mg_earth.settings.noise.np_vnatural_hills.octaves,
		persist = mg_earth.settings.noise.np_vnatural_hills.persist,
	}
	mg_earth["np_vnatural_mnt_step"] = {
		lacunarity = mg_earth.settings.noise.np_vnatural_mnt_step.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_mnt_step.offset,
		scale = mg_earth.settings.noise.np_vnatural_mnt_step.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_mnt_step.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_mnt_step.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_mnt_step.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_mnt_step.seed,
		octaves = mg_earth.settings.noise.np_vnatural_mnt_step.octaves,
		persist = mg_earth.settings.noise.np_vnatural_mnt_step.persist,
	}
	mg_earth["np_vnatural_mnt_ridge"] = {
		lacunarity = mg_earth.settings.noise.np_vnatural_mnt_ridge.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_mnt_ridge.offset,
		scale = mg_earth.settings.noise.np_vnatural_mnt_ridge.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_mnt_ridge.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_mnt_ridge.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_mnt_ridge.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_mnt_ridge.seed,
		octaves = mg_earth.settings.noise.np_vnatural_mnt_ridge.octaves,
		persist = mg_earth.settings.noise.np_vnatural_mnt_ridge.persist,
	}
	-- Hill/mountain noise modifier, influences mountains for overhangs 3D
--[[	mg_earth["np_vnatural_mnt_var"] = {
		lacunarity = mg_earth.settings.noise.np_vnatural_mnt_var.lacunarity,
		offset = mg_earth.settings.noise.np_vnatural_mnt_var.offset,
		scale = mg_earth.settings.noise.np_vnatural_mnt_var.scale,
		spread = {x = (mg_earth.settings.noise.np_vnatural_mnt_var.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_vnatural_mnt_var.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_vnatural_mnt_var.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_vnatural_mnt_var.seed,
		octaves = mg_earth.settings.noise.np_vnatural_mnt_var.octaves,
		persist = mg_earth.settings.noise.np_vnatural_mnt_var.persist,
	}--]]

end

--vValleys Noises
if mg_earth.config.enable_vValleys == true then
	mg_earth["np_val_terrain"] = {
		flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_val_terrain.lacunarity,
		offset = mg_earth.settings.noise.np_val_terrain.offset,
		scale = mg_earth.settings.noise.np_val_terrain.scale,
		spread = {x = (mg_earth.settings.noise.np_val_terrain.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_val_terrain.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_val_terrain.spread.z * mg_world_scale)},
		--seed = 5202,
		seed = mg_earth.settings.noise.np_val_terrain.seed,
		octaves = mg_earth.settings.noise.np_val_terrain.octaves,
		persist = mg_earth.settings.noise.np_val_terrain.persist,
	}
	mg_earth["np_val_river"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.noise.np_val_river.lacunarity,
		offset = mg_earth.settings.noise.np_val_river.offset,
		scale = mg_earth.settings.noise.np_val_river.scale,
		spread = {x = (mg_earth.settings.noise.np_val_river.spread.x), y = (mg_earth.settings.noise.np_val_river.spread.y), z = (mg_earth.settings.noise.np_val_river.spread.z)},
		seed = mg_earth.settings.noise.np_val_river.seed,
		octaves = mg_earth.settings.noise.np_val_river.octaves,
		persist = mg_earth.settings.noise.np_val_river.persist,
	}
	mg_earth["np_val_depth"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.noise.np_val_depth.lacunarity,
		offset = mg_earth.settings.noise.np_val_depth.offset,
		scale = mg_earth.settings.noise.np_val_depth.scale,
		spread = {x = (mg_earth.settings.noise.np_val_depth.spread.x), y = (mg_earth.settings.noise.np_val_depth.spread.y), z = (mg_earth.settings.noise.np_val_depth.spread.z)},
		seed = mg_earth.settings.noise.np_val_depth.seed,
		octaves = mg_earth.settings.noise.np_val_depth.octaves,
		persist = mg_earth.settings.noise.np_val_depth.persist,
	}
	mg_earth["np_val_profile"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.noise.np_val_profile.lacunarity,
		offset = mg_earth.settings.noise.np_val_profile.offset,
		scale = mg_earth.settings.noise.np_val_profile.scale,
		spread = {x = (mg_earth.settings.noise.np_val_profile.spread.x), y = (mg_earth.settings.noise.np_val_profile.spread.y), z = (mg_earth.settings.noise.np_val_profile.spread.z)},
		seed = mg_earth.settings.noise.np_val_profile.seed,
		octaves = mg_earth.settings.noise.np_val_profile.octaves,
		persist = mg_earth.settings.noise.np_val_profile.persist,
	}
	mg_earth["np_val_slope"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.noise.np_val_slope.lacunarity,
		offset = mg_earth.settings.noise.np_val_slope.offset,
		scale = mg_earth.settings.noise.np_val_slope.scale,
		spread = {x = (mg_earth.settings.noise.np_val_slope.spread.x), y = (mg_earth.settings.noise.np_val_slope.spread.y), z = (mg_earth.settings.noise.np_val_slope.spread.z)},
		seed = mg_earth.settings.noise.np_val_slope.seed,
		octaves = mg_earth.settings.noise.np_val_slope.octaves,
		persist = mg_earth.settings.noise.np_val_slope.persist,
	}
	mg_earth["np_val_fill"] = {
		flags = "eased",
		lacunarity = mg_earth.settings.noise.np_val_fill.lacunarity,
		offset = mg_earth.settings.noise.np_val_fill.offset,
		scale = mg_earth.settings.noise.np_val_fill.scale,
		spread = {x = (mg_earth.settings.noise.np_val_fill.spread.x), y = (mg_earth.settings.noise.np_val_fill.spread.y), z = (mg_earth.settings.noise.np_val_fill.spread.z)},
		seed = mg_earth.settings.noise.np_val_fill.seed,
		octaves = mg_earth.settings.noise.np_val_fill.octaves,
		persist = mg_earth.settings.noise.np_val_fill.persist,
	}
end

--v2D_noise Noise
if mg_earth.config.enable_v2d_noise == true then
	mg_earth["np_2d_base"] = {
		--flags = "defaults",
		lacunarity = mg_earth.settings.noise.np_2d_base.lacunarity,
		offset = mg_earth.settings.noise.np_2d_base.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_2d_base.scale * mg_world_scale,
		seed = mg_earth.settings.noise.np_2d_base.seed,
		spread = {x = (mg_earth.settings.noise.np_2d_base.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_2d_base.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_2d_base.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_2d_base.octaves,
		persist = mg_earth.settings.noise.np_2d_base.persist,
	}
end

--v3D_noise Noise
if mg_earth.config.enable_v3d_noise == true then
	mg_earth["np_3d_noise"] = {
		lacunarity = mg_earth.settings.noise.np_3d_noise.lacunarity,
		offset = mg_earth.settings.noise.np_3d_noise.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_3d_noise.scale * mg_world_scale,
		seed = mg_earth.settings.noise.np_3d_noise.seed,
		spread = {x = (mg_earth.settings.noise.np_3d_noise.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_3d_noise.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_3d_noise.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_3d_noise.octaves,
		persist = mg_earth.settings.noise.np_3d_noise.persist,
	}
end

-- Cave Noises
if mg_earth.config.enable_caves == true then
	mg_earth["np_cave1"] = {
		-- -- Caverealms
		offset = mg_earth.settings.noise.np_cave1.offset,
		scale = mg_earth.settings.noise.np_cave1.scale,
		spread = {x = (mg_earth.settings.noise.np_cave1.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_cave1.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_cave1.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_cave1.seed,
		octaves = mg_earth.settings.noise.np_cave1.octaves,
		persist = mg_earth.settings.noise.np_cave1.persist,
	}
	mg_earth["np_cave2"] = {
		-- -- Subterrain
		offset = mg_earth.settings.noise.np_cave2.offset,
		scale = mg_earth.settings.noise.np_cave2.scale,
		spread = {x = (mg_earth.settings.noise.np_cave2.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_cave2.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_cave2.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_cave2.seed,
		octaves = mg_earth.settings.noise.np_cave2.octaves,
		persist = mg_earth.settings.noise.np_cave2.persist,
	}
end

--Cavern Noises
if mg_earth.config.enable_caverns == true then
	mg_earth["np_cavern1"] = {
		-- -- Caverealms
		offset = mg_earth.settings.noise.np_cavern1.offset,
		scale = mg_earth.settings.noise.np_cavern1.scale,
		spread = {x = (mg_earth.settings.noise.np_cavern1.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_cavern1.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_cavern1.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_cavern1.seed,
		octaves = mg_earth.settings.noise.np_cavern1.octaves,
		persist = mg_earth.settings.noise.np_cavern1.persist,
	}
	mg_earth["np_cavern2"] = {
		-- -- Subterrain
		offset = mg_earth.settings.noise.np_cavern2.offset,
		scale = mg_earth.settings.noise.np_cavern2.scale,
		spread = {x = (mg_earth.settings.noise.np_cavern2.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_cavern2.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_cavern2.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_cavern2.seed,
		octaves = mg_earth.settings.noise.np_cavern2.octaves,
		persist = mg_earth.settings.noise.np_cavern2.persist,
	}
	mg_earth["np_wave"] = {
		offset = mg_earth.settings.noise.np_wave.offset,
		scale = mg_earth.settings.noise.np_wave.scale,
		spread = {x = (mg_earth.settings.noise.np_wave.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_wave.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_wave.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_wave.seed,
		octaves = mg_earth.settings.noise.np_wave.octaves,
		persist = mg_earth.settings.noise.np_wave.persist,
	}
--[[mg_earth["np_cave_biome"] = {
		offset = mg_earth.settings.noise.np_cave_biome.offset,
		scale = mg_earth.settings.noise.np_cave_biome.scale,
		spread = {x = (mg_earth.settings.noise.np_cave_biome.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_cave_biome.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_cave_biome.spread.z * mg_world_scale)},
		seed = mg_earth.settings.noise.np_cave_biome.seed,
		octaves = mg_earth.settings.noise.np_cave_biome.octaves,
		persist = mg_earth.settings.noise.np_cave_biome.persist,
	 }
--]]
end

-- 3d noise used for making bridge columns.  Comes from Paramats path_v7 and road_v7 mods.
if (mg_earth.config.roads.enable == true) or (mg_earth.config.streets.enable == true) or ((mg_earth.config.city.enable == true) and ((mg_earth.config.city.style == "road") or (mg_earth.config.city.style == "street"))) then
	mg_earth["np_bridge_column"] = {
			lacunarity = mg_earth.settings.noise.np_bridge_column.lacunarity,
			-- offset = mg_earth.settings.noise.np_bridge_column.offset * mg_world_scale,
			offset = mg_earth.settings.noise.np_bridge_column.offset,
			-- scale = mg_earth.settings.noise.np_bridge_column.scale * mg_world_scale,
			scale = mg_earth.settings.noise.np_bridge_column.scale,
			seed = mg_earth.settings.noise.np_bridge_column.seed,
			spread = {x = (mg_earth.settings.noise.np_bridge_column.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_bridge_column.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_bridge_column.spread.z * mg_world_scale)},
			octaves = mg_earth.settings.noise.np_bridge_column.octaves,
			persist = mg_earth.settings.noise.np_bridge_column.persist,
				-- offset = 0,
				-- scale = 1,
				-- spread = {x = 8, y = 8, z = 8},
				-- seed = 1728833,
				-- octaves = 3,
				-- persist = 2
	}
end

-- 2D noise for city areas
if (mg_earth.config.city.enable == true) then
	-- 2D noise for city areas
	mg_earth["np_grid_city"] = {
			lacunarity = mg_earth.settings.noise.np_grid_city.lacunarity,
			offset = mg_earth.settings.noise.np_grid_city.offset * mg_world_scale,
			scale = mg_earth.settings.noise.np_grid_city.scale * mg_world_scale,
			seed = mg_earth.settings.noise.np_grid_city.seed,
			spread = {x = (mg_earth.settings.noise.np_grid_city.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_grid_city.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_grid_city.spread.z * mg_world_scale)},
			octaves = mg_earth.settings.noise.np_grid_city.octaves,
			persist = mg_earth.settings.noise.np_grid_city.persist,
				-- offset = 0,
				-- scale = 1,
				-- -- spread = {x = 1024, y = 1024, z = 1024},
				-- spread = {x = 256, y = 256, z = 256},
				-- -- spread = {x = 128, y = 128, z = 128},
				-- seed = 3166616,
				-- -- octaves = 2,
				-- octaves = 5,
				-- persist = 0.5
	}
	-- 2D noise for base terrain
--[[mg_earth["np_grid_base"] = {
			lacunarity = mg_earth.settings.noise.np_grid_base.lacunarity,
			offset = mg_earth.settings.noise.np_grid_base.offset * mg_world_scale,
			scale = mg_earth.settings.noise.np_grid_base.scale * mg_world_scale,
			seed = mg_earth.settings.noise.np_grid_base.seed,
			spread = {x = (mg_earth.settings.noise.np_grid_base.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_grid_base.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_grid_base.spread.z * mg_world_scale)},
			octaves = mg_earth.settings.noise.np_grid_base.octaves,
			persist = mg_earth.settings.noise.np_grid_base.persist,
				-- offset = 0,
				-- scale = 1,
				-- -- spread = {x = 2048, y = 2048, z = 2048},
				-- -- spread = {x = 1024, y = 1024, z = 1024},
				-- spread = {x = 512, y = 512, z = 512},
				-- -- seed = -9111,
				-- seed = 5934,
				-- octaves = 6,
				-- persist = 0.6
	}--]]
	-- 2D noise for intercity roads
--[[mg_earth["np_grid_road"] = {
			lacunarity = mg_earth.settings.noise.np_grid_road.lacunarity,
			offset = mg_earth.settings.noise.np_grid_road.offset * mg_world_scale,
			scale = mg_earth.settings.noise.np_grid_road.scale * mg_world_scale,
			seed = mg_earth.settings.noise.np_grid_road.seed,
			spread = {x = (mg_earth.settings.noise.np_grid_road.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_grid_road.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_grid_road.spread.z * mg_world_scale)},
			octaves = mg_earth.settings.noise.np_grid_road.octaves,
			persist = mg_earth.settings.noise.np_grid_road.persist,
				-- offset = 0,
				-- scale = 1,
				-- -- spread = {x = 2048, y = 2048, z = 2048},
				-- -- spread = {x = 1024, y = 1024, z = 1024},
				-- spread = {x = 512, y = 512, z = 512},
				-- -- seed = -9111, -- same seed as above for similar structre but smoother
				-- seed = 5934, -- same seed as above for similar structre but smoother
				-- octaves = 5,
				-- persist = 0.5
	}--]]
end

-- Note that because there is 1 octave, changing 'persistence' has no effect.
-- For wider lines, but also fewer less gaps in the lines change 'scale' towards -20000.0.
-- For lines further apart, increase the scale of the entire pattern by increasing all components of 'spread'. This will make the lines wider so you will then need to tune 'scale'.
--	Road Noise.  Paramats original roads noise, requested by texmex in mapgen questions forum topic.
mg_earth["np_road"] = {
		lacunarity = mg_earth.settings.noise.np_road.lacunarity,
		offset = mg_earth.settings.noise.np_road.offset * mg_world_scale,
		scale = mg_earth.settings.noise.np_road.scale * mg_world_scale,
		seed = mg_earth.settings.noise.np_road.seed,
		spread = {x = (mg_earth.settings.noise.np_road.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_road.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_road.spread.z * mg_world_scale)},
		octaves = mg_earth.settings.noise.np_road.octaves,
		persist = mg_earth.settings.noise.np_road.persist,
		flags = mg_earth.settings.noise.np_road.flags,
			-- offset = 0,
			-- scale = 31000,
			-- spread = {x = 256, y = 256, z = 256},
			-- seed = 8675309,
			-- octaves = 1,
			-- persist = 0.5,
			-- lacunarity = 2,
	-- flags = "defaults, absvalue",
}

--	2d noise used to add noise based curves to lines denoting path, road, and street paths.
if (mg_earth.config.paths.enable == true) or (mg_earth.config.roads.enable == true) or (mg_earth.config.streets.enable == true) then
	mg_earth["np_road_jitter"] = {
			lacunarity = mg_earth.settings.noise.np_road_jitter.lacunarity,
			offset = mg_earth.settings.noise.np_road_jitter.offset * mg_world_scale,
			scale = mg_earth.settings.noise.np_road_jitter.scale * mg_world_scale,
			seed = mg_earth.settings.noise.np_road_jitter.seed,
			spread = {x = (mg_earth.settings.noise.np_road_jitter.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_road_jitter.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_road_jitter.spread.z * mg_world_scale)},
			octaves = mg_earth.settings.noise.np_road_jitter.octaves,
			persist = mg_earth.settings.noise.np_road_jitter.persist,
			flags = mg_earth.settings.noise.np_road_jitter.flags,
				-- -- scale = 1.2,
				-- offset = 0,
				-- scale = 20,
				-- spread = {x = 256, y = 256, z = 256},
				-- seed = 8675309,
				-- octaves = 7,
				-- persist = 0.6,
				-- lacunarity = 2,
		-- flags = "defaults, absvalue",
	}
end

--2d noise used to define areas with cliffs.
mg_earth["np_cliffs"] = {
	lacunarity = mg_earth.settings.noise.np_cliffs.lacunarity,
	offset = mg_earth.settings.noise.np_cliffs.offset,
	scale = mg_earth.settings.noise.np_cliffs.scale * mg_world_scale,
	spread = {x = (mg_earth.settings.noise.np_cliffs.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_cliffs.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_cliffs.spread.z * mg_world_scale)},
	--seed = 78901,
	seed = mg_earth.settings.noise.np_cliffs.seed,
	octaves = mg_earth.settings.noise.np_cliffs.octaves,
	persist = mg_earth.settings.noise.np_cliffs.persist,
}

-- 2d Noise used to vary the depth of soil, or the defined biome filler.
mg_earth["np_fill"] = {
	flags = "defaults",
	lacunarity = mg_earth.settings.noise.np_fill.lacunarity,
	offset = mg_earth.settings.noise.np_fill.offset * mg_world_scale,
	scale = mg_earth.settings.noise.np_fill.scale * mg_world_scale,
	spread = {x = (mg_earth.settings.noise.np_fill.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_fill.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_fill.spread.z * mg_world_scale)},
	seed = mg_earth.settings.noise.np_fill.seed,
	octaves = mg_earth.settings.noise.np_fill.octaves,
	persistence = mg_earth.settings.noise.np_fill.persist,
}

--Sine Wave
mg_earth["np_sin"] = {
	offset = mg_earth.settings.noise.np_sin.offset,
	scale = mg_earth.settings.noise.np_sin.scale,
	spread = {x = (mg_earth.settings.noise.np_sin.spread.x * mg_world_scale), y = (mg_earth.settings.noise.np_sin.spread.y * mg_world_scale), z = (mg_earth.settings.noise.np_sin.spread.z * mg_world_scale)},
	seed = mg_earth.settings.noise.np_sin.seed,
	octaves = mg_earth.settings.noise.np_sin.octaves,
	persist = mg_earth.settings.noise.np_sin.persist,
	lacunarity = mg_earth.settings.noise.np_sin.lacunarity,
}

mg_earth["np_heat"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = mg_noise_heat_offset,
	scale = mg_noise_heat_scale,
	spread = {x = mg_noise_heathumid_spread, y = mg_noise_heathumid_spread, z = mg_noise_heathumid_spread},
	seed = 5349,
	octaves = 3,
	persist = 0.5,
}
mg_earth["np_heat_blend"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0,
	scale = 1.5,
	spread = {x = 8, y = 8, z = 8},
	seed = 13,
	octaves = 2,
	persist = 1,
}
mg_earth["np_humid"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = mg_noise_humid_offset,
	scale = mg_noise_humid_scale,
	spread = {x = mg_noise_heathumid_spread, y = mg_noise_heathumid_spread, z = mg_noise_heathumid_spread},
	seed = 842,
	octaves = 3,
	persist = 0.5,
}
mg_earth["np_humid_blend"] = {
	flags = "defaults",
	lacunarity = 2,
	offset = 0,
	scale = 1.5,
	spread = {x = 8, y = 8, z = 8},
	seed = 90003,
	octaves = 2,
	persist = 1,
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



		-- mg_earth.config.cliffs_thresh = floor((mg_earth["np_v7_alt"].scale) * 0.5)
mg_earth.config.cliffs_thresh = 12

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


local heat_max		= max_height(mg_earth["np_heat"])
	-- local humid_min		= min_height(mg_earth["np_humid"])
local humid_max		= max_height(mg_earth["np_humid"])
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

	-- local run = b.x - a.x
	-- local rise = b.z - a.z
	-- local ln_length = (((run * run) + (rise * rise))^0.5)

	-- return max(1, (abs((run * (a.z - p.z)) - ((a.x - p.x) * rise)) / ln_length))

	return max(1, (abs(((b.x - a.x) * (a.z - p.z)) - ((a.x - p.x) * (b.z - a.z))) / ((((b.x - a.x) * (b.x - a.x)) + ((b.z - a.z) * (b.z - a.z)))^0.5)))

end

local function get_3d_dist2line(a,b,p)

	-- local run = b.x - a.x
	-- local rise = b.z - a.z
	-- local ln_length = (((run * run) + (rise * rise))^0.5)

	-- return max(1, (abs((run * (a.z - p.z)) - ((a.x - p.x) * rise)) / ln_length))

	return abs((b.x - a.x) * (a.x - p.x)) / abs(b.x - a.x)

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

	local dm = mg_earth.config.dist_metric
	local edge


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
		this = get_dist(dist_x,dist_z,dm)
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

					-- mg_earth.edgemap = ""

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

	local dm = mg_earth.config.dist_metric

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
		this = get_3d_dist(dist_x,dist_y,dist_z,dm)
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

	local dm = mg_earth.config.dist_metric

	local c_midpoint
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.m_x
		local t_z = pos.z - i_neighbor.m_z

		this_dist = get_dist(t_x, t_z, dm)

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

	local dm = mg_earth.config.dist_metric

	local c_neighbor
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.n_x
		local t_z = pos.z - i_neighbor.n_z

		this_dist = get_dist(t_x, t_z, dm)

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

	local dm = mg_earth.config.dist_metric

	local c_neighbor
	local this_dist
	local last_dist

	for i, i_neighbor in pairs(ppoints) do

		local t_x = pos.x - i_neighbor.n_x
		local t_y = pos.y - i_neighbor.n_y
		local t_z = pos.z - i_neighbor.n_z

		this_dist = get_3d_dist(t_x, t_y, t_z, dm)

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

		this_dist = get_dist(t_x, t_z, mg_earth.config.dist_metric)

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

		this_dist = get_3d_dist(t_x, t_y, t_z, mg_earth.config.dist_metric)

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

	save_worldpath(newpoints, p_file .. "_" .. tostring(mg_world_scale) .. "_" .. mg_earth.config.dist_metric .. "_NEW_POINTS")

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
				if type(desc.node_cave_liquid) == "table" then
					mg_earth.biome_info[desc.name].b_cave_liquid = minetest.get_content_id(desc.node_cave_liquid[1]) or mg_earth.c_cave_liquid
				elseif type(desc.node_cave_liquid) == "string" then
					mg_earth.biome_info[desc.name].b_cave_liquid = minetest.get_content_id(desc.node_cave_liquid) or mg_earth.c_cave_liquid
				end
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

					-- mg_earth.biome_info[desc.name].min_pos = desc.min_pos or {x=-31000, y=-31000, z=-31000}
					-- if desc.y_min and desc.y_min ~= "" then
						-- mg_earth.biome_info[desc.name].min_pos.y = math.max(mg_earth.biome_info[desc.name].min_pos.y, desc.y_min)
					-- end
					-- -- if desc.y_min and desc.y_min ~= "" then
						-- -- mg_earth.biome_info[desc.name].min_pos = desc.y_min
					-- -- end
					-- -- if desc.min_pos and desc.min_pos.y then
						-- -- -- mg_earth.biome_info[desc.name].min_pos = desc.min_pos or {x=-31000, y=-31000, z=-31000}
						-- -- mg_earth.biome_info[desc.name].min_pos = {}
						-- -- mg_earth.biome_info[desc.name].min_pos.y = desc.min_pos.y
					-- -- end

			-- mg_earth.biome_info[desc.name].min_pos = desc.min_pos or {x=-31000, y=-31000, z=-31000}
			if desc.y_min and desc.y_min ~= "" then
				local min_p = desc.y_min or -31000
				mg_earth.biome_info[desc.name].min_pos = {x = 31000, y = min_p, z = 31000}
			end

			-- mg_earth.biome_info[desc.name].max_pos = desc.max_pos or {x=31000, y=31000, z=31000}
			if desc.y_max and desc.y_max ~= "" then
				local max_p = desc.y_max or -31000
				mg_earth.biome_info[desc.name].max_pos = {x = 31000, y = max_p, z = 31000}
			end

					-- mg_earth.biome_info[desc.name].max_pos = desc.max_pos or {x=31000, y=31000, z=31000}
					-- if desc.y_max and desc.y_max ~= "" then
						-- mg_earth.biome_info[desc.name].max_pos.y = math.min(mg_earth.biome_info[desc.name].max_pos.y, desc.y_max)
					-- end
					-- -- if desc.y_max and desc.y_max ~= "" then
						-- -- mg_earth.biome_info[desc.name].max_pos = desc.y_max
					-- -- end
					-- -- if desc.max_pos and desc.max_pos.y then
						-- -- -- mg_earth.biome_info[desc.name].max_pos = desc.max_pos or {x=31000, y=31000, z=31000}
						-- -- mg_earth.biome_info[desc.name].max_pos = {}
						-- -- mg_earth.biome_info[desc.name].max_pos.y = desc.max_pos.y
					-- -- end

			if desc.heat_point and desc.heat_point ~= "" then
				mg_earth.biome_info[desc.name].b_heat = desc.heat_point or 50
			end

			if desc.humidity_point and desc.humidity_point ~= "" then
				mg_earth.biome_info[desc.name].b_humid = desc.humidity_point or 50
			end


		end
	end
end

local function calc_biome_from_noise(heat, humid, pos)
	local biome_closest = nil
	local biome_closest_blend = nil
	local dist_min = 31000
	local dist_min_blend = 31000

	for i, biome in pairs(mg_earth.biome_info) do
		local min_pos, max_pos = biome.min_pos, biome.max_pos
		if pos.y >= min_pos.y and pos.y <= max_pos.y + biome.vertical_blend
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


mg_earth.get_heat_at_pos = function(z,x)

	return get_heat_scalar({x = x, y = 0, z = z}) + minetest.get_perlin(mg_earth["np_heat"]):get_2d({x = x, y = z})

end

mg_earth.get_humid_at_pos = function(z,x)

	return get_humid_scalar({x = x, y = 0, z = z}) + minetest.get_perlin(mg_earth["np_humid"]):get_2d({x = x, y = z})

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



--##Heightmap functions.  v6, v7, v67, vIslands, vVoronoi, vEarth and master get_mg_heightmap.
local function get_terrain_cliffs(theight,z,x)

	local cheight = minetest.get_perlin(mg_earth["np_cliffs"]):get_2d({x=x,y=z})

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

local function get_terrain_carpathia(theight,z,x)

	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_hills = minetest.get_perlin(mg_earth["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_carp_mnt_ridge"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_carp_mnt_step"]):get_2d({x=x,y=z})

	local hill_mnt = n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills
	local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))
	local step_mnt =  n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)

	local hilliness = theight * 0.1

	local hills = hill_mnt * hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = hills + ridged_mountains + step_mountains

	local surface_level = 12 + mountains
	-- local surface_level = 12 + theight + mountains
	-- local surface_level = theight + mountains

	return surface_level

end

local function get_carp_smooth(theight,z,x)

	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_hills = minetest.get_perlin(mg_earth["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_carp_mnt_ridge"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_carp_mnt_step"]):get_2d({x=x,y=z})

	local hill_mnt = (n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills) * 0.618033988749
	local ridge_mnt =  (n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))) * 0.618033988749
	local step_mnt =  (n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)) * 0.618033988749

	local hilliness = theight * 0.0618033988749

	local hills = hill_mnt * hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = hills + ridged_mountains + step_mountains

	local surface_level = (theight * 0.618033988749) + mountains

	return surface_level

end

local function get_carp_mount(theight,z,x)

	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_hills = minetest.get_perlin(mg_earth["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_carp_mnt_ridge"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_carp_mnt_step"]):get_2d({x=x,y=z})

	local hill_mnt = n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills
	local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))
	local step_mnt =  n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)

	local hilliness = theight * 0.0618033988749

	local hills = hill_mnt * hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = (hills + ridged_mountains + step_mountains) * 0.618033988749

	local surface_level = (theight * 0.618033988749) + mountains

	return surface_level

end

local function get_v5_height(z,x)

	local filldepth = minetest.get_perlin(mg_earth["np_v5_fill_depth"]):get_2d({x=x,y=z})
	local factor = minetest.get_perlin(mg_earth["np_v5_factor"]):get_2d({x=x,y=z})
	local height = minetest.get_perlin(mg_earth["np_v5_height"]):get_2d({x=x,y=z})
	-- -- local ground = minetest.get_perlin(mg_earth["np_v5_ground"]):get_3d({x=x,y=y,z=z})
	-- local ground = minetest.get_perlin(mg_earth["np_v5_ground"]):get_3d({x=x,y=-31000,z=z})

	local f = 0.55 * factor
	if (f < 0.01) then
		f = 0.01
	elseif (f >= 1.0) then
		-- f = 1.6
		f = f * 1.6
	end

	local h = height

	-- if (ground * f) < (y - h) then

	-- end

	--return f, h, ground
	return filldepth, f, h

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

	local terrain_base = minetest.get_perlin(mg_earth["np_v6_base"]):get_2d({
			x = x + 0.5 * mg_earth["np_v6_base"].spread.x,
			y = z + 0.5 * mg_earth["np_v6_base"].spread.y})

	local terrain_higher = minetest.get_perlin(mg_earth["np_v6_higher"]):get_2d({
			x = x + 0.5 * mg_earth["np_v6_higher"].spread.x,
			y = z + 0.5 * mg_earth["np_v6_higher"].spread.y})

	local steepness = minetest.get_perlin(mg_earth["np_v6_steep"]):get_2d({
			x = x + 0.5 * mg_earth["np_v6_steep"].spread.x,
			y = z + 0.5 * mg_earth["np_v6_steep"].spread.y})

	local height_select = minetest.get_perlin(mg_earth["np_v6_height"]):get_2d({
			x = x + 0.5 * mg_earth["np_v6_height"].spread.x,
			y = z + 0.5 * mg_earth["np_v6_height"].spread.y})

	return get_v6_base(terrain_base, terrain_higher, steepness, height_select) + 2 -- (Dust)
end

local function get_v7_height(z,x)

	local aterrain = 0

	local hselect = minetest.get_perlin(mg_earth["np_v7_height"]):get_2d({x=x,y=z})
	local hselect = rangelim(hselect, 0, 1)

	local persist = minetest.get_perlin(mg_earth["np_v7_persist"]):get_2d({x=x,y=z})

	mg_earth["np_v7_base"].persistence = persist;
	local height_base = minetest.get_perlin(mg_earth["np_v7_base"]):get_2d({x=x,y=z})

	mg_earth["np_v7_alt"].persistence = persist;
	local height_alt = minetest.get_perlin(mg_earth["np_v7_alt"]):get_2d({x=x,y=z})

	if (height_alt > height_base) then
		aterrain = floor(height_alt)
	else
		aterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
	end

	return aterrain
end

local function get_vCarp2d_height(z,x)

	--local n_base = minetest.get_perlin(mg_earth["np_carp_base"]):get_2d({x=x,y=z})
	--local n_fill = minetest.get_perlin(mg_earth["np_carp_filler_depth"]):get_2d({x=x,y=z})

	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_carp_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_theight1 = minetest.get_perlin(mg_earth["np_carp_height1"]):get_2d({x=x,y=z})
	local n_theight2 = minetest.get_perlin(mg_earth["np_carp_height2"]):get_2d({x=x,y=z})
	local n_theight3 = minetest.get_perlin(mg_earth["np_carp_height3"]):get_2d({x=x,y=z})
	local n_theight4 = minetest.get_perlin(mg_earth["np_carp_height4"]):get_2d({x=x,y=z})
	local n_hills = minetest.get_perlin(mg_earth["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_carp_mnt_step"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_carp_mnt_ridge"]):get_2d({x=x,y=z})

	local hill_mnt = n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills
	local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))

	local step_mnt =  n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)

	local n_mnt_var = abs(minetest.get_perlin(mg_earth["np_carp_mnt_var"]):get_3d({x=x,y=-31000,z=z}))

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

local function get_vCarp2d_vals(z,x)

	local grad_wl = 1 - mg_water_level;
	local y_terrain_height = -31000

	--local n_base = minetest.get_perlin(mg_earth["np_carp_base"]):get_2d({x=x,y=z})
	--local n_fill = minetest.get_perlin(mg_earth["np_carp_filler_depth"]):get_2d({x=x,y=z})

	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_carp_terrain_step"]):get_2d({x=x,y=z}))
	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_carp_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_carp_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_theight1 = minetest.get_perlin(mg_earth["np_carp_height1"]):get_2d({x=x,y=z})
	local n_theight2 = minetest.get_perlin(mg_earth["np_carp_height2"]):get_2d({x=x,y=z})
	local n_theight3 = minetest.get_perlin(mg_earth["np_carp_height3"]):get_2d({x=x,y=z})
	local n_theight4 = minetest.get_perlin(mg_earth["np_carp_height4"]):get_2d({x=x,y=z})
	local n_hills = minetest.get_perlin(mg_earth["np_carp_hills"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_carp_mnt_step"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_carp_mnt_ridge"]):get_2d({x=x,y=z})

	local hill_mnt = n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills
	local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))
	local step_mnt =  n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)

	return n_theight1, n_theight2, n_theight3, n_theight4, hill_mnt, ridge_mnt, step_mnt

end

local function get_diamondsquare_height(minp, maxp)

	-- diasq.create(width, height, f)
	mg_earth.diasq.create((maxp.x - minp.x + 1), (maxp.x - minp.x + 1), mg_earth.diasq_buf)

end

local function get_vEarth_height(z,x)

		local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = x, z = z}, 1)
		local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = x, z = z}, 2)

				-- mg_earth.cellmap[i2d] = {m=m_idx,p=p_idx}
				-- mg_earth.cellmap[i2d] = {m_i=m_idx,m_d=m_dist,m_z=m_z,m_x=m_x,p_i=p_idx,p_d=p_dist,p_z=p_z,p_x=p_x}

		local vcontinental = ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
		local vbase = (mg_base_height * 1.4) - vcontinental

		-- local valt = (vbase / vcontinental) * (mg_world_scale / 0.01)
		local vt_alt1 = (vbase / vcontinental) * (mg_world_scale / 0.01)
						-- local vt_alt2 = (vbase / vcontinental) * ((mg_base_height * 1.4) * mg_world_scale)
		local vt_alt2 = (vbase / vcontinental) * ((mg_base_height * 1.4) * 0.1)
						-- local vt_alt3 = (((mg_base_height * 1.4) * mg_world_scale) / vcontinental) * vbase
		local vt_alt3 = (((mg_base_height * 1.4) * 0.1) / vcontinental) * vbase

						-- local vterrain = (vbase * 0.25) + (vt_alt1 * 0.25) + (vt_alt2 * 0.25) + (vt_alt3 * 0.25)
						-- local vterrain = vbase + ((vt_alt1 + vt_alt2 + vt_alt3) / 3)
						-- local vterrain = vbase + vt_alt1 + vt_alt2 + vt_alt3
						-- local vterrain = (vbase * 0.1) + ((((vt_alt1 * 0.1) + vt_alt1) + ((vt_alt2 * 0.1) + vt_alt2) + ((vt_alt3 * 0.1) + vt_alt3)) / vcontinental)
				-- local vterrain = (vbase * 0.25) + ((((vt_alt1 * 0.10) + vt_alt1) + ((vt_alt2 * 0.10) + vt_alt2) + ((vt_alt3 * 0.15) + vt_alt3)) / vcontinental)

		-- local vterrain = (vbase * 0.12) + (vt_alt2 * 0.37)
		local vterrain = (vbase * 0.12) + ((vt_alt1 + vt_alt2 + vt_alt3) / 3)

		return vterrain

end

local function get_vIslands_height(z,x)

	local tterrain = 0

	local hselect = minetest.get_perlin(mg_earth["np_vislands_height"]):get_2d({x=x,y=z})
	local hselect = rangelim(hselect, 0, 1)

	local persist = minetest.get_perlin(mg_earth["np_vislands_persist"]):get_2d({x=x,y=z})

	mg_earth["np_vislands_base"].persistence = persist;
	local height_base = minetest.get_perlin(mg_earth["np_vislands_base"]):get_2d({x=x,y=z})

	mg_earth["np_vislands_alt"].persistence = persist;
	local height_alt = minetest.get_perlin(mg_earth["np_vislands_alt"]):get_2d({x=x,y=z})

	if (height_alt > height_base) then
		tterrain = floor(height_alt)
	else
		tterrain = floor((height_base * hselect) + (height_alt * (1 - hselect)))
	end

	-- local cliffs_thresh = floor((mg_earth["np_v7_alt"].scale) * 0.5)
	local cheight = minetest.get_perlin(mg_earth["np_cliffs"]):get_2d({x=x,y=z})

	local t_cliff = 0

	if tterrain > 1 and tterrain < mg_earth.config.cliffs_thresh then
		local clifh = max(min(cheight,1),0)
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			tterrain = tterrain + (mg_earth.config.cliffs_thresh - tterrain) * clifh * ((tterrain < 2) and tterrain - 1 or 1)
		end
	end

	return tterrain, t_cliff

end

local function get_vLargeIslands_height(z,x)

	local base_max_height = max_height(mg_earth["np_vlargeislands_base"])
	local alt_max_height = max_height(mg_earth["np_vlargeislands_alt"])
	local peak_max_height = max_height(mg_earth["np_vlargeislands_peak"])

	local aterrain = 0

	local hselect = minetest.get_perlin(mg_earth["np_vlargeislands_height"]):get_2d({x=x,y=z})
	local hselect = rangelim(hselect, 0, 1)
	local persist = minetest.get_perlin(mg_earth["np_vlargeislands_persist"]):get_2d({x=x,y=z})

	mg_earth["np_vlargeislands_base"].persistence = persist;
	mg_earth["np_vlargeislands_alt"].persistence = persist;
	mg_earth["np_vlargeislands_peak"].persistence = persist;

	mg_earth["np_vlargeislands_base"].lacunarity = 2 + (persist * 0.1);
	mg_earth["np_vlargeislands_alt"].lacunarity = 2 + (persist * 0.1);
	mg_earth["np_vlargeislands_peak"].lacunarity = 2 + (persist * 0.1);

	local height_base = minetest.get_perlin(mg_earth["np_vlargeislands_base"]):get_2d({x=x,y=z})
	local height_alt = minetest.get_perlin(mg_earth["np_vlargeislands_alt"]):get_2d({x=x,y=z})

	local height_peak = minetest.get_perlin(mg_earth["np_vlargeislands_peak"]):get_2d({x=x,y=z})
	-- local height_peak = minetest.get_perlin(mg_earth["np_vlargeislands_peak"]):get_2d({x=x,y=z}) - 35

			-- local h_base = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 50)
			-- local h_base = floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect)))
	-- local h_base = floor(height_base)

			-- local h_alt = floor(height_alt)
	-- local h_alt = floor((height_alt * hselect) + (height_base * (1 - hselect)))

	-- local h_peak = floor((floor((height_peak * hselect) + (height_alt * (1 - hselect))) * hselect) + (height_base * (1 - hselect)))

	local h_base = floor(height_base)
	-- local h_base_t = h_base * abs(h_base / base_max_height)
	-- local h_alt = floor((height_alt * hselect) + (height_base * (1 - hselect)))
	-- local h_alt_t = h_alt * abs(h_alt / alt_max_height)
	local h_peak = floor((height_peak * hselect) + (height_base * (1 - hselect)))
	-- local h_peak = floor((height_peak * hselect) + (floor((height_alt * hselect) + (height_base * (1 - hselect))) * (1 - hselect)))
	-- local h_peak_t = h_peak * abs(h_peak / peak_max_height)

	if (h_base > h_peak) then
	-- if (h_base > h_peak) then
		-- aterrain = h_base + h_base_t
		aterrain = h_base
	else
		-- aterrain = h_peak + h_peak_t
		-- aterrain = h_peak * abs(h_peak / peak_max_height)
		aterrain = h_peak
	end

	-- if (h_base > h_peak) then
		-- aterrain = h_base
	-- else
		-- -- if (height_alt > height_peak) then
			-- -- aterrain = h_alt
		-- -- else
			-- aterrain = h_peak
		-- -- end
		-- -- if (height_alt > height_peak) then
			-- -- aterrain = h_peak
		-- -- else
			-- -- aterrain = h_alt
		-- -- end
		-- -- if (height_peak > height_alt) then
			-- -- aterrain = h_alt
		-- -- else
			-- -- aterrain = h_peak
		-- -- end
		-- -- if (height_peak > height_alt) then
			-- -- aterrain = h_peak
		-- -- else
			-- -- aterrain = h_alt
		-- -- end
	-- end

			-- local taper_height_min = 8
			-- local taper_height = max(0,min(1,(max(0,min(taper_height_min,h_y)) / taper_height_min)))

			-- local v6_height = get_v6_height(z,x)
			-- local d_humid = 0
			-- if nhumid < 50 then
				-- d_humid = (get_v6_height(z,x) * ((50 - nhumid) / 50))
			-- end
			-- local v6_height = d_humid * 0.5

			-- local vcarp_height = get_vCarp2d_height(z,x)

			-- local n_y, n_c = get_terrain_height_cliffs(aterrain,z,x)

	local cheight = minetest.get_perlin(mg_earth["np_cliffs"]):get_2d({x=x,y=z})

	local t_cliff = 0

	if aterrain > 1 and aterrain < mg_earth.config.cliffs_thresh then
		local clifh = max(min(cheight,1),0)
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			aterrain = aterrain + (mg_earth.config.cliffs_thresh - aterrain) * clifh * ((aterrain < 2) and aterrain - 1 or 1)
		end
	end

	return aterrain, t_cliff

end

local function get_vAltNatural_height(z,x)

	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_step"]):get_2d({x=x,y=z}))
	local n_hills = minetest.get_perlin(mg_earth["np_vnatural_hills"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_vnatural_mnt_ridge"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_vnatural_mnt_step"]):get_2d({x=x,y=z})

	local persist = minetest.get_perlin(mg_earth["np_vnatural_persist"]):get_2d({x=x,y=z})
	mg_earth["np_vnatural_base"].persistence = persist;
	local height_base = minetest.get_perlin(mg_earth["np_vnatural_base"]):get_2d({x=x,y=z})

	local cheight = minetest.get_perlin(mg_earth["np_cliffs"]):get_2d({x=x,y=z})

	local t_cliff = 0

	local e_base = get_vEarth_height(z,x)

	local hill_mnt = (n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills) * 0.618033988749
	local ridge_mnt =  (n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))) * 0.618033988749
	local step_mnt =  (n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)) * 0.618033988749

	local h_base = floor(height_base)

	local hilliness = h_base * 0.0618033988749

	local hills = hill_mnt * hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = hills + ridged_mountains + step_mountains

	local surface_level = e_base + mountains

	if surface_level > 1 and surface_level < mg_earth.config.cliffs_thresh then
		local clifh = max(min(cheight,1),0)
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			surface_level = surface_level + (mg_earth.config.cliffs_thresh - surface_level) * clifh * ((surface_level < 2) and surface_level - 1 or 1)
		end
	end

	return surface_level, t_cliff

end

local function get_vNatural_height(z,x)

	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_step"]):get_2d({x=x,y=z}))
	local n_hills = minetest.get_perlin(mg_earth["np_vnatural_hills"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_vnatural_mnt_ridge"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_vnatural_mnt_step"]):get_2d({x=x,y=z})

	local persist = minetest.get_perlin(mg_earth["np_vnatural_persist"]):get_2d({x=x,y=z})
	mg_earth["np_vnatural_base"].persistence = persist;
	local height_base = minetest.get_perlin(mg_earth["np_vnatural_base"]):get_2d({x=x,y=z})

	local cheight = minetest.get_perlin(mg_earth["np_cliffs"]):get_2d({x=x,y=z})

	local t_cliff = 0

	local e_base = get_vEarth_height(z,x)

	local hill_mnt = (n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills) * 0.618033988749
	local ridge_mnt =  (n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))) * 0.618033988749
	local step_mnt =  (n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)) * 0.618033988749

	local h_base = floor(height_base)

	if h_base > 1 and h_base < mg_earth.config.cliffs_thresh then
		local clifh = max(min(cheight,1),0)
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			h_base = h_base + (mg_earth.config.cliffs_thresh - h_base) * clifh * ((h_base < 2) and h_base - 1 or 1)
		end
	end

	local hilliness = h_base * 0.0618033988749

	local hills = hill_mnt * hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = hills + ridged_mountains + step_mountains

	local surface_level = ((e_base + h_base) * 0.618033988749) + mountains

	return surface_level, t_cliff

end

local function BAK_get_vNatural_height(z,x)

	local n_terrain_hills = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_hills"]):get_2d({x=x,y=z}))
	local n_terrain_ridge = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_ridge"]):get_2d({x=x,y=z}))
	local n_terrain_step = abs(minetest.get_perlin(mg_earth["np_vnatural_terrain_step"]):get_2d({x=x,y=z}))
	local n_hills = minetest.get_perlin(mg_earth["np_vnatural_hills"]):get_2d({x=x,y=z})
	local n_mnt_ridge = minetest.get_perlin(mg_earth["np_vnatural_mnt_ridge"]):get_2d({x=x,y=z})
	local n_mnt_step = minetest.get_perlin(mg_earth["np_vnatural_mnt_step"]):get_2d({x=x,y=z})
	-- local n_mnt_var = abs(minetest.get_perlin(mg_earth["np_vnatural_mnt_var"]):get_3d({x=x,y=-31000,z=z}))

	-- local hselect = minetest.get_perlin(mg_earth["np_vnatural_height"]):get_2d({x=x,y=z})
	local persist = minetest.get_perlin(mg_earth["np_vnatural_persist"]):get_2d({x=x,y=z})
	mg_earth["np_vnatural_base"].persistence = persist;
	-- mg_earth["np_vnatural_alt"].persistence = persist;
	-- mg_earth["np_vnatural_mount"].persistence = persist;
	-- mg_earth["np_vnatural_peak"].persistence = persist;
	local height_base = minetest.get_perlin(mg_earth["np_vnatural_base"]):get_2d({x=x,y=z})
	-- local height_alt = minetest.get_perlin(mg_earth["np_vnatural_alt"]):get_2d({x=x,y=z})
	-- local height_mount = minetest.get_perlin(mg_earth["np_vnatural_mount"]):get_2d({x=x,y=z})
	-- local height_peak = minetest.get_perlin(mg_earth["np_vnatural_peak"]):get_2d({x=x,y=z})

	local cheight = minetest.get_perlin(mg_earth["np_cliffs"]):get_2d({x=x,y=z})


	-- local aterrain = 0
	local t_cliff = 0

	-- local hselect = rangelim(hselect, 0, 1)
	local e_base = get_vEarth_height(z,x)

	local hill_mnt = (n_terrain_hills * n_terrain_hills * n_terrain_hills * n_hills * n_hills) * 0.618033988749
	-- local hill_mnt = n_terrain_hills * n_terrain_hills * n_hills
	local ridge_mnt =  (n_terrain_ridge * n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))) * 0.618033988749
	-- local ridge_mnt =  n_terrain_ridge * n_terrain_ridge * (1.0 - abs(n_mnt_ridge))
	local step_mnt =  (n_terrain_step * n_terrain_step * n_terrain_step * steps(n_mnt_step)) * 0.618033988749
	-- local step_mnt =  n_terrain_step * n_terrain_step * steps(n_mnt_step)

	-- local max_base		= max_height(mg_earth["np_vnatural_base"])
	-- local max_alt		= max_height(mg_earth["np_vnatural_alt"])
	-- local max_peak		= max_height(mg_earth["np_vnatural_peak"])

	local h_base = floor(height_base)
				-- local h_base = height_base
	-- local h_alt = floor((height_alt * hselect) + (height_base * (1 - hselect)))
				-- local h_alt = height_alt
	-- local h_mount = floor((height_mount * hselect) + (height_base * (1 - hselect)))
				-- local h_mount = height_mount - 25
				-- local h_mount = floor((floor((height_mount * hselect) + (height_alt * (1 - hselect))) * hselect) + (height_base * (1 - hselect)))
	-- local h_peak = floor((height_peak * hselect) + (height_base * (1 - hselect))) - 35
	-- local h_peak = floor((height_peak * hselect) + (height_base * (1 - hselect))) - 30
				-- local h_peak = height_peak - 50
				-- local h_peak = floor((floor((height_peak * hselect) + (height_alt * (1 - hselect))) * hselect) + (height_base * (1 - hselect)))

	-- if (height_base > height_alt) then
		-- aterrain = h_base
	-- else
		-- aterrain = h_alt
	-- end
	-- if (h_base > h_peak) then
		-- aterrain = h_base
	-- else
		-- aterrain = h_peak
	-- end
				-- if (h_peak > h_base) then
					-- aterrain = h_peak
				-- elseif (h_mount > h_base) then
					-- aterrain = h_mount
				-- elseif (h_alt > h_base) then
					-- aterrain = h_alt
				-- else
					-- aterrain = h_base
				-- end

	-- aterrain = h_base
	if h_base > 1 and h_base < mg_earth.config.cliffs_thresh then
		local clifh = max(min(cheight,1),0)
		if clifh > 0 then
			clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			t_cliff = clifh
			h_base = h_base + (mg_earth.config.cliffs_thresh - h_base) * clifh * ((h_base < 2) and h_base - 1 or 1)
		end
	end


			-- local com1, com2, com3, com4
			-- -- com1 = lerp(h_base, h_mount, n_mnt_var)
			-- -- com2 = lerp(h_alt, h_peak, n_mnt_var)
			-- -- com3 = lerp(h_alt, h_mount, n_mnt_var)
			-- -- com4 = lerp(h_base, h_peak, n_mnt_var)
			-- com1 = lerp(h_base, h_alt, n_mnt_var)
			-- com2 = lerp(h_base, h_mount, n_mnt_var)
			-- com3 = lerp(h_base, h_peak, n_mnt_var)

			-- -- local hilliness = max(min(com1,com2),min(com3,com4))
			-- local hilliness = max(min(com1,com2),min(com1,com3))
		-- local hilliness = lerp((aterrain / max_peak), n_mnt_var)
		-- local hilliness = lerp((h_base / max_base), (h_peak / max_peak), n_mnt_var)
		-- local hilliness = lerp(h_base, h_peak, n_mnt_var)
		-- local hilliness = (aterrain / max_peak) * n_mnt_var
		-- local hilliness = (aterrain / max_base)
	-- local hilliness = aterrain
	-- local hilliness = h_base * 0.1
	local hilliness = h_base * 0.0618033988749
	-- local hilliness = h_base / max_base
	-- local hilliness = (h_base * h_base) / max_base
	-- local hilliness = ((h_base + e_base) / mg_base_height) * 10
	-- local hilliness = (h_base / max_base) * 10
	-- local hilliness = (e_base / mg_base_height) * 10


	local hills = hill_mnt * hilliness
			-- local hills = hilliness
	local ridged_mountains = ridge_mnt * hilliness
	local step_mountains = step_mnt * hilliness

	local mountains = hills + ridged_mountains + step_mountains
			-- local mountains = hilliness + (hill_mnt * ridge_mnt * step_mnt)

			-- local surface_level = 12 + mountains
			-- local surface_level = 12 + mountains + e_base
					-- local surface_level = aterrain
	local surface_level = e_base + mountains
	-- local surface_level = h_base + mountains
	-- local surface_level = 12 + mountains
	-- local surface_level = h_base + 12 + mountains


	-- local cheight = minetest.get_perlin(mg_earth["np_cliffs"]):get_2d({x=x,y=z})

	-- local t_cliff = 0

	-- if surface_level > 1 and surface_level < mg_earth.config.cliffs_thresh then
		-- local clifh = max(min(cheight,1),0)
		-- if clifh > 0 then
			-- clifh = -1 * (clifh - 1) * (clifh - 1) + 1
			-- t_cliff = clifh
			-- surface_level = surface_level + (mg_earth.config.cliffs_thresh - surface_level) * clifh * ((surface_level < 2) and surface_level - 1 or 1)
		-- end
	-- end

	-- return aterrain
	-- return surface_level
	return surface_level, t_cliff

end

local function get_valleys_height(z,x,i2d)

	-- Check if in a river channel
	local v_rivers = minetest.get_perlin(mg_earth["np_val_river"]):get_2d({x=x,y=z})
	local abs_rivers = abs(v_rivers)

	local valley    = minetest.get_perlin(mg_earth["np_val_depth"]):get_2d({x=x,y=z})
	local valley_d  = valley * valley
	local base      = valley_d + minetest.get_perlin(mg_earth["np_val_terrain"]):get_2d({x=x,y=z})
	local river     = abs_rivers - mg_earth.config.river_size_factor
	local tv        = max(river / minetest.get_perlin(mg_earth["np_val_profile"]):get_2d({x=x,y=z}), 0)
	local valley_h  = valley_d * (1 - math.exp(-tv * tv))
	local surface_y = base + valley_h
	local slope     = valley_h * minetest.get_perlin(mg_earth["np_val_slope"]):get_2d({x=x,y=z})

	-- mg_earth.surfacemap[i2d] = surface_y
	-- mg_earth.slopemap[i2d] = slope

--# 2D Generation
	local n_fill = minetest.get_perlin(mg_earth["np_val_fill"]):get_3d({x=x,y=surface_y,z=z})

	local surface_delta = n_fill - surface_y;
	local density = slope * n_fill - surface_delta;

	local river_course = 31000
	if abs_rivers <= mg_earth.config.river_size_factor then
		-- TODO: Add riverbed calculation
		river_course = abs_rivers
	end

	return density, river_course

end

local function get_valleys3D_height(z,x)

	-- Check if in a river channel
	local v_rivers = minetest.get_perlin(mg_earth["np_val_river"]):get_2d({x=x,y=z})
	local abs_rivers = abs(v_rivers)

	local valley    = minetest.get_perlin(mg_earth["np_val_depth"]):get_2d({x=x,y=z})
	local valley_d  = valley * valley
	local base      = valley_d + minetest.get_perlin(mg_earth["np_val_terrain"]):get_2d({x=x,y=z})
	local river     = abs_rivers - mg_earth.config.river_size_factor
	local tv        = max(river / minetest.get_perlin(mg_earth["np_val_profile"]):get_2d({x=x,y=z}), 0)
	local valley_h  = valley_d * (1 - math.exp(-tv * tv))
	local surface_y = base + valley_h
	local slope     = valley_h * minetest.get_perlin(mg_earth["np_val_slope"]):get_2d({x=x,y=z})

	local river_course = 31000
	if abs_rivers <= mg_earth.config.river_size_factor then
		-- TODO: Add riverbed calculation
		river_course = abs_rivers
	end

	return surface_y, slope, river_course

end

local function get_voronoi_cells(z,x,i2d)

	-- if mg_earth.config.enable_vEarth == true then

		-- local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = x, z = z}, 1)
		-- local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = x, z = z}, 2)

		-- -- mg_earth.cellmap[i2d] = {m=m_idx,p=p_idx}
		-- mg_earth.cellmap[i2d] = {m_i=m_idx,m_d=m_dist,m_z=m_z,m_x=m_x,p_i=p_idx,p_d=p_dist,p_z=p_z,p_x=p_x}

	-- end

	local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = x, z = z}, 1)
	local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = x, z = z}, 2)

	return m_idx, m_dist, m_z, m_x, p_idx, p_dist, p_z, p_x

end

local function get_mg_heightmap(ppos,nheat,nhumid,i2d)

	local dm = mg_earth.config.dist_metric
	-- local np = mg_earth.noise

	local rw = mg_earth.config.rivers.width
	local vw = mg_earth.config.mg_valley_size

	local r_y						= -31000
	local r_c						= 0

	local mp_y						= 0
	local mpheight					= 0

	local vheight					= 0
	local nheight					= 0
	local n_c						= 0

	local v3D_height				= 0
	local v5_height					= 0
	local v6_height					= 0
	local v7_height					= 0
	local vCarp_height				= 0
	local vDiaSqr_height			= 0
	local vEarth_height				= 0
	local vEarthSimple_height		= 0
	local vIslands_height			= 0
	local vLargeIslands_height		= 0
	local vAltNatural_height		= 0
	local vNatural_height			= 0
	local vValleys_height			= 0
	local v2d_noise_height			= 0
	local v3d_noise_height			= 0
	local vBuiltin_height			= 0
	local vSinglenode_height		= 0
	local vDev_height				= 0
	local vDev3D_height				= 0

	if mg_earth.config.enable_builtin_heightmap == true then
		-- local hm = minetest.get_mapgen_object("heightmap")
		-- local t_y = hm[i2d]
		-- -- mg_earth.heightmap[index2d] = t_y
		-- -- mg_earth.cliffmap[index2d] = 0
		-- vbuiltin_height = t_y
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			vBuiltin_height = h_y
		else
			vBuiltin_height = t_y
		end
	end

	if mg_earth.config.enable_singlenode_heightmap == true then
		if mg_earth.mapgen_rivers == true then
				-- r_y = mapgen_rivers.heightmap[i2d] + minetest.get_perlin(mg_earth["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z})
			-- r_y = mapgen_rivers.heightmap[i2d]

			-- vSinglenode_height = mapgen_rivers.heightmap[i2d]
			-- mg_earth.lakemap[i2d] = mapgen_rivers.lakemap[i2d]

			-- if mapgen_rivers.lakemap[i2d] > mapgen_rivers.heightmap[i2d] then
				-- mg_earth.rivermap[i2d] = mapgen_rivers.lakemap[i2d] - mapgen_rivers.heightmap[i2d]
			-- else
				-- mg_earth.rivermap[i2d] = -31000
			-- end

			local t_y = r_y
			local h_y = mg_earth.heightmap[i2d]
			if h_y and h_y > -31000 then
				vSinglenode_height = h_y
			else
				vSinglenode_height = t_y
			end
		end
	end

	if mg_earth.config.enable_v5 == true then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			v5_height = h_y
		else
			v5_height = t_y
		end
	end

	if mg_earth.config.enable_v6 == true then
		if mg_earth.config.enable_v6_scalar == true then
			local d_humid = 0
			if nhumid < 50 then
				d_humid = (get_v6_height(ppos.z,ppos.x) * ((50 - nhumid) / 50))
			end
			v6_height = d_humid * 0.5
		else
			v6_height = get_v6_height(ppos.z,ppos.x)
		end
	end

	if mg_earth.config.enable_v7 == true then
		v7_height = get_v7_height(ppos.z,ppos.x)
	end

	if mg_earth.config.enable_vCarp == true then
		if mg_earth.config.enable_3d_ver == true then
			local t_y = r_y
			local h_y = mg_earth.heightmap[i2d]
			if h_y and h_y > -31000 then
				vCarp_height = h_y
			else
				vCarp_height = t_y
			end
		else
			vCarp_height = get_vCarp2d_height(ppos.z,ppos.x)
		end
	end

	if mg_earth.config.enable_vIslands == true then
		vIslands_height, n_c = get_vIslands_height(ppos.z,ppos.x)
	end

	if mg_earth.config.enable_vLargeIslands == true then

				-- local aterrain = 0

				-- local hselect = minetest.get_perlin(mg_earth["np_v7_height"]):get_2d({x=ppos.x,y=ppos.z})
				-- local hselect = rangelim(hselect, 0, 1)
				-- local persist = minetest.get_perlin(mg_earth["np_v7_persist"]):get_2d({x=ppos.x,y=ppos.z})

				-- mg_earth["np_2d_alt"].persistence = persist;
				-- mg_earth["np_2d_base"].persistence = persist;
				-- mg_earth["np_2d_peak"].persistence = persist;

				-- mg_earth["np_2d_alt"].lacunarity = 2 + (persist * 0.1);
				-- mg_earth["np_2d_base"].lacunarity = 2 + (persist * 0.1);
				-- mg_earth["np_2d_peak"].lacunarity = 2 + (persist * 0.1);

				-- local height_base = minetest.get_perlin(mg_earth["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z})
				-- local height_alt = minetest.get_perlin(mg_earth["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z})

				-- local height_peak = minetest.get_perlin(mg_earth["np_2d_peak"]):get_2d({x=ppos.x,y=ppos.z})

				-- local h_alt = floor(height_alt)
				-- -- local h_base = (floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect))) - 50)
				-- local h_base = floor((height_peak * hselect) + (floor((height_base * hselect) + (height_alt * (1 - hselect))) * (1 - hselect)))

				-- if (height_alt > height_base) then
					-- aterrain = h_alt
				-- else
					-- aterrain = h_base
				-- end

				-- -- local taper_height_min = 8
				-- -- local taper_height = max(0,min(1,(max(0,min(taper_height_min,h_y)) / taper_height_min)))

				-- -- local v6_height = get_v6_height(ppos.z,ppos.x)
				-- -- local d_humid = 0
				-- -- if nhumid < 50 then
					-- -- d_humid = (get_v6_height(ppos.z,ppos.x) * ((50 - nhumid) / 50))
				-- -- end
				-- -- local v6_height = d_humid * 0.5

				-- -- local vcarp_height = get_vCarp2d_height(ppos.z,ppos.x)

				-- local n_y, n_c = get_terrain_height_cliffs(aterrain,ppos.z,ppos.x)
				-- -- vLargeIslands_height = n_y + v6_height
				-- vLargeIslands_height = n_y

		vLargeIslands_height, n_c = get_vLargeIslands_height(ppos.z,ppos.x)

	end

	if mg_earth.config.enable_vAltNatural == true then
		vAltNatural_height, n_c = get_vAltNatural_height(ppos.z,ppos.x)
	end

	if mg_earth.config.enable_vNatural == true then
		vNatural_height, n_c = get_vNatural_height(ppos.z,ppos.x)
	end

	if mg_earth.config.enable_vValleys == true then
		if mg_earth.config.enable_3d_ver == true then
			local t_y = r_y
			local h_y = mg_earth.heightmap[i2d]
			if h_y and h_y > -31000 then
				vValleys_height = h_y
			else
				vValleys_height = t_y
			end
		else
			local v_y, v_c = get_valleys_height(ppos.z,ppos.x,i2d)
			vValleys_height = v_y * -1
			mg_earth.valleysrivermap[i2d] = v_c
		end
	end

	if mg_earth.config.enable_vDiaSqr == true then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			vDiaSqr_height = h_y
		else
			vDiaSqr_height = t_y
		end
	end

	if mg_earth.config.enable_v2d_noise == true then

		v2d_noise_height = minetest.get_perlin(mg_earth["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z})

	end

	if mg_earth.config.enable_v3d_noise == true then

		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			v3d_noise_height = h_y
		else
			v3d_noise_height = t_y
		end
	end

	if mg_earth.config.enable_v3D == true then
		local t_y = r_y
		local h_y = mg_earth.heightmap[i2d]
		if h_y and h_y > -31000 then
			v3D_height = h_y
		else
			v3D_height = t_y
		end
	end

	if mg_earth.config.enable_vDev == true then

		local v2d_base_max_height = max_height(mg_earth["np_2d_base"])
		local v2d_alt_max_height = max_height(mg_earth["np_2d_alt"])

				-- local t_terrain = 0
				-- -- local t_y = r_y
				-- local t_y = 0
				-- local h_y = mg_earth.heightmap[i2d]
				-- if h_y and h_y > -31000 then
					-- t_terrain = h_y
				-- else
					-- t_terrain = t_y
				-- end

		local aterrain = 0

		local hselect = minetest.get_perlin(mg_earth["np_v7_height"]):get_2d({x=ppos.x,y=ppos.z})
		local hselect = rangelim(hselect, 0, 1)
		local persist = minetest.get_perlin(mg_earth["np_v7_persist"]):get_2d({x=ppos.x,y=ppos.z})

		mg_earth["np_2d_base"].persistence = persist;
		mg_earth["np_2d_alt"].persistence = persist;
		mg_earth["np_2d_peak"].persistence = persist;

		mg_earth["np_2d_base"].lacunarity = 2 + (persist * 0.1);
		mg_earth["np_2d_alt"].lacunarity = 2 + (persist * 0.1);
		mg_earth["np_2d_peak"].lacunarity = 2 + (persist * 0.1);

		local height_base = minetest.get_perlin(mg_earth["np_2d_base"]):get_2d({x=ppos.x,y=ppos.z})
		local height_alt = minetest.get_perlin(mg_earth["np_2d_alt"]):get_2d({x=ppos.x,y=ppos.z})
		local height_peak = minetest.get_perlin(mg_earth["np_2d_peak"]):get_2d({x=ppos.x,y=ppos.z})

		local h_base = floor(height_base)
		local h_base_t = h_base * abs(h_base / v2d_base_max_height)
		local h_alt = floor((height_alt * hselect) + (height_base * (1 - hselect)))
		local h_alt_t = h_alt * abs(h_alt / v2d_base_max_height)

		if (height_base > height_alt) then
			aterrain = h_base + h_base_t
		else
			aterrain = h_alt + h_alt_t
		end


				-- vDev_height = t_terrain + sin(ppos.z * 0.01)

				-- vDev_height = nheat + nhumid
				-- vDev_height = minetest.get_perlin(mg_earth["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z}) * (1 / nhumid)

			-- local t_terrain = minetest.get_perlin(mg_earth["np_2d_base"]):get_2d({x = ppos.x, y = ppos.z})
		-- local t_terrain = get_vLargeIslands_height(ppos.z,ppos.x)
			-- vDev_height = t_terrain * (nhumid / humid_max)
			-- vDev_height = (nhumid^0.5)
		-- vDev_height = t_terrain + (t_terrain * (t_terrain / v2d_base_max_height)) + (t_terrain * (t_terrain / v2d_alt_max_height))
		local n_y, n_c = get_terrain_cliffs(aterrain,ppos.z,ppos.x)
		-- vDev_height = aterrain
		vDev_height = n_y

	end

	if mg_earth.config.enable_vEarthSimple == true then
		vEarthSimple_height = get_vEarth_height(ppos.z,ppos.x)
	end

	-- if mg_earth.config.enable_vDev3D == true then

		-- --get_dist((m_x - p_n[p_ni].m_x), (m_z - p_n[p_ni].m_z), dm)

		-- -- vDev3D_height = sin((ppos.x + ppos.z) * 0.01) * 100
		-- -- -- vDev3D_height = (ppos.x + ppos.z) - 50

		-- vDev3D_height = sin(get_dist((ppos.x - 0), (ppos.z - 0), "e") * 0.1) * 10

	-- end


	local nterrain = v3D_height + v5_height + v6_height + v7_height + vCarp_height + vDiaSqr_height + vEarthSimple_height + vIslands_height + vLargeIslands_height + vAltNatural_height + vNatural_height + vValleys_height + v2d_noise_height + v3d_noise_height + vDev_height + vDev3D_height + vBuiltin_height + vSinglenode_height


	if mg_earth.config.enable_cliffs == true then
		nheight, n_c = get_terrain_cliffs(nterrain,ppos.z,ppos.x)
	else
		nheight = nterrain
	end

	-- if mg_earth.config.enable_carpathia == true then
		-- nheight = get_terrain_carpathia(nterrain,ppos.z,ppos.x)
	-- else
		-- nheight = nterrain
	-- end

	if mg_earth.config.enable_carp_mount == true then
		nheight = get_carp_mount(nterrain,ppos.z,ppos.x)
	else
		nheight = nterrain
	end

	if mg_earth.config.enable_carp_smooth == true then
		nheight = get_carp_smooth(nterrain,ppos.z,ppos.x)
	else
		nheight = nterrain
	end

	if mg_earth.config.enable_voronoi == true then

		local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 1)
		local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 2)

		-- mg_earth.cellmap[i2d] = {m=m_idx,p=p_idx}
		mg_earth.cellmap[i2d] = {m_i=m_idx,m_d=m_dist,m_z=m_z,m_x=m_x,p_i=p_idx,p_d=p_dist,p_z=p_z,p_x=p_x}

		-- local m_n = mg_neighbors[m_idx]
		-- local m_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, m_n)
		-- local p_n = mg_neighbors[p_idx]
		-- local p_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, p_n)

	end

	if mg_earth.config.enable_vEarth == true then

		local m_idx, m_dist, m_z, m_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 1)
				-- get_cell_neighbors(m_idx, m_z, m_x, 1)
		local p_idx, p_dist, p_z, p_x = get_nearest_cell({x = ppos.x, z = ppos.z}, 2)
				-- get_cell_neighbors(p_idx, p_z, p_x, 2)

				-- local pm_idx, pm_dist, pm_z, pm_x = get_nearest_cell({x = p_x, z = p_z}, 1)

				-- if m_idx ~= pm_idx then
					-- m_dist = (m_dist + pm_dist) / 2
				-- end

		-- mg_earth.cellmap[i2d] = {m=m_idx,p=p_idx}
		mg_earth.cellmap[i2d] = {m_i=m_idx,m_d=m_dist,m_z=m_z,m_x=m_x,p_i=p_idx,p_d=p_dist,p_z=p_z,p_x=p_x}

		local m_n = mg_neighbors[m_idx]
		local m_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, m_n)
		local p_n = mg_neighbors[p_idx]
		local p_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, p_n)

-- ## TECTONIC UPLIFT
		local t = {}
		local use_tectonics = "default"		--"all", "only", "alt", "default" (or blank),

--[[		if mg_earth.settings.voronoi_file == 1  then
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

			t.dist = get_dist((t.x - ppos.x), (t.z - ppos.z), dm)
				-- t.t2e_dist = get_dist((t.x - p_n[p_ni].m_x), (t.z - p_n[p_ni].m_z), dm)
				-- t.dir, t.comp = get_direction_to_pos({x = t.x, z = t.z},{x = ppos.x, z = ppos.z})

				--local t_n = t.neighbors
				--local t_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, t_n)
				--local t_ni = get_nearest_neighbor({x = ppos.x, z = ppos.z}, t.neighbors)

		else
			use_tectonics = "default"
		end--]]

		local vcontinental = 0
		local vbase = 0

			-- local mpcontinental = 0
			-- local mpbase = 0

--[[		if use_tectonics == "all" then

			vcontinental = ((t.dist * mg_earth.config.v_tscale) + (m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			vbase = (mg_base_height * 1.4) - ((t.dist * mg_earth.config.v_tscale) + (m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			-- mpcontinental = ((t.t2e_dist * mg_earth.config.v_tscale) + (m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
			-- mpbase = (mg_base_height * 1.4) - ((t.t2e_dist * mg_earth.config.v_tscale) + (m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))

		elseif use_tectonics == "only" then

			vcontinental = (t.dist * mg_earth.config.v_tscale)
			vbase = (mg_base_height * 1.4) - (t.dist * mg_earth.config.v_tscale)
			-- mpcontinental = (t.t2e_dist * mg_earth.config.v_tscale)
			-- mpbase = (mg_base_height * 1.4) - (t.t2e_dist * mg_earth.config.v_tscale)

		elseif use_tectonics == "alt" then

			vcontinental = ((t.dist * mg_earth.config.v_tscale) + (p_dist * mg_earth.config.v_pscale))
			vbase = (mg_base_height * 1.4) - ((t.dist * mg_earth.config.v_tscale) + (p_dist * mg_earth.config.v_pscale))
			-- mpcontinental = ((t.t2e_dist * mg_earth.config.v_tscale) + (p2e_dist * mg_earth.config.v_pscale))
			-- mpbase = (mg_base_height * 1.4) - ((t.t2e_dist * mg_earth.config.v_tscale) + (p2e_dist * mg_earth.config.v_pscale))

		else

			vcontinental = ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			vbase = (mg_base_height * 1.4) - vcontinental
			-- mpcontinental = ((m2e_dist * mg_earth.config.v_cscale) + (p2e_dist * mg_earth.config.v_pscale))
			-- mpbase = (mg_base_height * 1.4) - mpcontinental

		end--]]

		vcontinental = ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale))
			-- vcontinental = (m_dist + p_dist) * mg_earth.config.v_cscale
		vbase = (mg_base_height * 1.4) - vcontinental
			-- vbase = (mg_base_height * 1.4) - (m_dist + p_dist)

		local valt = (vbase / vcontinental) * (mg_world_scale / 0.01)
			-- local mpalt = (mpbase / mpcontinental) * (mg_world_scale / 0.01)

		local vterrain = (vbase * 0.2) + (valt * 0.37)
					-- local vterrain = (vbase * 0.25) + (valt * 0.5)
					-- local vterrain = (mg_base_height * -1.4) + vcontinental
					-- local vterrain = (vbase * 0.35) + (valt * 0.35)
								-- local vterrain = (vbase + valt) * 0.35
								-- local vterrain = (abs(vbase) / (mg_base_height * 1.4)) * vbase
						-- local vterrain = (abs(vbase) / (mg_base_height * 1.4)) * ((mg_base_height * 1.4) - ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale)))
						-- local vterrain = (mg_base_height * 1.4) * (1 / vcontinental)
					-- local vterrain = (abs(((mg_base_height * 1.4) - ((m_dist * mg_earth.config.v_cscale) + (p_dist * mg_earth.config.v_pscale)))) / (mg_base_height * 1.4)) * vbase
								-- local vterrain = (abs(vbase) / vcontinental) * vbase
					-- local vterrain = ((abs(vbase) / (mg_base_height * 1.4)) * vbase) / vcontinental
					-- local vterrain = ((abs(vbase) / (mg_base_height * 1.4)) * vbase) / (m_dist + p_dist)
					-- local vterrain = (vbase / vcontinental) * ((mg_base_height * 1.4) * mg_world_scale)
					-- local vterrain = (((mg_base_height * 1.4) * mg_world_scale) / vcontinental) * vbase
								-- local vterrain = (((((abs(vbase) / (mg_base_height * 1.4)) * vbase) / vcontinental) + (mg_base_height * 1.4)) + 100) * 0.1

		-- local vt_alt1 = (vbase / vcontinental) * (mg_world_scale / 0.01)
				-- local vt_alt2 = (vbase / vcontinental) * ((mg_base_height * 1.4) * mg_world_scale)
		-- local vt_alt2 = (vbase / vcontinental) * ((mg_base_height * 1.4) * 0.1)
				-- local vt_alt3 = (((mg_base_height * 1.4) * mg_world_scale) / vcontinental) * vbase
		-- local vt_alt3 = (((mg_base_height * 1.4) * 0.1) / vcontinental) * vbase

				-- local vterrain = (vbase * 0.25) + (vt_alt1 * 0.25) + (vt_alt2 * 0.25) + (vt_alt3 * 0.25)
				-- local vterrain = vbase + ((vt_alt1 + vt_alt2 + vt_alt3) / 3)
				-- local vterrain = vbase + vt_alt1 + vt_alt2 + vt_alt3
				-- local vterrain = (vbase * 0.1) + ((((vt_alt1 * 0.1) + vt_alt1) + ((vt_alt2 * 0.1) + vt_alt2) + ((vt_alt3 * 0.1) + vt_alt3)) / vcontinental)
		-- local vterrain = (vbase * 0.25) + ((((vt_alt1 * 0.10) + vt_alt1) + ((vt_alt2 * 0.10) + vt_alt2) + ((vt_alt3 * 0.15) + vt_alt3)) / vcontinental)
				-- local vterrain = (vbase * 0.25) + (((vt_alt1 + vt_alt2 + vt_alt3) * 0.25) / vcontinental)
				-- local vterrain = vbase + ((vt_alt1 + vt_alt2 + vt_alt3) / vcontinental)
				-- local vterrain = (vt_alt2 + vt_alt3) / vbase
				-- local vterrain = vt_alt2 + vt_alt3

								-- local mpterrain = (mpbase * 0.1) + (mpalt * 0.35)
								-- local mpterrain = (mpbase * 0.35) + (mpalt * 0.35)
								-- local mpterrain = (mpbase + mpalt) * 0.35

		vheight = vterrain
					-- mpheight = mpterrain

					-- vEarth_height = vheight
					-- mp_y = mpheight


		if mg_earth.config.rivers.enable == true then

			mg_earth.valleymap[i2d]			= -31000
			mg_earth.rivermap[i2d]			= -31000
			mg_earth.riverpath[i2d]			= 0
			-- mg_earth.lfmap[i2d]				= -31000
			-- mg_earth.lfpath[i2d]			= 0
			-- mg_earth.rfmap[i2d]				= -31000
			-- mg_earth.rfpath[i2d]			= 0

			--Distance from cell center point to nearest neighbor cell center point.
			local p2n_dist = get_dist((p_x - p_n[p_ni].n_x), (p_z - p_n[p_ni].n_z), dm)

			--Distance between cell center point and nearest edge
					-- local m2e_dist = get_dist((m_x - p_n[p_ni].m_x), (m_z - p_n[p_ni].m_z), dm)
					-- local p2e_dist = get_dist((p_x - p_n[p_ni].m_x), (p_z - p_n[p_ni].m_z), dm)

			--Distance to line drawn from cell center point to neighbor cell center point.
			local n2pe_dist = get_dist2line({x = p_x, z = p_z}, {x = p_n[p_ni].n_x, z = p_n[p_ni].n_z}, {x = ppos.x, z = ppos.z})

			--Return inverse slope of line drawn from cell center point to nearest neighbor cell center point.  Returns slope of line drawn by edge.
			--Direction to cell nearest neighbor.
					-- local me_dir, me_comp = get_direction_to_pos({x = m_x, z = m_z},{x = m_n[m_ni].m_x, z = m_n[m_ni].m_z})
			local pe_dir, pe_comp = get_direction_to_pos({x = p_x, z = p_z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})
					-- local dir_pos_to_midpoint, comp_pos_to_midpoint = get_direction_to_pos({x = ppos.x, z = ppos.z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})

					-- local p2e_slope = get_slope({x = p_x, z = p_z},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})
			--local e_slope = get_slope_inverse({x = p_x, z = p_z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})
			local e_slope = get_slope_inverse({x = p_x, z = p_z},{x = p_n[p_ni].n_x, z = p_n[p_ni].n_z})

			--Headwater Pos			--Triangulate from Voronoi Cell Center, Nearest Neighbor Midpoint, and Point 400 meters along the edge, (downstream)
			--Pos of fork / main stem convergence

			-- local p2e_midpoint_x, p2e_midpoint_z = get_midpoint({x = p_x, z = p_z},{x = p_n[p_ni].m_x, z = p_n[p_ni].m_z})

			-- local p2e_dir_to_half, p2e_comp_to_half = get_direction_to_pos({x = p2e_midpoint_x, z = p2e_midpoint_z}, {x = ppos.x, z = ppos.z})

			-- local p2e_mid_dir_to_cell, p2e_mid_comp_to_cell = get_direction_to_pos({x = p_x, z = p_z},{x = p2e_midpoint_x, z = p2e_midpoint_z})
			-- local p2e_mid_dir_to_edge, p2e_mid_comp_to_edge = get_direction_to_pos({x = p_n[p_ni].m_x, z = p_n[p_ni].m_z},{x = p2e_midpoint_x, z = p2e_midpoint_z})

			-- local lf_x = p2e_midpoint_x - (p2e_dist * 0.5)
			-- local lf_z = p2e_midpoint_z - ((p2e_dist * 0.5) * e_slope)
			-- local rf_x = p2e_midpoint_x + (p2e_dist * 0.5)
			-- local rf_z = p2e_midpoint_z + ((p2e_dist * 0.5) * e_slope)

			-- local lc_x = p_n[p_ni].m_x - (p2e_dist * 0.5)
			-- local lc_z = p_n[p_ni].m_z - ((p2e_dist * 0.5) * e_slope)
			-- local rc_x = p_n[p_ni].m_x + (p2e_dist * 0.5)
			-- local rc_z = p_n[p_ni].m_z + ((p2e_dist * 0.5) * e_slope)

			local t_valley_size = min(vw, max(0,(n2pe_dist / rw)))
			local t_valley_scale = max(0,(min(vw, max(1,(n2pe_dist / rw))) / vw))

			local n_river_jitter = minetest.get_perlin(mg_earth["np_river_jitter"]):get_2d({x = ppos.x, y = ppos.z})

			local t_sin = 0
			-- local lf_sin = 0
			-- local rf_sin = 0

			if (e_slope >= -1) and (e_slope <= 1) then
				-- t_sin = ((t_valley_size * 0.3) * sin(n2pe_dist * 0.008) + n_river_jitter) * pe_dir.z
				t_sin = sin(n2pe_dist * 0.008) * (t_valley_size * 0.3)
			else
				-- t_sin = ((t_valley_size * 0.3) * sin(n2pe_dist * 0.008) + n_river_jitter) * pe_dir.x
				t_sin = sin(n2pe_dist * 0.008) * (t_valley_size * 0.3)
			end

			-- local lf_slope = get_slope({x = lf_x, z = lf_z},{x = lc_x, z = lc_z})
			-- local rf_slope = get_slope({x = rf_x, z = rf_z},{x = rc_x, z = rc_z})

			--Length of fork
			-- local lf_len = get_dist((lf_x - lc_x), (lf_z - lc_z), dm)
			-- local rf_len = get_dist((rf_x - rc_x), (rf_z - rc_z), dm)

			--Distance along fork to main stream (voronoi cell edge)
			-- local lf2pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = lf_x, z = lf_z})
			-- local rf2pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = rf_x, z = rf_z})

			-- local lf_dist = get_dist((lf_x - ppos.x), (lf_z - ppos.z), dm)
			-- local rf_dist = get_dist((rf_x - ppos.x), (rf_z - ppos.z), dm)

			-- local lf_valley_size = min(vw, max(0,(lf_dist / rw)))
			-- local rf_valley_size = min(vw, max(0,(rf_dist / rw)))

			-- local lf_valley_scale = max(0,(min(vw, max(1,(lf_dist / rw))) / vw))
			-- local rf_valley_scale = max(0,(min(vw, max(1,(rf_dist / rw))) / vw))

--[[			if (lf_slope >= -1) and (lf_slope <= 1) then
				lf_sin = n_river_jitter * p2e_dir_to_half.z
			else
				lf_sin = n_river_jitter * p2e_dir_to_half.x
			end--]]

--[[			if (rf_slope >= -1) and (rf_slope <= 1) then
				rf_sin = n_river_jitter * p2e_dir_to_half.z
			else
				rf_sin = n_river_jitter * p2e_dir_to_half.x
			end--]]

			--Distance to cell edge
			local pe_dist = get_dist2endline_inverse({x = (p_x - t_sin), z = (p_z - t_sin)}, {x = p_n[p_ni].m_x, z = p_n[p_ni].m_z}, {x = ppos.x, z = ppos.z})

			--Distance to fork
			-- local lfe_dist = get_dist2line({x = (lf_x - lf_sin), z = (lf_z - lf_sin)}, {x = lc_x, z = lc_z}, {x = ppos.x, z = ppos.z})
			-- local rfe_dist = get_dist2line({x = (rf_x - rf_sin), z = (rf_z - rf_sin)}, {x = rc_x, z = rc_z}, {x = ppos.x, z = ppos.z})


			if (vheight + nheight) >= 0 then

				local terrain_scalar_inv = (max(0,((250 * mg_world_scale) - (vheight + nheight))) / (250 * mg_world_scale))
				local r_size = rw * terrain_scalar_inv

				if n2pe_dist >= (((vheight + nheight) + vw) - r_size) then
					local t_river_size = rw * t_valley_scale
					mg_earth.rivermap[i2d] = pe_dist
					mg_earth.riverpath[i2d] = t_river_size
					mg_earth.valleymap[i2d] = (rw - pe_dist) * t_valley_scale

				end

--[[				if (lf2pe_dist >= pe_dist) then
					local lf_river_size = rw * lf_valley_scale
					-- if lfe_dist >= 0 and lfe_dist < lf_river_size then
					if lfe_dist <= pe_dist and lfe_dist < lf_river_size then
						mg_earth.rivermap[i2d] = lfe_dist
						mg_earth.riverpath[i2d] = lf_river_size
						mg_earth.valleymap[i2d] = (rw - lfe_dist) * lf_valley_scale
					end
				end--]]

--[[				if (rf2pe_dist >= pe_dist) then
					local rf_river_size = rw * rf_valley_scale
					-- if rfe_dist >= 0 and rfe_dist < rf_river_size then
					if rfe_dist <= pe_dist and rfe_dist < rf_river_size then
						mg_earth.rivermap[i2d] = rfe_dist
						mg_earth.riverpath[i2d] = rf_river_size
						mg_earth.valleymap[i2d] = (rw - rfe_dist) * rf_valley_scale
					end
				end--]]

			end


			local tn_h = nheight * ((min((t_valley_size * 2),max(pe_dist, (t_valley_size + 1))) - t_valley_size) / t_valley_size)

			local bterrain = vheight + tn_h
			-- local bterrain = lerp(tn_h, vheight, 0.5)

			if (pe_dist <= t_valley_size) then
				--tn_h = nheight * ((pe_dist - vw) / vw)
				tn_h = nheight * ((min((vw * 2),max(pe_dist, (vw + 1))) - vw) / vw)
				local val_grad = (1 / max(1, (t_valley_size - max(0,min(pe_dist, t_valley_size)))))
				bterrain = vheight + (tn_h * val_grad)
			end

--[[			if (lfe_dist <= lf_valley_size) then
				tn_h = nheight * ((min(vw,max(lfe_dist, (vw + 1))) - vw) / vw)
				local val_grad = (1 / max(1, (lf_valley_size - max(0,min(lfe_dist, lf_valley_size)))))
				bterrain = vheight + (tn_h * val_grad)
			end--]]

--[[			if (rfe_dist <= rf_valley_size) then
				tn_h = nheight * ((min(vw,max(rfe_dist, (vw + 1))) - vw) / vw)
				local val_grad = (1 / max(1, (rf_valley_size - max(0,min(rfe_dist, rf_valley_size)))))
				bterrain = vheight + (tn_h * val_grad)
			end--]]

			vEarth_height = bterrain

		else

			local bterrain = vheight + nheight
			-- local bterrain = lerp(vheight, nheight, 0.5)
			vEarth_height = bterrain

		end

		r_y = vEarth_height

	else

		r_y = nheight

	end

	-- if (mg_earth.config.enable_heightmap == true) and (mg_heightmap_select == "vFlat") then
	if (mg_earth.config.enable_heightmap == true) then
		r_y = mg_earth.config.mg_flat_height
		r_c = 0
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
local function make_boulder(pos,area,data,form,c_stone,c_fill,c_top)

	local psize = {}
	local boulder_center_rand = {}
	local dist_metric = ""
	local chunk_idx = 4
	local chunk_rand = math.random(5,20)
	local h_x,h_y,h_z
	local points_location_select = "faces"

	if form == "none" then
		psize = {
			x = 16,
			y = 16,
			z = 16,
		}
		dist_metric = "c"
		chunk_idx = 4
		points_location_select = "faces"
	elseif form == "flat" then
		psize = {
			x = 16,
			y = 8,
			z = 16,
		}
		dist_metric = "m"
		chunk_idx = 4
		points_location_select = "faces"
	elseif form == "boulder" then
		psize = {
			x = 16,
			y = 16,
			z = 16,
		}
		dist_metric = "cm"
		chunk_idx = 8
		points_location_select = "cornerfaces"
	elseif form == "hoodoo" then
		psize = {
			x = 10,
			y = 30,
			z = 10,
		}
		dist_metric = "cm"
		chunk_idx = 4
		points_location_select = "faces"
	elseif form == "berg" then
		psize = {
			x = 16,
			y = 16,
			z = 16,
		}
		dist_metric = "c"
		chunk_idx = 8
		points_location_select = "cornerfaces"
	elseif form == "mesa" then
		psize = {
			x = 16,
			y = 16,
			z = 16,
		}
		dist_metric = "m"
		chunk_idx = 8
		points_location_select = "cornerfaces"
	else
		psize = {
			x = 8,
			y = 8,
			z = 8,
		}
		dist_metric = "e"
		chunk_idx = 4
		points_location_select = "faces"
	end

	h_x = (psize.x / 2)
	h_y = (psize.y / 2)
	h_z = (psize.z / 2)

	boulder_center_rand = {
		x = h_x + math.random(-2,2),
		y = h_y + math.random(-2,2),
		z = h_z + math.random(-2,2),
	}

	local point_locations = {
		--FACES
		faces = {
			{x=h_x,						y=psize.y,					z=h_z},										--(5,10,5)		top face
			{x=psize.x,					y=h_y,						z=h_z},										--(10,5,5)		right face
			{x=h_x,						y=h_y,						z=psize.z},									--(1,5,10)		back face
			{x=boulder_center_rand.x,	y=boulder_center_rand.y,	z=boulder_center_rand.z},					--(5,5,5)		center
						-- {x=h_x,						y=1,						z=h_z},										--(5,1,5)		center	(bottom face)
			{x=h_x,						y=h_y,						z=1},										--(5,5,1)		front face
			{x=1,						y=h_y,						z=h_z},										--(1,5,5)		left face
			{x=h_x,						y=1,						z=h_z},										--(5,1,5)		bottom face
		},
		--CORNERS and FACES
		cornerfaces = {
			{x=1,						y=psize.y,					z=psize.z},									--(1,10,10)		left  top back
			{x=psize.x,					y=psize.y,					z=psize.z},									--(10,10,10)	right top back
			{x=h_x,						y=psize.y,					z=h_z},										--(5,10,5)		top face
			{x=psize.x,					y=h_y,						z=h_z},										--(10,5,5)		right face
			{x=h_x,						y=h_y,						z=psize.z},									--(1,5,10)		back face
			{x=1,						y=1,						z=psize.z},									--(1,1,10)		left  bottom back
			{x=psize.x,					y=1,						z=psize.z},									--c(10,1,10)	right bottom back
			{x=boulder_center_rand.x,	y=boulder_center_rand.y,	z=boulder_center_rand.z},					--(5,5,5)		center
						-- {x=h_x,						y=1,						z=h_z},										--(5,1,5)		center	(bottom face)
			{x=1,						y=psize.y,					z=1},										--c(1,10,1)		left  top front
			{x=psize.x,					y=psize.y,					z=1},										--c(10,10,1)	right top front
			{x=h_x,						y=1,						z=h_z},										--(5,1,5)		bottom face
			{x=1,						y=h_y,						z=h_z},										--(1,5,5)		left face
			{x=h_x,						y=h_y,						z=1},										--(5,5,1)		front face
			{x=1,						y=1,						z=1},										--c(1,1,1)		left  bottom front
			{x=psize.x,					y=1,						z=1},										--c(10,1,1)		right bottom front
		},
		--EDGES
		edges = {
			{x=h_x,						y=1,						z=1},										--(5,1,1)		front center bottom			--front bottom edge
			{x=1,						y=h_y,						z=1},										--(1,5,1)		front left center			--front left edge
			{x=psize.x,					y=h_y,						z=1},										--(10,5,1)		front right center			--front right edge
			{x=h_x,						y=psize.y,					z=1},										--(5,10,1)		front center top			--front top edge
			{x=1,						y=1,						z=h_z},										--(1,1,5)		center left bottom
			{x=1,						y=psize.y,					z=h_z},										--(1,5,5)		center left top
			{x=boulder_center_rand.x,	y=boulder_center_rand.y,	z=boulder_center_rand.z},					--(5,5,5)		center
						-- {x=h_x,						y=1,						z=h_z},										--(5,1,5)		center	(bottom face)
			{x=psize.x,					y=1,						z=h_z},										--(10,5,5)		center right bottom
			{x=psize.x,					y=psize.y,					z=h_z},										--(5,10,5)		center right top
			{x=h_x,						y=1,						z=psize.z},									--(5,5,10)		back center bottom
			{x=1,						y=h_y,						z=psize.z},									--(5,5,10)		back left center
			{x=psize.x,					y=h_y,						z=psize.z},									--(1,10,10)		back right center
			{x=h_x,						y=psize.y,					z=psize.z},									--(10,10,10)	back center top
		},
		--CORNERS
		corners = {
			{x=1,						y=1,						z=1},										--(1,1,1)		left  bottom front
			{x=psize.x,					y=1,						z=1},										--(10,1,1)		right bottom front
			{x=1,						y=1,						z=psize.z},									--(1,1,10)		left  bottom back
			{x=psize.x,					y=1,						z=psize.z},									--(10,1,10)		right bottom back
			{x=boulder_center_rand.x,	y=boulder_center_rand.y,	z=boulder_center_rand.z},					--(5,5,5)		center
						-- {x=h_x,						y=1,						z=h_z},										--(5,1,5)		center	(bottom face)
			{x=1,						y=psize.y,					z=1},										--(1,10,1)		left  top front
			{x=psize.x,					y=psize.y,					z=1},										--(10,10,1)		right top front
			{x=1,						y=psize.y,					z=psize.z},									--(1,10,10)		left  top back
			{x=psize.x,					y=psize.y,					z=psize.z},									--(10,10,10)	right top back
		},
		--CHUNK POINTS  (CORNERS and FACES of minp / maxp)
		chunk_points = {
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
		},
	}

	local chunk_points = point_locations[points_location_select]

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

					-- local vi = area:index(pos.x+c_x, pos.y+c_y, pos.z+c_z)
					local vi = area:index(pos.x+c_x, pos.y+c_y, pos.z+c_z)

					-- if points_location_select == "chunk_points" then
						-- if c_y == (10 + chunk_rand) then
							-- data[vi] = c_top
						-- elseif c_y < (10 + chunk_rand) and c_y >= (5 + chunk_rand) then
							-- data[vi] = c_fill
						-- elseif c_y < (5 + chunk_rand) then
							-- data[vi] = c_stone
						-- else
							-- data[vi] = mg_earth.c_ignore
						-- end
					-- else
						data[vi] = c_stone
					-- end
				end

			end
		end
	end

end

local function make_road(minp, maxp, area, data)

	-- local nvals_bridge_column = nobj_bridge_column:get2dMap_flat({x = minp.x, y = minp.z}, nbuf_bridge_column)

	local i2d = 1

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do

			local t_height				= mg_earth.heightmap[i2d]
			local t_biome				= mg_earth.biomemap[i2d]
			local t_stone				= mg_earth.biome_info[t_biome].b_stone or mg_earth.c_stone

			-- if minp.y > t_height or maxp.y < t_height then
				-- return
			-- end

			local x_n, x_p, z_n, z_p

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

			if (mg_earth.roadheight[i2d] > -31000) and (mg_earth.roadheight[i2d] <= mg_earth.config.roads.max_height) then

				local pathy = mg_earth.roadheight[i2d]
				local excatop = pathy + 6

				-- if minp.y > pathy or maxp.y < pathy then
				if minp.y > excatop or maxp.y < (pathy - 2) then
					return
				end

				-- local abscol = abs(nvals_bridge_column[i2d])
				local abscol = minetest.get_perlin(mg_earth["np_bridge_column"]):get_2d({x=x,y=z})


				-- scan disk 5 nodes above path
				local tunnel = false
				-- local excatop

				for zz = z - z_n, z + z_p do
					local vi = area:index(x - x_n, pathy + 6, zz)
					for xx = x - x_n, x + x_p do
						local nodid = data[vi]
						if (nodid == mg_earth.c_stone) or (nodid == t_stone) or (nodid == mg_earth.c_ice) then
							tunnel = true
						end
						vi = vi + 1
					end
				end

				-- if tunnel then
					-- excatop = pathy + 6
				-- else
					-- excatop = pathy + 6
				-- end

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
						if (nodid ~= mg_earth.c_stone) and (nodid ~= t_stone) then
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
						for y = pathy - 2, t_height, -1 do
							local nodid = data[vi]
							if (nodid == mg_earth.c_stone) or (nodid == t_stone) then
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
							if nodid == t_stone then
								det_destone = true
							elseif nodid == mg_earth.c_ice then
								det_ice = true
							end
							if tunnel and y == excatop then -- tunnel ceiling
								if nodid ~= mg_earth.c_air
										and nodid ~= mg_earth.c_ignore
										and nodid ~= mg_earth.c_lamp then
									if (abs(zz - z) == 2
											or abs(xx - x) == 2)
											and random() <= 0.2 then
										data[vi] = mg_earth.c_lamp
									elseif det_destone then
										data[vi] = t_stone
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
							end
							vi = vi + 1
						end
					end
				end
			end

			i2d = i2d + 1
		end
	end


end

local function make_street(minp, maxp, area, data)

	-- local nvals_bridge_column = nobj_bridge_column:get2dMap_flat({x = minp.x, y = minp.z}, nbuf_bridge_column)

	local i2d = 1

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do

			local t_height				= mg_earth.heightmap[i2d]
			local t_biome				= mg_earth.biomemap[i2d]
			local t_stone				= mg_earth.biome_info[t_biome].b_stone or mg_earth.c_stone

			-- if minp.y > t_height or maxp.y < t_height then
				-- return
			-- end

			local x_n, x_p, z_n, z_p

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


			if (mg_earth.streetheight[i2d] > -31000) and (mg_earth.streetheight[i2d] <= mg_earth.config.streets.max_height) then

				local pathy = mg_earth.streetheight[i2d]
				local excatop = pathy + 6

				-- if minp.y > pathy or maxp.y < pathy then
				if minp.y > excatop or maxp.y < (pathy - 2) then
					return
				end

				-- local abscol = abs(nvals_bridge_column[i2d])
				local abscol = minetest.get_perlin(mg_earth["np_bridge_column"]):get_2d({x=x,y=z})

				-- scan disk 5 nodes above path
				local tunnel = false
				-- local excatop

				for zz = z - z_n, z + z_p do
					local vi = area:index(x - x_n, pathy + 5, zz)
					for xx = x - x_n, x + x_p do
						local nodid = data[vi]
						if (nodid == mg_earth.c_stone) or (nodid == t_stone) or (nodid == mg_earth.c_ice) then
							tunnel = true
						end
						vi = vi + 1
					end
				end

				-- if tunnel then
					-- excatop = pathy + 6
				-- else
					-- excatop = pathy + 6
				-- end

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
				-- if math.random() <= 0.0625 then
				if (abscol < 0.3) then
					for xx = x - 1, x + 1 do
					for zz = z - 1, z + 1 do
						local vi = area:index(xx, pathy - 3, zz)
						-- for y = pathy - 3, t_height - 16, -1 do
						for y = pathy - 3, t_height, -1 do
							local nodid = data[vi]
							if (nodid == mg_earth.c_stone) or (nodid == t_stone) then
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
										and nodid ~= mg_earth.c_lamp then
									if (math.abs(zz - z) == 4
											or math.abs(xx - x) == 4)
											and math.random() <= 0.2 then
										data[vi] = mg_earth.c_lamp
									else
										data[vi] = mg_earth.c_concrete
									end
								end
							-- elseif y <= pathy + 5 then
							elseif y <= excatop then
								if nodid ~= mg_earth.c_roadblack
										and nodid ~= mg_earth.c_roadslab
										and nodid ~= mg_earth.c_roadwhite then
									data[vi] = mg_earth.c_air
								end
							end
							vi = vi + 1
						end
					end
				end
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


local function generate_2dNoise_map(minp, maxp, seed)

	if mg_earth.config.enable_v5 == true then

		-- mg_earth.v5_factormap = {}
		-- mg_earth.v5_heightmap = {}

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local filldepth, factor, height = get_v5_height(z,x)

				mg_earth.v5_filldepthmap[index2d] = filldepth
				mg_earth.v5_factormap[index2d] = factor
				mg_earth.v5_heightmap[index2d] = height

				-- ground = minetest.get_perlin(mg_earth["np_v5_ground"]):get_3d({x=x,y=-31000,z=z})

						-- -- if (ground * factor) >= (y - height) then
						-- if (ground * factor) >= (y - height) then
							-- mg_earth.heightmap[index2d] = y
						-- end

				-- mg_earth.heightmap[index2d] = (ground * factor) + height

				index2d = index2d + 1

			end
		end

	end

	if (mg_earth.config.enable_vCarp == true) and (mg_earth.config.enable_3d_ver == true) then

		mg_earth.carpmap = {}

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local n_t1, n_t2, n_t3, n_t4, h_mnt, r_mnt, s_mnt = get_vCarp2d_vals(z,x)

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

				local n_mnt_var = abs(minetest.get_perlin(mg_earth["np_carp_mnt_var"]):get_3d({x=x,y=-31000,z=z}))

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

	if mg_earth.config.enable_vDiaSqr == true then

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local ds_map = (mg_earth.diasq_buf[z + (mg_earth.config.diasq_size / 2)][x + (mg_earth.config.diasq_size / 2)])
				mg_earth.heightmap[index2d] = ds_map * 0.25

				index2d = index2d + 1

			end
		end

	end

	if (mg_earth.config.enable_vValleys == true) and (mg_earth.config.enable_3d_ver == true) then

		-- mg_earth.surfacemap = {}
		-- mg_earth.slopemap = {}
		-- mg_earth.valleysrivermap = {}

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local surface_y, slope, river_course = get_valleys3D_height(z,x)

			-- --# 2D Generation
				local n_fill = minetest.get_perlin(mg_earth["np_val_fill"]):get_3d({x=x,y=surface_y,z=z})

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

	local y_stride_3d = (maxp.x - minp.x + 1)
	local z_stride_3d = y_stride_3d * y_stride_3d

	if mg_world_scale == 1 then

		if mg_earth.settings.enable_caves then

			nobj_cave1 = nobj_cave1 or minetest.get_perlin_map(mg_earth["np_cave1"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cave1 = nobj_cave1:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			nobj_cave2 = nobj_cave2 or minetest.get_perlin_map(mg_earth["np_cave2"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cave2 = nobj_cave2:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

		end

		if mg_earth.settings.enable_caverns then

			nobj_cavern1 = nobj_cavern1 or minetest.get_perlin_map(mg_earth["np_cavern1"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cavern1 = nobj_cavern1:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			nobj_cavern2 = nobj_cavern2 or minetest.get_perlin_map(mg_earth["np_cavern2"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_cavern2 = nobj_cavern2:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			nobj_wave = nobj_wave or minetest.get_perlin_map(mg_earth["np_wave"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_wave = nobj_wave:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

		end

		if mg_earth.config.enable_v3d_noise == true then

			nobj_3d_noise = nobj_3d_noise or minetest.get_perlin_map(mg_earth["np_3d_noise"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_3d_noise = nobj_3d_noise:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

		end

		if mg_earth.config.enable_v3D == true then

			nobj_3dterrain = nobj_3dterrain or minetest.get_perlin_map(mg_earth["np_3dterrain"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_3dterrain = nobj_3dterrain:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

		end

		if (mg_earth.config.enable_vCarp == true) and (mg_earth.config.enable_3d_ver == true) then

			nobj_carp_mnt_var = nobj_carp_mnt_var or minetest.get_perlin_map(mg_earth["np_carp_mnt_var"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_carp_mnt_var = nobj_carp_mnt_var:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

		end

		if mg_earth.config.enable_v5 == true then
			nobj_v5_ground = nobj_v5_ground or minetest.get_perlin_map(mg_earth["np_v5_ground"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_v5_ground = nobj_v5_ground:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
			-- -- local nobj_v5_ground = mg_earth.noise_handler.get_noise_object(mg_earth["np_v5_ground"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			-- -- local nbuf_v5_ground = nobj_v5_ground.get_3d_map(minp)

			-- nbuf_v5_ground = mg_earth.noisemap(nobj_v5_ground, mg_earth["np_v5_ground"], minp3d, csize)

		end

		if (mg_earth.config.enable_vValleys == true) and (mg_earth.config.enable_3d_ver == true) then

			nobj_val_fill = nobj_val_fill or minetest.get_perlin_map(mg_earth["np_val_fill"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = maxp.x - minp.x + 1})
			nbuf_val_fill = nobj_val_fill:get_3d_map({x=minp.x,y=minp.y,z=minp.z})

		end

	end

	if mg_earth.config.enable_v3d_noise == true then

		-- mg_earth.densitymap = {}
		-- local nvals_3d_noise = nobj_3d_noise:get_3d_map_flat({x = minp.x, y = minp.y, z = minp.z}, nbuf_3d_noise)

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local n_f = 0

					if mg_world_scale == 1 then
						n_f = nbuf_3d_noise[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_f = minetest.get_perlin(mg_earth["np_3d_noise"]):get_3d({x = x, y = y, z = z})
					end

					-- mg_earth.heightmap[index2d] = nvals_3d_noise[index3d]
					mg_earth.heightmap[index2d] = n_f

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	if mg_earth.config.enable_v3D == true then

		-- mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local n_f = 0

					if mg_world_scale == 1 then
						n_f = nbuf_3dterrain[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_f = minetest.get_perlin(mg_earth["np_3dterrain"]):get_3d({x = x, y = y, z = z})
					end

					local density = (n_f + ((1 - y) / (mg_earth.config.terrain_density * mg_world_scale)))

					if density > 0 then
						mg_earth.heightmap[index2d] = y
					end

					mg_earth.densitymap[index3d] = density

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	if (mg_earth.config.enable_vCarp == true) and (mg_earth.config.enable_3d_ver == true) then

		-- mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local grad_wl = 1 - mg_water_level;
					local y_terrain_height = -31000

					local n_theight1 = mg_earth.carpmap[index2d].n_theight1
					local n_theight2 = mg_earth.carpmap[index2d].n_theight2
					local n_theight3 = mg_earth.carpmap[index2d].n_theight3
					local n_theight4 = mg_earth.carpmap[index2d].n_theight4
					local hill_mnt = mg_earth.carpmap[index2d].hill_mnt
					local ridge_mnt = mg_earth.carpmap[index2d].ridge_mnt
					local step_mnt = mg_earth.carpmap[index2d].step_mnt

					local n_mnt_var = 0

					if mg_world_scale == 1 then
						n_mnt_var = nbuf_carp_mnt_var[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_mnt_var = minetest.get_perlin(mg_earth["np_carp_mnt_var"]):get_3d({x = x, y = y, z = z})
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

		-- mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local n_3d_val = 0

					if mg_world_scale == 1 then
						n_3d_val = nbuf_3dterrain[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_3d_val = minetest.get_perlin(mg_earth["np_3dterrain"]):get_3d({x=x,y=y,z=z})
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

	if mg_earth.config.enable_v5 == true then

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local filldepth = mg_earth.v5_filldepthmap[index2d]
					local factor = mg_earth.v5_factormap[index2d]
					local height = mg_earth.v5_heightmap[index2d]
					local ground = 0

					if mg_world_scale == 1 then
						ground = nbuf_v5_ground[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						ground = minetest.get_perlin(mg_earth["np_v5_ground"]):get_3d({x=x,y=y,z=z})
					end

					mg_earth.v5_groundmap[index3d] = ground


											-- local hm = mg_earth.heightmap[index2d] or -31000
											-- local t_height = max(-31000, hm)

					local density = ((ground * factor) + height)

					if (ground * factor) >= (y - height) then
					-- if density >= 0 then
					-- if density >= y then

						mg_earth.heightmap[index2d] = y

					end

					-- mg_earth.heightmap[index2d] = density + ground
					-- mg_earth.densitymap[index3d] = density


					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end

	end

	if (mg_earth.config.enable_vValleys == true) and (mg_earth.config.enable_3d_ver == true) then

		-- mg_earth.densitymap = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					local n_fill = 0

					if mg_world_scale == 1 then
						n_fill = nbuf_val_fill[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						n_fill = minetest.get_perlin(mg_earth["np_val_fill"]):get_3d({x=x,y=y,z=z})
					end

					local surface_delta_y = y - mg_earth.surfacemap[index2d]

					local density_y = mg_earth.slopemap[index2d] * n_fill - surface_delta_y

					mg_earth.densitymap[index3d] = density_y

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end

	end

	if mg_earth.config.caves.enable == true then

		-- mg_earth.cave1map = {}
		-- mg_earth.cave2map = {}

		local index2d = 1
		local index3d = 1

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					if mg_world_scale == 1 then
						mg_earth.cave1map[index3d] = nbuf_cave1[z-minp.z+1][y-minp.y+1][x-minp.x+1]
						mg_earth.cave2map[index3d] = nbuf_cave2[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					else
						mg_earth.cave1map[index3d] = minetest.get_perlin(mg_earth["np_cave1"]):get_3d({x = x, y = y, z = z})
						mg_earth.cave2map[index3d] = minetest.get_perlin(mg_earth["np_cave2"]):get_3d({x = x, y = y, z = z})
					end


					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end

	end

	if mg_earth.config.caverns.enable == true then

		-- mg_earth.cavern1map = {}
		-- mg_earth.cavern2map = {}
		-- mg_earth.cavernwavemap = {}

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
						mg_earth.cavern1map[index3d] = minetest.get_perlin(mg_earth["np_cavern1"]):get_3d({x = x, y = y, z = z})
						mg_earth.cavern2map[index3d] = minetest.get_perlin(mg_earth["np_cavern2"]):get_3d({x = x, y = y, z = z})
						mg_earth.cavernwavemap[index3d] = minetest.get_perlin(mg_earth["np_wave"]):get_3d({x = x, y = y, z = z})
					end

					index2d = index2d + 1
					index3d = index3d + 1

				end
				index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
			end
			index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
		end
	end

	if mg_earth.config.enable_builtin_heightmap == true then

		local hm = minetest.get_mapgen_object("heightmap")

		local index2d = 1

		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do

				local t_y = hm[index2d]
				mg_earth.heightmap[index2d] = t_y

				index2d = index2d + 1

			end
		end

	end

	if mg_earth.config.enable_singlenode_heightmap == true then
		if mg_earth.mapgen_rivers == true then

			-- local hm = mapgen_rivers.heightmap

			local index2d = 1

			for z = minp.z, maxp.z do
				for x = minp.x, maxp.x do

					-- local t_y = hm[index2d]
					-- mg_earth.heightmap[index2d] = t_y

					mg_earth.heightmap[index2d] = mapgen_rivers.heightmap[index2d]
					mg_earth.lakemap[index2d] = mapgen_rivers.lakemap[index2d]

					if mapgen_rivers.lakemap[index2d] > mapgen_rivers.heightmap[index2d] then
						mg_earth.rivermap[index2d] = mapgen_rivers.lakemap[index2d] - mapgen_rivers.heightmap[index2d]
					else
						mg_earth.rivermap[index2d] = -31000
					end

					index2d = index2d + 1

				end
			end
		end
	end

end


local function generate_2d_roads(minp, maxp, area)

	-- Parameters
	local YFLAT = 7 -- Flat area elevation y
	local YSAND = 4 -- Top of beach y
	local TERSCA = 192 -- Vertical terrain scale in nodes
	local STODEP = 5 -- Stone depth below surface in nodes at sea level
	local TGRID = 0.18 -- City grid area width
	local TFLAT = 0.2 -- Flat coastal area width
	local TCITY = 0.5 -- City size.		-- 0.3 = 1/3 of coastal land area, 0 = 1/2 of coastal land area.
	local TFIS = 0 -- Fissure width

	local ch_half = ((maxp.x - minp.x + 1) / 2)
	local cross,nroad,eroad,sroad,wroad

--[[if (mg_earth.config.roads.enable == true) or (mg_earth.config.streets.enable == true) then
		nobj_bridge_column = nobj_bridge_column or minetest.get_perlin_map(mg_earth["np_bridge_column"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
		-- local nvals_bridge_column = nobj_bridge_column:get2dMap_flat({x = minp.x, y = minp.z}, nbuf_bridge_column)
	end--]]

--[[if (mg_earth.config.paths.enable == true) or (mg_earth.config.roads.enable == true) or (mg_earth.config.streets.enable == true) then
		nobj_road_jitter	= nobj_road_jitter   or minetest.get_perlin_map(mg_earth["np_road_jitter"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
		nbuf_road_jitter	= nobj_road_jitter:get_2d_map({x = minp.x, y = minp.z})
	end--]]

	if (mg_earth.config.city.enable == true) then
				-- nobj_grid_base   = nobj_grid_base   or minetest.get_perlin_map(mg_earth["np_grid_base"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
				-- nobj_grid_road   = nobj_grid_road   or minetest.get_perlin_map(mg_earth["np_grid_road"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
		nobj_grid_city   = nobj_grid_city   or minetest.get_perlin_map(mg_earth["np_grid_city"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})

				-- nbuf_grid_base = nobj_grid_base:get_2d_map({x = minp.x, y = minp.z})
				-- nbuf_grid_road = nobj_grid_road:get_2d_map({x = minp.x, y = minp.z})
		nbuf_grid_city = nobj_grid_city:get_2d_map({x = minp.x, y = minp.z})

				-- local cross = nbuf_grid_base[ch_half][ch_half] < TGRID and nbuf_grid_city[ch_half][ch_half] > TCITY
				-- local nroad = nbuf_grid_base[(maxp.x - minp.x)][ch_half] < TGRID and nbuf_grid_city[(maxp.x - minp.x)][ch_half] > TCITY
				-- local eroad = nbuf_grid_base[ch_half][(maxp.z - minp.z)] < TGRID and nbuf_grid_city[ch_half][(maxp.z - minp.z)] > TCITY
				-- local sroad = nbuf_grid_base[1][ch_half] < TGRID and nbuf_grid_city[1][ch_half] > TCITY
				-- local wroad = nbuf_grid_base[ch_half][1] < TGRID and nbuf_grid_city[ch_half][1] > TCITY
		cross = nbuf_grid_city[ch_half][ch_half] > TCITY
		nroad = nbuf_grid_city[(maxp.x - minp.x)][ch_half] > TCITY
		eroad = nbuf_grid_city[ch_half][(maxp.z - minp.z)] > TCITY
		sroad = nbuf_grid_city[1][ch_half] > TCITY
		wroad = nbuf_grid_city[ch_half][1] > TCITY

	end

	local i2d = 1
	local plot_height = -31000

	for z = minp.z, maxp.z do

				-- local n_xpreroad = -31000

		for x = minp.x, maxp.x do

			-- if minp.y > 0 or maxp.y < 0 then
				-- return
			-- end

			local x_n, x_p, z_n, z_p

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

--[[		if x > (minp.x + 1) then
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

			local n_road_jitter = minetest.get_perlin(mg_earth["np_road_jitter"]):get_2d({x=x,y=z})

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

			-- local xsn_t, xsp_t, zsn_t, zsp_t
			-- local xosn_t, xosp_t, zosn_t, zosp_t
			-- local xisn_t, xisp_t, zisn_t, zisp_t
			local x8sn_t, x8sp_t, z8sn_t, z8sp_t
			local x7sn_t, x7sp_t, z7sn_t, z7sp_t
			local x6sn_t, x6sp_t, z6sn_t, z6sp_t
			local x5sn_t, x5sp_t, z5sn_t, z5sp_t
			local x4sn_t, x4sp_t, z4sn_t, z4sp_t
			local x3sn_t, x3sp_t, z3sn_t, z3sp_t
			local x2sn_t, x2sp_t, z2sn_t, z2sp_t
			local x1sn_t, x1sp_t, z1sn_t, z1sp_t
			local x_avg, z_avg
			local xs_t_diff, zs_t_diff
			-- local x_dist, z_dist
			local stride = (maxp.x - minp.x + 1)

			-- --Get terrain height values along x and z axis, at +/- 10, +/-5 and +/-2 meters.
			-- Get terrain height values along a line of the x or z axis from -4 to +4 meters from center.
			-- Call heightmap function or use heightmap, depending on distance from minp and maxp
			if x >= (minp.x + 8) then
				x8sn_t = mg_earth.heightmap[i2d - 8]
				x7sn_t = mg_earth.heightmap[i2d - 7]
				x6sn_t = mg_earth.heightmap[i2d - 6]
				x5sn_t = mg_earth.heightmap[i2d - 5]
				x4sn_t = mg_earth.heightmap[i2d - 4]
				x3sn_t = mg_earth.heightmap[i2d - 3]
				x2sn_t = mg_earth.heightmap[i2d - 2]
				x1sn_t = mg_earth.heightmap[i2d - 1]
			else
				x8sn_t = get_mg_heightmap({x = (x - 8), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x7sn_t = get_mg_heightmap({x = (x - 7), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x6sn_t = get_mg_heightmap({x = (x - 6), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x5sn_t = get_mg_heightmap({x = (x - 5), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x4sn_t = get_mg_heightmap({x = (x - 4), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x3sn_t = get_mg_heightmap({x = (x - 3), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x2sn_t = get_mg_heightmap({x = (x - 2), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x1sn_t = get_mg_heightmap({x = (x - 1), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
			end
			if x <= (maxp.x - 8) then
				x8sp_t = mg_earth.heightmap[i2d + 8]
				x7sp_t = mg_earth.heightmap[i2d + 7]
				x6sp_t = mg_earth.heightmap[i2d + 6]
				x5sp_t = mg_earth.heightmap[i2d + 5]
				x4sp_t = mg_earth.heightmap[i2d + 4]
				x3sp_t = mg_earth.heightmap[i2d + 3]
				x2sp_t = mg_earth.heightmap[i2d + 2]
				x1sp_t = mg_earth.heightmap[i2d + 1]
			else
				x8sp_t = get_mg_heightmap({x = (x + 8), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x7sp_t = get_mg_heightmap({x = (x + 7), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x6sp_t = get_mg_heightmap({x = (x + 6), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x5sp_t = get_mg_heightmap({x = (x + 5), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x4sp_t = get_mg_heightmap({x = (x + 4), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x3sp_t = get_mg_heightmap({x = (x + 3), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x2sp_t = get_mg_heightmap({x = (x + 2), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				x1sp_t = get_mg_heightmap({x = (x + 1), y = 0, z = z}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
			end
			if z >= (minp.z + 8) then
				z8sn_t = mg_earth.heightmap[i2d - (stride * 8)]
				z7sn_t = mg_earth.heightmap[i2d - (stride * 7)]
				z6sn_t = mg_earth.heightmap[i2d - (stride * 6)]
				z5sn_t = mg_earth.heightmap[i2d - (stride * 5)]
				z4sn_t = mg_earth.heightmap[i2d - (stride * 4)]
				z3sn_t = mg_earth.heightmap[i2d - (stride * 3)]
				z2sn_t = mg_earth.heightmap[i2d - (stride * 2)]
				z1sn_t = mg_earth.heightmap[i2d - (stride * 1)]
			else
				z8sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 8)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z7sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 7)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z6sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 6)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z5sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 5)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z4sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 4)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z3sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 3)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z2sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 2)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z1sn_t = get_mg_heightmap({x = x, y = 0, z = (z - 1)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
			end
			if z <= (maxp.z - 8) then
				z8sp_t = mg_earth.heightmap[i2d + (stride * 8)]
				z7sp_t = mg_earth.heightmap[i2d + (stride * 7)]
				z6sp_t = mg_earth.heightmap[i2d + (stride * 6)]
				z5sp_t = mg_earth.heightmap[i2d + (stride * 5)]
				z4sp_t = mg_earth.heightmap[i2d + (stride * 4)]
				z3sp_t = mg_earth.heightmap[i2d + (stride * 3)]
				z2sp_t = mg_earth.heightmap[i2d + (stride * 2)]
				z1sp_t = mg_earth.heightmap[i2d + (stride * 1)]
			else
				z8sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 8)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z7sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 7)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z6sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 6)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z5sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 5)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z4sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 4)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z3sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 3)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z2sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 2)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
				z1sp_t = get_mg_heightmap({x = x, y = 0, z = (z + 1)}, mg_earth.get_heat_at_pos(z,x), mg_earth.get_humid_at_pos(z,x), i2d)
			end

--[[		if x >= (minp.x + 2) then
				xsn_t = mg_earth.heightmap[i2d - 2]
			else
				xsn_t = get_mg_heightmap({x = (x - 2), y = 0, z = z}, t_heat, t_humid, i2d)
			end
			if x <= (maxp.x - 2) then
				xsp_t = mg_earth.heightmap[i2d + 2]
			else
				xsp_t = get_mg_heightmap({x = (x + 2), y = 0, z = z}, t_heat, t_humid, i2d)
			end
			if z >= (minp.z + 2) then
				zsn_t = mg_earth.heightmap[i2d - (stride * 2)]
			else
				zsn_t = get_mg_heightmap({x = x, y = 0, z = (z - 2)}, t_heat, t_humid, i2d)
			end
			if z <= (maxp.z - 2) then
				zsp_t = mg_earth.heightmap[i2d + (stride * 2)]
			else
				zsp_t = get_mg_heightmap({x = x, y = 0, z = (z + 2)}, t_heat, t_humid, i2d)
			end--]]

			xs_t_diff = x8sp_t - x8sn_t
			zs_t_diff = z8sp_t - z8sn_t

				-- x_avg = (xsp_t + xisp_t + t_height + xisn_t + xsn_t) / 5
			-- x_avg = floor((xsp_t + xosp_t + xisp_t + xiisp_t + t_height + xiisn_t + xisn_t + xosn_t + xsn_t) / 9)
			x_avg = floor((x8sn_t + x7sn_t + x6sn_t + x5sn_t + x4sn_t + x3sn_t + x2sn_t + x1sn_t + t_height + x1sp_t + x2sp_t + x3sp_t + x4sp_t + x5sp_t + x6sp_t + x7sp_t + x8sp_t) / 17)
			-- x_avg = floor((xsp_t + xosp_t + xisp_t + xiisp_t + t_height + xiisn_t + xisn_t + xosn_t + xsn_t) / 9) * (1 / min(1, (xs_t_diff * 0.5)))
			-- x_avg = floor((xsp_t + xosp_t + xisp_t + xiisp_t + t_height + xiisn_t + xisn_t + xosn_t + xsn_t) / 9) / max(1, (xs_t_diff^0.5))
				-- z_avg = (zsp_t + zisp_t + t_height + zisn_t + zsn_t) / 5
			-- z_avg = floor((zsp_t + zosp_t + zisp_t + ziisp_t + t_height + ziisn_t + zisn_t + zosn_t + zsn_t) / 9)
			z_avg = floor((z8sn_t + z7sn_t + z6sn_t + z5sn_t + z4sn_t + z3sn_t + z2sn_t + z1sn_t + t_height + z1sp_t + z2sp_t + z3sp_t + z4sp_t + z5sp_t + z6sp_t + z7sp_t + z8sp_t) / 17)
			-- z_avg = floor((zsp_t + zosp_t + zisp_t + ziisp_t + t_height + ziisn_t + zisn_t + zosn_t + zsn_t) / 9) * (1 / min(1, (zs_t_diff * 0.5)))
			-- z_avg = floor((zsp_t + zosp_t + zisp_t + ziisp_t + t_height + ziisn_t + zisn_t + zosn_t + zsn_t) / 9) / max(1, (zs_t_diff^0.5))

			local txa_diff = t_height - x_avg
			local tza_diff = t_height - z_avg

			if mg_earth.config.city.enable == true then

				local xr = x - minp.x
				local zr = z - minp.z
				local chunk = (x >= minp.x and z >= minp.z)

				local sea = false
				local flat = false
				local city_limits = nbuf_grid_city[z-minp.z+1][x-minp.x+1] > TCITY
				local city_density = -31000

				-- local ty_additive = (max(mg_earth.config.streets.max_height,t_height) - mg_earth.config.streets.max_height) * 0.1
				local ty_additive = (max((mg_earth.config.streets.max_height * 0.5),t_height) - (mg_earth.config.streets.max_height * 0.5)) * 0.1
				-- local sin_scale = (mg_earth.config.streets.max_height * ((mg_earth.config.streets.max_height * 0.5) / max((mg_earth.config.streets.max_height * 0.5),t_height))) / mg_earth.config.streets.max_height
				local sin_scale = ((mg_earth.config.streets.max_height * 0.5) / max((mg_earth.config.streets.max_height * 0.5),t_height))

				local sblend = 0.5 + mg_earth.config.height_select_amplitude * (sin_scale - 0.5)
				-- -- local sblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * (0.25 * sin_scale)) - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (sin_scale - 0.5)
				-- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (t_height - 0.5)
				-- -- local xtblend = 0.5 + mg_earth.config.height_select_amplitude * (x_avg - 0.5)
				-- -- local ztblend = 0.5 + mg_earth.config.height_select_amplitude * (z_avg - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * (0.25 * sin_scale)) - 0.5)

				sblend = min(max(sblend, 0), 1)
				-- tblend = min(max(tblend, 0), 1)
				-- -- xtblend = min(max(xtblend, 0), 1)
				-- -- ztblend = min(max(ztblend, 0), 1)

				-- -- local blend = lerp(sblend,tblend,0.25)
				local blend = sblend

				local theight_alt, t_height_base, tlevel, ysurf, n_base
				local dist_to_x_street, dist_to_z_street
				local dist_to_street = -31000

						-- local n_road = nbuf_grid_road[z-minp.z+1][x-minp.x+1]
						-- local n_zpreroad

						-- local x_n, z_n

				-- local n_road_jitter = minetest.get_perlin(mg_earth["np_road_jitter"]):get_2d({x=x,y=z})

--[[			if z <= minp.z then
					n_zpreroad = minetest.get_perlin(mg_earth["np_grid_road"]):get_2d({x=x,y=(z-1)})
				else
					n_zpreroad = nbuf_grid_road[(z-1)-minp.z+1][x-minp.x+1]
				end--]]

--[[			if x <= minp.x then
					n_xpreroad = minetest.get_perlin(mg_earth["np_grid_road"]):get_2d({x=(x-1),y=z})
				else
					n_xpreroad = nbuf_grid_road[z-minp.z+1][(x-1)-minp.x+1]
				end--]]

				if t_height >= mg_earth.config.streets.terrain_min_height then
									-- if ((n_road >= 0 and n_xpreroad < 0) or (n_road < 0 and n_xpreroad >= 0)) or ((n_road >= 0 and n_zpreroad < 0) or (n_road < 0 and n_zpreroad >= 0)) then
										-- dist_to_x_street = 0
										-- dist_to_z_street = 0
										-- dist_to_street = 0
									-- -- elseif (xr >= 36 and xr <= 42 and zr >= 36 and zr <= 42 and (nroad or eroad or sroad or wroad) and cross) then
										-- -- dist_to_x_street = abs(39 - xr)
										-- -- dist_to_z_street = abs(39 - zr)
										-- -- dist_to_street = min(abs(39 - xr),abs(39 - zr))
									-- elseif (xr >= 33 and xr <= 45 and zr >= 43 and nroad and cross) then
					if (xr >= 33 and xr <= 45 and zr >= 43 and nroad and cross) then
						dist_to_x_street = abs(39 - xr)
						dist_to_z_street = -31000
						dist_to_street = abs(39 - xr) + n_road_jitter
					elseif (xr >= 43 and zr >= 33 and zr <= 45 and eroad and cross) then
						dist_to_x_street = -31000
						dist_to_z_street = abs(39 - zr)
						dist_to_street = abs(39 - zr) + n_road_jitter
					elseif (xr >= 33 and xr <= 45 and zr <= 35 and sroad and cross) then
						dist_to_x_street = abs(39 - xr)
						dist_to_z_street = -31000
						dist_to_street = abs(39 - xr) + n_road_jitter
					elseif (xr <= 35 and zr >= 33 and zr <= 45 and wroad and cross) then
						dist_to_x_street = -31000
						dist_to_z_street = abs(39 - zr)
						dist_to_street = abs(39 - zr) + n_road_jitter
					elseif (xr >= 33 and xr <= 45 and zr >= 33 and zr <= 45 and (nroad or eroad or sroad or wroad) and cross) then
						dist_to_x_street = abs(39 - xr)
						dist_to_z_street = abs(39 - zr)
						dist_to_street = min(abs(39 - xr),abs(39 - zr)) + n_road_jitter
					else
						dist_to_x_street = -31000
						dist_to_z_street = -31000
					end
--[[					if city_limits == true then
						if ((xr >= 1) and (xr <= 16)) and ((zr >= 1) and (zr <= 16)) then
							mg_earth.cityplotmap[i2d] = 13
						elseif ((xr >= 17) and (xr <= 32)) and ((zr >= 1) and (zr <= 16)) then
							mg_earth.cityplotmap[i2d] = 5
						elseif ((xr >= 49) and (xr <= 48)) and ((zr >= 1) and (zr <= 16)) then
							mg_earth.cityplotmap[i2d] = 6
						elseif ((xr >= 65) and (xr <= 80)) and ((zr >= 1) and (zr <= 16)) then
							mg_earth.cityplotmap[i2d] = 14
						elseif ((xr >= 1) and (xr <= 16)) and ((zr >= 17) and (zr <= 32)) then
							mg_earth.cityplotmap[i2d] = 11
						elseif ((xr >= 17) and (xr <= 32)) and ((zr >= 17) and (zr <= 32)) then
							-- if xr == 17 and zr == 17 then
								-- plot_height = mg_earth.heightmap[i2d]
							-- end
							mg_earth.cityplotmap[i2d] = 1
							-- mg_earth.heightmap[i2d] = plot_height
						elseif ((xr >= 49) and (xr <= 48)) and ((zr >= 17) and (zr <= 32)) then
							mg_earth.cityplotmap[i2d] = 2
						elseif ((xr >= 65) and (xr <= 80)) and ((zr >= 17) and (zr <= 32)) then
							mg_earth.cityplotmap[i2d] = 7
						elseif ((xr >= 1) and (xr <= 16)) and ((zr >= 49) and (zr <= 64)) then
							mg_earth.cityplotmap[i2d] = 12
						elseif ((xr >= 17) and (xr <= 32)) and ((zr >= 49) and (zr <= 64)) then
							mg_earth.cityplotmap[i2d] = 3
						elseif ((xr >= 49) and (xr <= 48)) and ((zr >= 49) and (zr <= 64)) then
							mg_earth.cityplotmap[i2d] = 4
						elseif ((xr >= 65) and (xr <= 80)) and ((zr >= 49) and (zr <= 64)) then
							mg_earth.cityplotmap[i2d] = 8
						elseif ((xr >= 1) and (xr <= 16)) and ((zr >= 65) and (zr <= 80)) then
							mg_earth.cityplotmap[i2d] = 15
						elseif ((xr >= 17) and (xr <= 32)) and ((zr >= 65) and (zr <= 80)) then
							mg_earth.cityplotmap[i2d] = 9
						elseif ((xr >= 49) and (xr <= 48)) and ((zr >= 65) and (zr <= 80)) then
							mg_earth.cityplotmap[i2d] = 10
						elseif ((xr >= 65) and (xr <= 80)) and ((zr >= 65) and (zr <= 80)) then
							mg_earth.cityplotmap[i2d] = 16
						else
							mg_earth.cityplotmap[i2d] = -1
						end
					end--]]
				else
					dist_to_x_street = -31000
					dist_to_z_street = -31000
				end

				if mg_earth.config.city.style == "road" then
					mg_earth.roadmap[i2d]		= -31000
					mg_earth.roadheight[i2d]	= -31000
					mg_earth.roaddirmap[i2d]	= 0
				elseif mg_earth.config.city.style == "path" or mg_earth.config.city.style == "gravel" then
					mg_earth.pathmap[i2d]		= -31000
					mg_earth.pathheight[i2d]	= -31000
					mg_earth.pathdirmap[i2d]	= 0
				else
					mg_earth.streetmap[i2d]	= -31000
					mg_earth.streetheight[i2d]	= -31000
					mg_earth.streetdirmap[i2d]	= 0
				end

				local street_height

				-- x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 9}, {x = t_height, z = 4}) * sin_scale
				-- z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 9, z = zsp_t}, {x = 4, z = t_height}) * sin_scale

				if (dist_to_z_street >= 0) and (dist_to_z_street <= mg_earth.config.streets.width) then

					theight_alt = floor(x_avg) + (mg_earth.config.streets.min_height * 0.5)
					-- -- t_height_base = min(t_height, (mg_earth.config.streets.max_height + ty_additive))
					-- t_height_base = max(mg_earth.config.streets.min_height, min(t_height, ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					t_height_base = max(mg_earth.config.streets.min_height, min(floor(x_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- -- t_height_base = t_height
					tlevel = floor(t_height_base * blend + theight_alt * (1 - blend))
					-- tlevel = floor(x_avg)
					-- tlevel = max(mg_earth.config.streets.min_height, min(floor(x_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- street_height = tlevel + mg_earth.config.streets.min_height
					-- street_height = tlevel + (mg_earth.config.streets.min_height * 0.5)
					street_height = max(mg_earth.config.streets.min_height, tlevel)

					if mg_earth.config.city.style == "road" then
						mg_earth.roadmap[i2d]		= dist_to_street
						mg_earth.roadheight[i2d]	= street_height
						mg_earth.roaddirmap[i2d]	= 2
					else
						mg_earth.streetmap[i2d] = dist_to_street
						mg_earth.streetheight[i2d] = street_height
						mg_earth.streetdirmap[i2d] = 2
					end
				end
				if (dist_to_x_street >= 0) and (dist_to_x_street <= mg_earth.config.streets.width) then

					theight_alt = floor(z_avg) + (mg_earth.config.streets.min_height * 0.5)
					-- -- t_height_base = min(t_height, (mg_earth.config.streets.max_height + ty_additive))
					-- t_height_base = max(mg_earth.config.streets.min_height, min(t_height, ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					t_height_base = max(mg_earth.config.streets.min_height, min(floor(z_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- -- t_height_base = t_height
					tlevel = floor(t_height_base * blend + theight_alt * (1 - blend))
					-- tlevel = floor(z_avg)
					-- tlevel = max(mg_earth.config.streets.min_height, min(floor(z_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- street_height = tlevel + mg_earth.config.streets.min_height
					-- street_height = tlevel + (mg_earth.config.streets.min_height * 0.5)
					street_height = max(mg_earth.config.streets.min_height, tlevel)

					if mg_earth.config.city.style == "road" then
						mg_earth.roadmap[i2d]		= dist_to_street
						mg_earth.roadheight[i2d]	= street_height
						mg_earth.roaddirmap[i2d]	= 1
					else
						mg_earth.streetmap[i2d] = dist_to_street
						mg_earth.streetheight[i2d] = street_height
						mg_earth.streetdirmap[i2d] = 1
					end
				end

				if city_limits == true then
					city_density = nbuf_grid_city[z-minp.z+1][x-minp.x+1]
				end
				mg_earth.citymap[i2d] = city_density

			end


			if mg_earth.config.roads.enable == true then

				-- local tblend_scale = 1 / max(1,(max((mg_earth.config.roads.max_height * 0.5),t_height) - (mg_earth.config.roads.max_height * 0.5)))
						-- local ty_additive = (max(mg_earth.config.roads.max_height,t_height) - mg_earth.config.roads.max_height) / mg_earth.config.roads.max_height
				-- local ty_additive = (max(mg_earth.config.roads.max_height,t_height) - mg_earth.config.roads.max_height) * 0.1
				local ty_additive = (max((mg_earth.config.roads.max_height * 0.5),t_height) - (mg_earth.config.roads.max_height * 0.5)) * 0.1
				-- local sin_scale = (mg_earth.config.roads.max_height * ((mg_earth.config.roads.max_height * 0.5) / max((mg_earth.config.roads.max_height * 0.5),t_height))) / mg_earth.config.roads.max_height
				local sin_scale = ((mg_earth.config.roads.max_height * 0.5) / max((mg_earth.config.roads.max_height * 0.5),t_height))

				local sblend = 0.5 + mg_earth.config.height_select_amplitude * (sin_scale - 0.5)
				-- -- local sblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * (0.25 * sin_scale)) - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (sin_scale - 0.5)
				-- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (t_height - 0.5)
				-- -- local xtblend = 0.5 + mg_earth.config.height_select_amplitude * (x_avg - 0.5)
				-- -- local ztblend = 0.5 + mg_earth.config.height_select_amplitude * (z_avg - 0.5)
						-- -- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (lerp(sin_scale,t_height,0.5) - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * sin_scale) - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * (0.25 * sin_scale)) - 0.5)

				sblend = min(max(sblend, 0), 1)
				-- tblend = min(max(tblend, 0), 1)
				-- -- xtblend = min(max(xtblend, 0), 1)
				-- -- ztblend = min(max(ztblend, 0), 1)

				-- -- local blend = lerp(sblend,tblend,0.25)
				local blend = sblend

				--Find the nearest grid line, create a sine wave along the perpendicular axis.
				local x_i, x_f = modf(x / mg_earth.config.roads.grid_width)
				local z_i, z_f = modf(z / mg_earth.config.roads.grid_width)

				local x_line, z_line, x_sin, z_sin
				if (x_f > -0.5) and (x_f < 0.5) then
					x_line = x_i * mg_earth.config.roads.grid_width
				else
					if x >= 0 then
						x_line = (x_i + 1) * mg_earth.config.roads.grid_width
					else
						x_line = (x_i - 1) * mg_earth.config.roads.grid_width
					end
				end
				if (z_f > -0.5) and (z_f < 0.5) then
					z_line = z_i * mg_earth.config.roads.grid_width
				else
					if z >= 0 then
						z_line = (z_i + 1) * mg_earth.config.roads.grid_width
					else
						z_line = (z_i - 1) * mg_earth.config.roads.grid_width
					end
				end

				local t_rd_sin_a = mg_earth.config.roads.sin_amp
				local t_rd_sin_f = mg_earth.config.roads.sin_freq

				x_sin = ((sin(z * t_rd_sin_f) * t_rd_sin_a) + zs_t_diff) * sin_scale
				z_sin = ((sin(x * t_rd_sin_f) * t_rd_sin_a) + xs_t_diff) * sin_scale

				-- local n_road_jitter = minetest.get_perlin(mg_earth["np_road_jitter"]):get_2d({x=x,y=z})

				local x_path_add_types = {
					jitter = n_road_jitter,
					terrain = z_avg,
					ta_diff = txa_diff,
					jitter_ta_diff = n_road_jitter + z_avg,
					sine_wave = x_sin,
					sine_jitter = x_sin + n_road_jitter,
					sine_terrain = x_sin + t_height,
					sine_terrain_jitter = x_sin + t_height + n_road_jitter,
				}
				local z_path_add_types = {
					jitter = n_road_jitter,
					terrain = x_avg,
					ta_diff = tza_diff,
					jitter_ta_diff = n_road_jitter + x_avg,
					sine_wave = z_sin,
					sine_jitter = z_sin + n_road_jitter,
					sine_terrain = z_sin + t_height,
					sine_terrain_jitter = z_sin + t_height + n_road_jitter,
				}

				--Streets
				local x_additive = x_path_add_types[mg_earth.config.roads.path_additive]
				local z_additive = z_path_add_types[mg_earth.config.roads.path_additive]

				--Determine path of roadway
				local dist_to_x_road, dist_to_z_road
				if t_height >= mg_earth.config.roads.terrain_min_height then
					-- -- dist_to_x_road = abs((x_line - x_sin) - x)
					-- dist_to_x_road = abs((x_line - n_road_jitter) - x)
					dist_to_x_road = abs((x_line - x_additive) - x)
					-- -- dist_to_z_road = abs((z_line - z_sin) - z)
					-- dist_to_z_road = abs((z_line - n_road_jitter) - z)
					dist_to_z_road = abs((z_line - z_additive) - z)
				else
					dist_to_x_road = -31000
					dist_to_z_road = -31000
				end

				if (mg_earth.config.city.enable == true) and (mg_earth.config.city.style == "road") then
					-- mg_earth.roadmap[i2d]		= -31000
					-- mg_earth.roadheight[i2d]	= -31000
					-- mg_earth.roaddirmap[i2d]	= 0
				else
					mg_earth.roadmap[i2d]		= -31000
					mg_earth.roadheight[i2d]	= -31000
					mg_earth.roaddirmap[i2d]	= 0
				end

				--Determine height of roadway
				local theight_alt, theight_base, tlevel, road_height

				-- x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 4}, {x = t_height, z = 2}) * sin_scale
					-- -- x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 4}, {x = t_height, z = 2})
				-- z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 4, z = zsp_t}, {x = 2, z = t_height}) * sin_scale
					-- -- z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 4, z = zsp_t}, {x = 2, z = t_height})

				if (dist_to_x_road >= 0) and (dist_to_x_road <= mg_earth.config.roads.width) then

							-- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (lerp((z_dist * sin_scale),t_height,0.5) - 0.5)
							-- tblend = min(max(tblend, 0), 1)

					theight_alt = floor(z_avg) + (mg_earth.config.roads.min_height * 0.5)
					-- -- theight_base = min(t_height, (mg_earth.config.roads.max_height + ty_additive))
					-- theight_base = max(mg_earth.config.roads.min_height,min(t_height, ((mg_earth.config.roads.max_height * 0.5) + ty_additive)))
					theight_base = max(mg_earth.config.roads.min_height,min(floor(z_avg), ((mg_earth.config.roads.max_height * 0.5) + ty_additive)))
					-- -- theight_base = t_height
					tlevel = floor(theight_base * blend + theight_alt * (1 - blend))
					-- tlevel = floor(z_avg)
					-- tlevel = max(mg_earth.config.roads.min_height,min(floor(z_avg), ((mg_earth.config.roads.max_height * 0.5) + ty_additive)))
					-- road_height = tlevel + mg_earth.config.roads.min_height
					-- road_height = tlevel + (mg_earth.config.roads.min_height * 0.5)
					road_height = max(mg_earth.config.roads.min_height, tlevel)

					mg_earth.roadmap[i2d] = dist_to_x_road
					mg_earth.roadheight[i2d] = road_height
					mg_earth.roaddirmap[i2d] = 1

				end
				if (dist_to_z_road >= 0) and (dist_to_z_road <= mg_earth.config.roads.width) then

							-- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (lerp((x_dist * sin_scale),t_height,0.5) - 0.5)
							-- tblend = min(max(tblend, 0), 1)

					theight_alt = floor(x_avg) + (mg_earth.config.roads.min_height * 0.5)
					-- -- theight_base = min(t_height, (mg_earth.config.roads.max_height + ty_additive))
					-- theight_base = max(mg_earth.config.roads.min_height,min(t_height, ((mg_earth.config.roads.max_height * 0.5) + ty_additive)))
					theight_base = max(mg_earth.config.roads.min_height,min(floor(x_avg), ((mg_earth.config.roads.max_height * 0.5) + ty_additive)))
					-- -- theight_base = t_height
					tlevel = floor(theight_base * blend + theight_alt * (1 - blend))
					-- tlevel = floor(x_avg)
					-- tlevel = max(mg_earth.config.roads.min_height,min(floor(x_avg), ((mg_earth.config.roads.max_height * 0.5) + ty_additive)))
					-- road_height = tlevel + mg_earth.config.roads.min_height
					-- road_height = tlevel + (mg_earth.config.roads.min_height * 0.5)
					road_height = max(mg_earth.config.roads.min_height, tlevel)

					mg_earth.roadmap[i2d] = dist_to_z_road
					mg_earth.roadheight[i2d] = road_height
					mg_earth.roaddirmap[i2d] = 2

				end
--[[				if ((dist_to_x_road >= 0) and (dist_to_x_road <= mg_earth.config.roads.width)) and ((dist_to_z_road >= 0) and (dist_to_z_road <= mg_earth.config.roads.width)) then

					theight_alt = floor(((z_avg + x_avg) / 2)) + (mg_earth.config.roads.min_height * 0.5)
					theight_base = max(mg_earth.config.roads.min_height, min(floor(((z_avg + x_avg) / 2)), ((mg_earth.config.roads.max_height * 0.5) + ty_additive)))

					tlevel = floor(theight_base * blend + theight_alt * (1 - blend))

					road_height = max(mg_earth.config.roads.min_height, tlevel)

					mg_earth.roadmap[i2d] = min(dist_to_x_road,dist_to_z_road)
					mg_earth.roadheight[i2d] = road_height
					mg_earth.roaddirmap[i2d] = 1

				end--]]

			end


			if mg_earth.config.streets.enable == true then

				-- local tblend_scale = 1 / max(1,(max((mg_earth.config.streets.max_height * 0.5),t_height) - (mg_earth.config.streets.max_height * 0.5)))
				-- local ty_additive = (max(mg_earth.config.streets.max_height,t_height) - mg_earth.config.streets.max_height) * 0.1
				local ty_additive = (max((mg_earth.config.streets.max_height * 0.5),t_height) - (mg_earth.config.streets.max_height * 0.5)) * 0.1
						-- local sin_scale = (mg_earth.config.streets.max_height * ((mg_earth.config.streets.max_height * 0.5) / max((mg_earth.config.streets.max_height * 0.5),t_height))) / mg_earth.config.streets.max_height
				local sin_scale = ((mg_earth.config.streets.max_height * 0.5) / max((mg_earth.config.streets.max_height * 0.5),t_height))
						-- local sin_scale = ((mg_earth.config.streets.max_height * (mg_earth.config.streets.max_height * 0.5)) / max((mg_earth.config.streets.max_height * 0.5),t_height)) / mg_earth.config.streets.max_height

				local sblend = 0.5 + mg_earth.config.height_select_amplitude * (sin_scale - 0.5)
				-- -- local sblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * (0.25 * sin_scale)) - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (sin_scale - 0.5)
				-- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (t_height - 0.5)
				-- -- local xtblend = 0.5 + mg_earth.config.height_select_amplitude * (x_avg - 0.5)
				-- -- local ztblend = 0.5 + mg_earth.config.height_select_amplitude * (z_avg - 0.5)
						-- -- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (lerp(sin_scale,t_height,0.5) - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * sin_scale) - 0.5)
				-- -- local tblend = 0.5 + mg_earth.config.height_select_amplitude * ((t_height * (0.25 * sin_scale)) - 0.5)

				sblend = min(max(sblend, 0), 1)
				-- tblend = min(max(tblend, 0), 1)
				-- -- xtblend = min(max(xtblend, 0), 1)
				-- -- ztblend = min(max(ztblend, 0), 1)

				-- -- local blend = lerp(sblend,tblend,0.25)
				local blend = sblend

				--Find the nearest grid line, create a sine wave along the perpendicular axis.
				local x_i, x_f = modf(x / mg_earth.config.streets.grid_width)
				local z_i, z_f = modf(z / mg_earth.config.streets.grid_width)

				local x_line, z_line, x_sin, z_sin
				if (x_f > -0.5) and (x_f < 0.5) then
					x_line = x_i * mg_earth.config.streets.grid_width
				else
					if x >= 0 then
						x_line = (x_i + 1) * mg_earth.config.streets.grid_width
					else
						x_line = (x_i - 1) * mg_earth.config.streets.grid_width
					end
				end
				if (z_f > -0.5) and (z_f < 0.5) then
					z_line = z_i * mg_earth.config.streets.grid_width
				else
					if z >= 0 then
						z_line = (z_i + 1) * mg_earth.config.streets.grid_width
					else
						z_line = (z_i - 1) * mg_earth.config.streets.grid_width
					end
				end

				local t_rd_sin_a = mg_earth.config.streets.sin_amp
				local t_rd_sin_f = mg_earth.config.streets.sin_freq

				x_sin = ((sin(z * t_rd_sin_f) * t_rd_sin_a) + (zs_t_diff * 0.5)) * sin_scale
				z_sin = ((sin(x * t_rd_sin_f) * t_rd_sin_a) + (xs_t_diff * 0.5)) * sin_scale

				-- local n_road_jitter = minetest.get_perlin(mg_earth["np_road_jitter"]):get_2d({x=x,y=z})

				local x_path_add_types = {
					jitter = n_road_jitter,
					terrain = z_avg,
					ta_diff = txa_diff,
					jitter_ta_diff = n_road_jitter + z_avg,
					sine_wave = x_sin,
					sine_jitter = x_sin + n_road_jitter,
					sine_terrain = x_sin + t_height,
					sine_terrain_jitter = x_sin + t_height + n_road_jitter,
				}
				local z_path_add_types = {
					jitter = n_road_jitter,
					terrain = x_avg,
					ta_diff = tza_diff,
					jitter_ta_diff = n_road_jitter + x_avg,
					sine_wave = z_sin,
					sine_jitter = z_sin + n_road_jitter,
					sine_terrain = z_sin + t_height,
					sine_terrain_jitter = z_sin + t_height + n_road_jitter,
				}

				--Streets
				local x_additive = x_path_add_types[mg_earth.config.streets.path_additive]
				local z_additive = z_path_add_types[mg_earth.config.streets.path_additive]

				--Determine path of street
				local dist_to_x_street, dist_to_z_street
				if t_height >= mg_earth.config.streets.terrain_min_height then
					-- -- dist_to_x_street = abs((x_line - x_sin) - x)
					-- dist_to_x_street = abs((x_line - n_road_jitter) - x)
					dist_to_x_street = abs((x_line - x_additive) - x)
					-- -- dist_to_z_street = abs((z_line - z_sin) - z)
					-- dist_to_z_street = abs((z_line - n_road_jitter) - z)
					dist_to_z_street = abs((z_line - z_additive) - z)
				else
					dist_to_x_street = -31000
					dist_to_z_street = -31000
				end

				if (mg_earth.config.city.enable == true) and (mg_earth.config.city.style == "street") then
					-- mg_earth.streetmap[i2d]	= -31000
					-- mg_earth.streetheight[i2d]	= -31000
					-- mg_earth.streetdirmap[i2d]	= 0
				else
					mg_earth.streetmap[i2d]	= -31000
					mg_earth.streetheight[i2d]	= -31000
					mg_earth.streetdirmap[i2d]	= 0
				end

				--Determine height of street
				local theight_alt, theight_base, tlevel, street_height

				-- x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 9}, {x = t_height, z = 4}) * sin_scale
					-- -- x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 9}, {x = t_height, z = 4})
				-- z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 9, z = zsp_t}, {x = 4, z = t_height}) * sin_scale
					-- -- z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 9, z = zsp_t}, {x = 4, z = t_height})

				if (dist_to_x_street >= 0) and (dist_to_x_street <= mg_earth.config.streets.width) then

							-- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (lerp((z_dist * sin_scale),t_height,0.5) - 0.5)
							-- tblend = min(max(tblend, 0), 1)

					theight_alt = floor(z_avg) + (mg_earth.config.streets.min_height * 0.5)
					-- -- theight_base = min(t_height, (mg_earth.config.streets.max_height + ty_additive))
					-- theight_base = max(mg_earth.config.streets.min_height, min(t_height, ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					theight_base = max(mg_earth.config.streets.min_height, min(floor(z_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- -- theight_base = t_height
					tlevel = floor(theight_base * blend + theight_alt * (1 - blend))
					-- tlevel = floor(z_avg)
					-- tlevel = max(mg_earth.config.streets.min_height, min(floor(z_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- street_height = tlevel + mg_earth.config.streets.min_height
					-- street_height = tlevel + (mg_earth.config.streets.min_height * 0.5)
					street_height = max(mg_earth.config.streets.min_height, tlevel)

					mg_earth.streetmap[i2d] = dist_to_x_street
					mg_earth.streetheight[i2d] = street_height
					mg_earth.streetdirmap[i2d] = 1

				end
				if (dist_to_z_street >= 0) and (dist_to_z_street <= mg_earth.config.streets.width) then

							-- local tblend = 0.5 + mg_earth.config.height_select_amplitude * (lerp((x_dist * sin_scale),t_height,0.5) - 0.5)
							-- tblend = min(max(tblend, 0), 1)

					theight_alt = floor(x_avg) + (mg_earth.config.streets.min_height * 0.5)
					-- -- theight_base = min(t_height, (mg_earth.config.streets.max_height + ty_additive))
					-- theight_base = max(mg_earth.config.streets.min_height, min(t_height, ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					theight_base = max(mg_earth.config.streets.min_height, min(floor(x_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- -- theight_base = t_height
					tlevel = floor(theight_base * blend + theight_alt * (1 - blend))
					-- tlevel = floor(x_avg)
					-- tlevel = max(mg_earth.config.streets.min_height, min(floor(x_avg), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))
					-- street_height = tlevel + mg_earth.config.streets.min_height
					-- street_height = tlevel + (mg_earth.config.streets.min_height * 0.5)
					street_height = max(mg_earth.config.streets.min_height, tlevel)

					mg_earth.streetmap[i2d] = dist_to_z_street
					mg_earth.streetheight[i2d] = street_height
					mg_earth.streetdirmap[i2d] = 2

				end
--[[				if ((dist_to_x_street >= 0) and (dist_to_x_street <= mg_earth.config.streets.width)) and ((dist_to_z_street >= 0) and (dist_to_z_street <= mg_earth.config.streets.width)) then

					theight_alt = floor(((z_avg + x_avg) / 2)) + (mg_earth.config.streets.min_height * 0.5)
					theight_base = max(mg_earth.config.streets.min_height, min(floor(((z_avg + x_avg) / 2)), ((mg_earth.config.streets.max_height * 0.5) + ty_additive)))

					tlevel = floor(theight_base * blend + theight_alt * (1 - blend))

					street_height = max(mg_earth.config.streets.min_height, tlevel)

					mg_earth.streetmap[i2d] = min(dist_to_x_street,dist_to_z_street)
					mg_earth.streetheight[i2d] = street_height
					mg_earth.streetdirmap[i2d] = 1

				end--]]

			end


			if mg_earth.config.paths.enable == true then

				-- local tblend_scale = 1 / max(1,(max((mg_earth.config.paths.max_height * 0.5),t_height) - (mg_earth.config.paths.max_height * 0.5)))
				local ty_additive = min(1, (max(mg_earth.config.paths.max_height,t_height) - mg_earth.config.paths.max_height) / mg_earth.config.paths.max_height)
				-- local sin_scale = (mg_earth.config.paths.max_height * ((mg_earth.config.paths.max_height * 0.5) / max((mg_earth.config.paths.max_height * 0.5),t_height))) / mg_earth.config.paths.max_height
				local sin_scale = ((mg_earth.config.streets.max_height * 0.5) / max((mg_earth.config.streets.max_height * 0.5),t_height))

				local tblend = 0.5 + mg_earth.config.height_select_amplitude * (sin_scale - 0.5)
				tblend = math.min(math.max(tblend, 0), 1)

				local x_i, x_f = math.modf(x / mg_earth.config.paths.grid_width)
				local z_i, z_f = math.modf(z / mg_earth.config.paths.grid_width)

				local x_line, z_line, x_sin, z_sin
				if (x_f >= -0.5) and (x_f <= 0.5) then
					x_line = x_i * mg_earth.config.paths.grid_width
				else
					if x >= 0 then
						x_line = (x_i + 1) * mg_earth.config.paths.grid_width
					else
						x_line = (x_i - 1) * mg_earth.config.paths.grid_width
					end
				end
				if (z_f >= -0.5) and (z_f <= 0.5) then
					z_line = z_i * mg_earth.config.paths.grid_width
				else
					if z >= 0 then
						z_line = (z_i + 1) * mg_earth.config.paths.grid_width
					else
						z_line = (z_i - 1) * mg_earth.config.paths.grid_width
					end
				end

				local t_rd_sin_a = mg_earth.config.paths.sin_amp
				local t_rd_sin_f = mg_earth.config.paths.sin_freq

				-- x_sin = ((sin(z * t_rd_sin_f) * t_rd_sin_a) + zs_t_diff) * sin_scale
				x_sin = (sin(z * t_rd_sin_f) * t_rd_sin_a) * sin_scale
				-- z_sin = ((sin(x * t_rd_sin_f) * t_rd_sin_a) + xs_t_diff) * sin_scale
				z_sin = (sin(x * t_rd_sin_f) * t_rd_sin_a) * sin_scale

				-- local n_road_jitter = minetest.get_perlin(mg_earth["np_road_jitter"]):get_2d({x=x,y=z})

				local x_path_add_types = {
					jitter = n_road_jitter,
					terrain = z_avg,
					ta_diff = txa_diff,
					jitter_ta_diff = n_road_jitter + z_avg,
					sine_wave = x_sin,
					sine_jitter = x_sin + n_road_jitter,
					sine_terrain = x_sin + t_height,
					sine_terrain_jitter = x_sin + t_height + n_road_jitter,
				}
				local z_path_add_types = {
					jitter = n_road_jitter,
					terrain = x_avg,
					ta_diff = tza_diff,
					jitter_ta_diff = n_road_jitter + x_avg,
					sine_wave = z_sin,
					sine_jitter = z_sin + n_road_jitter,
					sine_terrain = z_sin + t_height,
					sine_terrain_jitter = z_sin + t_height + n_road_jitter,
				}

				--Streets
				local x_additive = x_path_add_types[mg_earth.config.paths.path_additive]
				local z_additive = z_path_add_types[mg_earth.config.paths.path_additive]

				--Determine height of roadway
				local dist_to_x_path, dist_to_z_path
				if t_height >= mg_earth.config.paths.min_height then
					-- dist_to_x_path = abs((x_line - x_sin) - x)
					dist_to_x_path = abs((x_line - x_additive) - x)
					-- dist_to_z_path = abs((z_line - z_sin) - z)
					dist_to_z_path = abs((z_line - z_additive) - z)
				else
					dist_to_x_path = -31000
					dist_to_z_path = -31000
				end

				if (mg_earth.config.city.enable == true) and ((mg_earth.config.city.style == "path") or (mg_earth.config.city.style == "gravel")) then
					-- mg_earth.pathmap[i2d]	= -31000
					-- mg_earth.pathheight[i2d]	= -31000
					-- mg_earth.pathdirmap[i2d]	= 0
				else
					mg_earth.pathmap[i2d]		= -31000
					mg_earth.pathheight[i2d]	= -31000
					mg_earth.pathdirmap[i2d]	= 0
				end

				local theight_alt, theight_base, tlevel
				-- x_dist = get_dist2line({x = xsn_t, z = 0}, {x = xsp_t, z = 4}, {x = t_height, z = 2}) * sin_scale
				-- z_dist = get_dist2line({x = 0, z = zsn_t}, {x = 4, z = zsp_t}, {x = 2, z = t_height}) * sin_scale
				if (dist_to_x_path >= 0) and (dist_to_x_path <= mg_earth.config.paths.width) then

					-- theight_alt = z_dist
					theight_alt = floor(z_avg)
					-- theight_base = t_height
					theight_base = max(mg_earth.config.paths.min_height, min(floor(z_avg), ((mg_earth.config.paths.max_height * 0.5) + ty_additive)))
					tlevel = floor(theight_base * tblend + theight_alt * (1 - tblend))
					-- tlevel = floor(z_avg)
					-- tlevel = max(mg_earth.config.paths.min_height,min(floor(z_avg), ((mg_earth.config.paths.max_height * 0.5) + ty_additive)))

					mg_earth.pathmap[i2d] = dist_to_x_path
					mg_earth.pathheight[i2d] = tlevel + mg_earth.config.paths.min_height
					mg_earth.pathdirmap[i2d] = 1

				end
				if (dist_to_z_path >= 0) and (dist_to_z_path <= mg_earth.config.paths.width) then

					-- theight_alt = x_dist
					theight_alt = floor(x_avg)
					-- theight_base = t_height
					theight_base = max(mg_earth.config.paths.min_height, min(floor(x_avg), ((mg_earth.config.paths.max_height * 0.5) + ty_additive)))
					tlevel = floor(theight_base * tblend + theight_alt * (1 - tblend))
					-- tlevel = floor(x_avg)
					-- tlevel = max(mg_earth.config.paths.min_height,min(floor(x_avg), ((mg_earth.config.paths.max_height * 0.5) + ty_additive)))

					mg_earth.pathmap[i2d] = dist_to_z_path
					mg_earth.pathheight[i2d] = tlevel + mg_earth.config.paths.min_height
					mg_earth.pathdirmap[i2d] = 2

				end

			end


			i2d = i2d + 1

		end
	end


end

local function generate_3d_roads(minp, maxp, area, data)

	-- if (mg_earth.config.roads.enable == true) or (mg_earth.config.streets.enable == true) or ((mg_earth.config.city.enable == true) and ((mg_earth.config.city.style == "road") or (mg_earth.config.city.style == "street"))) then
		-- nobj_bridge_column = nobj_bridge_column or minetest.get_perlin_map(mg_earth["np_bridge_column"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
	-- end

	if mg_earth.config.roads.enable == true or (mg_earth.config.city.enable == true and mg_earth.config.city.style == "road") then
		make_road(minp, maxp, area, data)
	end

	if mg_earth.config.streets.enable == true or (mg_earth.config.city.enable == true and mg_earth.config.city.style == "street") then

		make_street(minp, maxp, area, data)
	end

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
			mg_earth.fillmap[index2d] = minetest.get_perlin(mg_earth["np_fill"]):get_2d({x=x,y=z})

			local t_y
			local t_c = 0

			if (mg_earth.config.enable_v3D == true) or (mg_earth.config.enable_v5 == true) or ((mg_earth.config.enable_3d_ver == true) and ((mg_earth.config.enable_vCarp == true) or (mg_earth.config.enable_vValleys == true))) then
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

			local nbiome_name = ""
						-- if mg_earth.gal or mg_world_scale < 0.1 or use_heat_scalar or use_humid_scalar then
			-- if mg_earth.gal and (mg_earth.config.gal_biomes == true) then
				-- nbiome_name = gal.get_biome_name(nheat,nhumid,{x=x,y=t_y,z=z})
			-- end
			if not nbiome_name or nbiome_name == "" then
				nbiome_name = calc_biome_from_noise(nheat,nhumid,{x=x,y=t_y,z=z})
			end
						-- local nbiome_name = calc_biome_from_noise(nheat,nhumid,{x=x,y=t_y,z=z})
			if not nbiome_name or nbiome_name == "" then
				local nbiome_data = minetest.get_biome_data({x=x,y=t_y,z=z})
				nbiome_name = minetest.get_biome_name(nbiome_data.biome)
			end
			mg_earth.biomemap[index2d] = nbiome_name

			if mg_earth.config.mg_ecosystems == true then
				local soil_type_idx, soil_idx, top_type_idx, top_idx = gal.get_ecosystem({x = x, y = t_y, z = z},nbiome_name)
				mg_earth.eco_map[index2d] = {soil_type_idx, soil_idx, top_type_idx, top_idx}
			end

			mg_earth.hh_mod[index2d] = min(0,(nheat - nhumid)) * mg_world_scale

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

	mg_earth.chunk_altitude = {
		mean = alt.mean / ((maxp.x - minp.x + 1) * (maxp.z - minp.z + 1)),
		min = alt.min,
		max = alt.max,
		avg = (alt.max + alt.min) / 2,
		rng = alt.max - alt.min,
		variance = (min(((alt.mean - alt.min) / (alt.max - alt.min)), ((alt.max - alt.mean) / (alt.max - alt.min))) / 0.5),
	}

	if mg_earth.config.mg_lakes_enabled then
		get_lakes(minp, maxp)
	end

end

local function generate_3d_map(minp, maxp, seed)

	-- index2d = 1
	-- index3d = 1
	-- -- y_terrain_height = -31000

	-- for z = minp.z, maxp.z do
		-- for y = minp.y, maxp.y do
			-- for x = minp.x, maxp.x do

				-- local t_height				= mg_earth.heightmap[index2d]
				-- if y <= t_height then
					-- mg_earth.heightmap_3d_flat[index3d] = t_height
				-- else

				-- end

			-- end
			-- index2d = index2d - (maxp.x - minp.x + 1) --shift the 2D index back
		-- end
		-- index2d = index2d + (maxp.x - minp.x + 1) --shift the 2D index up a layer
	-- end

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
	local stride = (maxp.x - minp.x + 1)

	--local csize = vector.add(vector.subtract(maxp, minp), 1)
	local chunk_size_half = abs((maxp.x - minp.x + 1) * 0.5)

	nobj_heatmap = nobj_heatmap or minetest.get_perlin_map(mg_earth["np_heat"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_heatmap = nobj_heatmap:get_2d_map({x = minp.x, y = minp.z})

	nobj_heatblend = nobj_heatblend or minetest.get_perlin_map(mg_earth["np_heat_blend"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_heatblend = nobj_heatblend:get_2d_map({x = minp.x, y = minp.z})

	nobj_humiditymap = nobj_humiditymap or minetest.get_perlin_map(mg_earth["np_humid"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_humiditymap = nobj_humiditymap:get_2d_map({x = minp.x, y = minp.z})

	nobj_humidityblend = nobj_humidityblend or minetest.get_perlin_map(mg_earth["np_humid_blend"], {x = maxp.x - minp.x + 1, y = maxp.x - minp.x + 1, z = 0})
	nbuf_humidityblend = nobj_humidityblend:get_2d_map({x = minp.x, y = minp.z})

	local write = false

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	mg_timer["preparation"] = os.clock()

	local chunk_deco = random(50)
	local chunk_rand = random(5,20)
	local chunk_rand_x = (20 - random(40))
	local chunk_rand_y = (20 - random(40))
	local chunk_rand_dm_x = random(4)
	local chunk_rand_dm_y = random(4)
	local chunk_rand_dm_z = random(4)

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
----------------------------------------------------------------------
	generate_2d_map(minp, maxp, seed, area)
----------------------------------------------------------------------

----------------------------------------------------------------------
	if (mg_earth.config.city.enable == true) or (mg_earth.config.streets.enable == true) or (mg_earth.config.roads.enable == true) or (mg_earth.config.paths.enable == true) then
		generate_2d_roads(minp, maxp, area)
	end
----------------------------------------------------------------------


	mg_timer["loop2D"] = os.clock()
	print("Time elapsed: "..tostring( mg_timer["loop2D"] - mg_timer["loop3D"] ));

	local index2d = 1
	local index3d = 1

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do

				local ivm = area:index(x, y, z)
				local ai = area:index(x,y+1,z) --above index
				local bi = area:index(x,y-1,z) --below index

				local write_3d = true
				--local write_3d = false

				local t_height				= mg_earth.heightmap[index2d]
				local t_biome				= mg_earth.biomemap[index2d]

				local t_heat				= mg_earth.biome_info[t_biome].b_heat
				local t_humid				= mg_earth.biome_info[t_biome].b_humid

				local t_filldepth			= 4 + mg_earth.fillmap[index2d]
				local t_filldepth			= 4
				local t_top_depth			= 1
				local t_water_top_depth		= 1
				local t_riverbed_depth		= mg_earth.config.rivers.width

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
				t_riverbed_depth			= mg_earth.biome_info[t_biome].b_riverbed_depth or mg_earth.config.rivers.width
				t_cave_liquid				= mg_earth.biome_info[t_biome].b_cave_liquid or mg_earth.c_cave_liquid
				t_dungeon					= mg_earth.biome_info[t_biome].b_dungeon or mg_earth.c_dungeon
				t_dungeon_alt				= mg_earth.biome_info[t_biome].b_dungeon_alt or mg_earth.c_dungeon_alt
				--t_dungeon_stair				= mg_earth.biome_info[t_biome].b_dungeon_stair

				local t_stone_height		= (t_height - (t_filldepth + t_top_depth))
				local t_fill_height			= (t_height - t_top_depth)


				if mg_earth.config.mg_ecosystems == true then

					-- if string.find(t_biome, "humid") or string.find(t_biome, "_temperate") or string.find(t_biome, "arid") then

						local t_eco					= mg_earth.eco_map[index2d]

						local t_alt = gal.get_altitude_zone({x = x, y = t_height, z = z})
						local soil_type_idx, soil_idx, top_type_idx, top_idx = unpack(t_eco)
						-- local biome_mod, biome_name = unpack(t_biome:split(":", true))
						-- if gal.ecosystems[biome_name] then
						if gal.ecosystems[t_biome] then
							t_top, t_filler, t_stone, t_dungeon, t_dungeon_alt = gal.get_ecosystem_data(t_biome, t_alt, soil_type_idx, soil_idx, top_type_idx, top_idx)
						end

					-- end

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

				if mg_earth.config.rivers.enable == true then

					if mg_earth.config.enable_vEarth == true then
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

					if mg_earth.config.enable_vValleys == true then

						local t_river_map			= mg_earth.valleysrivermap[index2d]

						mg_earth.config.river_size_factor = (mg_earth.config.rivers.width - (mg_earth.heightmap[index2d] / (40 * mg_world_scale))) / 100

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

					if mg_earth.config.enable_singlenode_heightmap == true then
						if mg_earth.mapgen_rivers == true then

							write_3d = false

							local lake = mg_earth.lakemap[index2d]

							-- if t_height <= maxp.y then

							local is_lake = lake > t_height

							if y <= t_height then
								if y <= t_stone_height then
									t_node = t_stone
								elseif y <= t_fill_height then
									t_node = t_filler
								-- elseif is_lake or y < mg_water_level then
								-- elseif mg_earth.rivermap[index2d] >= 0 or y < mg_water_level then
								elseif mg_earth.rivermap[index2d] >= 0 then
									t_node = t_river
									if y >= t_stone_height and y < t_height then
										t_node = t_riverbed
									end
								else
									t_node = t_top
								end
							elseif y <= (lake - 1) and (lake - 1) > mg_water_level then
								t_node = t_river
							elseif y <= mg_water_level then
								t_node = t_water
							end

							-- if y <= t_height then
								-- -- if mg_earth.rivermap[index2d] >= 0 or y < mg_water_level then
								-- if mg_earth.rivermap[index2d] >= 0 then
									-- -- t_node = t_river
									-- t_filler = t_river
									-- -- t_top = t_air
									-- t_top = t_river
									-- -- t_filler = t_riverbed
									-- -- t_top = t_river
									-- if y >= t_stone_height and y < t_height  and y > mg_water_level then
										-- -- t_node = t_riverbed
										-- t_filler = t_riverbed
										-- -- t_top = t_riverbed
										-- t_top = t_river
									-- end
								-- end
							-- -- elseif y <= (lake - 1) and (lake - 1) > mg_water_level then
							-- elseif y <= lake and lake > mg_water_level then
								-- -- t_node = t_river
								-- t_filler = t_river
								-- -- t_top = t_air
								-- t_top = t_river
							-- end

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

--[[				if mg_noise_select == "vStraight3D" then

					write_3d = false

					if mg_earth.densitymap[index3d] <= 0 then
						write_3d = true
					end
				end--]]

--[[				if mg_earth.config.enable_v5 == true then

					write_3d = false

					local filldepth = mg_earth.v5_filldepthmap[index2d]
					local factor = mg_earth.v5_factormap[index2d]
					local height = mg_earth.v5_heightmap[index2d]
					local ground = mg_earth.v5_groundmap[index3d]

					local density = mg_earth.densitymap[index3d]

					if (ground * factor) < (y - height) then
						-- if density < 0 then
						-- if density < y then
						if (y <= mg_water_level) then
							if y > (mg_water_level - t_water_top_depth) then
								t_node = t_water_top
							else
								t_node = t_water
							end
						else
							t_node = t_ignore
						end
					else
						-- if y < t_stone_height then
							-- t_node = t_stone
							write_3d = true
						-- elseif y >= t_stone_height and y < t_fill_height then
							-- t_node = t_filler
						-- elseif y >= t_fill_height and y <= t_height then
							-- t_node = t_top
						-- end
					end

				end--]]

				if (mg_earth.config.enable_vValleys == true) and (mg_earth.config.enable_3d_ver == true) then

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

				if mg_earth.config.paths.enable == true then

					if mg_earth.pathmap[index2d] >= 0 then

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

						local x_height = floor(lerp(x_n, x_p, 0.5))
						local z_height = floor(lerp(z_n, z_p, 0.5))

						local new_height_choices = {
							x_height,
							z_height,
						}
						local new_height = new_height_choices[mg_earth.pathdirmap[index2d]]

						mg_earth.pathheight[index2d] = new_height

						if (t_height <= mg_earth.pathheight[index2d]) then
							if (t_height >= mg_earth.config.max_beach) then

								t_top = mg_earth.c_path

								if mg_earth.config.rivers.enable == true then
									if (mg_earth.config.enable_vValleys == true) then
										local t_river_map = mg_earth.valleysrivermap[index2d]

										mg_earth.config.river_size_factor = (mg_earth.config.rivers.width - (mg_earth.heightmap[index2d] / (40 * mg_world_scale))) / 100

										if t_river_map > mg_earth.config.river_size_factor then
											t_top = t_air
										end
									elseif mg_earth.config.enable_vEarth == true then
										if (mg_earth.rivermap[index2d] >= 0) and (mg_earth.rivermap[index2d] <= mg_earth.riverpath[index2d]) then
											t_top = t_air
										end
									else
										-- if (mg_earth.rivermap[index2d] <= (mg_earth.riverpath[index2d]) + 1) then
											-- t_top = t_air
										-- end
									end
								end
							end
						end
					end
				end

				if write_3d == true then
					if y < t_stone_height then
						t_node = t_stone
						if mg_earth.config.mg_ecosystems == true then
							--ceiling
							if (data[bi] == t_air or data[bi] == t_ignore) and t_node == t_stone then --ceiling
								-- t_node = t_dungeon
								-- if math.random() < 0.01 then
									t_node = t_dungeon_alt
									-- t_node = t_dungeon
								-- end
							end
							--ground
							if data[bi] == t_stone and (t_node == t_air or t_node == t_ignore) then --ground
								-- data[bi] = t_dungeon
								-- if math.random() < 0.01 then
									-- data[bi] = t_dungeon_alt
									data[bi] = t_dungeon
								-- end
							end
						end
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

				if mg_earth.config.paths.enable == true then
					if (mg_earth.pathmap[index2d] >= 0) then		-- and not mg_earth.config.rivers.enable
						if (t_height > mg_earth.pathheight[index2d]) and (y <= t_height) then
							if (t_height >= mg_earth.config.max_beach) then
								if y == mg_earth.pathheight[index2d] then
									t_node = mg_earth.c_path
									if mg_earth.config.rivers.enable == true then
										if (mg_earth.config.enable_vValleys == true) then
											if mg_earth.valleysrivermap[index2d] > mg_earth.config.river_size_factor then
												t_node = t_air
											end
										elseif mg_earth.config.enable_vEarth == true then
											if (mg_earth.rivermap[index2d] <= (mg_earth.riverpath[index2d]) + 1) then
												t_node = t_air
											end
										else

										end
									end
								end
								if y == (mg_earth.pathheight[index2d] + ((mg_earth.config.paths.width * 2) + 1)) then
									t_node = mg_earth.c_path_sup
								end
								if (y > mg_earth.pathheight[index2d]) and (y < (mg_earth.pathheight[index2d] + ((mg_earth.config.paths.width * 2) + 1))) then
									t_node = t_air
									-- if (t_path > (mg_earth.config.paths.width + 1)) and (t_path < ((mg_earth.config.paths.width + 1) + 2)) then
										-- t_node = mg_earth.c_path_sup
									-- end
								end
								-- if (y > t_path_height) and (y < (t_path_height + (mg_earth.config.paths.width * 2))) then
									-- t_node = t_air
								-- end
							end
						end
					end
				end

				if mg_earth.config.mg_boulders == true then

					--Boulders on terrain surface, both above and below sea level.
					if y == t_height then
						if (data[bi] == t_top or data[bi] == t_filler or data[bi] == t_stone) and (data[bi] ~= t_water_top or data[bi] ~= t_water) and (data[bi] ~= t_air or data[bi] ~= t_ignore) then
							if math.random(5000) <= 1 then
								if string.find(t_biome, "arid") then
									local boulder_form = mg_earth.boulder_form_types[math.random(5,6)]
									make_boulder({x=x,y=t_height,z=z},area,data,boulder_form,t_stone,t_filler,t_top)
									-- make_boulder({x=x,y=t_height,z=z},area,data,"hoodoo",t_stone)
									-- make_boulder({x=x,y=y,z=z},area,data,"flat",t_stone)
								elseif string.find(t_biome, "semi") then
									-- local boulder_form = mg_earth.boulder_form_types[math.random(2,4)]
									make_boulder({x=x,y=t_height,z=z},area,data,"boulder",t_stone,t_ignore,t_ignore)
								elseif t_height < mg_water_level then
									local boulder_form = mg_earth.boulder_form_types[math.random(2,3)]
									make_boulder({x=x,y=t_height,z=z},area,data,boulder_form,t_stone,t_ignore,t_ignore)
								else
									local boulder_form = mg_earth.boulder_form_types[math.random(3,4)]
									make_boulder({x=x,y=t_height,z=z},area,data,boulder_form,t_stone,t_ignore,t_ignore)
								end
							end
						end
					end

--					--Large mesas in arid deserts
					if string.find(t_biome, "arid") and (t_height > (mg_water_level + 16)) then
						-- if (data[bi] == t_top or data[bi] == t_filler or data[bi] == t_stone) and (data[bi] ~= t_water_top or data[bi] ~= t_water) and (data[bi] ~= t_air or data[bi] ~= t_ignore) then
							if y >= t_height then
								if chunk_deco <= 1 then

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

										this = get_3d_dist((x - point.x),(y - point.y),(z - point.z),"m")

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
											t_node = t_stone
										elseif y < (5 + chunk_rand) then
											t_node = t_stone
										end
									end
								end
							end
						-- end
					end
--

					--Icebergs in cold biomes.
					if (y == mg_water_level) and (t_height < mg_water_level) then
						-- if string.find(t_biome, "cold") or string.find(t_biome, "cool_humid") then
						if t_heat <= 18 then
							if (data[bi] == t_water_top or data[bi] == t_water or data[bi] == mg_earth.c_ice) and (data[bi] ~= t_top or data[bi] ~= t_filler or data[bi] ~= t_stone) and (data[bi] ~= t_air or data[bi] ~= t_ignore) then
							-- if (t_node == t_water_top or t_node == t_water or t_node == mg_earth.c_ice) and (t_node ~= t_top or t_node ~= t_filler or t_node ~= t_stone or t_node ~= t_air or t_node ~= t_ignore) then
								-- if math.random((10000 - (2000 * (t_heat / heat_max)))) <= 1 then
								if math.random(5000) <= 1 then
									-- local boulder_form = mg_earth.boulder_form_types[math.random(1,3)]
									make_boulder({x=x,y=mg_water_level,z=z},area,data,"berg",mg_earth.c_ice,t_ignore,t_ignore)
									-- make_boulder({x=x,y=mg_water_level,z=z},area,data,"flat",mg_earth.c_ice)
									-- make_boulder({x=x,y=y,z=z},area,data,"flat",mg_earth.c_ice)
								end
							end
						end
					end

--					--Large Icebergs in open ocean
					if (y < 16) and (t_height < (mg_water_level - 16)) then
						-- if string.find(t_biome, "cold") or string.find(t_biome, "cool_humid") then
						if t_heat <= 15 then
							if chunk_deco <= 1 then

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

									this = get_3d_dist((x - point.x),(y - point.y),(z - point.z),"m") / 2

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
									if y <= (10 + chunk_rand) then
										t_node = mg_earth.c_ice
									end
								end
							end
						end
					end
				end

				if mg_earth.config.caves.enable == true then

					local taper_height_min = 8
					local taper_height = max(0,min(1,(max(0,min(taper_height_min,(t_height - y))) / taper_height_min)))

					local cave_1 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height))
					local cave_2 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height))

					if mg_earth.config.rivers.enable then
						local taper_river_min = mg_earth.config.rivers.width
						local taper_river = max(0,min(1,(max(0,min(taper_river_min,(mg_earth.rivermap[index2d] + taper_river_min))) / taper_river_min)))

						cave_1 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height)) * max(0,min(1,taper_river))
						cave_2 = mg_earth.cave1map[index3d] * max(0,min(1,taper_height)) * max(0,min(1,taper_river))
					end

					if ((cave_1 + cave_2) * mg_earth.config.caves.width) > mg_earth.config.caves.thresh then
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
				end

				if mg_earth.config.caverns.enable == true then
					if (y <= t_height) then

						local tcave1
						local tcave2

						local yblmax1 = t_height - mg_earth.config.caverns.BLEND * 1.5

						if y < mg_earth.config.caverns.yblmin then
							tcave1 = mg_earth.config.caverns.thresh1 + ((mg_earth.config.caverns.yblmin - y) / mg_earth.config.caverns.BLEND) ^ 2
							tcave2 = mg_earth.config.caverns.thresh2 + ((mg_earth.config.caverns.yblmin - y) / mg_earth.config.caverns.BLEND) ^ 2
						elseif y > yblmax1 then
							tcave1 = mg_earth.config.caverns.thresh1 + ((y - yblmax1) / mg_earth.config.caverns.BLEND) ^ 2
							tcave2 = mg_earth.config.caverns.thresh2 + ((y - mg_earth.config.caverns.yblmax2) / mg_earth.config.caverns.BLEND) ^ 2
						elseif y > mg_earth.config.caverns.yblmax2 then
							tcave1 = mg_earth.config.caverns.thresh1 + ((y - yblmax1) / mg_earth.config.caverns.BLEND) ^ 2
							tcave2 = mg_earth.config.caverns.thresh2 + ((y - mg_earth.config.caverns.yblmax2) / mg_earth.config.caverns.BLEND) ^ 2
						else
							tcave1 = mg_earth.config.caverns.thresh1
							tcave2 = mg_earth.config.caverns.thresh2
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

				if mg_earth.config.enable_heightmap == true then

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

						-- --MASTER CELLS
						local orbital_dist = get_3d_dist((x - m.m_x),(y - m.m_y),(z - m.m_z),"e")
						local planet_size = 0
						local m2e_dist = 0
						local ring_size = 0
						local ring_gap = 0
						local moon_orbit = 0

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

								this = get_3d_dist((x - point.x),(y - point.y),(z - point.z),mg_earth.config.dist_metric)

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

					if mg_heightmap_select == "vTubes" then

						if maxp.y < 0 or minp.y > 0 then
							return
						else

								-- local xd_tube = get_dist((y - mg_earth.center_of_chunk.y), (z - mg_earth.center_of_chunk.z), mg_earth.dist_metrics[chunk_rand_dm_x])
								-- local yd_tube = get_dist((x - mg_earth.center_of_chunk.x), (z - mg_earth.center_of_chunk.z), mg_earth.dist_metrics[chunk_rand_dm_y])
								-- local zd_tube = get_dist((x - mg_earth.center_of_chunk.x), (y - mg_earth.center_of_chunk.y), mg_earth.dist_metrics[chunk_rand_dm_z])

								-- local x_tube = (10 < (xd_tube - sin(x))) and ((xd_tube - sin(x)) < 20)
								-- local y_tube = (10 < (yd_tube - sin(y))) and ((yd_tube - sin(y)) < 20)
								-- local z_tube = (10 < (zd_tube - sin(z))) and ((zd_tube - sin(z)) < 20)

								-- if x_tube or y_tube or z_tube then
									-- t_node = t_stone
									-- if (xd_tube < 10) or (yd_tube < 10) or (zd_tube < 10) then
										-- t_node = t_ignore
									-- end
								-- else
									-- t_node = t_ignore
								-- end

							local x_sin = sin(x)
							local x_cos = cos(x)
							local y_sin = sin(y)
							local y_cos = cos(y)
							local y_tan = tan(y)
							local y_atan = atan(y)
							local z_sin = sin(z)
							local z_cos = cos(z)

							local x_tube_rad = get_3d_dist((x - x), (y - mg_earth.center_of_chunk.y), (z - mg_earth.center_of_chunk.z), mg_earth.dist_metrics[chunk_rand_dm_x])
							local y_tube_rad = get_3d_dist((x - mg_earth.center_of_chunk.x), (y - y), (z - mg_earth.center_of_chunk.z), mg_earth.dist_metrics[chunk_rand_dm_x])
							local z_tube_rad = get_3d_dist((x - mg_earth.center_of_chunk.x), (y - mg_earth.center_of_chunk.y), (z - z), mg_earth.dist_metrics[chunk_rand_dm_x])

							local wall_min = mg_earth.config.tube_radius - (mg_earth.config.tube_wall_density * 0.5)
							-- local wall_max = mg_earth.config.tube_radius + (mg_earth.config.tube_wall_density * 0.5)
							local wall_max = mg_earth.config.tube_radius

							local tube_rad = (wall_min > x_tube_rad) or (wall_min > y_tube_rad) or (wall_min > z_tube_rad)

							-- local x_tube = (wall_min < x_tube_rad) and (x_tube_rad < wall_max)
							local x_tube = (wall_min < (x_tube_rad - x_sin)) and ((x_tube_rad - x_sin) < wall_max)
							-- local y_tube = (wall_min < y_tube_rad) and (y_tube_rad < wall_max)
							local y_tube = (wall_min < (y_tube_rad - y_sin)) and ((y_tube_rad - y_sin) < wall_max)
							-- local z_tube = (wall_min < z_tube_rad) and (z_tube_rad < wall_max)
							local z_tube = (wall_min < (z_tube_rad - z_sin)) and ((z_tube_rad - z_sin) < wall_max)

							local tube_draw = x_tube or y_tube or z_tube

							if tube_draw then
								t_node = t_stone
								if tube_rad then
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

										-- --n["n_2d_base"] = minetest.get_perlin(mg_earth["np_2d_base"]):get_2d({x = x, y = z})
										-- -- n["n_2d_alt"] = minetest.get_perlin(mg_earth["np_2d_alt"]):get_2d({x = x, y = z})
										-- -- n["n_2d_sin"] = minetest.get_perlin(mg_earth["np_2d_sin"]):get_2d({x = x, y = z})
										-- --mg_earth.chunk_terrain["C"] = {x=mg_earth.center_of_chunk.x,	y=t_y,		z=mg_earth.center_of_chunk.z}

						local m = {}
						m["m_idx"], m["m_z"], m["m_x"], m["m_t"] = unpack(mg_points[mg_earth.cellmap[index2d].m_i])
						local p = {}
						p["p_idx"], p["p_z"], p["p_x"], p["p_t"] = unpack(mg_points[mg_earth.cellmap[index2d].p_i])
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


															-- --v2d_base_max_height = max_height(mg_earth["np_2d_base"])
															-- --local n_f = minetest.get_perlin(mg_earth["np_2d_base"]):get_3d({x = x, y = y, z = z})
													-- local n_f = minetest.get_perlin(np_3dterrain):get_3d({x = x, y = y, z = z})
														-- --if (n_f + ((1 - y) / mg_earth.config.terrain_density)) <= 0 then
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
														-- -- if d.pe_dist <= mg_earth.config.rivers.width then
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

						local n_2d_val = minetest.get_perlin(mg_earth["np_3dterrain"]):get_2d({x = x, y = z})
						local n_3d_val = minetest.get_perlin(mg_earth["np_3dterrain"]):get_3d({x=x,y=y,z=z})

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

				if mg_earth.config.enable_vDev3D == true then

					if maxp.y < 0 or minp.y > 160 then
						return
					else

						local x_sin = sin(x)
						local x_cos = cos(x)
						local y_sin = sin(y)
						local y_cos = cos(y)
						local y_tan = tan(y)
						local y_atan = atan(y)
						local z_sin = sin(z)
						local z_cos = cos(z)

						local x_tube_rad = get_3d_dist((x - x), (y - mg_earth.center_of_chunk.y), (z - mg_earth.center_of_chunk.z), mg_earth.dist_metrics[chunk_rand_dm_x])
						local y_tube_rad = get_3d_dist((x - mg_earth.center_of_chunk.x), (y - y), (z - mg_earth.center_of_chunk.z), mg_earth.dist_metrics[chunk_rand_dm_x])
						local z_tube_rad = get_3d_dist((x - mg_earth.center_of_chunk.x), (y - mg_earth.center_of_chunk.y), (z - z), mg_earth.dist_metrics[chunk_rand_dm_x])

						local wall_min = mg_earth.config.tube_radius - (mg_earth.config.tube_wall_density * 0.5)
						local wall_max = mg_earth.config.tube_radius + (mg_earth.config.tube_wall_density * 0.5)

						local tube_rad = (wall_min > x_tube_rad) or (wall_min > y_tube_rad) or (wall_min > z_tube_rad)

						local x_tube = (wall_min < x_tube_rad) and (x_tube_rad < wall_max)
						local y_tube = (wall_min < y_tube_rad) and (y_tube_rad < wall_max)
						local z_tube = (wall_min < z_tube_rad) and (z_tube_rad < wall_max)

						local tube_draw = x_tube or y_tube or z_tube

						if tube_draw then
							t_node = t_stone
							if tube_rad then
								t_node = t_ignore
							end
						else
							t_node = t_ignore
						end

					end
				end

				if (mg_earth.config.enable_v3D == true) or (mg_earth.config.enable_v5 == true) or ((mg_earth.config.enable_3d_ver == true) and (mg_earth.config.enable_vValleys == true)) then

					if mg_earth.config.enable_v3D == true then

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

--[[					if mg_noise_select == "vStraight3D" then

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
					end--]]

					if mg_earth.config.enable_v5 == true then

						-- local filldepth = mg_earth.v5_filldepthmap[index2d]
						-- local factor = mg_earth.v5_factormap[index2d]
						-- local height = mg_earth.v5_heightmap[index2d]
						-- local ground = mg_earth.v5_groundmap[index3d]

						-- local density = mg_earth.densitymap[index3d]

						-- if (ground * factor) < (y - height) then
							-- -- if density < 0 then
							-- -- if density < y then
								-- -- if (y <= mg_water_level) and (y > t_height) then
							-- if (y <= mg_water_level) then
									-- t_node = t_water_top
								-- else
									-- t_node = t_water
								-- end
							-- else
								-- t_node = t_ignore
							-- end
						-- else
							-- -- if y < t_stone_height then
								-- t_node = t_stone
							-- -- elseif y >= t_stone_height and y < t_fill_height then
								-- -- t_node = t_filler
							-- -- elseif y >= t_fill_height and y <= t_height then
								-- -- t_node = t_top
							-- -- end
						-- end

					end

					if (mg_earth.config.enable_vValleys == true) and (mg_earth.config.enable_3d_ver == true) then

						if (write_3d == false) and (y <= mg_water_level) and ((t_node == t_ignore) or (t_node == t_air)) then
							t_node = t_water
						end

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

	generate_3d_roads(minp, maxp, area, data)

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
	-- local chugent = math.ceil((os.clock() - mg_timer["start"]) * 1000)
	-- print(("[mg_earth] Generating from %s to %s"):format(minetest.pos_to_string(minp), minetest.pos_to_string(maxp)) .. "  :  " .. chugent .. " ms")
		-- print("[mg_earth] Mapchunk generation time " .. chugent .. " ms")
	-- print(("[mg_earth] Generating from %s to %s"):format(minetest.pos_to_string(minp), minetest.pos_to_string(maxp)) .. "  :  " .. math.ceil((os.clock() - mg_timer["start"]) * 1000) .. " ms")
	local gen_msg = ("[mg_earth] Generating from %s to %s"):format(minetest.pos_to_string(minp), minetest.pos_to_string(maxp)) .. "  :  " .. math.ceil((os.clock() - mg_timer["start"]) * 1000) .. " ms"
	-- minetest.chat_send_player(player:get_player_name(), gen_msg)
	print(gen_msg)

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
		print("mg_earth is manually collecting garbage as memory use has exceeded 500K.")
		collectgarbage("collect")
	end

end


minetest.register_on_generated(generate_map)


local function mg_earth_spawnplayer(player)

	local YFLAT = 7 -- Flat area elevation y
	local TERSCA = 192 -- Vertical terrain scale in nodes
	local TFLAT = 0.2 -- Flat coastal area width
	local PSCA = 16 -- Player scatter. Maximum distance in chunks (80 nodes)
					-- of player spawn points from (0, 0, 0).
	local xsp
	local ysp
	local zsp
	-- local nobj_base = nil

	for chunk = 1, 128 do
		print ("[noisegrid] searching for spawn " .. chunk)
		local x0 = 80 * math.random(-PSCA, PSCA) - 32
		local z0 = 80 * math.random(-PSCA, PSCA) - 32
		local y0 = -32
		local x1 = x0 + 79
		local z1 = z0 + 79
		local y1 = 47

		local sidelen = 80
		local chulens = {x = sidelen, y = sidelen, z = 1}
		local minposxz = {x = x0, y = z0}

				-- nobj_base = nobj_base or minetest.get_perlin_map(np_base, chulens)
		nobj_grid_base   = nobj_grid_base   or minetest.get_perlin_map(mg_earth["np_grid_base"], chulens)
		local nvals_base = nobj_grid_base:get2dMap_flat(minposxz)

		-- -- nobj_grid_base   = nobj_grid_base   or minetest.get_perlin_map(mg_earth["np_grid_base"], {x = (maxp.x - minp.x + 1), y = (maxp.x - minp.x + 1), z = 1})
		-- nobj_grid_base		= nobj_grid_base   or minetest.get_perlin_map(mg_earth["np_grid_base"], {x = x0, y = z0, z = 1})
		-- -- nbuf_grid_bas		= nobj_grid_base:get_2d_map({x = minp.x, y = minp.z})
		-- nbuf_grid_bas		= nobj_grid_base:get_2d_map({x = x0, y = z0})


		local nixz = 1
		for z = z0, z1 do
			for x = x0, x1 do
				local ysurf
				local n_base = nvals_base[nixz]
					-- local n_base = nbuf_grid_base[z][x]
					-- -- local n_base = mg_earth.heightmap[nixz]
					-- -- local n_base = mg_earth.player_spawn_point.y
					-- -- local n_absbase = math.abs(n_base)
				if n_base > TFLAT then
					ysurf = YFLAT + math.floor((n_base - TFLAT) * TERSCA)
				elseif n_base < -TFLAT then
					ysurf = YFLAT - math.floor((-TFLAT - n_base) * TERSCA)
				else
					ysurf = YFLAT
				end
				if ysurf >= 1 then
					ysp = ysurf + 1
					xsp = x
					zsp = z
					break
				end
				nixz = nixz + 1
			end
			if ysp then
				break
			end
		end
		if ysp then
			break
		end
	end
	if ysp then
		print ("[noisegrid] spawn player (" .. xsp .. " " .. ysp .. " " .. zsp .. ")")
		player:set_pos({x = xsp, y = ysp, z = zsp})
	else
		print ("[noisegrid] no suitable spawn found")
		player:set_pos({x = 0, y = 2, z = 0})
	end
end

-- minetest.register_on_newplayer(function(player)
	-- mg_earth_spawnplayer(player)
-- end)

-- minetest.register_on_respawnplayer(function(player)
	-- mg_earth_spawnplayer(player)
	-- return true
-- end)



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




