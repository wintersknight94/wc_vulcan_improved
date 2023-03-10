-- LUALOCALS < ---------------------------------------------------------
local include, minetest, nodecore, pairs, vector
    = include, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local localpref = "nc_concrete:" .. modname:gsub("^nc_", "") .. "_"
-- ================================================================== --
local pumice = "nc_igneous_pumice.png"
local pumcrete = pumice.. "^[colorize:black:80"
local pummix = pumice.. "^(nc_fire_ash.png^[mask:nc_concrete_mask.png)"
-- ================================================================== --
minetest.register_node(modname .. ":pumcrete", {
	description = "Pumcrete",
	tiles = {pumcrete},
	groups = {
		cracky = 2,
		pumcrete = 1
	},
	drop_in_place = "nc_igneous:pumice",
	crush_damage = 2,
	sounds = nodecore.sounds("nc_optics_glassy", nil, 0.6)
})
-- ================================================================== --
nodecore.register_concrete_etchable({
	basename = modname .. ":pumcrete",
	pliant_opacity = 80,
	pattern_opacity = 60,
	pliant = {
		sounds = nodecore.sounds("nc_terrain_crunchy"),
		drop_in_place = {"nc_concrete:pumaggregate_wet_source"},
		silktouch = false
	}
})
------------------------------------------------------------------------
nodecore.register_concrete({
	name = "pumaggregate",
	description = "Volcanic Aggregate",
	tile_powder = pummix,
	tile_wet = pumice.. "^(nc_fire_ash.png^("
	.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)",
	sound = "nc_terrain_chompy",
	groups_powder = {crumbly = 1},
	craft_from_keys = {"group:pumice"},
	craft_from = {groups = {pumice = true}},
	to_crude = "nc_igneous:pumice",
	to_washed = "nc_terrain:gravel",
	to_molded = localpref .. "pumcrete_blank_ply"
})
------------------------------------------------------------------------
nodecore.register_stone_bricks("pumcrete", "Volcanic",
	pumcrete,
	250, 132,
	modname .. ":pumcrete",
	{cracky = 2},
	{
		cracky = 3,
		nc_door_scuff_opacity = 56,
		door_operate_sound_volume = 120
	}
)
-- ================================================================== --

minetest.override_item("nc_stonework:bricks_pumcrete",
	{sounds = nodecore.sounds("nc_optics_glassy", nil, 0.6)}
)
minetest.override_item("nc_stonework:bricks_pumcrete_bonded",
	{sounds = nodecore.sounds("nc_optics_glassy", nil, 0.6)}
)

-- disabled until i resolve strange and frustrating bug
--minetest.override_item("nc_doors:panel_bricks_pumcrete_bonded",
--	{sounds = nodecore.sounds("nc_optics_glassy", nil, 0.6)}
--)
--minetest.override_item("nc_doors:door_bricks_pumcrete_bonded",
--	{sounds = nodecore.sounds("nc_optics_glassy", nil, 0.6)}
--)

-- ================================================================== --
minetest.override_item("nc_igneous:pumice",{
	groups = {
		snappy = 2,
		cracky = 2,
		pumice = 1,
		stack_as_node = 1
	}
})
-- ================================================================== --

