-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local root = {
	".ccc.",
	"csssc",
	"cspsc",
	"csssc",
	".ccc.",
}
local rareslice = {
	"..c..",
	".sss.",
	"cspsc",
	".sss.",
	"..c..",
}
local midsection = {
	".....",
	".csc.",
	".sps.",
	".csc.",
	".....",
}
local topsection = {
	".....",
	"..s..",
	".sms.",
	"..s..",
	".....",
}
local crown = {
	".....",
	"..s..",
	".s.s.",
	"..s..",
	".....",
}
local peak = {
	".....",
	"..c..",
	".c.c.",
	"..c..",
	".....",
}
nodecore.vulcan_vent_schematic = nodecore.ezschematic(
	{
		["."] =	{name = "nc_terrain:water_source", prob = 0},
		s	 =	{name = "nc_terrain:stone", prob = 255},
		c	 =	{name = "nc_igneous:pumice", prob = 125},
		m	 =	{name = "nc_igneous:amalgam", prob = 255},
		p	 =	{name = "nc_terrain:lava_source", prob = 255},
	},
	{
		root,		--1
		root,		--2
		root,		--3
		rareslice,	--4
		rareslice,	--5
		midsection,	--6
		topsection,	--7
		crown,		--8
		peak			--9
	},
	{
		yslice_prob = {
			{ypos = 1, prob = 150},	--1
			{ypos = 2, prob = 200},	--2
			{ypos = 3, prob = 255},	--3
			{ypos = 4, prob = 100},	--4
			{ypos = 5, prob = 100},	--5
			{ypos = 6, prob = 255},	--6
			{ypos = 7, prob = 255},	--7
			{ypos = 8, prob = 225},	--8
			{ypos = 9, prob = 100},	--9
		}
	}
)

minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:soil", "group:sand", "group:gravel", "group:stone"},
		sidelen = 16,
		fill_ratio = 0.0001,
		biomes = {"seabed"},
		y_min = -1000,
		y_max = -2,
		schematic = nodecore.vulcan_vent_schematic,
		flags = "force_placement", "place_center_x, place_center_z", "all_floors",
		rotation = "random",
		place_offset_y = -3,
		replacements = {},
	})
