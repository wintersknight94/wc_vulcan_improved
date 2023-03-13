-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-- ================================================================== --
local obsidian = "nc_optics_glass_frost.png^[colorize:BLACK:200"
-- ================================================================== --
minetest.register_node(modname .. ":obsidian", {
	description = "Obsidian",
	tiles = {obsidian},
	groups = {
		cracky = 2,
		obsidian = 1
	},
	crush_damage = 4,
	sounds = nodecore.sounds("nc_optics_glassy", nil, 0.9)
})
------------------------------------------------------------------------
minetest.register_craftitem(modname .. ":shard", {
	description = "Obsidian Shard",
	inventory_image = "nc_stonework_stone.png^[colorize:black:80",
	wield_image = "[combine:16x16:0,2=nc_stonework_stone.png^[colorize:BLACK:80",
	wield_scale = {x = 1.25, y = 1.25, z = 1.75},
	sounds = nodecore.sounds("nc_optics_glassy", nil, 0.9),
	groups = {shard = 1, pebble = 1, obsidian = 1}
})
-- ================================================================== --
nodecore.register_craft({
	label = "break obsidian to shards",
	action = "pummel",
	indexkeys = {modname.. ":obsidian"},
	nodes = {
		{match = modname.. ":obsidian", replace = "air"}
	},
	items = {
		{name = modname .. ":shard", count = 8, scatter = 5}
	},
	toolgroups = {cracky = 2},
	itemscatter = 5
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "melt shards togethers",
	action = "pummel",
	toolgroups = {thumpy = 2},
	touchgroups = {
		coolant = 0,
		lava = 1
	},
	indexkeys = {modname .. ":shard"},
	nodes = {
		{
			match = {name = modname .. ":shard", count = 8},
			replace = "air"
		}
	},
	items = {
		modname.. ":obsidian"
	}
})
-- ================================================================== --
local adzedef
adzedef = {
	description = "Obsidian-Tipped Adze",
	inventory_image = "nc_woodwork_adze.png^(nc_stonework_tip_adze.png^[colorize:BLACK:80)",
	groups = {
		firestick = 2,
		flammable = 2
	},
	tool_capabilities = nodecore.toolcaps({
			choppy = 4,
			crumbly = 4
		}),
	sounds = nodecore.sounds("nc_optics_glassy", nil, 0.9),
	after_use = function(_, who)
		nodecore.toolbreakeffects(who, adzedef)
		return ItemStack("nc_woodwork:adze")
	end
}
minetest.register_tool(modname .. ":adze_obsidian", adzedef)
------------------------------------------------------------------------
nodecore.register_craft({
		label = "assemble obsidian adze",
		action = "stackapply",
		wield = {name = modname .. ":shard"},
		consumewield = 1,
		indexkeys = {"nc_woodwork:adze"},
		nodes = {
			{
				match = {
					name = "nc_woodwork:adze",
					wear = 0.05
				},
				replace = "air"
			},
		},
		items = {
			{name = modname .. ":adze_obsidian"}
		},
	})
-- ================================================================== --
local function tooltip(name, group)
	local tool = modname .. ":tool_" .. name:lower() .. "_obsidian"
	local wood = "nc_woodwork:tool_" .. name:lower()
	minetest.register_tool(tool, {
			description = "Obsidian-Tipped " .. name,
			inventory_image = "nc_woodwork_tool_" .. name:lower() .. ".png^(nc_stonework_tip_" .. name:lower() .. ".png^[colorize:BLACK:80)",
			tool_wears_to = wood,
			groups = {
				flammable = 2
			},
			tool_capabilities = nodecore.toolcaps({
					uses = 0.25,
					[group] = 3
				}),
			on_ignite = modname .. ":shard",
			sounds = nodecore.sounds("nc_optics_glassy", nil, 0.9),
		})
	local woodmatch = {name = wood, wear = 0.05}
	nodecore.register_craft({
			label = "assemble " .. tool,
			action = "stackapply",
			wield = {name = modname .. ":shard"},
			consumewield = 1,
			indexkeys = {wood},
			nodes = {{match = woodmatch, replace = "air"}},
			items = {tool}
		})
end

tooltip("Mallet", "thumpy")
tooltip("Spade", "crumbly")
tooltip("Hatchet", "choppy")
tooltip("Pick", "cracky")


