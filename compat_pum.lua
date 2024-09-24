-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
--<>----------------------------------------------------------------<>--

minetest.register_alias("nc_concrete:pumaggregate",					"nc_concrete:pumpowder")

minetest.register_alias(modname.. ":pumcrete",						"nc_igneous:pumice")

minetest.register_alias("nc_stonework:bricks_pumcrete",				"nc_stonework:bricks_coalstone")
minetest.register_alias("nc_stonework:bricks_pumcrete_bonded",		"nc_stonework:bricks_coalstone_bonded")

