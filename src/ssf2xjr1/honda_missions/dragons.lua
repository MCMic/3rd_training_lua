
local function step1Logic(self, _input)
  -- substate 6 est nécessaire mais c’est un peu bourrin
  if (
    (
      gamestate.player_objects[2].is_idle or
      (((gamestate.player_objects[2].substate == 0x06) or (gamestate.player_objects[2].substate == 0x08)) and (gamestate.player_objects[2].posture == 0x0C))
    ) and
    not self.dragon
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
    self.dragon = true
  else
    self.dragon = false
  end
end

local function step2Logic(self, _input)
  if (self.dragon) then
    self.dragon = false
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
    self.dragon = true
  else
    -- input block
    _input[gamestate.player_objects[2].prefix.." "..sequence_input_to_key("back", gamestate.player_objects[2].flip_input)] = true
    -- maybe not needed as we can dragon anything on reaction (but it’s harder to implement)
  end
end

function missionPunishDragons()
  -- first part should be spam
  -- second part random and reaction
  mission = Mission:new({
    id = "dragons",
    init = function (self)
      Mission.init(self)
      self.next = false
      self.punishing = false
      self.punished = 0
      self.dragon = false
      self.step = 1
      savestate.load(savestate.create("data/"..rom_name.."/savestates/honda_oldken.fs"))
    end,
    mainLogic = function (self, _input)
      if (self.next) then
        savestate.load(savestate.create("data/"..rom_name.."/savestates/honda_oldken.fs"))
        self.step = self.step + 1
        self.punished = 0
        self.next = false
        return
      end
      if (self.step == 1) then
        step1Logic(self, _input)
      else
        step2Logic(self, _input)
      end
      if ((gamestate.player_objects[2].posture == 0xE) or (gamestate.player_objects[2].posture == 0x14)) then
        -- If player is hit or thrown, count a punish
        if (not self.punishing) then
          self.punished = self.punished + 1
          self.punishing = true
          if ((self.step >= 2) and (self.punished >= 5)) then
            -- delay before winning screen
            self.wait = 50
            self.won = true
          end
        end
      else
        self.punishing = false
      end
      if ((self.punished >= 5) and (self.step == 1)) then
        self.next = true
        self.wait = 50
        return
      end
      if (gamestate.player_objects[1].life < gamestate.player_objects[1].max_life) then
        -- If you lose life you lose
        self.wait = 50
        self.lost = true
      end
    end,
    formatHelp = function (self)
      return string.format("Punished dragons: %d/5 (step %d/2)", self.punished, self.step)
    end,
    getScore = function(self)
      return (self.step - 1) * 5 + self.punished
    end
  })
  mission:init()
end
