function shuffleTable (list)
  for i = #list, 2, -1 do
    local j = math.random(i)
    list[i], list[j] = list[j], list[i]
  end
end

function setupAttackStep(mission)
  savestate.load(savestate.create("data/"..rom_name.."/savestates/ehonda_"..mission.attacks[mission.current].p2..".fs"))
  memory.writebyte(addresses.players[2].gauge_addr, gamestate.player_objects[2].max_meter_gauge)
  mission.attack_started = false
  mission.wait = math.random(100,200)
  for i = 1,2 do
    if (mission.attacks[mission.current].pos[i] ~= nil) then
      local _pos = 0
      if (type(mission.attacks[mission.current].pos[i]) == "table") then
        _pos = math.random(mission.attacks[mission.current].pos[i][1], mission.attacks[mission.current].pos[i][2])
      else
        _pos = mission.attacks[mission.current].pos[i]
      end
      memory.writeword(addresses.players[i].pos_x, _pos)
      print(i.." ".._pos)
    end
  end
end

function nextAttackStep(mission)
  mission.current = mission.current + 1
  if (mission.current <= #mission.attacks) then
    setupAttackStep(mission)
  end
end

function missionAttacks(_rule, _attacks)
  mission = {
    rule = _rule,
    attacks = _attacks,
    init = function ()
      shuffleTable(mission.attacks)
      mission.current = nil
      mission.wait = 0
      mission.lost = false
      is_menu_open = false
      menu_stack_clear()
      mission.next = false
    end,
    logic = function (_input)
      if (not mission.current) then
        mission.current = 1
        setupAttackStep(mission)
      end
      if (not gamestate.is_in_match) then
        return
      end
      if (mission.wait > 0) then
        if (((gamestate.player_objects[1].posture == 0xA) or (gamestate.player_objects[1].posture == 0xC)) and (math.abs(gamestate.player_objects[2].pos_x - gamestate.player_objects[1].pos_x) < 150)) then
          -- If P1 is close and attacking, block
          _input[gamestate.player_objects[2].prefix.." "..sequence_input_to_key("back", gamestate.player_objects[2].flip_input)] = true
        end
        mission.wait = mission.wait - 1
        return
      end
      if (mission.next) then
        nextAttackStep(mission)
        mission.next = false
        return
      end
      if (mission.attack_started and gamestate.player_objects[2].posture ~= 0xC) then
        if ((gamestate.player_objects[2].posture == 0xE) or (gamestate.player_objects[2].posture == 0x14)) then
          -- If player is hit or thrown, count a punish
          mission.next = true
          mission.wait = 50
          return
        else
          print(gamestate.player_objects[2].posture)
          mission.lost = true
          mission.wait = 50
          _input[gamestate.player_objects[2].prefix.." "..sequence_input_to_key("back", gamestate.player_objects[2].flip_input)] = true
        end
      end
      if (not mission.attack_started) then
        if ((gamestate.player_objects[2].posture == 0xE) or (gamestate.player_objects[2].posture == 0x14)) then
          -- Too soon!
          mission.lost = true
          mission.wait = 50
          mission.help = "Do not attack before the super!"
        end
        local _specials = character_specific[gamestate.player_objects[2].char_str].specials
        local _variation = 1
        local _special = #_specials
        if (mission.attacks[mission.current].variations ~= nil) then
          _variation = mission.attacks[mission.current].variations[math.random(1,#mission.attacks[mission.current].variations)]
        end
        if (mission.attacks[mission.current].special ~= nil) then
          _special = mission.attacks[mission.current].special
        end
        do_special_move(_input, gamestate.player_objects[2], _specials[_special], _variation)
        mission.attack_started = true
        mission.wait = 2 -- wait 2 starting frames
      end
    end,
    ongui = function ()
      if ((mission.current ~= nil) and (mission.current <= #mission.attacks)) then
        local _help = string.format("%s (%d/%d): %s", mission.rule, mission.current, #mission.attacks, mission.attacks[mission.current].help)
        gui.box(1, 1, string.len(_help) * 4.1 + 2, 15, gui_box_bg_color, gui_box_outline_color)
        gui.text(5, 5, _help)
      end
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
      return (mission.current ~= nil and mission.current > #mission.attacks)
    end,
  }
  mission.init()
end
