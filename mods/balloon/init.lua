local minetest, math, vector, pairs = minetest, math, vector, pairs
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

minetest.settings:set("time_speed", 0)

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

local timers = {
        environment = 0,
        balloon = 0,
        score = 0,
}

-- player
local players = {}

local function p_get(p, v)
        return players[p][v]
end

local function p_set(p, v, n)
        players[p][v] = n
end

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
        player:set_eye_offset(vector.new(0, 5, -60))
        --player:set_look_horizontal(0)
        set_random_sky(player)
        player:set_properties({
                textures = {"blank.png"},
        })
        player:override_day_night_ratio(0.7)
end

local function get_status(player)
        return players[player].status
end

local function set_status(player, status)
        players[player].status = status
end

local function reset_pos(obj)
        obj:set_pos(vector.new(0, 100, 0))
        obj:set_velocity(vector.new(0, 0, 0))
end


local function add_paused_screen(player)
        players[player].hud.paused = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.5, y = 0.5},
                text = "Press JUMP to start",
                number = 0x4B726E,
                size = {x = 2, y = 2},
                z_index = 0,
                style = 1,
        })
end

local function set_highscore(player)
        local score = p_get(player, "score")
        if score > p_get(player, "highscore") then
               p_set(player, "highscore", score)
        end
        p_set(player, "score", 0)
        player:get_meta():set_int("highscore", p_get(player, "highscore"))
end

local function get_score(player, highscore)
        local n = p_get(player, "score")
        if highscore then
                n = p_get(player, "highscore")
        end
        local score = tostring(n)
        local len = string.len(score)
        if len < 6 then
                for i = 1, 6 - len do
                        score = 0 .. score
                end
        end
        return score
end

local function update_score_hud(player)
        player:hud_change(p_get(player, "hud").score, "text", "HI " .. get_score(player, true) .. "   " .. get_score(player))
end

local function pause_game(player, balloon)
        set_highscore(player)
        set_status(player, "paused")
        add_paused_screen(player)
        reset_pos(balloon)
end

local balloon_scale = 3
minetest.register_entity("balloon:balloon", {
        initial_properties = {
                visual = "mesh",
                mesh = "balloon.obj",
                physical = true,
                collide_with_objects = false,
                textures = {"balloon_balloon.png"},
                collisionbox = {-0.2 * balloon_scale, 0, -0.2 * balloon_scale, 0.2 * balloon_scale, 1 * balloon_scale, 0.2 * balloon_scale},
                automatic_rotate = 0.1,
                visual_size = vector.new(balloon_scale, balloon_scale, balloon_scale),
        },
        _balloonist = nil,
        on_step = function(self, dtime, moveresult)
                for n, _ in pairs(timers) do
                        timers[n] = timers[n] + dtime
                end

                local balloon = self.object
                
                if self._balloonist then
                        local player = self._balloonist
                        local control = player:get_player_control()
                        local status = get_status(player)

                        minetest.close_formspec(player:get_player_name(), "")

                        if timers.environment >= 30 then
                                set_random_sky(player)
                                timers.environment = 0
                        end

                        if status == "running" then
                                if timers.score >= 0.5 then
                                        p_set(player, "score", math.ceil(balloon:get_pos().x))--p_get(player, "score") + 1)
                                end
                                
                                if control.left then
                                        balloon:set_velocity(vector.new(5, -1, 10))
                                elseif control.right then
                                        balloon:set_velocity(vector.new(5, -1, -10))
                                else
                                        balloon:set_velocity(vector.new(10, -1, 0))
                                end

                                if control.sneak then
                                        pause_game(player, balloon)
                                end

                        elseif status == "paused" or status == "not_started" then
                                if control.jump then
                                        set_status(player, "running")
                                        player:hud_remove(players[player].hud.paused)
                                end
                        end

                        for _, collision in pairs(moveresult.collisions) do
                                if minetest.get_node(collision.node_pos).name ~= "" then
                                        pause_game(player, balloon)
                                        break
                                end
                        end
                        update_score_hud(player)
                else
                        balloon:remove()
                end
        end,
        _attach_balloonist = function(self, player)
		self._balloonist = player
		player:set_attach(self.object, "", vector.new(0, 0, 0), vector.new(0, 0, 0))
	end,
})

minetest.register_on_newplayer(function(player)
        reset_pos(player)
end)

minetest.register_on_joinplayer(function(player)
        set_environment(player)

        players[player] = {
                status = "not_started",
                -- "not_started", "paused", "running"
                score = 0,
                highscore = player:get_meta():get_int("highscore"),
        }
        players[player].hud = {
                overlay = player:hud_add({
                        hud_elem_type = "image",
                        position = {x = 0.5, y = 0.5},
                        scale = {x = -101, y = -101},
                        text = "balloon_hud_overlay.png",
                        z_index = -1,
                }),
                score = player:hud_add({
                        hud_elem_type = "text",
                        position = {x = 0, y = 0},
                        offset = {x = 20, y = 20},
                        text = "HI 000000   000000",
                        number = 0x4B726E,
                        alignment = {x = 1, y = 1},
                        z_index = 0,
                        style = 1,
                })
        }
        add_paused_screen(player)
        reset_pos(player)

        local balloon = minetest.add_entity(player:get_pos(), "balloon:balloon"):get_luaentity()
        balloon._attach_balloonist(balloon, player)
end)

minetest.register_on_leaveplayer(function(player)
        players[player] = nil
end)

local mapgen_aliases = {
        {"stone", 15},
        {"water_source", 13},
        {"river_water_source", 13},
}

for _, mg_alias in pairs(mapgen_aliases) do
        minetest.register_alias("mapgen_" .. mg_alias[1], prefix .. mg_alias[2])
end
