
print("2X!")

gamestate.was_frozen = false

-- ## read
gamestate.read = function ()
  -- game
  gamestate.read_game_vars()

  -- players
  gamestate.read_player_vars(gamestate.player_objects[1])
  gamestate.read_player_vars(gamestate.player_objects[2])

  -- projectiles
  --~ read_projectiles()
  projectiles = projectiles or {}

  if gamestate.is_in_match then
    update_flip_input(gamestate.player_objects[1], gamestate.player_objects[2])
    update_flip_input(gamestate.player_objects[2], gamestate.player_objects[1])
  end

  --~ function update_player_relationships(_self, _other)
    --~ -- Can't do this inside read_player_vars cause we need both players to have read their stuff
    --~ if _self.has_just_started_wake_up then
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
  --~ memory.writebyte(addresses.global.turbo, 0xFF) -- Remove frameksip for now

  -- freeze game
  if _settings.freeze then
    if (not gamestate.was_frozen) then
      gamestate.previous_turbo = memory.readbyte(addresses.global.turbo)
      memory.writebyte(addresses.global.turbo, 0xFF) -- Remove frameksip
    end
    memory.writeword(addresses.players[1].input, 0x00) -- Remove P1 inputs
    memory.writeword(addresses.players[2].input, 0x00) -- Remove P2 inputs

    memory.writeword(addresses.global.slowdown, 0xFFFF) -- Maximum slowdown

    gamestate.was_frozen = true
  else
    if (gamestate.was_frozen) then
      memory.writebyte(addresses.global.turbo, gamestate.previous_turbo) -- Put back turbo
      memory.writeword(addresses.global.slowdown, 0x00) -- Remove slowdown
    end
    gamestate.was_frozen = false
  end

  -- timer
  if _settings.infinite_time or _settings.freeze then
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

  _obj.flip_x         = memory.readbyte(_obj.addresses.flip_x)
  _obj.previous_pos_x = _obj.pos_x or 0
  _obj.previous_pos_y = _obj.pos_y or 0
  _obj.pos_x          = memory.readwordsigned(_obj.addresses.pos_x)
  _obj.pos_y          = memory.readwordsigned(_obj.addresses.pos_y)
  local _char_id      = memory.readbyte(_obj.addresses.char)
  if (_char_id < #rom.characters) then
    _obj.char_id        = _char_id
  elseif _obj.char_id == nil then
    _obj.char_id        = 1
  end
  _obj.animation_ptr  = memory.readdword(_obj.addresses.animation_ptr)
  _obj.hitbox_ptr     = memory.readdword(_obj.addresses.hitbox_ptr)

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

function gamestate.read_player_vars(_player_obj)
  read_input(_player_obj)

  if gamestate.is_object_invalid(_player_obj) then --invalid objects
    return false
  end

  --~ print(string.format("%08X",memory.readdword(_player_obj.addresses.base + 0x18B3)))
  --~ gui.text(10, 10*_player_obj.id, string.format("%08X",
    --~ memory.readdword(_player_obj.addresses.state)
    --~ memory.readdword(_player_obj.base + 0x27),
    --~ memory.readword(_player_obj.base + 0x10)
  --~ ), text_default_color, text_default_border_color)

  local _debug_state_variables = _player_obj.debug_state_variables

  local _prev_pos_x = _player_obj.pos_x or 0
  local _prev_pos_y = _player_obj.pos_y or 0

  gamestate.read_game_object(_player_obj)

  local _previous_movement_type = _player_obj.movement_type or 0

  _player_obj.char_str = rom.characters[_player_obj.char_id + 1]

  _player_obj.remaining_freeze_frames = 0 -- fixme
  _player_obj.freeze_type = 0
  --~ local _previous_remaining_freeze_frames = _player_obj.remaining_freeze_frames or 0
  --~ _player_obj.remaining_freeze_frames = memory.readbyte(_player_obj.base + 0x45)
  --~ _player_obj.freeze_type = 0
  --~ if _player_obj.remaining_freeze_frames ~= 0 then
    --~ if _player_obj.remaining_freeze_frames < 127 then
      --~ -- inflicted freeze I guess (when the opponent parry you for instance)
      --~ _player_obj.freeze_type = 1
      --~ _player_obj.remaining_freeze_frames = _player_obj.remaining_freeze_frames
    --~ else
      --~ _player_obj.freeze_type = 2
      --~ _player_obj.remaining_freeze_frames = 256 - _player_obj.remaining_freeze_frames
    --~ end
  --~ end
  --~ local _remaining_freeze_frame_diff = _player_obj.remaining_freeze_frames - _previous_remaining_freeze_frames
  --~ if _remaining_freeze_frame_diff > 0 then
    --~ log(_player_obj.prefix, "fight", string.format("freeze %d", _player_obj.remaining_freeze_frames))
    --~ --print(string.format("%d: %d(%d)",  _player_obj.id, _player_obj.remaining_freeze_frames, _player_obj.freeze_type))
  --~ end

  local _previous_action = _player_obj.action or 0x00
  local _previous_movement_type2 = _player_obj.movement_type2 or 0x00
  local _previous_posture = _player_obj.posture or 0x00

  _player_obj.previous_input_capacity = _player_obj.input_capacity or 0
  _player_obj.input_capacity          = 1
  _player_obj.action                  = memory.readdword(_player_obj.base + 0xAC)
  _player_obj.action_ext              = memory.readdword(_player_obj.base + 0x12C)
  _player_obj.previous_recovery_time  = _player_obj.recovery_time or 0
  --~ _player_obj.recovery_time           = memory.readbyte(_player_obj.base + 0x187)
  _player_obj.movement_type           = memory.readbyte(_player_obj.base + 0x0AD)
  _player_obj.movement_type2          = memory.readbyte(_player_obj.base + 0x0AF) -- seems that we can know which basic movement the player is doing from there
  _player_obj.total_received_projectiles_count = memory.readword(_player_obj.base + 0x430) -- on block or hit

  -- postures
  --  0x00 -- standing neutral
  --  0x02 -- crouching
  --  0x04 -- airborn
  --  0x08 -- proximity guard
  --  0x0A -- normal attack
  --  0x0C -- special move
  --  0x0E -- hitstun/blockstun/stun/holdgrabbed
  --  0x14 -- after a throw
  _player_obj.posture = memory.readbyte(_player_obj.addresses.state)
  _player_obj.substate = memory.readbyte(_player_obj.addresses.substate)
  -- airborn
  --  0x00 -- On the ground
  --  0x01 -- In the air
  --  0xFF -- Knocked down
  _player_obj.previous_airborn = _player_obj.airborn or 0
  _player_obj.airborn = memory.readbyte(_player_obj.addresses.airborn)

  _player_obj.busy_flag = 0

  local _previous_is_in_basic_action = _player_obj.is_in_basic_action or false
  _player_obj.is_in_basic_action = _player_obj.action < 0xFF and _previous_action < 0xFF -- this triggers one frame early than it should, so we delay it artificially
  _player_obj.has_just_entered_basic_action = not _previous_is_in_basic_action and _player_obj.is_in_basic_action

  local _previous_recovery_flag = _player_obj.recovery_flag or 1
  _player_obj.recovery_flag = memory.readbyte(_player_obj.base + 0x3B)
  _player_obj.has_just_ended_recovery = _previous_recovery_flag ~= 0 and _player_obj.recovery_flag == 0

  _player_obj.meter_gauge = memory.readbyte(_player_obj.addresses.gauge_addr)
  _player_obj.max_meter_gauge = 48
  if (_player_obj.meter_gauge >= _player_obj.max_meter_gauge) then
    _player_obj.meter_count = 1
  else
    _player_obj.meter_count = 0
  end
  _player_obj.selected_sa = 1
  _player_obj.max_meter_count = 1

  -- CROUCHED
  _player_obj.is_crouched = _player_obj.posture == 0x02

  -- LIFE
  _player_obj.life = memory.readword(_player_obj.addresses.life)

  -- BONUSES
  _player_obj.damage_bonus  = 0
  _player_obj.stun_bonus    = 0
  _player_obj.defense_bonus = 0

  -- THROW
  local _previous_is_throwing = _player_obj.is_throwing or false
  _player_obj.is_throwing = bit.rshift(_player_obj.movement_type2, 4) == 9
  _player_obj.has_just_thrown = not _previous_is_throwing and _player_obj.is_throwing

  _player_obj.is_being_thrown = (_player_obj.posture == 0x14)
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
  _player_obj.is_attacking = (_player_obj.posture == 0x0A or _player_obj.posture == 0x0C or (_player_obj.posture == 0x04 and _player_obj.substate == 0x06))
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
  _player_obj.animation = memory.readdword(_player_obj.addresses.animation_ptr)
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

  _player_obj.last_movement_type_change_frame = _player_obj.last_movement_type_change_frame or 0
  if _player_obj.movement_type ~= _previous_movement_type then
    _player_obj.last_movement_type_change_frame = gamestate.frame_number
  end

  -- is blocking/has just blocked/has just been hit/has_just_parried
  --~ 0x5E -> 0x69
  --~ 0x6A -> 0x7A
  --~ 0x7C -> 0x90
  local _hitstun = memory.readbyte(_player_obj.addresses.hitstun_counter)

  _player_obj.has_just_blocked = false
  _player_obj.is_blocking = false
  _player_obj.recovery_time = 0
  if (not _player_obj.is_wakingup and _player_obj.posture == 0xE) then
    if (_hitstun > 0x5E and _hitstun < 0x69) then
      _player_obj.is_blocking = true
      _player_obj.recovery_time = 0x69 - _hitstun
    end
    if (_hitstun > 0x6A and _hitstun < 0x7A) then
      _player_obj.is_blocking = true
      _player_obj.recovery_time = 0x7A - _hitstun
    end
    if (_hitstun > 0x7C and _hitstun < 0x90) then
      _player_obj.is_blocking = true
      _player_obj.recovery_time = 0x90 - _hitstun
    end
  end

  if _player_obj.is_blocking and _player_obj.previous_recovery_time ~= 0 then
    _player_obj.has_just_blocked = true
    log(_player_obj.prefix, "fight", "block")
    if _debug_state_variables then
      print(string.format("%d - %s blocked", gamestate.frame_number, _player_obj.prefix))
    end
  end

  _player_obj.has_just_been_hit = false
  if _total_received_hit_count_diff > 0 then
    _player_obj.has_just_been_hit = true
    log(_player_obj.prefix, "fight", "hit")
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
  _player_obj.is_in_jump_startup = _player_obj.posture == 0x04 and _player_obj.substate == 0x00 and not _player_obj.is_blocking
  _player_obj.previous_standing_state = _player_obj.standing_state or 0
  if (_player_obj.airborn == 0x00) then
    _player_obj.standing_state = 1
  else
    _player_obj.standing_state = 0
  end
  _player_obj.has_just_landed = is_state_on_ground(_player_obj.standing_state, _player_obj) and not is_state_on_ground(_player_obj.previous_standing_state, _player_obj)
  if _debug_state_variables and _player_obj.has_just_landed then print(string.format("%d - %s landed (%d > %d)", gamestate.frame_number, _player_obj.prefix, _player_obj.previous_standing_state, _player_obj.standing_state)) end
  if _player_obj.debug_standing_state and _player_obj.previous_standing_state ~= _player_obj.standing_state then print(string.format("%d - %s standing state changed (%d > %d)", gamestate.frame_number, _player_obj.prefix, _player_obj.previous_standing_state, _player_obj.standing_state)) end

  -- AIR RECOVERY STATE
  _player_obj.is_in_air_recovery = false
  _player_obj.has_just_entered_air_recovery = false

  -- IS IDLE
  local _previous_is_idle = _player_obj.is_idle or false
  _player_obj.idle_time = _player_obj.idle_time or 0
  _player_obj.is_idle = (
    (_player_obj.posture == 0 or _player_obj.posture == 2) and
    memory.readword(_player_obj.addresses.life) == memory.readword(_player_obj.addresses.life_backup) and -- not the prettiest fix but it does avoid life refill bug
    not _player_obj.is_attacking and
    not _player_obj.is_blocking and
    not _player_obj.is_wakingup and
    not _player_obj.is_being_thrown and
    not _player_obj.is_in_jump_startup and
    _player_obj.recovery_time == _player_obj.previous_recovery_time and
    _player_obj.remaining_freeze_frames == 0 and
    _player_obj.input_capacity > 0
  )

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

    _player_obj.previous_is_wakingup = _player_obj.is_wakingup or false
    _player_obj.is_wakingup = _player_obj.is_wakingup or false
    _player_obj.wakeup_time = _player_obj.wakeup_time or 0
    if _player_obj.previous_airborn == 0xFF and _player_obj.airborn == 0 and _player_obj.posture == 0x0E then
      _player_obj.is_wakingup = true
      _player_obj.is_past_wakeup_frame = false
      _player_obj.wakeup_time = 0
      _player_obj.wakeup_animation = _player_obj.animation
      if debug_wakeup then
        print(string.format("%d - %s wakeup started", gamestate.frame_number, _player_obj.prefix))
      end
      _player_obj.remaining_wakeup_time = 39 -- fixme
    end

    _player_obj.previous_is_fast_wakingup = false
    _player_obj.is_fast_wakingup = false
    _player_obj.has_just_started_fast_wake_up = false

    if _player_obj.is_wakingup then
      _player_obj.wakeup_time = _player_obj.wakeup_time + 1
      _player_obj.remaining_wakeup_time = _player_obj.remaining_wakeup_time - 1

    end

    if _player_obj.is_wakingup and _previous_posture == 0x0E and _player_obj.posture ~= 0x0E then
      -- fixme reset wakeup at round end
      if debug_wakeup then
        print(string.format("%d - %s wake up: %s, %d", gamestate.frame_number, _player_obj.prefix, _player_obj.wakeup_animation, _player_obj.wakeup_time))
      end
      _player_obj.is_wakingup = false
      _player_obj.is_past_wakeup_frame = false
    end

    _player_obj.has_just_started_wake_up = not _player_obj.previous_is_wakingup and _player_obj.is_wakingup
    _player_obj.has_just_woke_up = _player_obj.previous_is_wakingup and not _player_obj.is_wakingup

    if _player_obj.has_just_started_wake_up then
      log(_player_obj.prefix, "fight", string.format("wakeup 1"))
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

  -- STUN
  _player_obj.stun_max    = 100 -- fixme
  _player_obj.stun_bar    = memory.readbyte(_player_obj.addresses.stun)
end

function gamestate.reset_player_objects()
  gamestate.player_objects = {
    make_player_object(1, addresses.players[1].base, "P1"),
    make_player_object(2, addresses.players[2].base, "P2")
  }

  gamestate.P1 = gamestate.player_objects[1]
  gamestate.P2 = gamestate.player_objects[2]
  gamestate.P1.max_life = 144
  gamestate.P2.max_life = 144
end

function gamestate.set_player_life(_player_obj, _life)
  if (_player_obj.life == _life) then
    return
  end
  print(string.format("%04X %04X %04X %04X",
    memory.readword(_player_obj.addresses.life),
    memory.readword(_player_obj.addresses.life_backup),
    memory.readword(_player_obj.addresses.life_hud),
    _life
  ))
  -- fixme with infinite life, causes problems
  memory.writeword(_player_obj.addresses.life, _life)
  memory.writeword(_player_obj.addresses.life_backup, _life)
  memory.writeword(_player_obj.addresses.life_hud, _life)
  _player_obj.life = _life
end

function gamestate.refill_meter(_player_obj, _wanted_meter)
  local _previous_gauge = memory.readbyte(_player_obj.addresses.gauge_addr)

  local _meter = memory.readbyte(_player_obj.addresses.gauge_addr)

  if _meter > _wanted_meter then
    _meter = _meter - 6
    _meter = math.max(_meter, _wanted_meter)
  elseif _meter < _wanted_meter then
    _meter = _meter + 6
    _meter = math.min(_meter, _wanted_meter)
  end

  local _wanted_gauge = _meter

  if _wanted_gauge ~= _previous_gauge then
    memory.writebyte(_player_obj.addresses.gauge_addr, _wanted_gauge)
  end
end

function gamestate.refill_meter_max(_player_obj)
  local _previous_gauge = memory.readbyte(_player_obj.addresses.gauge_addr)

  local _wanted_gauge = _player_obj.max_meter_gauge

  if _wanted_gauge ~= _previous_gauge then
    memory.writebyte(_player_obj.addresses.gauge_addr, _wanted_gauge)
  end
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
