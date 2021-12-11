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
                                size = vector.new(7, 10, 7),
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
                speed = {x = 20, z = 10},
        })
end

local timers = {
        environment = 0,
        balloon = 0,
        score = 0,
        counter = 0,
        spawn_objects = 0,
}

local players = {}

local function p_get(p, v)
        return players[p][v]
end

local function p_set(p, v, n)
        players[p][v] = n
end

local function set_environment(player)
        player:hud_set_flags({
                healthbar = false,
                crosshair = false,
                wielditem = false,
                breathbar = false,
                minimap = false,
                minimap_radar = false,
        })
        player:hud_set_hotbar_image("blank.png")
        player:hud_set_hotbar_selected_image("balloon_hotbar_selected.png")
        player:hud_set_hotbar_itemcount(2)
        player:set_sun({
                sunrise_visible = false,
        })
        player:set_stars({
                count = 500,
        })
        player:set_eye_offset(vector.new(0, 20, -60))
        player:set_look_horizontal(4.7)
        player:set_look_vertical(0)
        set_random_sky(player)
        player:set_properties({
                textures = {"blank.png"},
        })
        player:override_day_night_ratio(0.7)
        player:set_inventory_formspec(
                "formspec_version[4]"..
                "size[10, 10]" ..
                "label[0.5,0.5;Controls:\n\n" ..
                "- down: lower the balloon\n" ..
                "- left: move the balloon to the left\n" ..
                "- right: move the balloon to the rigth\n" ..
                "- jump: start game\n" ..
                "- aux1: abort game\n" ..
                "- dig: use the selected item]"
	)
end

local function reset_pos(obj)
        obj:move_to(vector.new(0, 100, 0))
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
        local n = p_get(player, "score") + p_get(player, "coin_points")
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
        p_set(player, "status", "paused")
        add_paused_screen(player)
        reset_pos(balloon)
        balloon:set_properties({
                physical = false,
        })
end

minetest.register_craftitem(prefix .. "gasbottle_item", {
        inventory_image = "balloon_gasbottle.png",
        on_use = function(itemstack, user, pointed_thing)
        end,
})

minetest.register_craftitem(prefix .. "sandbag_item", {
        inventory_image = "balloon_sandbag.png",
        on_use = function(itemstack, user, pointed_thing)
        end,
})

local function register_spawn_entity(name, scale, texture, rotation, extras)
        local properties = {
                initial_properties = {
                        visual = "mesh",
                        mesh = "balloon_" .. name .. ".obj",
                        physical = true,
                        collide_with_objects = false,
                        pointable = false,
                        textures = {texture},
                        visual_size = vector.new(scale, scale, scale),
                },
                _attached_player = nil,
                on_step = function(self)
                        local player = self._attached_player
                        if not player or
                        (player and (p_get(player, "status") == "paused") or (self.object:get_pos().x - player:get_pos().x > 200)) then
                                self.object:remove()
                        end
                end,
        }

        if rotation then
                properties.initial_properties.automatic_rotate = 3
        end

        if extras then
                for setting, value in pairs(extras) do
                        properties[setting] = value
                end
        end

        minetest.register_entity(prefix .. name, properties)
end

register_spawn_entity("coin", 6, "balloon_coin.png", true)
register_spawn_entity("bird", 6, "", false, {
        on_activate = function(self)
                self.object:set_properties({
                        textures = {color_to_texture(random_color())},
                })
                self.object:set_velocity(vector.new(-10, math.random(-2, 2), math.random(-2, 2)))
        end
})
register_spawn_entity("gasbottle", 10, color_to_texture(3), true)
register_spawn_entity("sandbag", 10, color_to_texture(8), true)

local balloon_scale = 3
minetest.register_entity(prefix .. "balloon", {
        initial_properties = {
                visual = "mesh",
                mesh = "balloon_balloon.obj",
                physical = true,
                pointable = false,
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
                        local player_name = player:get_player_name()
                        local control = player:get_player_control()
                        local status = p_get(player, "status")
                        local balloon_pos = balloon:get_pos()

                        if timers.environment >= 30 then
                                set_random_sky(player)
                                timers.environment = 0
                        end

                        if status == "running" then
                                minetest.add_particle({
                                        pos = vector.offset(balloon:get_pos(), math.random(-15, 15) / 100, 0.5, math.random(-15, 15) / 100),
                                        velocity = vector.offset(balloon:get_velocity(), 0, 2, 0),
                                        expirationtime = 0.3,
                                        size = math.random(1, 10) / 20,
                                        texture = color_to_texture(math.random(1, 4)),
                                        playername = player_name,
                                })

                                if timers.score >= 0.5 then
                                        p_set(player, "score", math.floor(balloon_pos.x + 0.5))
                                end

                                local vx, vy, vz = 10, -1, 0
                                if control.left then
                                        vz = 20
                                elseif control.right then
                                        vz = -20
                                else
                                        vx = 20
                                end
                                if control.down then
                                        vy = -10
                                end
                                balloon:set_velocity(vector.new(vx, vy, vz))

                                if control.aux1 then
                                        pause_game(player, balloon)
                                end

                                if timers.spawn_objects > math.random(10, 30) / 10 then
                                        local coin = minetest.add_entity(
                                                vector.offset(balloon_pos,
                                                        math.random(50, 200),
                                                        math.random(-10, 10),
                                                        math.random(-20, 20)
                                                ), "balloon:gasbottle"
                                        )
                                        coin:get_luaentity()._attached_player = player
                                        timers.spawn_objects = 0
                                end
                        elseif status == "counting" then
                                local counting = p_get(player, "counting")
                                if not p_get(player, "hud").counter then
                                        players[player].hud.counter = player:hud_add({
                                                hud_elem_type = "text",
                                                position = {x = 0.5, y = 0.5},
                                                text = counting,
                                                number = 0x4B726E,
                                                size = {x = 5, y = 5},
                                                z_index = 0,
                                                style = 1,
                                        })
                                        balloon:set_velocity(vector.new(0, 0, 0))
                                elseif counting < 0 then
                                        pause_game(player, balloon)
                                        player:hud_remove(p_get(player, "hud").counter)
                                        p_set(player, "counting", 5)
                                        players[player].hud.counter = nil
                                else
                                        if timers.counter >= 0.5 then
                                                p_set(player, "counting", counting - 1)
                                                player:hud_change(p_get(player, "hud").counter, "text", counting)
                                                timers.counter = 0
                                        end
                                end
                        elseif status == "paused" then
                                if control.jump then
                                        p_set(player, "status", "running")
                                        player:hud_remove(players[player].hud.paused)
                                end
                        end

                        if balloon_pos.x >= 60 and not balloon:get_properties().physical and minetest.get_node(balloon_pos).name == "air" then
                                self.object:set_properties({
                                        physical = true,
                                })
                        elseif moveresult then
                                for _, collision in pairs(moveresult.collisions) do
                                        if minetest.get_node(collision.node_pos).name ~= "" then
                                                p_set(player, "status", "counting")
                                                break
                                        end
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
                status = "paused",
                -- "paused", "running", "counting"
                score = 0,
                coin_points = 0,
                counting = 5,
                highscore = player:get_meta():get_int("highscore"),
                balloon = nil,
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
                        position = {x = 1, y = 0},
                        offset = {x = -20, y = 20},
                        text = "",
                        number = 0x4B726E,
                        alignment = {x = -1, y = 1},
                        z_index = 0,
                        style = 1,
                })
        }
        local balloon = minetest.add_entity(player:get_pos(), "balloon:balloon"):get_luaentity()
        balloon._attach_balloonist(balloon, player)

        local balloon_obj = balloon.object
        pause_game(player, balloon_obj)
        p_set(player, "balloon", balloon_obj)
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

minetest.register_chatcommand("scores", {
        description = "Get the highscore of all players",
        func = function(name, param)
                local str = ""
                for player, _ in pairs(players) do
                        str = str .. player:get_player_name() .. ": " .. p_get(player, "highscore") .. "\n"
                end
                minetest.chat_send_player(name, minetest.colorize("#" .. colors[13], str))
        end
})

--[[minetest.sound_play(
        {
                name = "balloon_sink",
                gain = 1.0,
                pitch = 1.0,
        },
        {
                to_player = player_name,
                object = balloon,
        }, true
)]]