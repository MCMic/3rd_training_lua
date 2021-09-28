gamestate = {
  -- variables
  frame_number = 0,
  is_in_match = false,
  player_objects = {},
  P1 = nil,
  P2 = nil,
}

-- # api
function make_input_set(_value)
  return {
    up = _value,
    down = _value,
    left = _value,
    right = _value,
    LP = _value,
    MP = _value,
    HP = _value,
    LK = _value,
    MK = _value,
    HK = _value,
    start = _value,
    coin = _value
  }
end

function make_player_object(_id, _base, _prefix)
  return {
    id = _id,
    base = _base,
    addresses = addresses.players[_id],
    prefix = _prefix,
    input = {
      pressed = make_input_set(false),
      released = make_input_set(false),
      down = make_input_set(false),
      state_time = make_input_set(0),
    },
    blocking = {
      wait_for_block_string = true,
      block_string = false,
    },
    counter = {
      attack_frame = -1,
      ref_time = -1,
      recording_slot = -1,
    },
    throw = {},
    max_life = 160,
    meter_gauge = 0,
    meter_count = 0,
    max_meter_gauge = 0,
    max_meter_count = 0,
  }
end

function gamestate.reset_player_objects()
  gamestate.player_objects = {
    make_player_object(1, addresses.players[1].base, "P1"),
    make_player_object(2, addresses.players[2].base, "P2")
  }

  gamestate.P1 = gamestate.player_objects[1]
  gamestate.P2 = gamestate.player_objects[2]
end

function read_input(_player_obj)

  function read_single_input(_input_object, _input_name, _input)
    _input_object.pressed[_input_name] = false
    _input_object.released[_input_name] = false
    if _input_object.down[_input_name] == false and _input then _input_object.pressed[_input_name] = true end
    if _input_object.down[_input_name] == true and _input == false then _input_object.released[_input_name] = true end

    if _input_object.down[_input_name] == _input then
      _input_object.state_time[_input_name] = _input_object.state_time[_input_name] + 1
    else
      _input_object.state_time[_input_name] = 0
    end
    _input_object.down[_input_name] = _input
  end

  local _local_input = joypad.get()
  read_single_input(_player_obj.input, "start", _local_input[_player_obj.prefix.." Start"])
  read_single_input(_player_obj.input, "coin", _local_input[_player_obj.prefix.." Coin"])
  read_single_input(_player_obj.input, "up", _local_input[_player_obj.prefix.." Up"])
  read_single_input(_player_obj.input, "down", _local_input[_player_obj.prefix.." Down"])
  read_single_input(_player_obj.input, "left", _local_input[_player_obj.prefix.." Left"])
  read_single_input(_player_obj.input, "right", _local_input[_player_obj.prefix.." Right"])
  read_single_input(_player_obj.input, "LP", _local_input[_player_obj.prefix.." Weak Punch"])
  read_single_input(_player_obj.input, "MP", _local_input[_player_obj.prefix.." Medium Punch"])
  read_single_input(_player_obj.input, "HP", _local_input[_player_obj.prefix.." Strong Punch"])
  read_single_input(_player_obj.input, "LK", _local_input[_player_obj.prefix.." Weak Kick"])
  read_single_input(_player_obj.input, "MK", _local_input[_player_obj.prefix.." Medium Kick"])
  read_single_input(_player_obj.input, "HK", _local_input[_player_obj.prefix.." Strong Kick"])
end

function read_projectiles()
  local _MAX_OBJECTS = 30
  projectiles_count = projectiles_count or 0
  projectiles = projectiles or {}

  -- flag everything as expired by default, we will reset the flag it we update the projectile
  for _id, _obj in pairs(projectiles) do
    _obj.expired = true
  end

  -- how we recover hitboxes data for each projectile is taken almost as is from the cps3-hitboxes.lua script
  --object = {initial = 0x02028990, index = 0x02068A96},
  local _index = 0x02068A96
  local _initial = 0x02028990
  local _list = 3
  local _obj_index = memory.readwordsigned(_index + (_list * 2))

  local _obj_slot = 1
  while _obj_slot <= _MAX_OBJECTS and _obj_index ~= -1 do
    local _base = _initial + bit.lshift(_obj_index, 11)
    local _id = string.format("%08X", _base)
    local _obj = projectiles[_id]
    local _is_initialization = false
    if _obj == nil then
       _obj = {base = _base, projectile = _obj_slot}
       _obj.id = _id
       _obj.is_forced_one_hit = true
       _obj.lifetime = 0
       _obj.has_activated = false
       _is_initialization = true
    end
    if gamestate.read_game_object(_obj) then
      _obj.emitter_id = memory.readbyte(_obj.base + 0x2) + 1

      if _is_initialization then
        _obj.initial_flip_x = _obj.flip_x
        _obj.emitter_animation = gamestate.player_objects[_obj.emitter_id].animation
      else
        _obj.lifetime = _obj.lifetime + 1
      end

      if #_obj.boxes > 0 then
        _obj.has_activated = true
      end
      _obj.expired = false
      _obj.is_converted = _obj.flip_x ~= _obj.initial_flip_x
      _obj.previous_remaining_hits = _obj.remaining_hits or 0
      _obj.remaining_hits = memory.readbyte(_obj.base + 0x9C + 2)
      if _obj.remaining_hits > 0 then
        _obj.is_forced_one_hit = false
      end
      --_obj.remaining_hits2 = memory.readbyte(_obj.base + 0x49 + 0) -- Looks like attack validity or whatever
      _obj.projectile_type = string.format("%02X", memory.readbyte(_obj.base + 0x91))
      if _is_initialization then
        _obj.projectile_start_type = _obj.projectile_type -- type can change during projectile life (ex: aegis)
      end
      _obj.remaining_freeze_frames = memory.readbyte(_obj.base + 0x45)
      if projectiles[_obj.id] == nil then
        log(gamestate.player_objects[_obj.emitter_id].prefix, "projectiles", string.format("projectile %s %s 1", _obj.id, _obj.projectile_type))
      end
      projectiles[_obj.id] = _obj
    end

    -- Get the index to the next object in this list.
    _obj_index = memory.readwordsigned(_obj.base + 0x1C)
    _obj_slot = _obj_slot + 1
  end

  -- if a projectile is still expired, we remove it
  projectiles_count = 0
  for _id, _obj in pairs(projectiles) do
    if _obj.expired then
      log(gamestate.player_objects[_obj.emitter_id].prefix, "projectiles", string.format("projectile %s 0", _id))
      projectiles[_id] = nil
    else
      projectiles_count = projectiles_count + 1
    end
  end

  -- now the list is clean, let's do stuff
  for _id, _obj in pairs(projectiles) do
    update_object_velocity(_obj, true)
  end
end


function update_flip_input(_player, _other_player)
  local _debug = false
  if _player.flip_input == nil then
    _player.flip_input = _other_player.pos_x >= _player.pos_x
    return
  end

  local _previous_flip_input = _player.flip_input
  local _flip_hysteresis = 0
  local _diff = _other_player.pos_x - _player.pos_x
  if math.abs(_diff) >= _flip_hysteresis then
    _player.flip_input = _other_player.pos_x >= _player.pos_x
  end

  if _previous_flip_input ~= _player.flip_input then
    log(_player.prefix, "fight", "flip input")
  end
end

-- # tools
function update_object_velocity(_object, _debug)
  _debug = _debug or false
  -- VELOCITY & ACCELERATION
  local _velocity_frame_sampling_count = 10

  _object.pos_samples = _object.pos_samples or {}
  _object.velocity_samples = _object.velocity_samples or {}

  if _object.remaining_freeze_frames > 0 then
    return
  end

  local _pos = { x = _object.pos_x, y = _object.pos_y }
  table.insert(_object.pos_samples, _pos)
  while #_object.pos_samples > _velocity_frame_sampling_count do
    table.remove(_object.pos_samples, 1)
  end
  local _velocity = {
    x = (_pos.x - _object.pos_samples[1].x) / #_object.pos_samples,
    y = (_pos.y - _object.pos_samples[1].y) / #_object.pos_samples,
  }

  table.insert(_object.velocity_samples, _velocity)
  while #_object.velocity_samples > _velocity_frame_sampling_count do
    table.remove(_object.velocity_samples, 1)
  end
  _object.acc = {
    x = (_velocity.x - _object.velocity_samples[1].x) / #_object.velocity_samples,
    y = (_velocity.y - _object.velocity_samples[1].y) / #_object.velocity_samples,
  }
end


function is_state_on_ground(_state, _player_obj)
  -- 0x01 is standard standing
  -- 0x02 is standard crouching
  if _state == 0x01 or _state == 0x02 then
    return true
  elseif character_specific[_player_obj.char_str].additional_standing_states ~= nil then
    for _, _standing_state in ipairs(character_specific[_player_obj.char_str].additional_standing_states) do
      if _standing_state == _state then
        return true
      end
    end
  end
end

-- Run rom specific gamestate.lua if it exists
rom_gamestate = loadfile("src/" .. rom_name .. "/gamestate.lua")
if (rom_gamestate ~= nil) then
  rom_gamestate()
else
  require("src/sfiii3nr1/gamestate.lua")
end

-- # initialize player objects
gamestate.reset_player_objects()
