-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math, pairs
    = minetest, nodecore, math, pairs
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local water_level = tonumber(minetest.get_mapgen_setting("water_level"))

local c_air = minetest.get_content_id("air")
local c_lava = minetest.get_content_id("nc_terrain:lava_source")

local c_volcanic = minetest.get_content_id("nc_terrain:hard_stone_4")
local c_igneous = minetest.get_content_id("nc_igneous:pumice")

----- -----
local c_stone = minetest.get_content_id("nc_terrain:stone")
local c_lodestone = minetest.get_content_id("nc_lode:stone")
local c_hardstone = minetest.get_content_id("nc_terrain:hard_stone_1")
local c_hardlodestone = minetest.get_content_id("nc_lode:stone_1")
----- -----

local is_adjacent_to_air = function(area, data, x, y, z)
	return (data[area:index(x+1, y, z)] == c_air
		or data[area:index(x-1, y, z)] == c_air
		or data[area:index(x, y, z+1)] == c_air
		or data[area:index(x, y, z-1)] == c_air
		or data[area:index(x, y-1, z)] == c_air)
end

----------------------------------------
-------------Magma Conduits-------------
minetest.register_ore({
	ore_type = "vein",
	ore = "nc_terrain:lava_source",
	wherein = {
		"nc_terrain:stone",
		"nc_terrain:hard_stone",
		"nc_terrain:sand",
		"nc_terrain:gravel",
		"nc_terrain:dirt",
		"nc_terrain:dirt_with_grass",
		"nc_terrain:water_source",
		"nc_concrete:sandstone",
	},
	column_height_min = 2,
	column_height_max = 6,
	y_min = -720,
	y_max = -80,
	noise_threshold = 0.9,
	noise_params = {
		offset = 0,
		scale = 2,
		spread = {x = 400, y = 800, z = 400},
		seed = 25391,
		octaves = 4,
		persist = 0.5,
		flags = "eased",
	},
	random_factor = 0,
})

----------------------------------------
----------Generation Functions----------
local remove_unsupported_lava
remove_unsupported_lava = function(area, data, vi, x, y, z)
	--if below water level, abort. Caverns are on their own.
	if y < water_level or not area:contains(x, y, z) then return end

	if data[vi] == c_lava then
		if is_adjacent_to_air(area, data, x, y, z) then
			data[vi] = c_air
			for pi, x2, y2, z2 in area:iter_xyz(x-1, y, z-1, x+1, y+1, z+1) do
				if pi ~= vi and area:containsi(pi) then
					remove_unsupported_lava(area, data, pi, x2, y2, z2)
				end
			end
		end
	end
end

-- Placing Basalt around Magma Conduits upon Worldgen, hopefully will reduce abm bogging.
local vulcanize = function(area, data, vi, x, y, z, minp, maxp)
	if data[vi] == c_lava then
		for pi in area:iter(math.max(x-1, minp.x), math.max(y-1, minp.y), math.max(z-1, minp.z),
							math.min(x+1, maxp.x), math.min(y+1, maxp.y), math.min(z+1, maxp.z)) do
			if data[pi] == c_air then
				data[pi] = c_volcanic
			end
			if data[pi] == c_stone then
				data[pi] = c_volcanic
			end
			if data[pi] == c_lodestone then
				data[pi] = c_volcanic
			end
			if data[pi] == c_hardstone then
				data[pi] = c_volcanic
			end
			if data[pi] == c_hardlodestone then
				data[pi] = c_volcanic
			end
		end
	end
end

local data = {}

minetest.register_on_generated(function(minp, maxp, seed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)
	
	for vi, x, y, z in area:iterp_xyz(minp, maxp) do
		vulcanize(area, data, vi, x, y, z, minp, maxp)
		remove_unsupported_lava(area, data, vi, x, y, z)
	end
		
	--send data back to voxelmanip
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	--write it to world
	vm:write_to_map()
end)
