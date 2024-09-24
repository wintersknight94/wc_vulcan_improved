-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-- ================================================================== --
-- ================================================================== --
minetest.register_node(modname .. ":stone_hot", {
	description = "Stone",
	tiles = {"(nc_terrain_stone.png^[colorize:red:32)^(nc_terrain_stone_hard.png^[opacity:64)"},
		groups = {
--			stone = 1,
--			rock = 1,
--			smoothstone = 1,
			cracky = 2
		},
		light_source = 2,
		glow = 1,
		drop_in_place = "nc_terrain:cobble",
		silktouch = false,
		sounds = nodecore.sounds("nc_terrain_stony"),
		mapcolor = {r = 75, g = 70, b = 70}
})
------------------------------------------------------------------------
