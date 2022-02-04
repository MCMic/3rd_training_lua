function shuffleTable (list)
  for i = #list, 2, -1 do
    local j = math.random(i)
    list[i], list[j] = list[j], list[i]
  end
end

function setupAttackStep(self)
  savestate.load(savestate.create("data/"..rom_name.."/savestates/ehonda_"..self.attacks[self.current].p2..".fs"))
  memory.writebyte(addresses.players[2].gauge_addr, gamestate.player_objects[2].max_meter_gauge)
  self.attack_started = false
  self.wait = math.random(100,200)
  for i = 1,2 do
    if (self.attacks[self.current].pos[i] ~= nil) then
      local _pos = 0
      if (type(self.attacks[self.current].pos[i]) == "table") then
        _pos = math.random(self.attacks[self.current].pos[i][1], self.attacks[self.current].pos[i][2])
      else
        _pos = self.attacks[self.current].pos[i]
      end
      memory.writeword(addresses.players[i].pos_x, _pos)
      print(i.." ".._pos)
    end
  end
end

function nextAttackStep(self)
  self.current = self.current + 1
  if (self.current <= #self.attacks) then
    setupAttackStep(self)
  else
    self.won = true
  end
end

function missionAttacks(_rule, _attacks, _id)
  mission = Mission:new({
    id = _id,
    rule = _rule,
    attacks = _attacks,
    init = function (self)
      Mission.init(self)
      shuffleTable(self.attacks)
      self.current = nil
      self.next = false
    end,
    formatHelp = function (self)
      if ((self.current ~= nil) and (self.current <= #self.attacks)) then
        return string.format("%s (%d/%d): %s", self.rule, self.current, #self.attacks, self.attacks[self.current].help)
      else
        return nil
      end
    end,
    logic = function (self, _input)
      if (not self.current) then
        self.current = 1
        setupAttackStep(self)
      end
      if (not gamestate.is_in_match) then
        return
      end
      if (self.wait > 0) then
        if (((gamestate.player_objects[1].posture == 0xA) or (gamestate.player_objects[1].posture == 0xC)) and (math.abs(gamestate.player_objects[2].pos_x - gamestate.player_objects[1].pos_x) < 150)) then
          -- If P1 is close and attacking, block
          _input[gamestate.player_objects[2].prefix.." "..sequence_input_to_key("back", gamestate.player_objects[2].flip_input)] = true
        end
        self.wait = self.wait - 1
        return
      end
      if (self.next) then
        nextAttackStep(self)
        self.next = false
        return
      end
      if (self.attack_started and gamestate.player_objects[2].posture ~= 0xC) then
        if ((gamestate.player_objects[2].posture == 0xE) or (gamestate.player_objects[2].posture == 0x14)) then
          -- If player is hit or thrown, count a punish
          self.next = true
          self.wait = 50
          return
        else
          print(gamestate.player_objects[2].posture)
          self.lost = true
          self.wait = 50
          _input[gamestate.player_objects[2].prefix.." "..sequence_input_to_key("back", gamestate.player_objects[2].flip_input)] = true
        end
      end
      if (not self.attack_started) then
        if ((gamestate.player_objects[2].posture == 0xE) or (gamestate.player_objects[2].posture == 0x14)) then
          -- Too soon!
          self.lost = true
          self.wait = 50
          self.help = "Do not attack before the super!"
        end
        local _specials = character_specific[gamestate.player_objects[2].char_str].specials
        local _variation = 1
        local _special = #_specials
        if (self.attacks[self.current].variations ~= nil) then
          _variation = self.attacks[self.current].variations[math.random(1,#self.attacks[self.current].variations)]
        end
        if (self.attacks[self.current].special ~= nil) then
          _special = self.attacks[self.current].special
        end
        do_special_move(_input, gamestate.player_objects[2], _specials[_special], _variation)
        self.attack_started = true
        self.wait = 2 -- wait 2 starting frames
      end
    end,
    getScore = function(self)
      return self.current - 1
    end
  })
  mission:init()
end
