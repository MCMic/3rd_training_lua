local player_keys = {
  "Up",
  "Down",
  "Left",
  "Right",
  "Weak Punch",
  "Medium Punch",
  "Strong Punch",
  "Weak Kick",
  "Medium Kick",
  "Strong Kick",
}

local player_keys_extra = {
  "Start",
  "Coin",
}

local sequence_to_key_mapping = {
  up = "Up",
  down = "Down",
  LP = "Weak Punch",
  MP = "Medium Punch",
  HP = "Strong Punch",
  LK = "Weak Kick",
  MK = "Medium Kick",
  HK = "Strong Kick",
}

key_to_sequence_mapping = {}
for k, v in pairs(sequence_to_key_mapping) do
  key_to_sequence_mapping[v] = k
end

-- _input is the input table
-- _id is the player id (1 or 2)
-- _extra is whether Start and Coin should also be cleared
function clear_player_input(_input, _id, _extra)
  for i, key in pairs(player_keys) do
    _input["P".._id.." "..key] = false
  end

  if (_extra) then
    for i, key in pairs(player_keys_extra) do
      _input["P".._id.." "..key] = false
    end
  end
end

function make_input_empty(_input)
  if _input == nil then
    return
  end

  clear_player_input(_input, 1, true)
  clear_player_input(_input, 2, true)
end

-- players
function queue_input_sequence(_player_obj, _sequence, _offset)
  _offset = _offset or 0
  if _sequence == nil or #_sequence == 0 then
    return
  end

  if _player_obj.pending_input_sequence ~= nil then
    return
  end

  local _seq = {}
  _seq.sequence = copytable(_sequence)
  _seq.current_frame = 1 - _offset

  _player_obj.pending_input_sequence = _seq
end

function process_pending_input_sequence(_player_obj, _input)
  if _player_obj.pending_input_sequence == nil then
    return
  end
  if is_menu_open then
    return
  end
  if not gamestate.is_in_match then
    return
  end

  -- Cancel all input
  clear_player_input(_input, _player_obj.id, false)

  local _gauges_base = 0
  if _player_obj.id == 1 then
    _gauges_base = 0x020259D8
  elseif _player_obj.id == 2 then
    _gauges_base = 0x02025FF8
  end
  local _gauges_offsets = { 0x0, 0x1C, 0x38, 0x54, 0x70 }

  if _player_obj.pending_input_sequence.current_frame >= 1 then
    local _s = ""
    local _current_frame_input = _player_obj.pending_input_sequence.sequence[_player_obj.pending_input_sequence.current_frame]
    for i = 1, #_current_frame_input do
      local _input_name = _player_obj.prefix.." "
      if _current_frame_input[i] == "forward" then
        if _player_obj.flip_input then _input_name = _input_name.."Right" else _input_name = _input_name.."Left" end
      elseif _current_frame_input[i] == "back" then
        if _player_obj.flip_input then _input_name = _input_name.."Left" else _input_name = _input_name.."Right" end
      elseif sequence_to_key_mapping[_current_frame_input[i]] ~= nil then
        _input_name = _input_name..sequence_to_key_mapping[_current_frame_input[i]]
      elseif _current_frame_input[i] == "h_charge" then
        if _player_obj.char_str == "urien" then
          memory.writeword(_gauges_base + _gauges_offsets[1], 0xFFFF)
        elseif _player_obj.char_str == "oro" then
          memory.writeword(_gauges_base + _gauges_offsets[3], 0xFFFF)
        elseif _player_obj.char_str == "chunli" then
        elseif _player_obj.char_str == "q" then
          memory.writeword(_gauges_base + _gauges_offsets[1], 0xFFFF)
          memory.writeword(_gauges_base + _gauges_offsets[2], 0xFFFF)
        elseif _player_obj.char_str == "remy" then
          memory.writeword(_gauges_base + _gauges_offsets[2], 0xFFFF)
          memory.writeword(_gauges_base + _gauges_offsets[3], 0xFFFF)
        elseif _player_obj.char_str == "alex" then
          memory.writeword(_gauges_base + _gauges_offsets[5], 0xFFFF)
        end
      elseif _current_frame_input[i] == "v_charge" then
        if _player_obj.char_str == "urien" then
          memory.writeword(_gauges_base + _gauges_offsets[2], 0xFFFF)
          memory.writeword(_gauges_base + _gauges_offsets[4], 0xFFFF)
        elseif _player_obj.char_str == "oro" then
          memory.writeword(_gauges_base + _gauges_offsets[1], 0xFFFF)
        elseif _player_obj.char_str == "chunli" then
          memory.writeword(_gauges_base + _gauges_offsets[1], 0xFFFF)
        elseif _player_obj.char_str == "q" then
        elseif _player_obj.char_str == "remy" then
          memory.writeword(_gauges_base + _gauges_offsets[1], 0xFFFF)
        elseif _player_obj.char_str == "alex" then
          memory.writeword(_gauges_base + _gauges_offsets[4], 0xFFFF)
        end
      end
      _input[_input_name] = true
      _s = _s.._input_name
    end
  end
  --print(_s)

  _player_obj.pending_input_sequence.current_frame = _player_obj.pending_input_sequence.current_frame + 1
  if _player_obj.pending_input_sequence.current_frame > #_player_obj.pending_input_sequence.sequence then
    _player_obj.pending_input_sequence = nil
  end
end

function clear_input_sequence(_player_obj)
  _player_obj.pending_input_sequence = nil
end

function is_playing_input_sequence(_player_obj)
  return _player_obj.pending_input_sequence ~= nil and _player_obj.pending_input_sequence.current_frame >= 1
end

function make_input_sequence(_stick, _button)

  if _button == "recording" then
    return nil
  end

  local _sequence = {}
  local _offset = 0
  if      _stick == "none"    then _sequence = { { } }
  elseif  _stick == "forward" then _sequence = { { "forward" } }
  elseif  _stick == "back"    then _sequence = { { "back" } }
  elseif  _stick == "down"    then _sequence = { { "down" } }
  elseif  _stick == "jump"    then _sequence = { { "up" } }
  elseif  _stick == "super jump" then _sequence = { { "down" }, { "up" } }
  elseif  _stick == "forward jump" then
    _sequence = { { "forward", "up" }, { "forward", "up" }, { "forward", "up" } }
    _offset = 2
  elseif  _stick == "forward super jump" then
    _sequence = { { "down" }, { "forward", "up" }, { "forward", "up" } }
    _offset = 2
  elseif  _stick == "back jump" then
    _sequence = { { "back", "up" }, { "back", "up" } }
    _offset = 2
  elseif  _stick == "back super jump" then
    _sequence = { { "down" }, { "back", "up" }, { "back", "up" } }
    _offset = 2
  elseif  _stick == "guard jump" then
    _sequence = {
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "up" }, { "up" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" }
    }
    _offset = 13
  elseif  _stick == "guard forward jump" then
    _sequence = {
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "forward", "up" },
      { "forward", "up" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" }
    }
    _offset = 13
  elseif  _stick == "guard back jump" then
    _sequence = {
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "back", "up" },
      { "back", "up" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" },
      { "down", "back" }
    }
    _offset = 13
  elseif  _stick == "QCF"     then _sequence = { { "down" }, {"down", "forward"}, {"forward"} }
  elseif  _stick == "QCB"     then _sequence = { { "down" }, {"down", "back"}, {"back"} }
  elseif  _stick == "HCF"     then _sequence = { { "back" }, {"down", "back"}, {"down"}, {"down", "forward"}, {"forward"} }
  elseif  _stick == "HCB"     then _sequence = { { "forward" }, {"down", "forward"}, {"down"}, {"down", "back"}, {"back"} }
  elseif  _stick == "DPF"     then _sequence = { { "forward" }, {"down"}, {"down", "forward"} }
  elseif  _stick == "DPB"     then _sequence = { { "back" }, {"down"}, {"down", "back"} }
  elseif  _stick == "HCharge" then _sequence = { { "back", "h_charge" }, {"forward"} }
  elseif  _stick == "VCharge" then _sequence = { { "down", "v_charge" }, {"up"} }
  elseif  _stick == "360"     then _sequence = { { "forward" }, { "forward", "down" }, {"down"}, { "back", "down" }, { "back" }, { "up" } }
  elseif  _stick == "DQCF"    then _sequence = { { "down" }, {"down", "forward"}, {"forward"}, { "down" }, {"down", "forward"}, {"forward"} }
  elseif  _stick == "720"     then _sequence = { { "forward" }, { "forward", "down" }, {"down"}, { "back", "down" }, { "back" }, { "up" }, { "forward" }, { "forward", "down" }, {"down"}, { "back", "down" }, { "back" } }
  -- full moves special cases
  elseif  _stick == "back dash" then _sequence = { { "back" }, {}, { "back" } }
    return _sequence
  elseif  _stick == "forward dash" then _sequence = { { "forward" }, {}, { "forward" } }
    return _sequence
  elseif  _stick == "Shun Goku Satsu" then _sequence = { { "LP" }, {}, {}, { "LP" }, { "forward" }, {"LK"}, {}, { "HP" } }
    return _sequence
  elseif  _stick == "Kongou Kokuretsu Zan" then _sequence = { { "down" }, {}, { "down" }, {}, { "down", "LP", "MP", "HP" } }
    return _sequence
  elseif  _stick == "Demon Armageddon" then _sequence = { { "up" }, {}, { "up" }, {}, { "up", "LK", "MK" } }
    return _sequence
  end

  if     _button == "none" then
  elseif _button == "EXP"  then
    table.insert(_sequence[#_sequence], "MP")
    table.insert(_sequence[#_sequence], "HP")
  elseif _button == "EXK"  then
    table.insert(_sequence[#_sequence], "MK")
    table.insert(_sequence[#_sequence], "HK")
  elseif _button == "LP+LK" then
    table.insert(_sequence[#_sequence], "LP")
    table.insert(_sequence[#_sequence], "LK")
  elseif _button == "MP+MK" then
    table.insert(_sequence[#_sequence], "MP")
    table.insert(_sequence[#_sequence], "MK")
  elseif _button == "HP+HK" then
    table.insert(_sequence[#_sequence], "HP")
    table.insert(_sequence[#_sequence], "HK")
  else
    table.insert(_sequence[#_sequence], _button)
  end

  return _sequence, _offset
end

-- swap inputs
function swap_inputs(_input)
  function swap(_key)
    local carry = _input["P1 ".._key]
    _input["P1 ".._key] = _input["P2 ".._key]
    _input["P2 ".._key] = carry
  end

  for i, key in pairs(player_keys) do
    swap(key)
  end
end

function sequence_input_to_key(_key, _flip_input)
  if _key == "forward" then
    if _flip_input then
      return "Right"
    else
      return "Left"
    end
  elseif _key == "back" then
    if _flip_input then
      return "Left"
    else
      return "Right"
    end
  else
    return sequence_to_key_mapping[_key]
  end
end

function key_to_sequence_input(_key, _flip_input)
  if _key == "Left" then
    if _flip_input then
      return "back"
    else
      return "forward"
    end
  end

  if _key == "Right" then
    if _flip_input then
      return "forward"
    else
      return "back"
    end
  end

  return key_to_sequence_mapping[_key]
end
