
print("2X!")

-- ## read
gamestate.read = function ()
  -- game
  gamestate.read_game_vars()

  -- players
  --~ read_player_vars(gamestate.player_objects[1])
  --~ read_player_vars(gamestate.player_objects[2])

  --~ -- projectiles
  --~ read_projectiles()

  --~ if gamestate.is_in_match then
    --~ update_flip_input(gamestate.player_objects[1], gamestate.player_objects[2])
    --~ update_flip_input(gamestate.player_objects[2], gamestate.player_objects[1])
  --~ end

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
  gamestate.frame_number = memory.readdword(0x02007F00) -- FIXME

  -- is in match
  local _previous_is_in_match = gamestate.is_in_match
  if _previous_is_in_match == nil then _previous_is_in_match = true end
  gamestate.is_in_match = (memory.readword(0xFF847F) ~= 0)
  has_match_just_started = not _previous_is_in_match and gamestate.is_in_match
end
