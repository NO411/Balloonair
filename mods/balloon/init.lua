local minetest, math, vector, pairs, table = minetest, math, vector, pairs, table
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

local function table_random(t)
        return t[math.random(#t)]
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
        if players[p] then
                return players[p][v]
        else
                return ""
        end
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
        player:set_eye_offset(vector.new(0, 30, -60))
        player:set_look_horizontal(4.7)
        player:set_look_vertical(0)
        set_random_sky(player)
        player:set_properties({
                textures = {"blank.png"},
                pointable = false,
        })
        player:override_day_night_ratio(0.7)
        player:set_inventory_formspec(
                "formspec_version[4]"..
                "size[10, 10]" ..
                "label[0.5,0.5;Controls:\n\n" ..
                "- Down: lower the balloon\n" ..
                "- Left: move the balloon to the left\n" ..
                "- Right: move the balloon to the rigth\n" ..
                "- Jump: start game\n" ..
                "- Aux1: abort game\n" ..
                "- Dig: use the selected item\n" ..
                "- Escape: pause game]"
        )
        player:get_inventory():set_size("main", 2)
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
        local score = p_get(player, "score") + p_get(player, "coin_points")
        if score > p_get(player, "highscore") then
               p_set(player, "highscore", score)
        end
        p_set(player, "score", 0)
        p_set(player, "coin_points", 0)
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

local function remove_gas_drive(b_ent)
        b_ent._gas_drive = false
        b_ent._gasbottle:set_properties({
                is_visible = false
        })
end

local function remove_sand_drive(b_ent, all, sandbag)
        if all then
                b_ent._sand_drive = 0
                for _, obj in pairs(b_ent._sandbags) do
                        obj:set_properties({
                                is_visible = false,
                        })
                end
        elseif sandbag then
                b_ent._sand_drive = b_ent._sand_drive - 1
                sandbag:set_properties({
                        is_visible = false,
                })
        end
end

local function pause_game(player, balloon)
        set_highscore(player)
        p_set(player, "status", "paused")
        add_paused_screen(player)
        reset_pos(balloon)
        balloon:set_properties({
                physical = false,
        })
        for i, item in pairs({"gasbottle", "sandbag"}) do
                player:get_inventory():set_stack("main", i, {name = prefix .. item .. "_item", count = 2})
        end
        local b_ent = balloon:get_luaentity()
        remove_gas_drive(b_ent)
        remove_sand_drive(b_ent, true)
end

local function play_power_up(player)
        minetest.sound_play({name = "balloon_rise", gain = 1.0, pitch = 1.0}, {to_player = player:get_player_name()}, true)
end

minetest.register_craftitem(prefix .. "gasbottle_item", {
        inventory_image = "balloon_gasbottle.png",
        on_use = function(itemstack, user, pointed_thing)
                local balloon = p_get(user, "balloon")
                local b_ent = balloon:get_luaentity()
                if not b_ent._gas_drive and p_get(user, "status") == "running" then
                        b_ent._gas_drive = true
                        itemstack:take_item()
                        local gasbottle = b_ent._gasbottle
                        gasbottle:set_properties({
                                is_visible = true
                        })
                        minetest.after(10, function()
                                if balloon and gasbottle then
                                        remove_gas_drive(b_ent)
                                end
                        end)
                        play_power_up(user)
                end
                return itemstack
        end,
})

minetest.register_craftitem(prefix .. "sandbag_item", {
        inventory_image = "balloon_sandbag.png",
        on_use = function(itemstack, user, pointed_thing)
                local balloon = p_get(user, "balloon")
                local b_ent = balloon:get_luaentity()
                local sand_drive = b_ent._sand_drive
                if sand_drive < 4 and p_get(user, "status") == "running" then

                        b_ent._sand_drive = sand_drive + 1
                        local sandbag
                        for _, obj in pairs(b_ent._sandbags) do
                                if b_ent._sandbags and not obj:get_properties().is_visible then
                                        obj:set_properties({
                                                is_visible = true,
                                        })
                                        sandbag = obj
                                        break
                                end
                        end
                        itemstack:take_item()
                        minetest.after(10, function()
                                if balloon and sandbag then
                                        remove_sand_drive(b_ent, false, sandbag)
                                end
                        end)
                        play_power_up(user)
                end
                return itemstack
        end,
})

local spawn_entities = {}
local function register_spawn_entity(name, scale, texture, rotation, spawn, extras)
        local properties = {
                initial_properties = {
                        visual = "mesh",
                        mesh = "balloon_" .. name .. ".obj",
                        physical = true,
                        collide_with_objects = false,
                        pointable = false,
                        textures = {texture},
                        visual_size = vector.new(scale, scale, scale),
			collisionbox = {-10, -10, -10, 10, 10, 10},
                },
                _attached_player = nil,
                on_step = function(self)
                        local player = self._attached_player
                        if not player or (spawn and (player and p_get(player, "status") == "paused") or (player:get_pos() and self.object:get_pos().x - player:get_pos().x > 200)) then
                                self.object:remove()
                        end
                end,
        }

        if rotation then
                local r = 3
                if type(rotation) == "number" then
                        r = rotation
                end
                properties.initial_properties.automatic_rotate = r
        end

        if extras then
                for setting, value in pairs(extras) do
                        properties[setting] = value
                end
        end

        local ent_name = prefix .. name
        if spawn then
                table.insert(spawn_entities, ent_name)
        else
                properties.initial_properties.is_visible = false
        end
        minetest.register_entity(ent_name, properties)

end

register_spawn_entity("coin", 15, "balloon_coin.png", true, true)
register_spawn_entity("bird", 10, "", false, true, {
        on_activate = function(self)
                self.object:set_properties({
                        textures = {color_to_texture(random_color())},
                })
                self.object:set_velocity(vector.new(-10, math.random(-2, 2), math.random(-2, 2)))
        end
})
register_spawn_entity("gasbottle", 10, color_to_texture(3), true, true)
register_spawn_entity("sandbag", 10, color_to_texture(8), true, true)

local balloon_scale = 3
register_spawn_entity("balloon_gasbottle", 1, color_to_texture(3), 0.1)
register_spawn_entity("balloon_sandbag", 1, color_to_texture(8), 0.1)
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
        _gas_drive = false,
        _sand_drive = 0,
        _gasbottle = nil,
        _sandbags = {nil},
	_bird_drive = false,
        on_step = function(self, dtime, moveresult)
                for n, _ in pairs(timers) do
                        timers[n] = timers[n] + dtime
                end
                local balloon = self.object
                local player = self._balloonist
                if player and players[player] then
                        local player_name = player:get_player_name()
                        local control = player:get_player_control()
                        local status = p_get(player, "status")
                        local balloon_pos = balloon:get_pos()

                        if timers.environment >= 30 then
                                set_random_sky(player)
                                timers.environment = 0
                        end

                        if status == "running" then
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

                                if self._gas_drive then
					for i = 1, 2 do
                                        	minetest.add_particle({
                                        	        pos = vector.offset(balloon:get_pos(), math.random(-15, 15) / 100, 0.6, math.random(-15, 15) / 100),
                                        	        velocity = vector.offset(balloon:get_velocity(), -0.3, 3, 0),
                                        	        expirationtime = 0.3,
                                        	        size = math.random(1, 10) / 20,
                                        	        texture = color_to_texture(math.random(1, 4)),
                                        	        playername = player_name,
                                        	})
					end
                                        vx = vx + 30
                                end

                                local sand_drive = self._sand_drive
                                if sand_drive > 0 then
					for i = 1, sand_drive do
                                        	minetest.add_particle({
                                        	        pos = vector.offset(balloon:get_pos(), math.random(-20, 20) / 100, balloon_scale / 2 - 2, math.random(-20, 20) / 100),
                                        	        velocity = vector.offset(balloon:get_velocity(), math.random(-5, 5) / 10, -1, math.random(-5, 5) / 10),
                                        	        expirationtime = 1,
                                        	        size = math.random(1, 10) / 15,
                                        	        texture = color_to_texture(table_random({1, 6, 15, 16})),
                                        	        playername = player_name,
                                        	})
					end
                                        vy = sand_drive * 2
                                end

                                if control.down then
                                        vy = -10
                                end

				if self._bird_drive then
					vy = vy - 20
				end

                                balloon:set_velocity(vector.new(vx, vy, vz))

                                if control.aux1 then
                                        pause_game(player, balloon)
                                end

                                if timers.spawn_objects > 1 then
                                        local random_pos = vector.offset(balloon_pos,
                                                math.random(50, 200),
                                                math.random(-10, 10),
                                                math.random(-20, 20)
                                        )
                                        if minetest.get_node(random_pos).name == "air" then
                                                local ent = minetest.add_entity(random_pos, table_random(spawn_entities))
                                                ent:get_luaentity()._attached_player = player
                                        end
                                        timers.spawn_objects = 0
                                end

                                local radius = balloon_scale / 2
                                for _, obj in pairs(minetest.get_objects_inside_radius(vector.offset(balloon_pos, 0, radius, 0), radius + 2.5)) do
                                        local ent = obj:get_luaentity()
                                        if ent then
                                                local ename = ent.name
                                                if ename ~= prefix .. "balloon" and ename ~= prefix .. "balloon_gasbottle" and ename ~= prefix .. "balloon_sandbag" then
                                                        if ename == prefix .. "bird" then
                                                                minetest.sound_play({name = "balloon_bird" .. math.random(1, 3), gain = 1.0, pitch = 1.0}, {to_player = player_name, object = obj}, true)
								minetest.sound_play({name = "balloon_sink", gain = 1.0, pitch = 1.0}, {to_player = player:get_player_name()}, true)
								self._bird_drive = true
								minetest.after(2, function()
									if player and self._bird_drive then
										self._bird_drive = false
									end
								end)
                                                        else
                                                                minetest.sound_play({name = "balloon_collect", gain = 1.0, pitch = 1.0}, {to_player = player_name, object = obj}, true)
                                                        end

                                                        if ename == prefix .. "coin" then
                                                                p_set(player, "coin_points", p_get(player, "coin_points") + 100)
                                                                local bonus_hud = p_get(player, "hud").bonus_points
                                                                if not bonus_hud then
                                                                        players[player].hud.bonus_points = player:hud_add({
                                                                                hud_elem_type = "text",
                                                                                position = {x = 0.75, y = 0.5},
                                                                                text = "+100",
                                                                                number = 0x4B726E,
                                                                                z_index = 0,
                                                                                style = 1,
                                                                        })
                                                                        minetest.after(2, function()
                                                                                if player then
                                                                                        player:hud_remove(p_get(player, "hud").bonus_points)
                                                                                        players[player].hud.bonus_points = nil
                                                                                end
                                                                        end)
                                                                else
                                                                        local text = player:hud_get(bonus_hud).text
                                                                        local value = tonumber(string.sub(text, 2, 2)) + 1
                                                                        player:hud_change(bonus_hud, "text", "+" .. value .. "00")
                                                                end
                                                        elseif ename == prefix .. "sandbag" or ename == prefix .. "gasbottle" then
                                                                player:get_inventory():add_item("main", {name = ename .. "_item"})
                                                        end
                                                        obj:move_to(balloon_pos)
                                                        obj:remove()
                                                end
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

                        update_score_hud(player)
                else
                        balloon:remove()
                end
        end,
        _attach_balloonist = function(self, player)
                local balloon = self.object
		self._balloonist = player
		player:set_attach(balloon, "", vector.new(0, 0, 0), vector.new(0, 0, 0))

                local gasbottle = minetest.add_entity(balloon:get_pos(), prefix .. "balloon_gasbottle")
                gasbottle:set_attach(balloon, "", vector.new(0, 0, 0), vector.new(0, 0, 0))
                gasbottle:get_luaentity()._attached_player = player
                self._gasbottle = gasbottle

                for i = 1, 4 do
                        local sandbag = minetest.add_entity(balloon:get_pos(), prefix .. "balloon_sandbag")
                        sandbag:set_attach(balloon, "", vector.new(0, 0, 0), vector.new(0, (i - 1) * 90, 0))
                        sandbag:get_luaentity()._attached_player = player
                        self._sandbags[i] = sandbag
                end
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
        local balloon = minetest.add_entity(player:get_pos(), prefix .. "balloon"):get_luaentity()
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
        description = "Get the highscore of all online players",
        func = function(name, param)
                local str = ""
                for player, _ in pairs(players) do
                        str = str .. player:get_player_name() .. ": " .. p_get(player, "highscore") .. "\n"
                end
                minetest.chat_send_player(name, minetest.colorize("#" .. colors[13], str))
        end
})
