-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()

--local function findlava(pos)
--	return nodecore.find_nodes_around(pos, "group:lava")
--end

--Vulcanize Soil--
nodecore.register_abm({
		label = "Vulcanize Soil",
		nodenames = {"group:soil", "group:clay"},
		neighbors = {"nc_terrain:lava_source", "nc_terrain:lava_flowing"},
		neighbors_invert = true,
		interval = 20,
		chance = 10,
		action = function(pos)
			nodecore.set_loud(pos, {name = "nc_concrete:adobe"})
		end
	})

--Vulcanize Sand--
nodecore.register_abm({
		label = "Vulcanize Sand",
		nodenames = {"group:sand"},
		neighbors = {"nc_terrain:lava_source", "nc_terrain:lava_flowing"},
		neighbors_invert = true,
		interval = 20,
		chance = 10,
		action = function(pos)
			nodecore.set_loud(pos, {name = "nc_concrete:sandstone"})
		end
	})

--Vulcanize Gravel--
nodecore.register_abm({
		label = "Vulcanize Gravel",
		nodenames = {"group:gravel"},
		neighbors = {"nc_terrain:lava_source", "nc_terrain:lava_flowing"},
		neighbors_invert = true,
		interval = 20,
		chance = 10,
		action = function(pos)
			nodecore.set_loud(pos, {name = "nc_terrain:stone"})
		end
	})

--Vulcanize Cobble--
nodecore.register_abm({
		label = "Vulcanize Cobble",
		nodenames = {"nc_terrain:cobble", "nc_terrain:cobble_loose"},
		neighbors = {"nc_terrain:lava_source", "nc_terrain:lava_flowing"},
		neighbors_invert = true,
		interval = 20,
		chance = 10,
		action = function(pos)
			nodecore.set_loud(pos, {name = "nc_terrain:stone"})
		end
	})
	
--Vulcanize Carbon--
nodecore.register_abm({
		label = "Vulcanize Carbon",
		nodenames = {"nc_tree:tree","nc_tree:root","group:charcoal","group:mossy", "group:coal"},
		neighbors = {"nc_terrain:lava_source", "nc_terrain:lava_flowing"},
		neighbors_invert = true,
		interval = 20,
		chance = 10,
		action = function(pos)
			nodecore.set_loud(pos, {name = "nc_concrete:coalstone"})
		end
	})

--Vulcanize Silica--
nodecore.register_abm({
		label = "Vulcanize Silica",
--		nodenames = {"group:silica"},
		nodenames = {"nc_optics:glass_crude"},
		neighbors = {"nc_terrain:lava_source", "nc_terrain:lava_flowing"},
		neighbors_invert = true,
		interval = 20, --600,	-- had to extend this or else making float glass was impossible. Even still, dont leave your float glass too long.
		chance = 10, --100,
		action = function(pos)
			nodecore.set_loud(pos, {name = "nc_concrete:cloudstone"})
		end
	})

if minetest.get_modpath("wc_naturae") then
--Vulcanize Coquina--
nodecore.register_abm({
		label = "Vulcanize Coquina",
		nodenames = {"wc_naturae:coquina"},
		neighbors = {"nc_terrain:lava_source", "nc_terrain:lava_flowing"},
		neighbors_invert = true,
		interval = 20,
		chance = 10,
		action = function(pos)
			nodecore.set_loud(pos, {name = "wc_naturae:shellstone"})
		end
	})
end