-- LUALOCALS < ---------------------------------------------------------
local include, nodecore, minetest
    = include, nodecore, minetest
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
--<>----------------------------------------------------------------<>--

minetest.register_alias_force("mapgen_lava_source", "air")
--<>--
if minetest.settings:get_bool(modname.. ".warmstone", true) then
	include("warmstone")
end
--<>--
if minetest.settings:get_bool(modname.. ".concrete", true) then
	include("pumcrete")
	else include("compat_pum")
end
--<>--
if minetest.settings:get_bool(modname.. ".obsidian", true) then
	include("obsidian")
end
--<>--
include("voxelarea_iterator")
--<>--
include("magma_veins")
--<>--
include("volcanoes")
--<>--
--include("podobo")
--<>--
if minetest.settings:get_bool(modname.. ".hydrothermal", true) then
	include("hydrothermal_vents")
end
--<>--
if minetest.settings:get_bool(modname.. ".metamorphic", true) then
	include("vulcan")
end
--<>--
if minetest.settings:get_bool(modname.. ".pummine", true) then
	include("pummine")
end
--<>----------------------------------------------------------------<>--