local minetest, math, vector, pairs, table = minetest, math, vector, pairs, table
local modname = minetest.get_current_modname()

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

local function play_sound(sound, max, player)
	minetest.sound_play({name = "balloon_" .. sound .. math.random(1, max), gain = 1.0, pitch = 1.0}, {to_player = player:get_player_name()}, true)
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

local function remove_hud(player, ...)
	local hud = p_get(player, "hud")
	local id = hud
	local ids = {...}
	for i, _id in pairs(ids) do
		if i == #ids then
			player:hud_remove(id[_id])
			id[_id] = nil
			break
		end
		id = id[_id]
	end
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
	player:hud_set_hotbar_itemcount(3)
	player:get_inventory():set_size("main", 3)
	player:set_sun({
		sunrise_visible = false,
	})
	player:set_stars({
		count = 500,
	})
	player:set_eye_offset(vector.new(0, 30, -60))
	player:set_look_horizontal(4.7)
	player:set_look_vertical(0.28)
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
end

local function reset_pos(balloon)
	local player = balloon:get_luaentity()._balloonist
	local n_player
	for n, p in pairs(minetest.get_connected_players()) do
		if player == p then
			n_player = n
			break
		end
	end
	balloon:move_to(vector.new(0, 100, 50 * n_player - 50))
	balloon:set_velocity(vector.new(0, 0, 0))
end


local function add_paused_screen(player)
	p_get(player, "hud").paused = player:hud_add({
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
	local ret = false
	local score = p_get(player, "score") + p_get(player, "coin_points")
	if score > p_get(player, "highscore") then
		p_set(player, "highscore", score)
		ret = true
	end
	p_set(player, "score", 0)
	p_set(player, "coin_points", 0)
	player:get_meta():set_int("highscore", p_get(player, "highscore"))
	return ret
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

local function remove_bird_drive(b_ent)
	b_ent._bird_drive = false
	b_ent.object:set_properties({
		automatic_rotate = 0.1,
	})
end

local function update_boost_board(player, effect)
	player:hud_change(p_get(player, "hud").boost_board, "text", "balloon_hud_boost_board" .. effect .. ".png")
end

local function remove_shield_drive(b_ent)
	b_ent._shield_drive = false
	b_ent.object:set_properties({
		physical = true,
	})
	local player = b_ent._balloonist
	if p_get(player, "hud").boosts.counters[6] then
		remove_hud(player, "boosts", "counters", 6)
		remove_hud(player, "boosts", "images", 6)
	end
	update_boost_board(player, "")
end

local function remove_sand_drive(b_ent, all, sandbag, i)
	if all then
		b_ent._sand_drives = {false, false, false, false}
		b_ent._sand_drive = 0
		for _, obj in pairs(b_ent._sandbags) do
			obj:set_properties({
				is_visible = false,
			})
		end
	elseif sandbag then
		b_ent._sand_drive = b_ent._sand_drive - 1
		b_ent._sand_drives[i] = false
		sandbag:set_properties({
			is_visible = false,
		})
	end
end

local function add_explosion(amount, player, balloon)
	for i = 1, #colors do
		minetest.add_particlespawner({
			amount = amount,
			time = 1,
			minvel = vector.new(-5, 0, -5),
			maxvel = vector.new(5, 5, 5),
			attached = balloon,
			minexptime = 1,
			maxexptime = 1,
			minsize = 1,
			maxsize = 5,
			texture = color_to_texture(i),
			playername = player_name,
		})
	end
	play_sound("explosion", 1, player)
end

local function pause_game(player, balloon, won)
	p_set(player, "status", "paused")
	local balloon_pos = balloon:get_pos()
	minetest.after(0.01, function()
		if p_get(player, "status") == "paused" then
			add_paused_screen(player)
		end
	end)
	if set_highscore(player) then
		if not p_get(player, "hud").new_highscore then
			local highscore = p_get(player, "highscore")
			local text = "New Highscore!"

			if won then
				text = "YOU WON!"
			end

			p_get(player, "hud").new_highscore = {
				player:hud_add({
					hud_elem_type = "text",
					position = {x = 0.5, y = 0.1},
					text = highscore,
					number = 0xAE5D40,
					size = {x = 2, y = 2},
					z_index = 0,
					style = 1,
				}),
				player:hud_add({
					hud_elem_type = "text",
					position = {x = 0.5, y = 0.2},
					text = text,
					number = 0xC77B58,
					size = {x = 2, y = 2},
					z_index = 0,
					style = 1,
				})
			}
			p_get(player, "timers").new_highscore = 0
			add_explosion(10, player, balloon)
		else
			player:hud_change(p_get(player, "hud").new_highscore[1], "text", highscore)
		end
	end
	reset_pos(balloon)

	local inv = player:get_inventory()
	inv:set_stack("main", 1, {name = prefix .. "gasbottle_item", count = 1})
	inv:set_stack("main", 2, {name = prefix .. "shield_coin_item", count = 1})
	inv:set_stack("main", 3, {name = prefix .. "sandbag_item", count = 2})

	local b_ent = balloon:get_luaentity()
	b_ent._speed = 0

	remove_gas_drive(b_ent)
	remove_sand_drive(b_ent, true)
	remove_shield_drive(b_ent)
	remove_bird_drive(b_ent)

	players[player].boosts = {0, 0, 0, 0, 0, 0}

	local boost_hud = p_get(player, "hud").boosts

	if boost_hud.counters[1] then
		remove_hud(player, "boosts", "counters", 1)
	end
	
	for i = 1, 6 do
		if boost_hud.images[i] then
			remove_hud(player, "boosts", "images", i)
		end
	end

	for i = 2, 5 do
		if boost_hud.counters[i]  then
			remove_hud(player, "boosts", "counters", i)
		end
	end

	balloon:set_properties({
		physical = false,
	})
	balloon:set_rotation(vector.new(0, 0, 0))
end

local function add_boost_hud(player, i, image)
	p_get(player, "boosts")[i] = 10
	local boost_hud = p_get(player, "hud").boosts
	boost_hud.counters[i] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0},
		offset = {x = -20, y = 20 + 30 * i},
		alignment = {x = -1, y = 1},
		text = "10",
		number = 0x4B726E,
		z_index = 0,
		style = 1,
	})
	boost_hud.images[i] = player:hud_add({
		hud_elem_type = "image",
		position = {x = 1, y = 0},
		alignment = {x = -1, y = 1},
		scale = {x = 1.5, y = 1.5},
		offset = {x = -40, y = 17.5 + 30 * i},
		text = "balloon_" .. image .. ".png",
		z_index = 0,
	})
end

local function can_activate_boost(balloon, b_ent, drive, player)
	return balloon and b_ent and
	p_get(player, "status") == "running" and
	((type(b_ent["_" .. drive .. "_drive"]) == "number" and b_ent["_" .. drive .. "_drive"] < 4) or not b_ent["_" .. drive .. "_drive"])
end

minetest.register_craftitem(prefix .. "gasbottle_item", {
	inventory_image = "balloon_gasbottle.png",
	on_use = function(itemstack, user, pointed_thing)
		local balloon = p_get(user, "balloon")
		local b_ent = balloon:get_luaentity()
		if can_activate_boost(balloon, b_ent, "gas", user) then
			b_ent._gas_drive = true
			itemstack:take_item()
			local gasbottle = b_ent._gasbottle
			gasbottle:set_properties({
				is_visible = true
			})
			add_boost_hud(user, 1, "gasbottle")
			play_sound("gas", 2, user)
		end
		return itemstack
	end,
})

minetest.register_craftitem(prefix .. "shield_coin_item", {
	inventory_image = "balloon_shield.png",
	on_use = function(itemstack, user, pointed_thing)
		local balloon = p_get(user, "balloon")
		local b_ent = balloon:get_luaentity()
		if can_activate_boost(balloon, b_ent, "shield", user) then
			b_ent._shield_drive = true
			itemstack:take_item()
			add_boost_hud(user, 6, "shield")
			update_boost_board(user, "_shield")
			balloon:set_properties({
				physical = false,
			})
			play_sound("use_shield", 1, user)
		end
		return itemstack
	end,
})

minetest.register_craftitem(prefix .. "sandbag_item", {
	inventory_image = "balloon_sandbag.png",
	on_use = function(itemstack, user, pointed_thing)
		local balloon = p_get(user, "balloon")
		local b_ent = balloon:get_luaentity()
		if can_activate_boost(balloon, b_ent, "sand", user) then
			b_ent._sand_drive = b_ent._sand_drive + 1
			for i, drive in pairs(b_ent._sand_drives) do
				if not drive then
					b_ent._sandbags[i]:set_properties({
						is_visible = true,
					})
					b_ent._sand_drives[i] = true
					add_boost_hud(user, i + 1, "sandbag")
					break
				end
			end

			itemstack:take_item()
			play_sound("sand", 2, user)
		end
		return itemstack
	end,
})

local spawn_entities = {}
local function register_spawn_entity(name, scale, texture, probability, rotation, spawn, extras, init_extras)
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

	if init_extras then
		for setting, value in pairs(init_extras) do
			properties.initial_properties[setting] = value
		end
	end

	local ent_name = prefix .. name
	if spawn and probability then
		for i = 1, 100 * probability do
			table.insert(spawn_entities, ent_name)
		end
	else
		properties.initial_properties.is_visible = false
	end
	
	minetest.register_entity(ent_name, properties)
end

register_spawn_entity("coin", 15, "balloon_coin.png", 0.5, true, true)
register_spawn_entity("shield_coin", 15, "balloon_shield_coin.png", 0.05, 10, true, nil, {mesh = "balloon_coin.obj"})

register_spawn_entity("bird", 10, "", 0.3, false, true, {
	on_activate = function(self)
		self.object:set_properties({
			textures = {color_to_texture(random_color())},
		})
		self.object:set_velocity(vector.new(-40, 0, 0))
	end
})

register_spawn_entity("gasbottle", 10, color_to_texture(3), 0.05, true, true)
register_spawn_entity("sandbag", 10, color_to_texture(8), 0.1, true, true)

register_spawn_entity("balloon_gasbottle", 1, color_to_texture(3), nil, 0.1)
register_spawn_entity("balloon_sandbag", 1, color_to_texture(8), nil, 0.1)

local function spawn_random_entity(pos, player)
	if minetest.get_node(pos).name == "air" then
		minetest.add_entity(pos, table_random(spawn_entities)):get_luaentity()._attached_player = player
	end
end

local balloon_scale = 3

local function main_loop(self, balloon, player, timers, moveresult, dtime)
	local player_name = player:get_player_name()
	local control = player:get_player_control()
	local status = p_get(player, "status")
	local balloon_pos = balloon:get_pos()
	local hud = p_get(player, "hud")
	local rotation = balloon:get_rotation()


	if timers.environment >= 30 then
		set_random_sky(player)
		timers.environment = 0
	end
	
	if status == "running" then
		local boosts = p_get(player, "boosts")

		if timers.score >= 0.5 then
			p_set(player, "score", math.floor(balloon_pos.x + 0.5))
		end

		local sand_drive = self._sand_drive
		if timers.seconds >= 1 then
			local boost_hud = hud.boosts
			if self._gas_drive then
				local gas_seconds = boosts[1]
				if gas_seconds == 0 then
					remove_gas_drive(self)
					remove_hud(player, "boosts", "counters", 1)
					remove_hud(player, "boosts", "images", 1)
				else
					player:hud_change(boost_hud.counters[1], "text", gas_seconds)
					boosts[1] = gas_seconds - 1
				end
			end

			if self._shield_drive then
				local shield_seconds = boosts[6]
				if shield_seconds == 0 then
					remove_shield_drive(self)
				else
					player:hud_change(boost_hud.counters[6], "text", shield_seconds)
					boosts[6] = shield_seconds - 1
				end
			end

			for i = 2, 5 do
				local sandbag = self._sandbags[i - 1]
				if self._sand_drives[i - 1] then
					local sand_seconds = boosts[i]
					if sand_seconds == 0 then
						remove_hud(player, "boosts", "counters", i)
						remove_hud(player, "boosts", "images", i)
						remove_sand_drive(self, false, sandbag, i - 1)
					else
						player:hud_change(boost_hud.counters[i], "text", sand_seconds)
						boosts[i] = sand_seconds - 1
					end
				end
			end
			timers.seconds = 0
		end

		if timers.bird >= 1.5 and self._bird_drive then
			remove_bird_drive(self)
		end

		local rx, rz = 0, 0
		local vx, vy, vz = 10, -1, 0
		local rotx = rotation.x
		if control.left then
			vz = 20
			if rotx > -0.2 then
				rx = rotx - 0.004
			else
				rx = -0.21
			end
		elseif control.right then
			vz = -20
			if rotx < 0.2 then
				rx = rotx + 0.004
			else
				rx = 0.21
			end
		else
			vx = 20
			if rotx > 0.01 then
				rx = rotx - 0.004
			elseif rotx < -0.01 then
				rx = rotx + 0.004
			else
				rx = 0
			end
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
			if rotation.z < 0.2 then
				rz = rotation.z + 0.005
			else
				rz = 0.21
			end
		else
			if rotation.z > 0.01 then
				rz = rotation.z - 0.005
			else
				rz = 0
			end
		end

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

		local _speed = self._speed
		self._speed = _speed + 0.01

		balloon:set_velocity(vector.new(vx + _speed, vy, vz))
		balloon:set_rotation(vector.new(rx, 0, rz))

		if timers.change_spawn_pos > 3 then
			self._spawn_pos = {
				y = balloon_pos.y + math.random(-10, 10),
				z = balloon_pos.z + math.random(-20, 20)
			}
			timers.change_spawn_pos = 0
		end

		if timers.spawn_objects >= 0.7 then
			local _pos = self._spawn_pos
			local x = balloon_pos.x + 90
			if math.random(1, 10) == 1 then
				for i = -2, 2 do
					local pos = vector.new(x, _pos.y, _pos.z + i * 8)
					spawn_random_entity(pos, player)
				end
			else
				local pos = vector.new(x, _pos.y, _pos.z)
				spawn_random_entity(pos, player)
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
						play_sound("bird", 3, player)
						if not self._shield_drive then
							play_sound("sink", 2, player)
							self._bird_drive = true
							balloon:set_properties({
								automatic_rotate = 5,
							})
							timers.bird = 0
						else
							remove_shield_drive(self)
							play_sound("remove_shield", 1, player)
						end
					else
						play_sound("collect", 1, player)
					end
					if ename == prefix .. "coin" then
						p_set(player, "coin_points", p_get(player, "coin_points") + 10)
						local bonus_hud = p_get(player, "hud").bonus_points
						if not bonus_hud then
							hud.bonus_points = player:hud_add({
								hud_elem_type = "text",
								position = {x = 0.75, y = 0.5},
								text = "+10",
								size = {x = 2, y = 2},
								number = 0x4B726E,
								z_index = -2,
								style = 1,
							})
							minetest.after(1.2, function()
								if player then
									remove_hud(player, "bonus_points")
								end
							end)
						else
							local get_bonus_hud = player:hud_get(bonus_hud)
							if get_bonus_hud then
								local text = get_bonus_hud.text
								local value = tonumber(string.sub(text, 2, 2)) + 1
								player:hud_change(bonus_hud, "text", "+" .. value .. "0")
							end
						end
					elseif ename == prefix .. "sandbag" or ename == prefix .. "gasbottle" or ename == prefix .. "shield_coin" then
						player:get_inventory():add_item("main", {name = ename .. "_item"})
					end
					obj:move_to(balloon_pos)
					obj:remove()
				end
			end
		end

		local bonus_hud = hud.bonus_points
		if bonus_hud and player:hud_get(bonus_hud) then
			local get_bonus_hud = player:hud_get(bonus_hud)
			player:hud_change(bonus_hud, "position", {
				x = get_bonus_hud.position.x + 0.002,
				y = get_bonus_hud.position.y - 0.005,
			})
		end

		if not self._shield_drive and balloon_pos.x >= 60 and not balloon:get_properties().physical and minetest.get_node(balloon_pos).name == "air" then
			self.object:set_properties({
				physical = true,
			})
		elseif moveresult and not self._shield_drive then
			for _, collision in pairs(moveresult.collisions) do
				if minetest.get_node(collision.node_pos).name ~= "" then
					p_set(player, "status", "counting")
					balloon:set_properties({
						automatic_rotate = 0,
					})
					break
				end
			end
		end

		if balloon_pos.x > 30900 then
			pause_game(player, balloon, true)
			add_explosion(100, player, balloon)
		end

		if control.aux1 then
			pause_game(player, balloon)
		end

	elseif status == "counting" then
		local counting = p_get(player, "counting")
		if not hud.counter then
			hud.counter = player:hud_add({
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
			remove_hud(player, "counter")
			p_set(player, "counting", 5)
		else
			if timers.counter >= 0.5 then
				p_set(player, "counting", counting - 1)
				player:hud_change(hud.counter, "text", counting)
				play_sound("tick", 1, player)
				timers.counter = 0
			end
		end
	elseif status == "paused" then
		if control.jump then
			p_set(player, "status", "running")
			remove_hud(player, "paused")
		end
	end
	
	if hud.new_highscore and timers.new_highscore >= 1 then
		for i = 1, 2 do
			player:hud_change(hud.new_highscore[i], "position", {
				x = 0.5,
				y = player:hud_get(hud.new_highscore[i]).position.y - 0.01
			})
		end
		if timers.new_highscore >= 2 then
			remove_hud(player, "new_highscore", 1)
			remove_hud(player, "new_highscore", 2)
			hud.new_highscore = nil
		end
	end

	update_score_hud(player)
end

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
	_gasbottle = nil,

	_sand_drive = 0,
	_sand_drives = {false, false, false, false},
	_sandbags = {nil},

	_bird_drive = false,

	_shield_drive = false,
	
	_spawn_pos = {y = 0, z = 0},
	_speed = 0,
	on_step = function(self, dtime, moveresult)
		local balloon = self.object
		local player = self._balloonist
		if player and players[player] then

			local timers = p_get(player, "timers")
			for n, _ in pairs(timers) do
				timers[n] = timers[n] + dtime
			end

			main_loop(self, balloon, player, timers, moveresult, dtime)
			
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

minetest.register_on_joinplayer(function(player)
	set_environment(player)

	players[player] = {
		status = "paused",
		score = 0,
		coin_points = 0,
		counting = 5,
		highscore = player:get_meta():get_int("highscore"),
		balloon = nil,
		boosts = {0, 0, 0, 0, 0, 0},
		timers = {
			environment = 0,
			balloon = 0,
			score = 0,
			counter = 0,
			spawn_objects = 0,
			change_spawn_pos = 0,
			seconds = 0,
			bird = 0,
			new_highscore = 0,
		},
		hud = {
			overlay = player:hud_add({
				hud_elem_type = "image",
				position = {x = 0.5, y = 0.5},
				scale = {x = -101, y = -101},
				text = "balloon_hud_overlay.png",
				z_index = -1,
			}),
			boost_board = player:hud_add({
				hud_elem_type = "image",
				position = {x = 1, y = 0},
				scale = {x = 0.46, y = 0.5},
				offset = {x = -5, y = 5},
				alignment = {x = -1, y = 1},
				text = "balloon_hud_boost_board.png",
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
			}),
			boosts = {
				counters = {},
				images = {},
			},
		},
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
		minetest.chat_send_player(name, minetest.colorize("#" .. colors[13], string.sub(str, 1, -2)))
	end
})
