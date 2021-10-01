

function make_input_empty(_input)
  if _input == nil then
    return
  end

  _input["P1 Up"] = false
  _input["P1 Down"] = false
  _input["P1 Left"] = false
  _input["P1 Right"] = false
  _input["P1 Weak Punch"] = false
  _input["P1 Medium Punch"] = false
  _input["P1 Strong Punch"] = false
  _input["P1 Weak Kick"] = false
  _input["P1 Medium Kick"] = false
  _input["P1 Strong Kick"] = false
  _input["P1 Start"] = false
  _input["P1 Coin"] = false
  _input["P2 Up"] = false
  _input["P2 Down"] = false
  _input["P2 Left"] = false
  _input["P2 Right"] = false
  _input["P2 Weak Punch"] = false
  _input["P2 Medium Punch"] = false
  _input["P2 Strong Punch"] = false
  _input["P2 Weak Kick"] = false
  _input["P2 Medium Kick"] = false
  _input["P2 Strong Kick"] = false
  _input["P2 Start"] = false
  _input["P2 Coin"] = false
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
  _input[_player_obj.prefix.." Up"] = false
  _input[_player_obj.prefix.." Down"] = false
  _input[_player_obj.prefix.." Left"] = false
  _input[_player_obj.prefix.." Right"] = false
  _input[_player_obj.prefix.." Weak Punch"] = false
  _input[_player_obj.prefix.." Medium Punch"] = false
  _input[_player_obj.prefix.." Strong Punch"] = false
  _input[_player_obj.prefix.." Weak Kick"] = false
  _input[_player_obj.prefix.." Medium Kick"] = false
  _input[_player_obj.prefix.." Strong Kick"] = false

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
      elseif _current_frame_input[i] == "up" then
        _input_name = _input_name.."Up"
      elseif _current_frame_input[i] == "down" then
        _input_name = _input_name.."Down"
      elseif _current_frame_input[i] == "LP" then
        _input_name = _input_name.."Weak Punch"
      elseif _current_frame_input[i] == "MP" then
        _input_name = _input_name.."Medium Punch"
      elseif _current_frame_input[i] == "HP" then
        _input_name = _input_name.."Strong Punch"
      elseif _current_frame_input[i] == "LK" then
        _input_name = _input_name.."Weak Kick"
      elseif _current_frame_input[i] == "MK" then
        _input_name = _input_name.."Medium Kick"
      elseif _current_frame_input[i] == "HK" then
        _input_name = _input_name.."Strong Kick"
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
function swap_inputs(_out_input_table)
  function swap(_input)
    local carry = _out_input_table["P1 ".._input]
    _out_input_table["P1 ".._input] = _out_input_table["P2 ".._input]
    _out_input_table["P2 ".._input] = carry
  end

  swap("Up")
  swap("Down")
  swap("Left")
  swap("Right")
  swap("Weak Punch")
  swap("Medium Punch")
  swap("Strong Punch")
  swap("Weak Kick")
  swap("Medium Kick")
  swap("Strong Kick")
end

function stick_input_to_sequence_input(_player_obj, _input)
  if _input == "Up" then return "up" end
  if _input == "Down" then return "down" end
  if _input == "Weak Punch" then return "LP" end
  if _input == "Medium Punch" then return "MP" end
  if _input == "Strong Punch" then return "HP" end
  if _input == "Weak Kick" then return "LK" end
  if _input == "Medium Kick" then return "MK" end
  if _input == "Strong Kick" then return "HK" end

  if _input == "Left" then
    if _player_obj.flip_input then
      return "back"
    else
      return "forward"
    end
  end

  if _input == "Right" then
    if _player_obj.flip_input then
      return "forward"
    else
      return "back"
    end
  end
  return ""
end
