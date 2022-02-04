-- ## read
function gamestate.read()
  -- game
  gamestate.read_game_vars()

  -- players
  gamestate.read_player_vars(gamestate.player_objects[1])
  gamestate.read_player_vars(gamestate.player_objects[2])

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

function gamestate.read_player_vars(_player_obj)
  if gamestate.is_object_invalid(_player_obj) then --invalid objects
    return false
  end

  local _debug_state_variables = _player_obj.debug_state_variables

  read_input(_player_obj)

  local _prev_pos_x = _player_obj.pos_x or 0
  local _prev_pos_y = _player_obj.pos_y or 0

  gamestate.read_game_object(_player_obj)

  local _previous_movement_type = _player_obj.movement_type or 0

  _player_obj.char_str = rom.characters[_player_obj.char_id + 1]

  local _previous_remaining_freeze_frames = _player_obj.remaining_freeze_frames or 0
  _player_obj.remaining_freeze_frames = memory.readbyte(_player_obj.base + 0x45)
  _player_obj.freeze_type = 0
  if _player_obj.remaining_freeze_frames ~= 0 then
    if _player_obj.remaining_freeze_frames < 127 then
      -- inflicted freeze I guess (when the opponent parry you for instance)
      _player_obj.freeze_type = 1
      _player_obj.remaining_freeze_frames = _player_obj.remaining_freeze_frames
    else
      _player_obj.freeze_type = 2
      _player_obj.remaining_freeze_frames = 256 - _player_obj.remaining_freeze_frames
    end
  end
  local _remaining_freeze_frame_diff = _player_obj.remaining_freeze_frames - _previous_remaining_freeze_frames
  if _remaining_freeze_frame_diff > 0 then
    log(_player_obj.prefix, "fight", string.format("freeze %d", _player_obj.remaining_freeze_frames))
    --print(string.format("%d: %d(%d)",  _player_obj.id, _player_obj.remaining_freeze_frames, _player_obj.freeze_type))
  end

  local _previous_action = _player_obj.action or 0x00
  local _previous_movement_type2 = _player_obj.movement_type2 or 0x00
  local _previous_posture = _player_obj.posture or 0x00

  _player_obj.previous_input_capacity = _player_obj.input_capacity or 0
  _player_obj.input_capacity = memory.readword(_player_obj.base + 0x46C)
  _player_obj.action = memory.readdword(_player_obj.base + 0xAC)
  _player_obj.action_ext = memory.readdword(_player_obj.base + 0x12C)
  _player_obj.previous_recovery_time = _player_obj.recovery_time or 0
  _player_obj.recovery_time = memory.readbyte(_player_obj.base + 0x187)
  _player_obj.movement_type = memory.readbyte(_player_obj.base + 0x0AD)
  _player_obj.movement_type2 = memory.readbyte(_player_obj.base + 0x0AF) -- seems that we can know which basic movement the player is doing from there
  _player_obj.total_received_projectiles_count = memory.readword(_player_obj.base + 0x430) -- on block or hit

-- postures
--  0x00 -- standing neutral
--  0x08 -- going backwards
--  0x06 -- going forward
--  0x20 -- crouching
--  0x16 -- neutral jump
--  0x14 -- flying forward
--  0x18 -- flying backwards
--  0x1A -- high jump
--  0x26 -- knocked down
  _player_obj.posture = memory.readbyte(_player_obj.base + 0x20E)

  _player_obj.busy_flag = memory.readword(_player_obj.base + 0x3D1)

  local _previous_is_in_basic_action = _player_obj.is_in_basic_action or false
  _player_obj.is_in_basic_action = _player_obj.action < 0xFF and _previous_action < 0xFF -- this triggers one frame early than it should, so we delay it artificially
  _player_obj.has_just_entered_basic_action = not _previous_is_in_basic_action and _player_obj.is_in_basic_action

  local _previous_recovery_flag = _player_obj.recovery_flag or 1
  _player_obj.recovery_flag = memory.readbyte(_player_obj.base + 0x3B)
  _player_obj.has_just_ended_recovery = _previous_recovery_flag ~= 0 and _player_obj.recovery_flag == 0

  _player_obj.meter_gauge = memory.readbyte(_player_obj.addresses.gauge_addr)
  _player_obj.meter_count = memory.readbyte(_player_obj.addresses.meter_addr[2])
  if _player_obj.id == 1 then
    _player_obj.max_meter_gauge = memory.readbyte(0x020695B3)
    _player_obj.max_meter_count = memory.readbyte(0x020695BD)
    _player_obj.selected_sa = memory.readbyte(0x0201138B) + 1
    _player_obj.superfreeze_decount = memory.readbyte(0x02069520) -- seems to be in P2 memory space, don't know why
  else
    _player_obj.max_meter_gauge = memory.readbyte(0x020695DF)
    _player_obj.max_meter_count = memory.readbyte(0x020695E9)
    _player_obj.selected_sa = memory.readbyte(0x0201138C) + 1
    _player_obj.superfreeze_decount = memory.readbyte(0x02069088) -- seems to be in P1 memory space, don't know why
  end

  -- CROUCHED
  _player_obj.is_crouched = _player_obj.posture == 0x20

  -- LIFE
  _player_obj.life = memory.readbyte(_player_obj.base + 0x9F)

  -- BONUSES
  _player_obj.damage_bonus = memory.readword(_player_obj.base + 0x43A)
  _player_obj.stun_bonus = memory.readword(_player_obj.base + 0x43E)
  _player_obj.defense_bonus = memory.readword(_player_obj.base + 0x440)

  -- THROW
  local _previous_is_throwing = _player_obj.is_throwing or false
  _player_obj.is_throwing = bit.rshift(_player_obj.movement_type2, 4) == 9
  _player_obj.has_just_thrown = not _previous_is_throwing and _player_obj.is_throwing

  _player_obj.is_being_thrown = memory.readbyte(_player_obj.base + 0x3CF) ~= 0
  _player_obj.throw_countdown = _player_obj.throw_countdown or 0
  _player_obj.previous_throw_countdown = _player_obj.throw_countdown

  local _throw_countdown = memory.readbyte(_player_obj.base + 0x434)
  if _throw_countdown > _player_obj.previous_throw_countdown then
    _player_obj.throw_countdown = _throw_countdown + 2 -- air throw animations seems to not match the countdown (ie. Ibuki's Air Throw), let's add a few frames to it
  else
    _player_obj.throw_countdown = math.max(_player_obj.throw_countdown - 1, 0)
  end

  if _player_obj.debug_freeze_frames and _player_obj.remaining_freeze_frames > 0 then print(string.format("%d - %d remaining freeze frames", gamestate.frame_number, _player_obj.remaining_freeze_frames)) end

  update_object_velocity(_player_obj)

  -- ATTACKING
  local _previous_is_attacking = _player_obj.is_attacking or false
  _player_obj.is_attacking_byte = memory.readbyte(_player_obj.base + 0x428)
  _player_obj.is_attacking = _player_obj.is_attacking_byte > 0
  _player_obj.is_attacking_ext_byte = memory.readbyte(_player_obj.base + 0x429)
  _player_obj.is_attacking_ext = _player_obj.is_attacking_ext_byte > 0
  _player_obj.has_just_attacked =  _player_obj.is_attacking and not _previous_is_attacking
  if _debug_state_variables and _player_obj.has_just_attacked then print(string.format("%d - %s attacked", gamestate.frame_number, _player_obj.prefix)) end

  -- ACTION
  local _previous_action_count = _player_obj.action_count or 0
  _player_obj.action_count = memory.readbyte(_player_obj.base + 0x459)
  _player_obj.has_just_acted = _player_obj.action_count > _previous_action_count
  if _debug_state_variables and _player_obj.has_just_acted then print(string.format("%d - %s acted (%d > %d)", gamestate.frame_number, _player_obj.prefix, _previous_action_count, _player_obj.action_count)) end

  -- ANIMATION
  local _self_cancel = false
  local _previous_animation = _player_obj.animation or ""
  _player_obj.animation = bit.tohex(memory.readword(_player_obj.base + 0x202), 4)
  _player_obj.has_animation_just_changed = _previous_animation ~= _player_obj.animation
  if not _player_obj.has_animation_just_changed then
    if (frame_data[_player_obj.char_str] and frame_data[_player_obj.char_str][_player_obj.animation]) then
      local _all_hits_done = true
      local _frame = gamestate.frame_number - _player_obj.current_animation_start_frame - _player_obj.current_animation_freeze_frames
      for __, _hit_frame in ipairs(frame_data[_player_obj.char_str][_player_obj.animation].hit_frames) do
        local _last_hit_frame = 0
        if type(_hit_frame) == "number" then
          _last_hit_frame = _hit_frame
        else
          _last_hit_frame = _hit_frame.max
        end

        if _frame <= _last_hit_frame then
          _all_hits_done = false
          break
        end
      end
      if _player_obj.has_just_attacked and _all_hits_done then
        _player_obj.has_animation_just_changed = true
        _self_cancel = true
        log(_player_obj.prefix, "blocking", string.format("self cancel"))
      end
    end
  end

  if _player_obj.has_animation_just_changed then
    _player_obj.current_animation_start_frame = gamestate.frame_number
    _player_obj.current_animation_freeze_frames = 0
  end
  if _debug_state_variables and _player_obj.has_animation_just_changed then print(string.format("%d - %s animation changed (%s -> %s)", gamestate.frame_number, _player_obj.prefix, _previous_animation, _player_obj.animation)) end

  -- special case for animations that introduce animations that hit at frame 0 (Alex's VChargeK for instance)
  -- Note: It's unlikely that intro animation will ever have freeze frames, so I don't think we need to handle that
  local _previous_relevant_animation = _player_obj.relevant_animation or ""
  if _player_obj.has_animation_just_changed then
    _player_obj.relevant_animation = _player_obj.animation
    _player_obj.relevant_animation_start_frame = _player_obj.current_animation_start_frame
    if frame_data_meta[_player_obj.char_str] and frame_data_meta[_player_obj.char_str].moves[_player_obj.animation] and frame_data_meta[_player_obj.char_str].moves[_player_obj.animation].proxy then
      _player_obj.relevant_animation = frame_data_meta[_player_obj.char_str].moves[_player_obj.animation].proxy.id
      _player_obj.relevant_animation_start_frame = _player_obj.current_animation_start_frame -
       frame_data_meta[_player_obj.char_str].moves[_player_obj.animation].proxy.offset
    end
  end
  _player_obj.has_relevant_animation_just_changed = _self_cancel or _player_obj.relevant_animation ~= _previous_relevant_animation

  if _player_obj.has_relevant_animation_just_changed then
    _player_obj.relevant_animation_freeze_frames = 0
  end
  if _player_obj.has_relevant_animation_just_changed then
    if _debug_state_variables then print(string.format("%d - %s relevant animation changed (%s -> %s)", gamestate.frame_number, _player_obj.prefix, _previous_relevant_animation, _player_obj.relevant_animation)) end
    log(_player_obj.prefix, "animation", string.format("rel anim %s->%s", _previous_relevant_animation, _player_obj.relevant_animation))
  end


  if _player_obj.remaining_freeze_frames > 0 then
    _player_obj.current_animation_freeze_frames = _player_obj.current_animation_freeze_frames + 1
    _player_obj.relevant_animation_freeze_frames = _player_obj.relevant_animation_freeze_frames + 1
  end

  _player_obj.animation_frame_id = memory.readword(_player_obj.base + 0x21A)
  local _frame_id2 = memory.readbyte(_player_obj.base + 0x214)
  local _frame_id3 = 0--memory.readbyte(_player_obj.base + 0x205)
  local _complex_id = ""
  for _i = 0, 0x4 do
    _complex_id = _complex_id..string.format("%08X",memory.readdword(_player_obj.base + 0x214 + _i * 0x04))
  end
  _player_obj.animation_frame_hash = string_hash(_complex_id)
  _player_obj.animation_frame = gamestate.frame_number - _player_obj.current_animation_start_frame - _player_obj.current_animation_freeze_frames
  _player_obj.relevant_animation_frame = gamestate.frame_number - _player_obj.relevant_animation_start_frame - _player_obj.relevant_animation_freeze_frames

  _player_obj.relevant_animation_frame_data = nil
  if frame_data[_player_obj.char_str] then
    _player_obj.relevant_animation_frame_data = frame_data[_player_obj.char_str][_player_obj.relevant_animation]
  end

  _player_obj.highest_hit_id = 0
  _player_obj.next_hit_id = 0
  if _player_obj.relevant_animation_frame_data ~= nil then

    -- Resync animation
    -- NOTE: frame_id2 has been added at some point and might not present on all frame data
    local _relevant_frame_data = _player_obj.relevant_animation_frame_data.frames[_player_obj.relevant_animation_frame + 1]

    if _player_obj.relevant_animation_frame >= 0
    and _player_obj.remaining_freeze_frames == 0
    and _relevant_frame_data ~= nil
    and _relevant_frame_data.frame_id ~= nil
    and (
      (_relevant_frame_data.hash == nil and _relevant_frame_data.frame_id ~= _player_obj.animation_frame_id)
      or (_relevant_frame_data.hash ~= nil and (_relevant_frame_data.hash ~= _player_obj.animation_frame_hash))
    )
    then
      local _frame_count =  #_player_obj.relevant_animation_frame_data.frames
      local _resync_range_begin = -1
      local _resync_range_end = -1
      local _resync_target = -1

      for _i = 1, _frame_count do
        local _frame_index = _i
        local _frame = _player_obj.relevant_animation_frame_data.frames[_frame_index]
        if (_frame.hash == nil and _frame.frame_id == _player_obj.animation_frame_id) or (_frame.hash ~= nil and _frame.hash == _player_obj.animation_frame_hash) then
          if _resync_range_begin == -1 then
            _resync_range_begin = _frame_index
          end
          _resync_range_end = _frame_index
        end
      end

      -- if behind, always go th the range begin, else go at end unless it has been wrapping
      if _resync_range_begin >= 0 then
        if _player_obj.relevant_animation_frame < _resync_range_begin then
          _resync_target = _resync_range_begin
        else
          local _delta = math.abs(_player_obj.relevant_animation_frame - _resync_range_end)
          if _delta > _frame_count * 0.5 then
            _resync_target = _resync_range_begin
          else
            _resync_target = _resync_range_end
          end
        end
      end

      if _resync_target >= 0 then
        log(_player_obj.prefix, "animation", string.format("resynced %s (%d->%d)(%d.%d->%d.%d)", _player_obj.relevant_animation, _player_obj.relevant_animation_frame, (_resync_target - 1), _player_obj.animation_frame_id, _player_obj.animation_frame_hash, _player_obj.relevant_animation_frame_data.frames[_resync_target].frame_id, _player_obj.relevant_animation_frame_data.frames[_resync_target].hash or -1))
        if _player_obj.debug_animation_frames then
          print(string.format("%d: resynced anim %s from frame %d to %d (%d -> %d)", gamestate.frame_number, _player_obj.relevant_animation, _player_obj.relevant_animation_frame_data.frames[_player_obj.relevant_animation_frame + 1].frame_id, _frame.frame_id, _player_obj.relevant_animation_frame, (_resync_target - 1)))
        end

        _player_obj.relevant_animation_frame = (_resync_target - 1)
        _player_obj.relevant_animation_start_frame = gamestate.frame_number - (_resync_target - 1 + _player_obj.relevant_animation_freeze_frames)
      end
    end

    -- find current attack id
    for _index, _hit_frame in ipairs(_player_obj.relevant_animation_frame_data.hit_frames) do
      if type(_hit_frame) == "number" then

        if _player_obj.relevant_animation_frame >= _hit_frame then
          _player_obj.highest_hit_id = _index
        end
      else
        if _player_obj.relevant_animation_frame >= _hit_frame.min then
          _player_obj.highest_hit_id = _index
        end
      end
    end

    for _index = #_player_obj.relevant_animation_frame_data.hit_frames, 1, -1 do
      local _hit_frame = _player_obj.relevant_animation_frame_data.hit_frames[_index]
      if type(_hit_frame) == "number" then
        if _player_obj.relevant_animation_frame <= _hit_frame then
          _player_obj.next_hit_id = _index
        end
      else
        if _player_obj.relevant_animation_frame <= _hit_frame.max then
          _player_obj.next_hit_id = _index
        end
      end
    end

    if _player_obj.debug_animation_frames then
      print(string.format("%d - %d, %d, %d, %d", gamestate.frame_number, _player_obj.relevant_animation_frame, _player_obj.remaining_freeze_frames, _player_obj.animation_frame_id, _player_obj.highest_hit_id))
    end
  end
  if _player_obj.has_just_acted then
    _player_obj.last_act_animation = _player_obj.animation
  end

  -- RECEIVED HITS/BLOCKS/PARRYS
  local _previous_total_received_hit_count = _player_obj.total_received_hit_count or nil
  _player_obj.total_received_hit_count = memory.readword(_player_obj.base + 0x33E)
  local _total_received_hit_count_diff = 0
  if _previous_total_received_hit_count then
    if _previous_total_received_hit_count == 0xFFFF then
      _total_received_hit_count_diff = 1
    else
      _total_received_hit_count_diff = _player_obj.total_received_hit_count - _previous_total_received_hit_count
    end
  end

  local _previous_received_connection_marker = _player_obj.received_connection_marker or 0
  _player_obj.received_connection_marker = memory.readword(_player_obj.base + 0x32E)
  _player_obj.received_connection = _previous_received_connection_marker == 0 and _player_obj.received_connection_marker ~= 0

  _player_obj.last_movement_type_change_frame = _player_obj.last_movement_type_change_frame or 0
  if _player_obj.movement_type ~= _previous_movement_type then
    _player_obj.last_movement_type_change_frame = gamestate.frame_number
  end

  -- is blocking/has just blocked/has just been hit/has_just_parried
  _player_obj.blocking_id = memory.readbyte(_player_obj.base + 0x3D3)
  _player_obj.has_just_blocked = false
  if _player_obj.received_connection and _player_obj.received_connection_marker ~= 0xFFF1 and _total_received_hit_count_diff == 0 then --0xFFF1 is parry
    _player_obj.has_just_blocked = true
    log(_player_obj.prefix, "fight", "block")
    if _debug_state_variables then
      print(string.format("%d - %s blocked", gamestate.frame_number, _player_obj.prefix))
    end
  end
  _player_obj.is_blocking = _player_obj.blocking_id > 0 and _player_obj.blocking_id < 5 or _player_obj.has_just_blocked

  _player_obj.has_just_been_hit = false
  if _total_received_hit_count_diff > 0 then
    _player_obj.has_just_been_hit = true
    log(_player_obj.prefix, "fight", "hit")
  end

  _player_obj.has_just_parried = false
  if _player_obj.received_connection and _player_obj.received_connection_marker == 0xFFF1 and _total_received_hit_count_diff == 0 then
    _player_obj.has_just_parried = true
    log(_player_obj.prefix, "fight", "parry")
    if _debug_state_variables then print(string.format("%d - %s parried", gamestate.frame_number, _player_obj.prefix)) end
  end

  -- HITS
  local _previous_hit_count = _player_obj.hit_count or 0
  _player_obj.hit_count = memory.readbyte(_player_obj.base + 0x189)
  _player_obj.has_just_hit = _player_obj.hit_count > _previous_hit_count
  if _player_obj.has_just_hit then
    log(_player_obj.prefix, "fight", "has hit")
    if _debug_state_variables then
      print(string.format("%d - %s hit (%d > %d)", gamestate.frame_number, _player_obj.prefix, _previous_hit_count, _player_obj.hit_count))
    end
  end

  -- BLOCKS
  local _previous_connected_action_count = _player_obj.connected_action_count or 0
  local _previous_blocked_count = _previous_connected_action_count - _previous_hit_count
  _player_obj.connected_action_count = memory.readbyte(_player_obj.base + 0x17B)
  local _blocked_count = _player_obj.connected_action_count - _player_obj.hit_count
  _player_obj.has_just_been_blocked = _blocked_count > _previous_blocked_count
  if _debug_state_variables and _player_obj.has_just_been_blocked then print(string.format("%d - %s blocked (%d > %d)", gamestate.frame_number, _player_obj.prefix, _previous_blocked_count, _blocked_count)) end

  -- LANDING
  local _previous_is_in_jump_startup = _player_obj.is_in_jump_startup or false
  _player_obj.is_in_jump_startup = _player_obj.movement_type2 == 0x0C and _player_obj.movement_type == 0x00 and not _player_obj.is_blocking
  _player_obj.previous_standing_state = _player_obj.standing_state or 0
  _player_obj.standing_state = memory.readbyte(_player_obj.base + 0x297)
  _player_obj.has_just_landed = is_state_on_ground(_player_obj.standing_state, _player_obj) and not is_state_on_ground(_player_obj.previous_standing_state, _player_obj)
  if _debug_state_variables and _player_obj.has_just_landed then print(string.format("%d - %s landed (%d > %d)", gamestate.frame_number, _player_obj.prefix, _player_obj.previous_standing_state, _player_obj.standing_state)) end
  if _player_obj.debug_standing_state and _player_obj.previous_standing_state ~= _player_obj.standing_state then print(string.format("%d - %s standing state changed (%d > %d)", gamestate.frame_number, _player_obj.prefix, _player_obj.previous_standing_state, _player_obj.standing_state)) end

  -- AIR RECOVERY STATE
  local _debug_air_recovery = false
  local _previous_is_in_air_recovery = _player_obj.is_in_air_recovery or false
  local _r1 = memory.readbyte(_player_obj.base + 0x12F)
  local _r2 = memory.readbyte(_player_obj.base + 0x3C7)
  _player_obj.is_in_air_recovery = _player_obj.standing_state == 0 and _r1 == 0 and _r2 == 0x06 and _player_obj.pos_y ~= 0
  _player_obj.has_just_entered_air_recovery = not _previous_is_in_air_recovery and _player_obj.is_in_air_recovery

  if not _previous_is_in_air_recovery and _player_obj.is_in_air_recovery then
    log(_player_obj.prefix, "fight", string.format("air recovery 1"))
    if _debug_air_recovery then
      print(string.format("%s entered air recovery", _player_obj.prefix))
    end
  end
  if _previous_is_in_air_recovery and not _player_obj.is_in_air_recovery then
    log(_player_obj.prefix, "fight", string.format("air recovery 0"))
    if _debug_air_recovery then
      print(string.format("%s exited air recovery", _player_obj.prefix))
    end
  end



  -- IS IDLE
  local _previous_is_idle = _player_obj.is_idle or false
  _player_obj.idle_time = _player_obj.idle_time or 0
  _player_obj.is_idle = (
    not _player_obj.is_attacking and
    not _player_obj.is_attacking_ext and
    not _player_obj.is_blocking and
    not _player_obj.is_wakingup and
    not _player_obj.is_fast_wakingup and
    not _player_obj.is_being_thrown and
    not _player_obj.is_in_jump_startup and
    bit.band(_player_obj.busy_flag, 0xFF) == 0 and
    _player_obj.recovery_time == _player_obj.previous_recovery_time and
    _player_obj.remaining_freeze_frames == 0 and
    _player_obj.input_capacity > 0
  )

  --[[
  if _player_obj.id == 1 then
    print(string.format(
      "%d: %d, %d, %d, %d, %d, %d, %d, %04x, %d, %d, %04x",
      to_bit(_player_obj.is_idle),
      to_bit(_player_obj.is_attacking),
      to_bit(_player_obj.is_attacking_ext),
      to_bit(_player_obj.is_blocking),
      to_bit(_player_obj.is_wakingup),
      to_bit(_player_obj.is_fast_wakingup),
      to_bit(_player_obj.is_being_thrown),
      to_bit(_player_obj.is_in_jump_startup),
      _player_obj.busy_flag,
      _player_obj.recovery_time,
      _player_obj.remaining_freeze_frames,
      _player_obj.input_capacity
    ))
  end
  ]]

  if _player_obj.is_idle then
    _player_obj.idle_time = _player_obj.idle_time + 1
  else
    _player_obj.idle_time = 0
  end

  if _previous_is_idle ~= _player_obj.is_idle then
    log(_player_obj.prefix, "fight", string.format("idle %d", to_bit(_player_obj.is_idle)))
  end


  if gamestate.is_in_match then

    -- WAKE UP
    _player_obj.previous_can_fast_wakeup = _player_obj.can_fast_wakeup or 0
    _player_obj.can_fast_wakeup = memory.readbyte(_player_obj.base + 0x402)

    local _previous_fast_wakeup_flag = _player_obj.fast_wakeup_flag or 0
    _player_obj.fast_wakeup_flag = memory.readbyte(_player_obj.base + 0x403)

    local _previous_is_flying_down_flag = _player_obj.is_flying_down_flag or 0
    _player_obj.is_flying_down_flag = memory.readbyte(_player_obj.base + 0x8D) -- does not reset to 0 after air reset landings, resets to 0 after jump start

    _player_obj.previous_is_wakingup = _player_obj.is_wakingup or false
    _player_obj.is_wakingup = _player_obj.is_wakingup or false
    _player_obj.wakeup_time = _player_obj.wakeup_time or 0
    if _previous_is_flying_down_flag == 1 and _player_obj.is_flying_down_flag == 0 and _player_obj.standing_state == 0 and
      (
        _player_obj.movement_type ~= 2 -- movement type 2 is hugo's running grab
        and _player_obj.movement_type ~= 5 -- movement type 5 is ryu's reversal DP on landing
      ) then
      _player_obj.is_wakingup = true
      _player_obj.is_past_wakeup_frame = false
      _player_obj.wakeup_time = 0
      _player_obj.wakeup_animation = _player_obj.animation
      if debug_wakeup then
        print(string.format("%d - %s wakeup started", gamestate.frame_number, _player_obj.prefix))
      end
    end

    _player_obj.previous_is_fast_wakingup = _player_obj.is_fast_wakingup or false
    _player_obj.is_fast_wakingup = _player_obj.is_fast_wakingup or false
    if _player_obj.is_wakingup and _previous_fast_wakeup_flag == 1 and _player_obj.fast_wakeup_flag == 0 then
      _player_obj.is_fast_wakingup = true
      _player_obj.is_past_wakeup_frame = true
      _player_obj.wakeup_time = 0
      _player_obj.wakeup_animation = _player_obj.animation
      if debug_wakeup then
        print(string.format("%d - %s fast wakeup started", gamestate.frame_number, _player_obj.prefix))
      end
    end

    if _player_obj.previous_can_fast_wakeup ~= 0 and _player_obj.can_fast_wakeup == 0 then
      _player_obj.is_past_wakeup_frame = true
    end

    if _player_obj.is_wakingup then
      _player_obj.wakeup_time = _player_obj.wakeup_time + 1
    end

    if _player_obj.is_wakingup and _previous_posture == 0x26 and _player_obj.posture ~= 0x26 then
      if debug_wakeup then
        print(string.format("%d - %s wake up: %d, %s, %d", gamestate.frame_number, _player_obj.prefix, to_bit(_player_obj.is_fast_wakingup), _player_obj.wakeup_animation, _player_obj.wakeup_time))
      end
      _player_obj.is_wakingup = false
      _player_obj.is_fast_wakingup = false
      _player_obj.is_past_wakeup_frame = false
    end

    _player_obj.has_just_started_wake_up = not _player_obj.previous_is_wakingup and _player_obj.is_wakingup
    _player_obj.has_just_started_fast_wake_up = not _player_obj.previous_is_fast_wakingup and _player_obj.is_fast_wakingup
    _player_obj.has_just_woke_up = _player_obj.previous_is_wakingup and not _player_obj.is_wakingup

    if _player_obj.has_just_started_wake_up then
      log(_player_obj.prefix, "fight", string.format("wakeup 1"))
    end
    if _player_obj.has_just_started_fast_wake_up then
      log(_player_obj.prefix, "fight", string.format("fwakeup 1"))
    end
    if _player_obj.has_just_woke_up then
      log(_player_obj.prefix, "fight", string.format("wakeup 0"))
    end
  end

  if not _previous_is_in_jump_startup and _player_obj.is_in_jump_startup then
    _player_obj.last_jump_startup_duration = 0
    _player_obj.last_jump_startup_frame = gamestate.frame_number
  end

  if _player_obj.is_in_jump_startup then
    _player_obj.last_jump_startup_duration = _player_obj.last_jump_startup_duration + 1
  end

  -- TIMED SA
  if character_specific[_player_obj.char_str].timed_sa[_player_obj.selected_sa] then
    if _player_obj.superfreeze_decount > 0 then
      _player_obj.is_in_timed_sa = true
    elseif _player_obj.is_in_timed_sa and memory.readbyte(_player_obj.addresses.gauge_addr) == 0 then
      _player_obj.is_in_timed_sa = false
    end
  else
    _player_obj.is_in_timed_sa = false
  end

  -- PARRY BUFFERS
  -- global game consts
  _player_obj.parry_forward = _player_obj.parry_forward or { name = "FORWARD", max_validity = 10, max_cooldown = 23 }
  _player_obj.parry_down = _player_obj.parry_down or { name = "DOWN", max_validity = 10, max_cooldown = 23 }
  _player_obj.parry_air = _player_obj.parry_air or { name = "AIR", max_validity = 7, max_cooldown = 20 }
  _player_obj.parry_antiair = _player_obj.parry_antiair or { name = "ANTI-AIR", max_validity = 5, max_cooldown = 18 }

  function read_parry_state(_parry_object, _validity_addr, _cooldown_addr)
    -- read data
    _parry_object.last_hit_or_block_frame =  _parry_object.last_hit_or_block_frame or 0
    if _player_obj.has_just_blocked or _player_obj.has_just_been_hit then
      _parry_object.last_hit_or_block_frame = gamestate.frame_number
    end
    _parry_object.last_validity_start_frame = _parry_object.last_validity_start_frame or 0
    local _previous_validity_time = _parry_object.validity_time or 0
    _parry_object.validity_time = memory.readbyte(_validity_addr)
    _parry_object.cooldown_time = memory.readbyte(_cooldown_addr)
    if _parry_object.cooldown_time == 0xFF then _parry_object.cooldown_time = 0 end
    if _previous_validity_time == 0 and _parry_object.validity_time ~= 0 then
      _parry_object.last_validity_start_frame = gamestate.frame_number
      _parry_object.delta = nil
      _parry_object.success = nil
      _parry_object.armed = true
      log(_player_obj.prefix, "parry_training_".._parry_object.name, "armed")
    end

    -- check success/miss
    if _parry_object.armed then
      if _player_obj.has_just_parried then
        -- right
        _parry_object.delta = gamestate.frame_number - _parry_object.last_validity_start_frame
        _parry_object.success = true
        _parry_object.armed = false
        _parry_object.last_hit_or_block_frame = 0
        log(_player_obj.prefix, "parry_training_".._parry_object.name, "success")
      elseif _parry_object.last_validity_start_frame == gamestate.frame_number - 1 and (gamestate.frame_number - _parry_object.last_hit_or_block_frame) < 20 then
        local _delta = _parry_object.last_hit_or_block_frame - gamestate.frame_number + 1
        if _parry_object.delta == nil or math.abs(_parry_object.delta) > math.abs(_delta) then
          _parry_object.delta = _delta
          _parry_object.success = false
        end
        log(_player_obj.prefix, "parry_training_".._parry_object.name, "late")
      elseif _player_obj.has_just_blocked or _player_obj.has_just_been_hit then
        local _delta = gamestate.frame_number - _parry_object.last_validity_start_frame
        if _parry_object.delta == nil or math.abs(_parry_object.delta) > math.abs(_delta) then
          _parry_object.delta = _delta
          _parry_object.success = false
        end
        log(_player_obj.prefix, "parry_training_".._parry_object.name, "early")
      end
    end
    if gamestate.frame_number - _parry_object.last_validity_start_frame > 30 and _parry_object.armed then

      _parry_object.armed = false
      _parry_object.last_hit_or_block_frame = 0
      log(_player_obj.prefix, "parry_training_".._parry_object.name, "reset")
    end
  end

  read_parry_state(_player_obj.parry_forward, _player_obj.addresses.parry_forward_validity_time_addr, _player_obj.addresses.parry_forward_cooldown_time_addr)
  read_parry_state(_player_obj.parry_down, _player_obj.addresses.parry_down_validity_time_addr, _player_obj.addresses.parry_down_cooldown_time_addr)
  read_parry_state(_player_obj.parry_air, _player_obj.addresses.parry_air_validity_time_addr, _player_obj.addresses.parry_air_cooldown_time_addr)
  read_parry_state(_player_obj.parry_antiair, _player_obj.addresses.parry_antiair_validity_time_addr, _player_obj.addresses.parry_antiair_cooldown_time_addr)

-- CHARGE STATE
  -- global game consts
  _player_obj.charge_1 = _player_obj.charge_1 or { name = "Charge1", max_charge = 43, max_reset = 43, enabled = false }
  _player_obj.charge_2 = _player_obj.charge_2 or { name = "Charge2", max_charge = 43, max_reset = 43, enabled = false }
  _player_obj.charge_3 = _player_obj.charge_3 or { name = "Charge3", max_charge = 43, max_reset = 43, enabled = false }


  function read_charge_state(_charge_object, _valid_charge, _charge_addr, _reset_addr)
    if _valid_charge == false then
      _charge_object.charge_time = 0
      _charge_object.reset_time = 0
      _charge_object.enabled = false
      return
    end
    _charge_object.overcharge = _charge_object.overcharge or 0
    _charge_object.last_overcharge = _charge_object.last_overcharge or 0
    _charge_object.overcharge_start = _charge_object.overcharge_start or 0
    _charge_object.enabled = true
    local _previous_charge_time = _charge_object.charge_time or 0
    local _previous_reset_time = _charge_object.reset_time or 0
    _charge_object.charge_time = memory.readbyte(_charge_addr)
    _charge_object.reset_time = memory.readbyte(_reset_addr)
    if _charge_object.charge_time == 0xFF then _charge_object.charge_time = 0 else _charge_object.charge_time = _charge_object.charge_time + 1 end
    if _charge_object.reset_time == 0xFF then _charge_object.reset_time = 0 else _charge_object.reset_time = _charge_object.reset_time + 1 end
    if _charge_object.charge_time == 0 then
      if _charge_object.overcharge_start == 0 then
        _charge_object.overcharge_start = gamestate.frame_number
      else
        _charge_object.overcharge = gamestate.frame_number - _charge_object.overcharge_start
      end
    end
    if _charge_object.charge_time == _charge_object.max_charge then
      if _charge_object.overcharge ~= 0 then _charge_object.last_overcharge = _charge_object.overcharge end
        _charge_object.overcharge = 0
        _charge_object.overcharge_start = 0
    end -- reset overcharge
  end

  charge_table = {
    ["alex"] = { _charge_1_addr = _player_obj.addresses.charge_1_addr, _reset_1_addr = _player_obj.addresses.charge_1_reset_addr, _name1 = "Elbow", _valid_1 = true,
      _charge_2_addr = _player_obj.addresses.charge_2_addr, _reset_2_addr = _player_obj.addresses.charge_2_reset_addr, _name2= "Stomp", _valid_2 = true,
      _charge_3_addr = _player_obj.addresses.charge_3_addr, _reset_3_addr = _player_obj.addresses.charge_3_reset_addr, _valid_3 = false},
    ["oro"] = { _charge_1_addr = _player_obj.addresses.charge_3_addr, _reset_1_addr = _player_obj.addresses.charge_3_reset_addr, _name1= "Sun Disk", _valid_1 = true,
      _charge_2_addr = _player_obj.addresses.charge_5_addr, _reset_2_addr = _player_obj.addresses.charge_5_reset_addr, _name2= "Yanma", _valid_2 = true,
      _charge_3_addr = _player_obj.addresses.charge_3_addr, _reset_3_addr = _player_obj.addresses.charge_3_reset_addr, _valid_3 = false},
    ["urien"] = { _charge_1_addr = _player_obj.addresses.charge_5_addr, _reset_1_addr = _player_obj.addresses.charge_5_reset_addr, _name1= "Tackle", _valid_1 = true,
      _charge_2_addr = _player_obj.addresses.charge_2_addr, _reset_2_addr = _player_obj.addresses.charge_2_reset_addr, _name2= "Kneedrop", _valid_2 = true,
      _charge_3_addr = _player_obj.addresses.charge_4_addr, _reset_3_addr = _player_obj.addresses.charge_4_reset_addr, _name3= "Headbutt", _valid_3 = true},
    ["remy"] = { _charge_1_addr = _player_obj.addresses.charge_4_addr, _reset_1_addr = _player_obj.addresses.charge_4_reset_addr, _name1= "LoV High", _valid_1 = true,
      _charge_2_addr = _player_obj.addresses.charge_3_addr, _reset_2_addr = _player_obj.addresses.charge_3_reset_addr, _name2= "LoV Low", _valid_2 = true,
      _charge_3_addr = _player_obj.addresses.charge_5_addr, _reset_3_addr = _player_obj.addresses.charge_5_reset_addr, _name3= "Rising", _valid_3 = true},
    ["q"] = { _charge_1_addr = _player_obj.addresses.charge_5_addr, _reset_1_addr = _player_obj.addresses.charge_5_reset_addr, _name1= "Dash Atk", _valid_1 = true,
      _charge_2_addr = _player_obj.addresses.charge_4_addr, _reset_2_addr = _player_obj.addresses.charge_4_reset_addr, _name2= "Dash Low", _valid_2 = true,
      _charge_3_addr = _player_obj.addresses.charge_3_addr, _reset_3_addr = _player_obj.addresses.charge_3_reset_addr, _valid_3 = false},
    ["chunli"] = { _charge_1_addr = _player_obj.addresses.charge_5_addr, _reset_1_addr = _player_obj.addresses.charge_5_reset_addr, _name1= "Bird Kick", _valid_1 = true,
      _charge_2_addr = _player_obj.addresses.charge_2_addr, _reset_2_addr = _player_obj.addresses.charge_2_reset_addr, _valid_2 = false,
      _charge_3_addr = _player_obj.addresses.charge_3_addr, _reset_3_addr = _player_obj.addresses.charge_3_reset_addr, _valid_3 = false}
  }

  if charge_table[_player_obj.char_str] then
    _player_obj.charge_1.name= charge_table[_player_obj.char_str]._name1
    read_charge_state(_player_obj.charge_1, charge_table[_player_obj.char_str]._valid_1, charge_table[_player_obj.char_str]._charge_1_addr, charge_table[_player_obj.char_str]._reset_1_addr)
    if charge_table[_player_obj.char_str]._name2 then _player_obj.charge_2.name= charge_table[_player_obj.char_str]._name2 end
    read_charge_state(_player_obj.charge_2, charge_table[_player_obj.char_str]._valid_2, charge_table[_player_obj.char_str]._charge_2_addr, charge_table[_player_obj.char_str]._reset_2_addr)
    if charge_table[_player_obj.char_str]._name3 then _player_obj.charge_3.name= charge_table[_player_obj.char_str]._name3 end
    read_charge_state(_player_obj.charge_3, charge_table[_player_obj.char_str]._valid_3, charge_table[_player_obj.char_str]._charge_3_addr, charge_table[_player_obj.char_str]._reset_3_addr)
  else
    read_charge_state(_player_obj.charge_1, false, _player_obj.addresses.charge_1_addr, _player_obj.addresses.charge_1_reset_addr)
    read_charge_state(_player_obj.charge_2, false, _player_obj.addresses.charge_1_addr, _player_obj.addresses.charge_1_reset_addr)
    read_charge_state(_player_obj.charge_3, false, _player_obj.addresses.charge_1_addr, _player_obj.addresses.charge_1_reset_addr)
  end
  -- STUN
  _player_obj.stun_max = memory.readbyte(_player_obj.addresses.stun_max_addr)
  _player_obj.stun_timer = memory.readbyte(_player_obj.addresses.stun_timer_addr)
  _player_obj.stun_bar = bit.rshift(memory.readdword(_player_obj.addresses.stun_bar_addr), 24)
end

function gamestate.set_player_life(_player_obj, _life)
  memory.writebyte(_player_obj.base + 0x9F, _life)
  _player_obj.life = _life
end

function select_gill()
  character_select_coroutine = coroutine.create(co_select_gill)
end

function co_select_gill(_input)
  local _player_id = 0

  local _p1_character_select_state = gamestate.get_character_select_state(1)
  local _p2_character_select_state = gamestate.get_character_select_state(2)

  if _p1_character_select_state > 2 and _p2_character_select_state > 2 then
    return
  end

  if _p1_character_select_state <= 2 then
    _player_id = 1
  else
    _player_id = 2
  end

  memory.writebyte(addresses.players[_player_id].character_select_col, 3)
  memory.writebyte(addresses.players[_player_id].character_select_row, 1)

  make_input_empty(_input)
  _input[gamestate.player_objects[_player_id].prefix.." Weak Punch"] = true
end

function select_shingouki()
  character_select_coroutine = coroutine.create(co_select_shingouki)
end

function co_select_shingouki(_input)
  local _player_id = 0

  local _p1_character_select_state = gamestate.get_character_select_state(1)
  local _p2_character_select_state = gamestate.get_character_select_state(2)

  if _p1_character_select_state > 2 and _p2_character_select_state > 2 then
    return
  end

  if _p1_character_select_state <= 2 then
    _player_id = 1
  else
    _player_id = 2
  end

  memory.writebyte(addresses.players[_player_id].character_select_col, 0)
  memory.writebyte(addresses.players[_player_id].character_select_row, 6)

  make_input_empty(_input)
  _input[gamestate.player_objects[_player_id].prefix.." Weak Punch"] = true

  co_wait_x_frames(20)

  memory.writebyte(addresses.players[_player_id].character_select_id, 0x0F)
end

function gamestate.refill_meter(_player_obj, _wanted_meter)
  -- If the SA is a timed SA, the gauge won't go back to 0 when it reaches max. We have to make special cases for it
  local _is_timed_sa = character_specific[_player_obj.char_str].timed_sa[_player_obj.selected_sa]

  local _previous_gauge = memory.readbyte(_player_obj.addresses.gauge_addr)
  local _previous_meter_count = memory.readbyte(_player_obj.addresses.meter_addr[2])
  local _previous_meter_count_slave = memory.readbyte(_player_obj.addresses.meter_addr[1])

  if _previous_meter_count == _previous_meter_count_slave then
    local _meter = 0
    -- If the SA is a timed SA, the gauge won't go back to 0 when it reaches max
    if _is_timed_sa then
      _meter = _previous_gauge
    else
       _meter = _previous_gauge + _player_obj.max_meter_gauge * _previous_meter_count
    end

    if _meter > _wanted_meter then
      _meter = _meter - 6
      _meter = math.max(_meter, _wanted_meter)
    elseif _meter < _wanted_meter then
      _meter = _meter + 6
      _meter = math.min(_meter, _wanted_meter)
    end

    local _wanted_gauge = _meter % _player_obj.max_meter_gauge
    local _wanted_meter_count = math.floor(_meter / _player_obj.max_meter_gauge)
    local _previous_meter_count = memory.readbyte(_player_obj.addresses.meter_addr[2])
    local _previous_meter_count_slave = memory.readbyte(_player_obj.addresses.meter_addr[1])

    if character_specific[_player_obj.char_str].timed_sa[_player_obj.selected_sa] and _wanted_meter_count == 1 and _wanted_gauge == 0 then
      _wanted_gauge = _player_obj.max_meter_gauge
    end

    --if _player_obj.id == 1 then
    --  print(string.format("%d: %d/%d/%d (%d/%d)", _wanted_meter, _wanted_gauge, _wanted_meter_count, _player_obj.max_meter_gauge, _previous_gauge, _previous_meter_count))
    --end

    if _wanted_gauge ~= _previous_gauge then
      memory.writebyte(_player_obj.addresses.gauge_addr, _wanted_gauge)
    end
    if _previous_meter_count ~= _wanted_meter_count then
      memory.writebyte(_player_obj.addresses.meter_addr[2], _wanted_meter_count)
      memory.writebyte(_player_obj.addresses.meter_update_flag, 0x01)
    end
  end
end

function gamestate.refill_meter_max(_player_obj)
  -- If the SA is a timed SA, the gauge won't go back to 0 when it reaches max. We have to make special cases for it
  local _is_timed_sa = character_specific[_player_obj.char_str].timed_sa[_player_obj.selected_sa]

  local _previous_meter_count = memory.readbyte(_player_obj.addresses.meter_addr[2])
  local _previous_meter_count_slave = memory.readbyte(_player_obj.addresses.meter_addr[1])
  if _previous_meter_count ~= _player_obj.max_meter_count and _previous_meter_count_slave ~= _player_obj.max_meter_count then
    local _gauge_value = 0
    if _is_timed_sa then
      _gauge_value = _player_obj.max_meter_gauge
    end
    memory.writebyte(_player_obj.addresses.gauge_addr, _gauge_value)
    memory.writebyte(_player_obj.addresses.meter_addr[2], _player_obj.max_meter_count)
    memory.writebyte(_player_obj.addresses.meter_update_flag, 0x01)
  end
end
