-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-- ================================================================== --
minetest.register_abm({
	label = "Vulcanian Eruption",
	nodenames = {"group:lava"},
	neighbors = {"air"},
	interval = 3600,	--3600 = 1hr
	chance = 100,
	action = function(pos)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			minetest.chat_send_all("vulcan eruption check")
		if not nodecore.buildable_to(above) then
			minetest.chat_send_all("blocked above")
			return
		end
		if #nodecore.find_nodes_around(pos, "group:lava", 5) > 600 then
			minetest.chat_send_all("Danger!! Volcanic Eruption!!")
			return nodecore.set_loud(above, {name = "nc_terrain:lava_source"})
		end
--		return nodecore.set_loud(above, {name = "nc_terrain:lava_source"})
	end
})


--minetest.register_abm({
--	label = "Strombolian Eruption",
--	nodenames = {"group:lava"},
--	neighbors = {"air"},
--	interval = 3,	--3600 = 1hr
--	chance = 1,
--	action = function(pos)
--		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
--		local jetabove = {x = pos.x, y = pos.y + , z = pos.z},
--			minetest.chat_send_all("stromboli eruption check")
--		if not nodecore.buildable_to(above) then
--			minetest.chat_send_all("blocked above")
--			return
--		end
--		if #nodecore.find_nodes_around(pos, "group:lava", 5) > 600 then
--			minetest.chat_send_all("Danger!! Strombolian Eruption!!")
--			return nodecore.set_loud(jetabove, {name = "nc_terrain:lava_source"})
--		end
----		return nodecore.set_loud(above, {name = "nc_terrain:lava_source"})
--	end
--})


