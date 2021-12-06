local minetest, math, vector, pairs = minetest, math, vector, pairs
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local prefix = modname .. ":"
local colors = {
        "D1B187",
        "C77B58",
        "AE5D40",
        "79444A",
        "4B3D44",
        "BA9158",
        "927441",
        "4d4539",
        "77743B",
        "B3A555",
        "D2C9A5",
        "8CABA1",
        "4B726E",
        "574852",
        "847875",
        "AB9B8E",
}

local function color_to_texture(n)
        return "balloon_blank.png^[colorize:#" .. colors[n]
end

local function random_color(disallowed_color)
        if not disallowed_color then
                disallowed_color = 0
        end
        local clr = math.random(#colors)
        while clr == disallowed_color do
                clr = math.random(#colors)
        end
        return clr
end

minetest.register_node(prefix .. 13, {
        drawtype = "liquid",
        pointable = false,
        tiles = {color_to_texture(13) .. ":" .. 220},
        paramtype = "light",
        liquidtype = "source",
        use_texture_alpha = "blend",
	liquid_alternative_flowing = prefix .. 13,
	liquid_alternative_source = prefix .. 13,
})

local function get_tree_schematic(_, t, l)
        return {
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, l, l, l, _, _,
                _, _, l, l, l, _, _,
                _, _, _, l, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,

                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, l, l, l, l, l, _,
                _, l, l, l, l, l, _,
                _, _, l, l, l, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
        
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                l, l, t, _, _, l, l,
                _, l, l, _, t, l, _,
                _, l, l, l, l, l, _,
                _, _, _, l, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
        
                _, _, _, t, _, _, _,
                _, _, _, t, _, _, _,
                _, _, _, t, _, _, _,
                _, _, _, t, _, _, _,
                l, l, _, t, _, l, l,
                l, l, _, _, _, l, l,
                _, l, l, l, l, l, _,
                _, l, l, l, l, l, _,
                _, _, l, l, l, _, _,
                _, _, _, l, _, _, _,
        
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                l, l, _, _, t, l, l,
                _, l, t, _, l, l, _,
                _, l, l, l, l, l, _,
                _, _, l, l, l, _, _,
                _, _, _, l, _, _, _,
                _, _, _, _, _, _, _,
        
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, l, l, l, l, l, _,
                _, l, l, l, l, l, _,
                _, l, l, l, l, _, _,
                _, _, l, l, l, _, _,
                _, _, _, l, _, _, _,
                _, _, _, _, _, _, _,
        
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, l, l, l, _, _,
                _, _, l, l, l, _, _,
                _, _, _, l, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
                _, _, _, _, _, _, _,
        }
end

for n, color in pairs(colors) do
        if n ~= 13 then
                minetest.register_node(prefix .. n, {
                        tiles = {color_to_texture(n)},
                        pointable = false,
                })
                minetest.register_biome({
                        name = n,
                        node_top = prefix .. n,
                        depth_top = 3,
                        node_filler = prefix .. random_color(13),
                        depth_filler = 3,
                        node_stone = prefix .. random_color(13),
                        node_riverbed = prefix .. 15,
		        depth_riverbed = 1,
                        heat_point = 100 / #colors * n,
                        humidity_point = 100 / #colors * n,
                        y_max = 1000,
                        y_min = -3,
                })
                minetest.register_decoration({
                        deco_type = "schematic",
                        place_on = {prefix .. n},
                        sidelen = 80,
                        fill_ratio = 0.01,
                        biomes = {n},
                        y_min = 2,
                        y_max = 1000,
                        schematic = {
                                size = {x = 7, y = 10, z = 7},
	                        data = get_tree_schematic(
                                        {name = "air", param1 = 255, param2 = 0},
                                        {name = prefix .. random_color(13), param1 = 255, param2 = 0},
                                        {name = prefix .. random_color(13), param1 = 240, param2 = 0}
                                ),
                                flags = {"place_center_x, place_center_z"},
                                rotation = "random",
                        }
                })
        end
end

local function set_random_sky(player)
        local clr1 = "#" .. colors[random_color(11)]
        local clr2 = "#" .. colors[random_color()]
        player:set_sky({
                type = "regular",
                sky_color = {
                        day_sky = clr1,
                        day_horizon = clr1,
                        dawn_sky = clr1,
                        dawn_horizon = clr1,
                        night_sky = clr1,
                        night_horizon = clr1,
                },
                clouds = true,
        })
        player:set_clouds({
                color = clr2,
                speed = {x = -10, z = -20},
        })
end

-- player
local function set_environment(player)
        player:hud_set_flags({
                --hotbar = false,
                healthbar = false,
                crosshair = false,
                wielditem = false,
                breathbar = false,
                minimap = false,
                minimap_radar = false,
        })
        player:hud_set_hotbar_image("blank.png")
        player:hud_set_hotbar_selected_image("balloon_hotbar_selected.png")
        player:set_inventory_formspec("size[0.1, 0.1]")
        player:set_sun({
                sunrise_visible = false,
        })
        player:set_stars({
                count = 500,
        })
        set_random_sky(player)
        player:set_properties({
                textures = {"blank.png"},
        })
end

local timers = {
        environment = 0,
        balloon = 0,
}

local balloon_scale = 3
minetest.register_entity("balloon:balloon", {
        initial_properties = {
                visual = "mesh",
                mesh = "balloon.obj",
                physical = true,
                collide_with_objects = false,
                textures = {"balloon_balloon.png"},
                collisionbox = {-0.5 * balloon_scale, 0, -0.5 * balloon_scale, 0.5 * balloon_scale, 1 * balloon_scale, 0.5 * balloon_scale},
                --pointable = false,
                automatic_rotate = 0.1,
                visual_size = {
                        x = balloon_scale,
                        y = balloon_scale,
                        z = balloon_scale,
                },
                --glow = 1, TODO: check for night
                --automatic_face_movement_dir = 1,
                --automatic_face_movement_max_rotation_per_sec = -2,
        },
        on_activate = function(self, staticdata, dtime_s)
                self.object:set_velocity({x=0, y=1, z=0})
        end,
        _lost = false,
        on_step = function(self, dtime, moveresult)
                if moveresult.touching_ground and not self._lost then
                        self._lost = true
                end
        end,
        
})

local players = {}
minetest.register_on_joinplayer(function(player)
        set_environment(player)
        minetest.add_entity(player:get_pos(), "balloon:balloon")
        players[player] = {}
        players[player].hud = player:hud_add({
                hud_elem_type = "image",
                position = { x = 0.5, y = 0.5 },
                scale = { x = -101, y = -101 },
                text = "balloon_hud_overlay.png",
                z_index = 0,
        })
end)



minetest.register_globalstep(function(dtime)
        for a, _ in pairs(timers) do
                timers[a] = timers[a] + dtime
        end
	for _, player in pairs(minetest.get_connected_players()) do
		minetest.close_formspec(player:get_player_name(), "")
                if timers.environment >= 30 then
                        set_random_sky(player)
                        timers.environment = 0
                end
	end
end)

local mapgen_aliases = {
        {"stone", 15},
        {"water_source", 13},
        {"river_water_source", 13},
}

for _, mg_alias in pairs(mapgen_aliases) do
        minetest.register_alias("mapgen_" .. mg_alias[1], prefix .. mg_alias[2])
end