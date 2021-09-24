
character_select_coroutine = nil

-- 0 is out
-- 1 is waiting for input release for p1
-- 2 is selecting p1
-- 3 is waiting for input release for p2
-- 4 is selecting p2
character_select_sequence_state = 0

function co_wait_x_frames(_frame_count)
  local _start_frame = gamestate.frame_number
  while gamestate.frame_number < _start_frame + _frame_count do
    coroutine.yield()
  end
end

function start_character_select_sequence()
  savestate.load(savestate.create("data/"..rom_name.."/savestates/character_select.fs"))
  character_select_sequence_state = 1
end

function update_character_select(_input, _do_fast_forward)

  if not character_select_sequence_state == 0 then
    return
  end

  -- Infinite select time
  --memory.writebyte(addresses.global.character_select_timer, 0x30)

  if (character_select_coroutine ~= nil) then
    make_input_empty(_input)
    local _status = coroutine.status(character_select_coroutine)
    if _status == "suspended" then
      local _r, _error = coroutine.resume(character_select_coroutine, _input)
      if not _r then
        print(_error)
      end
    elseif _status == "dead" then
      character_select_coroutine = nil
    end
    return
  end

  local _p1_character_select_state = gamestate.get_character_select_state(1)
  local _p2_character_select_state = gamestate.get_character_select_state(2)

  --print(string.format("%d, %d, %d", character_select_sequence_state, _p1_character_select_state, _p2_character_select_state))

  if _p1_character_select_state > 4 and not gamestate.is_in_match then
    if character_select_sequence_state == 2 then
      character_select_sequence_state = 3
    end
    swap_inputs(_input)
  end

  -- wait for all inputs to be released
  if character_select_sequence_state == 1 or character_select_sequence_state == 3 then
    for _key, _state in pairs(_input) do
      if _state == true then
        make_input_empty(_input)
        return
      end
    end
    character_select_sequence_state = character_select_sequence_state + 1
  end

  if has_match_just_started then
    emu.speedmode("normal")
    character_select_sequence_state = 0
  elseif not gamestate.is_in_match then
    if _do_fast_forward and _p1_character_select_state > 4 and _p2_character_select_state > 4 then
      emu.speedmode("turbo")
    elseif character_select_sequence_state == 0 and (_p1_character_select_state < 5 or _p2_character_select_state < 5) then
      emu.speedmode("normal")
      character_select_sequence_state = 1
    end
  else
    character_select_sequence_state = 0
  end

end

function draw_character_select()
  local _p1_character_select_state = gamestate.get_character_select_state(1)
  local _p2_character_select_state = gamestate.get_character_select_state(2)

  if _p1_character_select_state <= 2 or _p2_character_select_state <= 2 then
    gui.text(10, 10, "Alt+1 -> Return To Character Select Screen", text_default_color, text_default_border_color)
    if rom_name == "sfiii3nr1" then
      gui.text(10, 20, "Alt+2 -> Gill", text_default_color, text_default_border_color)
      gui.text(10, 30, "Alt+3 -> Shin Gouki", text_default_color, text_default_border_color)
    end
  end
end
