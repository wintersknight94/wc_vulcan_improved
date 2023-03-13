-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
--<>----------------------------------------------------------------<>--

minetest.register_alias_force("mapgen_lava_source", "air")

--<>--

include("voxelarea_iterator")

--<>--

include("magma_veins")

--<>--

include("volcanoes")

--<>--

--include("podobo")

--<>--

if minetest.settings:get_bool(modname.. ".concrete", true) then
	include("pumcrete")
end

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

--<>--

if minetest.settings:get_bool(modname.. ".obsidian", true) then
	include("obsidian")
end

