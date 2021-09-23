
print("2X!")

-- ## read
gamestate.read = function ()
  -- game
  gamestate.read_game_vars()

  -- players
  read_player_vars(gamestate.player_objects[1])
  read_player_vars(gamestate.player_objects[2])

  -- projectiles
  --~ read_projectiles()
  projectiles = projectiles or {}

  if gamestate.is_in_match then
    update_flip_input(gamestate.player_objects[1], gamestate.player_objects[2])
    update_flip_input(gamestate.player_objects[2], gamestate.player_objects[1])
  end

  --~ function update_player_relationships(_self, _other)
    --~ -- Can't do this inside read_player_vars cause we need both players to have read their stuff
    --~ if _self.has_just_started_wake_up or _self.has_just_started_fast_wake_up then
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

function gamestate.is_object_invalid (_obj)
  return (memory.readword(_obj.base) <= 0x0100)
end

gamestate.read_game_object = function (_obj)
  if gamestate.is_object_invalid(_obj) then --invalid objects
    return false
  end

  _obj.friends = 0
  _obj.flip_x = memory.readbyte(_obj.base + 0x12) -- testme
  _obj.previous_pos_x = _obj.pos_x or 0
  _obj.previous_pos_y = _obj.pos_y or 0
  _obj.pos_x = memory.readwordsigned(_obj.base + 0x06)
  _obj.pos_y = memory.readwordsigned(_obj.base + 0x0A)
  _obj.char_id = memory.readword(_obj.base + 0x390)

  _obj.boxes = {}
  local _boxes = {
    --~ {initial = 1, offset = 0x2D4, type = "push", number = 1},
    --~ {initial = 1, offset = 0x2C0, type = "throwable", number = 1},
    --~ {initial = 1, offset = 0x2A0, type = "vulnerability", number = 4},
    --~ {initial = 1, offset = 0x2A8, type = "ext. vulnerability", number = 4},
    --~ {initial = 1, offset = 0x2C8, type = "attack", number = 4},
    --~ {initial = 1, offset = 0x2B8, type = "throw", number = 1}
  }

  for _, _box in ipairs(_boxes) do
    for i = _box.initial, _box.number do
      read_box(_obj, memory.readdword(_obj.base + _box.offset) + (i-1)*8, _box.type)
    end
  end
  return true
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
