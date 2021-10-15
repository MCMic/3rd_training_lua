
local function step1Logic(_input)
  -- substate 6 est nécessaire mais c’est un peu bourrin
  if (
    (
      gamestate.player_objects[2].is_idle or
      (((gamestate.player_objects[2].substate == 0x06) or (gamestate.player_objects[2].substate == 0x08)) and (gamestate.player_objects[2].posture == 0x0C))
    ) and
    not mission.dragon
  ) then
    -- If player is idle or falling down from previous dragon, input a dragon
    do_special_move (_input, gamestate.player_objects[2], character_specific.ken.specials[2], 1)
    --~ local fake_input = {}
    --~ do_special_move (fake_input, gamestate.player_objects[2], character_specific.ken.specials[2], 1)
    --~ memory.writeword(gamestate.player_objects[2].addresses.base + 0x394, 0x0016)
    --~ memory.writeword(gamestate.player_objects[2].addresses.base + 0x392, 0x0016)
    --~ print(memory.readword(gamestate.player_objects[2].addresses.base + 0x392))
    --~ print(memory.readword(gamestate.player_objects[2].addresses.base + 0x394))
    -- Boolean to avoid inputing dragon again on next frame
    mission.dragon = true
  else
    mission.dragon = false
  end
end

local function step2Logic(_input)
  if (mission.dragon) then
    mission.dragon = false
    return
  end
  local _dragon = false
  local _variation = 1
  if (((gamestate.player_objects[1].posture == 0xA) or (gamestate.player_objects[1].posture == 0xC)) and (math.abs(gamestate.player_objects[2].pos_x - gamestate.player_objects[1].pos_x) < 150)) then
    -- if P1 is attacking, dragon
    _dragon = true
  elseif (gamestate.player_objects[2].is_idle) then
    -- If player is idle, randomly input a dragon
    _dragon = (math.random(1,20) == 2)
    _variation = math.random(1,6)
    -- LP 1/2, MP 1/3, HP 1/6
    if (_variation < 4) then
      _variation = 1
    elseif (_variation < 6) then
      _variation = 2
    else
      _variation = 3
    end
  elseif (((gamestate.player_objects[2].substate == 0x06) or (gamestate.player_objects[2].substate == 0x08)) and (gamestate.player_objects[2].posture == 0x0C)) then
    -- If player is falling down from previous dragon, input a dragon more often
    -- substate 6 est nécessaire mais c’est un peu bourrin
    _dragon = (math.random(1,3) == 2)
  end
  if (_dragon) then
    do_special_move (_input, gamestate.player_objects[2], character_specific.ken.specials[2], _variation)
    mission.dragon = true
  else
    -- input block
    _input[gamestate.player_objects[2].prefix.." "..sequence_input_to_key("back", gamestate.player_objects[2].flip_input)] = true
    -- maybe not needed as we can dragon anything on reaction (but it’s harder to implement)
  end
end

function missionPunishDragons()
  -- first part should be spam
  -- second part random and reaction
  mission = {
    init = function ()
      mission.next = false
      mission.punishing = false
      mission.punished = 0
      mission.dragon = false
      mission.step = 1
      mission.lost = false
      mission.wait = 0
      is_menu_open = false
      menu_stack_clear()
      savestate.load(savestate.create("data/"..rom_name.."/savestates/honda_oldken.fs"))
    end,
    logic = function (_input)
      if (not gamestate.is_in_match) then
        return
      end
      if (mission.wait > 0) then
        mission.wait = mission.wait - 1
        return
      end
      if (mission.next) then
        savestate.load(savestate.create("data/"..rom_name.."/savestates/honda_oldken.fs"))
        mission.step = mission.step + 1
        mission.punished = 0
        mission.next = false
      end
      if (mission.step == 1) then
        step1Logic(_input)
      else
        step2Logic(_input)
      end
      if ((gamestate.player_objects[2].posture == 0xE) or (gamestate.player_objects[2].posture == 0x14)) then
        -- If player is hit or thrown, count a punish
        if (not mission.punishing) then
          mission.punished = mission.punished + 1
          mission.punishing = true
          if (mission.iswon()) then
            -- delay before winning screen
            mission.wait = 50
          end
        end
      else
        mission.punishing = false
      end
      if ((mission.punished >= 5) and (mission.step == 1)) then
        mission.next = true
        mission.wait = 50
        return
      end
      if (gamestate.player_objects[1].life < gamestate.player_objects[1].max_life) then
        -- If you lose life you lose
        mission.wait = 50
        mission.lost = true
      end
    end,
    ongui = function ()
      local _help = string.format("Punished dragons: %d/5 (step %d/2)", mission.punished, mission.step)
      gui.box(1, 1, string.len(_help) * 4.1 + 2, 15, gui_box_bg_color, gui_box_outline_color)
      gui.text(5, 5, _help)
    end,
    islost = function ()
      if (not gamestate.is_in_match) then
        return false
      end
      if (mission.wait > 0) then
        return false
      end
      return mission.lost
    end,
    iswon = function ()
      if (not gamestate.is_in_match) then
        return false
      end
      if (mission.wait > 0) then
        return false
      end
      return ((mission.step >= 2) and (mission.punished >= 5))
    end,
  }
  mission.init()
end
