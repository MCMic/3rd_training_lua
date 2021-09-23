-- ## read
function gamestate.read()
  -- game
  gamestate.read_game_vars()

  -- players
  read_player_vars(gamestate.player_objects[1])
  read_player_vars(gamestate.player_objects[2])

  -- projectiles
  read_projectiles()

  if gamestate.is_in_match then
    update_flip_input(gamestate.player_objects[1], gamestate.player_objects[2])
    update_flip_input(gamestate.player_objects[2], gamestate.player_objects[1])
  end

  function update_player_relationships(_self, _other)
    -- Can't do this inside read_player_vars cause we need both players to have read their stuff
    if _self.has_just_started_wake_up or _self.has_just_started_fast_wake_up then
      _self.wakeup_other_last_act_animation = _other.last_act_animation
      _self.remaining_wakeup_time = find_wake_up(_self.char_str, _self.wakeup_animation, _self.wakeup_other_last_act_animation) or 0
    end
    if _self.remaining_wakeup_time ~= nil then
      _self.remaining_wakeup_time = math.max(_self.remaining_wakeup_time - 1, 0)
    end
  end
  update_player_relationships(gamestate.player_objects[1], gamestate.player_objects[2])
  update_player_relationships(gamestate.player_objects[2], gamestate.player_objects[1])
end

function gamestate.read_game_vars()
  -- frame number
  gamestate.frame_number = memory.readdword(addresses.global.frame_number)

  -- is in match
  -- I believe the bytes that are expected to be 0xff means that a character has been locked, while the byte expected to be 0x02 is the current match state. 0x02 means that round has started and players can move
  local p1_locked = memory.readbyte(0x020154C6);
  local p2_locked = memory.readbyte(0x020154C8);
  local match_state = memory.readbyte(0x020154A7);
  local _previous_is_in_match = gamestate.is_in_match
  if _previous_is_in_match == nil then _previous_is_in_match = true end
  gamestate.is_in_match = ((p1_locked == 0xFF or p2_locked == 0xFF) and match_state == 0x02);
  has_match_just_started = not _previous_is_in_match and gamestate.is_in_match
end

-- ## write
function gamestate.write_game_vars(_settings)
  -- freeze game
  if _settings.freeze then
    memory.writebyte(0x0201136F, 0xFF)
  else
    memory.writebyte(0x0201136F, 0x00)
  end

  -- timer
  if _settings.infinite_time then
    memory.writebyte(0x02011377, 100)
  end

  -- music
  if _settings.music_volume then
    memory.writebyte(0x02078D06, _settings.music_volume * 8)
  end
end

function gamestate.read_screen_information()
  -- screen stuff
  screen_x = memory.readwordsigned(0x02026CB0)
  screen_y = memory.readwordsigned(0x02026CB4)
  scale = memory.readwordsigned(0x0200DCBA) --FBA can't read from 04xxxxxx
  scale = 0x40/(scale > 0 and scale or 1)
end

-- - 0 is no player
-- - 1 is intro anim
-- - 2 is character select
-- - 3 is SA intro anim
-- - 4 is SA select
-- - 5 is locked SA
-- Will always stay at 5 after that and during the match
function gamestate.get_character_select_state(id)
  return memory.readbyte(addresses.players[id].character_select_state)
end

function gamestate.is_object_invalid (_obj)
  return (memory.readdword(_obj.base + 0x2A0) == 0)
end

function gamestate.read_game_object(_obj)
  if gamestate.is_object_invalid(_obj) then --invalid objects
    return false
  end

  _obj.friends = memory.readbyte(_obj.base + 0x1)
  _obj.flip_x = memory.readbytesigned(_obj.base + 0x0A) -- sprites are facing left by default
  _obj.previous_pos_x = _obj.pos_x or 0
  _obj.previous_pos_y = _obj.pos_y or 0
  _obj.pos_x = memory.readwordsigned(_obj.base + 0x64)
  _obj.pos_y = memory.readwordsigned(_obj.base + 0x68)
  _obj.char_id = memory.readword(_obj.base + 0x3C0)

  _obj.boxes = {}
  local _boxes = {
    {initial = 1, offset = 0x2D4, type = "push", number = 1},
    {initial = 1, offset = 0x2C0, type = "throwable", number = 1},
    {initial = 1, offset = 0x2A0, type = "vulnerability", number = 4},
    {initial = 1, offset = 0x2A8, type = "ext. vulnerability", number = 4},
    {initial = 1, offset = 0x2C8, type = "attack", number = 4},
    {initial = 1, offset = 0x2B8, type = "throw", number = 1}
  }

  for _, _box in ipairs(_boxes) do
    for i = _box.initial, _box.number do
      gamestate.read_box(_obj, memory.readdword(_obj.base + _box.offset) + (i-1)*8, _box.type)
    end
  end
  return true
end

function gamestate.read_box(_obj, _ptr, _type)
  if _obj.friends > 1 then --Yang SA3
    if _type ~= "attack" then
      return
    end
  end

  local _box = {
    left   = memory.readwordsigned(_ptr + 0x0),
    width  = memory.readwordsigned(_ptr + 0x2),
    bottom = memory.readwordsigned(_ptr + 0x4),
    height = memory.readwordsigned(_ptr + 0x6),
    type   = _type,
  }

  if _box.left == 0 and _box.width == 0 and _box.height == 0 and _box.bottom == 0 then
    return
  end

  table.insert(_obj.boxes, _box)
end
