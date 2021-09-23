
print("2X!")

-- ## read
gamestate.read = function ()
  -- game
  gamestate.read_game_vars()

  -- players
  read_player_vars(gamestate.player_objects[1])
  read_player_vars(gamestate.player_objects[2])

  -- projectiles
  --~ read_projectiles()
  projectiles = projectiles or {}

  if gamestate.is_in_match then
    update_flip_input(gamestate.player_objects[1], gamestate.player_objects[2])
    update_flip_input(gamestate.player_objects[2], gamestate.player_objects[1])
  end

  --~ function update_player_relationships(_self, _other)
    --~ -- Can't do this inside read_player_vars cause we need both players to have read their stuff
    --~ if _self.has_just_started_wake_up or _self.has_just_started_fast_wake_up then
      --~ _self.wakeup_other_last_act_animation = _other.last_act_animation
      --~ _self.remaining_wakeup_time = find_wake_up(_self.char_str, _self.wakeup_animation, _self.wakeup_other_last_act_animation) or 0
    --~ end
    --~ if _self.remaining_wakeup_time ~= nil then
      --~ _self.remaining_wakeup_time = math.max(_self.remaining_wakeup_time - 1, 0)
    --~ end
  --~ end
  --~ update_player_relationships(gamestate.player_objects[1], gamestate.player_objects[2])
  --~ update_player_relationships(gamestate.player_objects[2], gamestate.player_objects[1])
end

gamestate.read_game_vars = function ()
  -- frame number
  --~ gamestate.frame_number = memory.readbyte(addresses.global.frame_number)
  gamestate.frame_number = emu.framecount()

  -- is in match
  local _previous_is_in_match = gamestate.is_in_match
  if _previous_is_in_match == nil then _previous_is_in_match = true end
  gamestate.is_in_match = (memory.readword(0xFF847F) ~= 0)
  has_match_just_started = not _previous_is_in_match and gamestate.is_in_match
end

-- ## write
function gamestate.write_game_vars(_settings)
  -- freeze game
  if _settings.freeze then
    --~ memory.writebyte(0x0201136F, 0xFF)
  else
    --~ memory.writebyte(0x0201136F, 0x00)
  end

  -- timer
  if _settings.infinite_time then
    timer = memory.readbyte(addresses.global.round_timer)
    if (timer < 0x98) then
      memory.writeword(addresses.global.round_timer,0x9928)
    end
  end

  -- music
  --~ if _settings.music_volume then
    --~ memory.writebyte(0x02078D06, _settings.music_volume * 8)
  --~ end
end

function gamestate.is_object_invalid (_obj)
  return (memory.readword(_obj.base) <= 0x0100)
end

gamestate.read_game_object = function (_obj)
  if gamestate.is_object_invalid(_obj) then --invalid objects
    return false
  end

  _obj.flip_x         = memory.readbyte(_obj.base + 0x12) -- testme
  _obj.previous_pos_x = _obj.pos_x or 0
  _obj.previous_pos_y = _obj.pos_y or 0
  _obj.pos_x          = memory.readwordsigned(_obj.base + 0x06)
  _obj.pos_y          = memory.readwordsigned(_obj.base + 0x0A)
  _obj.char_id        = memory.readword(_obj.base + 0x390)
  _obj.animation_ptr  = memory.readdword(_obj.base + 0x1A)
  _obj.hitbox_ptr     = memory.readdword(_obj.base + 0x34)

  _obj.boxes = {}
  local _boxes = {
    {addr_table = 0x0, id_ptr = 0x8, id_space = 0x04, type = "vulnerability"},
    {addr_table = 0x2, id_ptr = 0x9, id_space = 0x04, type = "vulnerability"},
    {addr_table = 0x4, id_ptr = 0xA, id_space = 0x04, type = "vulnerability"},
    {addr_table = 0x6, id_ptr = 0xC, id_space = 0x10, type = "attack"},
    {addr_table = 0x8, id_ptr = 0xD, id_space = 0x04, type = "push"},
    --~ throw_box_list = {
      --~ {param_offset = 0x6C, type = "throwable"},
      --~ {param_offset = 0x64, type = "throw"},
    --~ }
  }

  for _, _box in ipairs(_boxes) do
    gamestate.read_box(_obj, _box)
  end
  return true
end

function gamestate.read_box(_obj, _box)
  local box = {
    type = _box.type,
    id = memory.readbyte(_obj.animation_ptr + _box.id_ptr),
  }

  if (box.id == 0) then
    return
  end

  box.address = _obj.hitbox_ptr + memory.readwordsigned(_obj.hitbox_ptr + _box.addr_table) + box.id * _box.id_space
  box.hval   = memory.readbytesigned(box.address + 0)
  box.hval2  = memory.readbyte(box.address + 5)
  if box.hval2 >= 0x80 and box.type == "attack" then
    box.hval = -box.hval2
  end
  box.vval  = memory.readbytesigned(box.address + 1)
  box.hrad  = memory.readbyte(box.address + 2)
  box.vrad  = memory.readbyte(box.address + 3)

  box.left   = box.hval - box.hrad
  box.width  = box.hrad * 2
  box.bottom = box.vval - box.vrad
  box.height = box.vrad * 2

  table.insert(_obj.boxes, box)
end

-- - 0 is no player
-- - 1 is intro anim
-- - 2 is character select
-- - 3 is SA intro anim
-- - 4 is SA select
-- - 5 is locked SA
-- Will always stay at 5 after that and during the match
gamestate.get_character_select_state = function (id)
  if (memory.readword(0xFF8008) ~= 0) then
    return 5
  end
  if (memory.readbyte(addresses.players[id].char_select) > 0x30) then
    return 5
  end
  return 2
end

gamestate.read_screen_information = function ()
  -- screen stuff
  screen_x = memory.readword(addresses.global.screen_x)
  screen_y = memory.readword(addresses.global.screen_y)
  --~ scale = memory.readwordsigned(0x0200DCBA) --FBA can't read from 04xxxxxx
  --~ scale = 0x40/(scale > 0 and scale or 1)
  scale = 1 -- fixme
end

-- # tools
function game_to_screen_space(_x, _y)
  local _px = _x - screen_x
  local _py = emu.screenheight() - (_y - screen_y) - rom.ground_offset
  return _px, _py
end
