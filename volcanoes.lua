-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math
    = minetest, nodecore, math
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
------------------------------------------------------------------------
local depth_root = -720
local depth_base = -80		-- point where the mountain root starts expanding
local depth_maxwidth = -64	-- point of maximum width

local radius_vent = 2		-- approximate minimum radius of vent - noise adds a lot to this
local radius_lining = 5		-- the difference between this and the vent radius is about how thick the layer of lining nodes is, though noise will affect it
local caldera_min = 4		-- minimum radius of caldera
local caldera_max = 32		-- maximum radius of caldera

local scorch_line = 80		-- above this elevation ash is added to the soil
local scorch_border = 32	-- transitional zone where there's scorched soil

local depth_maxpeak = 160
local depth_minpeak = 32
local slope_min = 0.45
local slope_max = 1.75

local region_mapblocks = 16
local mapgen_chunksize = tonumber(minetest.get_mapgen_setting("chunksize"))
local volcano_region_size = region_mapblocks * mapgen_chunksize * 16

local magma_chambers_enabled = true
local chamber_radius_multiplier = 0.4

local p_active = 0.3
local p_dormant = 0.3
local p_extinct = 0.3

if p_active + p_dormant + p_extinct > 1.0 then
	minetest.log("error", "[nc_vulcan] probabilities of various volcano types adds up to more than 1")
end

local state_dormant = 1 - p_active
local state_extinct = 1 - p_active - p_dormant
local state_none = 1 - p_active - p_dormant - p_extinct

local c_air = minetest.get_content_id("air")
local c_lava = minetest.get_content_id("nc_terrain:lava_source")
local c_water = minetest.get_content_id("nc_terrain:water_source")

local c_lining = minetest.get_content_id("nc_terrain:hard_stone_4")
local c_hot_lining = minetest.get_content_id("nc_terrain:hard_stone_3")

local c_cone = minetest.get_content_id("nc_terrain:stone")
local c_plug = minetest.get_content_id("nc_igneous:pumice")

local c_ash = minetest.get_content_id("nc_fire:ash")
local c_pumash = minetest.get_content_id("nc_concrete:pumpowder")
local c_carbon = minetest.get_content_id("nc_concrete:coalstone")
local c_gravel = minetest.get_content_id("nc_terrain:gravel")
local c_igneous = minetest.get_content_id("nc_igneous:pumice")
local c_sand = minetest.get_content_id("nc_terrain:sand")
local c_soil = minetest.get_content_id("nc_terrain:dirt")
local c_underwater_soil = c_sand

if minetest.settings:get_bool(modname.. ".obsidian", true) then
	c_lining = minetest.get_content_id(modname.. ":obsidian")
	c_underwater_soil = minetest.get_content_id(modname.. ":obsidian")
end
if minetest.settings:get_bool(modname.. ".warmstone", true) then
	c_hot_lining = minetest.get_content_id(modname.. ":stone_hot")
end
if minetest.settings:get_bool(modname.. ".concrete", true) then
	c_igneous = minetest.get_content_id(modname.. ":pumcrete")
	c_plug = minetest.get_content_id(modname.. ":pumcrete")
end

local water_level = tonumber(minetest.get_mapgen_setting("water_level"))
local mapgen_seed = tonumber(minetest.get_mapgen_setting("seed"))

-- derived values

local radius_cone_max =  (depth_maxpeak - depth_maxwidth) * slope_max + radius_lining + 20
local depth_maxwidth_dist = depth_maxwidth-depth_base
local depth_maxpeak_dist = depth_maxpeak-depth_maxwidth

local scatter_2d = function(min_xz, gridscale, border_width)
	local bordered_scale = gridscale - 2 * border_width
	local point = {}
	point.x = math.random() * bordered_scale + min_xz.x + border_width
	point.y = 0
	point.z = math.random() * bordered_scale + min_xz.z + border_width
	return point
end

-- For some reason, map chunks generate with -32, -32, -32 as the "origin" minp. To make the large-scale grid align with map chunks it needs to be offset like this.
local get_corner = function(pos)
	return {x = math.floor((pos.x+32) / volcano_region_size) * volcano_region_size - 32, z = math.floor((pos.z+32) / volcano_region_size) * volcano_region_size - 32}
end

local get_volcano = function(pos)
	local corner_xz = get_corner(pos)
	local next_seed = math.random(1, 1000000000)
	math.randomseed(corner_xz.x + corner_xz.z * 2 ^ 8 + mapgen_seed)

	local state = math.random()
	if state < state_none then
		math.randomseed(next_seed)
		return nil
	end
	
	local location = scatter_2d(corner_xz, volcano_region_size, radius_cone_max)
	local depth_peak = math.random(depth_minpeak, depth_maxpeak)
	local depth_lava
	if state < state_extinct then
		depth_lava = - math.random(1, math.abs(depth_root)) -- extinct, put the lava somewhere deep.
	elseif state < state_dormant then
		depth_lava = depth_peak - math.random(5, 50) -- dormant
	else
		depth_lava = depth_peak - math.random(1, 25) -- active, put the lava near the top
	end
	local slope = math.random() * (slope_max - slope_min) + slope_min
	local caldera = math.random() * (caldera_max - caldera_min) + caldera_min
		
	math.randomseed(next_seed)
	return {location = location, depth_peak = depth_peak, depth_lava = depth_lava, slope = slope, state = state, caldera = caldera}
end

local perlin_params = {
	offset = 0,
	scale = 1,
	spread = {x=30, y=30, z=30},
	seed = -40901,
	octaves = 3,
	persist = 0.67
}
local nvals_perlin_buffer = {}
local nobj_perlin = nil
local data = {}

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y > depth_maxpeak or maxp.y < depth_root then
		return
	end

	local volcano = get_volcano(minp)
	
	if volcano == nil then
		return -- no volcano in this map region
	end
	
	local depth_peak = volcano.depth_peak
	local base_radius = (depth_peak - depth_maxwidth) * volcano.slope + radius_lining
	local chamber_radius = (base_radius / volcano.slope) * chamber_radius_multiplier

	-- early out if the volcano is too far away to matter
	-- The plus 20 is because the noise being added will generally be in the 0-20 range, see the "distance" calculation below
	if	volcano.location.x - base_radius - 20 > maxp.x or 
		volcano.location.x + base_radius + 20 < minp.x or 
		volcano.location.z - base_radius - 20 > maxp.z or
		volcano.location.z + base_radius + 20 < minp.z
	then
		return
	end
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)
	
	local sidelen = mapgen_chunksize * 16 --length of a mapblock
	local chunk_lengths = {x = sidelen, y = sidelen, z = sidelen} --table of chunk edges

	nobj_perlin = nobj_perlin or minetest.get_perlin_map(perlin_params, chunk_lengths)
	local nvals_perlin = nobj_perlin:get3dMap_flat(minp, nvals_perlin_buffer) -- switch to get_3d_map_flat for minetest v0.5
	local noise_area = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
	local noise_iterator = noise_area:iterp(minp, maxp)
	
	local x_coord = volcano.location.x
	local z_coord = volcano.location.z
	local depth_lava = volcano.depth_lava
	local caldera = volcano.caldera
	local state = volcano.state
	
	-- Create a table of biome data for use with the biomemap.
	if not biome_ids then
		biome_ids = {}
		for name, desc in pairs(minetest.registered_biomes) do
			local i = minetest.get_biome_id(desc.name)
			local biome_data = {}
			--biome_data.name = desc.name
			if desc.node_dust ~= nil and desc.node_dust ~= "" then
				biome_data.c_dust = minetest.get_content_id(desc.node_dust)
			end
			if desc.node_top ~= nil and desc.node_top ~= "" then
				biome_data.c_top = minetest.get_content_id(desc.node_top)
				if biome_data.c_top == c_sand then
					biome_data.c_top = c_gravel -- beach sand just doesn't look nice on the side of a volcano, replace it with ash
				end
			end
			if desc.node_filler ~= nil and desc.node_filler ~= "" then
				biome_data.c_filler = minetest.get_content_id(desc.node_filler)
				if biome_data.c_filler == c_sand then
					biome_data.c_filler = c_gravel -- beach sand just doesn't look nice on the side of a volcano, replace it with ash
				end
			end
			biome_ids[i] = biome_data
		end
	end	
	local biomemap = minetest.get_mapgen_object("biomemap")
	local minx = minp.x
	local minz = minp.z
	
	for vi, x, y, z in area:iterp_xyz(minp, maxp) do
	
		local vi3d = noise_iterator()

		local distance_perturbation = (nvals_perlin[vi3d]+1)*10
		local distance = vector.distance({x=x, y=y, z=z}, {x=x_coord, y=y, z=z_coord}) - distance_perturbation

		local biome_data
		if biomemap ~= nil then
			biome_data = biome_ids[biomemap[(z-minz) * sidelen + (x-minx) + 1]]
		end

		-- Determine what materials to use at this y level
		-------------------------------------------------------------------------------------------------
		
		local c_top
		local c_filler
		local c_dust
		if state ~= state_active then
			if y < water_level then
				c_top = c_igneous
				c_filler = c_underwater_soil
			elseif biome_data ~= nil then
				c_top = biome_data.c_top
				c_filler = biome_data.c_filler
				c_dust = biome_data.c_dust
			else
				c_top = c_gravel
				c_filler = c_igneous
				c_dust = c_air
			end
		elseif y < water_level then
			c_top = c_igneous
			c_filler = c_underwater_soil
		elseif y < scorch_line and biome_data ~= nil then
			c_top = biome_data.c_top
			c_filler = biome_data.c_filler
			c_dust = biome_data.c_dust
		else
			c_top = c_pumash
			c_filler = c_igneous
			c_dust = c_ash
		end
		
		local pipestuff
		local liningstuff
		if y < depth_lava + math.random() * 1.1 then
			pipestuff = c_lava
			liningstuff = c_hot_lining
		else
			if state < state_dormant then
				pipestuff = c_plug -- dormant volcano
				liningstuff = c_lining
			else
				pipestuff = c_air -- active volcano
				liningstuff = c_hot_lining
			end
		end

		-- Actually create the volcano
		-------------------------------------------------------------------------------------------
		
		if y < depth_base then
			if magma_chambers_enabled and y < depth_root + chamber_radius then -- Magma chamber lower half
				local lower_half = ((y - depth_root) / chamber_radius) * chamber_radius
				if distance < lower_half + radius_vent then
					data[vi] = c_lava -- Put lava in the magma chamber even for extinct volcanoes, if someone really wants to dig for it it's down there.
				elseif distance < lower_half + radius_lining  and data[vi] ~= c_lava then -- leave holes into existing lava
					data[vi] = liningstuff
				end
			elseif magma_chambers_enabled and y < depth_root + chamber_radius * 2 then -- Magma chamber upper half
				local upper_half = (1 - (y - depth_root - chamber_radius) / chamber_radius) * chamber_radius
				if distance < upper_half + radius_vent then
					data[vi] = c_lava
				elseif distance < upper_half + radius_lining and data[vi] ~= c_lava then -- leave hole existing lava
					data[vi] = liningstuff
				end
			else -- pipe
				if distance < radius_vent then
					data[vi] = pipestuff
				elseif distance < radius_lining and data[vi] ~= c_lava then -- leave holes into existing lava
					data[vi] = liningstuff
				end
			end
		elseif y < depth_maxwidth then -- root
			if distance < radius_vent then
				data[vi] = pipestuff
			elseif distance < radius_lining then
				data[vi] = liningstuff
			elseif distance < radius_lining + ((y - depth_base)/depth_maxwidth_dist) * base_radius then
				data[vi] = c_cone
			end
		elseif y < depth_peak + 5 then -- cone
			local current_elevation = y - depth_maxwidth
			local peak_elevation = depth_peak - depth_maxwidth
			if current_elevation > peak_elevation - caldera and distance < current_elevation - peak_elevation + caldera then
				data[vi] = c_air -- caldera
			elseif distance < radius_vent then
				data[vi] = pipestuff
			elseif distance < radius_lining then
				data[vi] = liningstuff
			elseif distance <  current_elevation * -volcano.slope + base_radius then
				data[vi] = c_cone
				if data[vi + area.ystride] == c_air and c_dust ~= nil then
					data[vi + area.ystride] = c_dust
				end
			elseif c_top ~= nil and c_filler ~= nil and distance < current_elevation * -volcano.slope + base_radius + nvals_perlin[vi3d]*-4 then
				data[vi] = c_top
				if data[vi - area.ystride] == c_top then
					data[vi - area.ystride] = c_filler
				end
				if data[vi + area.ystride] == c_air and c_dust ~= nil then
					data[vi + area.ystride] = c_dust
				end
			end
			
		end
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

----------------------------------------------------------------------------------------------
-- Debugging and sightseeing commands

minetest.register_privilege("findvolcano", { description = "Allows players to use a console command to find volcanoes", give_to_singleplayer = false})

function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

local send_volcano_state = function(pos, name)
	local corner_xz = get_corner(pos)
	local volcano = get_volcano(pos)
	if volcano == nil then
		return false
	end
	local location = {x=math.floor(volcano.location.x), y=volcano.depth_peak, z=math.floor(volcano.location.z)}
	local text = "Peak at " .. minetest.pos_to_string(location)
		.. ", Slope: " .. tostring(round(volcano.slope, 2))
		.. ", State: "
	if volcano.state < state_extinct then
		text = text .. "Extinct"
	elseif volcano.state < state_dormant then
		text = text .. "Dormant"
	else
		text = text .. "Active"
	end
	
	minetest.chat_send_player(name, text)
	return true
end

local send_nearby_states = function(pos, name)
	local retval = false
	retval = send_volcano_state({x=pos.x-volcano_region_size, y=0, z=pos.z+volcano_region_size}, name) or retval
	retval = send_volcano_state({x=pos.x, y=0, z=pos.z+volcano_region_size}, name) or retval
	retval = send_volcano_state({x=pos.x+volcano_region_size, y=0, z=pos.z+volcano_region_size}, name) or retval
	retval = send_volcano_state({x=pos.x-volcano_region_size, y=0, z=pos.z}, name) or retval
	retval = send_volcano_state(pos, name) or retval
	retval = send_volcano_state({x=pos.x+volcano_region_size, y=0, z=pos.z}, name) or retval
	retval = send_volcano_state({x=pos.x-volcano_region_size, y=0, z=pos.z-volcano_region_size}, name) or retval
	retval = send_volcano_state({x=pos.x, y=0, z=pos.z-volcano_region_size}, name) or retval
	retval = send_volcano_state({x=pos.x+volcano_region_size, y=0, z=pos.z-volcano_region_size}, name) or retval
	return retval
end

minetest.register_chatcommand("findvolcano", {
    params = "pos", -- Short parameter description
    description = "find the volcanoes near the player's map region, or in the map region containing pos if provided",
    func = function(name, param)
		if minetest.check_player_privs(name, {findvolcano = true}) then
			local pos = {}
			pos.x, pos.y, pos.z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
			pos.x = tonumber(pos.x)
			pos.y = tonumber(pos.y)
			pos.z = tonumber(pos.z)
			if pos.x and pos.y and pos.z then
				if not send_nearby_states(pos, name) then
					minetest.chat_send_player(name, "No volcanoes near " .. minetest.pos_to_string(pos))
				end
				return true
			else
				local playerobj = minetest.get_player_by_name(name)
				pos = playerobj:get_pos()
				if not send_nearby_states(pos, name) then
					pos.x = math.floor(pos.x)
					pos.y = math.floor(pos.y)
					pos.z = math.floor(pos.z)
					minetest.chat_send_player(name, "No volcanoes near " .. minetest.pos_to_string(pos))
				end
				return true
			end
		else
			return false, "You need the findvolcano privilege to use this command."
		end
	end,
})
