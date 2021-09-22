supported_roms = {
  sfiii3nr1 = {
    name = "Street Fighter III 3rd Strike (Japan 990512)",
    is_4rd_strike = false,
    functions = {
      read_game_vars = function ()
        -- frame number
        gamestate.frame_number = memory.readdword(0x02007F00)

        -- is in match
        -- I believe the bytes that are expected to be 0xff means that a character has been locked, while the byte expected to be 0x02 is the current match state. 0x02 means that round has started and players can move
        local p1_locked = memory.readbyte(0x020154C6);
        local p2_locked = memory.readbyte(0x020154C8);
        local match_state = memory.readbyte(0x020154A7);
        local _previous_is_in_match = gamestate.is_in_match
        if _previous_is_in_match == nil then _previous_is_in_match = true end
        gamestate.is_in_match = ((p1_locked == 0xFF or p2_locked == 0xFF) and match_state == 0x02);
        has_match_just_started = not _previous_is_in_match and gamestate.is_in_match
      end,
    }
  },
  sfiii4n = {
    name = "Street Fighter III 3rd Strike - 4rd Arrange Edition 2013 (990608)",
    is_4rd_strike = true,
  },
  ssf2xjr1 = {
    name = "Super Street Fighter II X - Grand Master Challenge (Japan 940223)",
    is_4rd_strike = false,
    functions = {
      read_game_vars = function ()
        -- frame number
        gamestate.frame_number = memory.readdword(0x02007F00) -- FIXME

        -- is in match
        local _previous_is_in_match = gamestate.is_in_match
        if _previous_is_in_match == nil then _previous_is_in_match = true end
        gamestate.is_in_match = (memory.readword(0xFF847F) ~= 0)
        has_match_just_started = not _previous_is_in_match and gamestate.is_in_match
        --~ print(gamestate.frame_number .. " " .. tostring(_previous_is_in_match) .. " " .. tostring(gamestate.is_in_match))
        --~ TODO:
        --~ Voir quand ya besoin ou pas que gamestate.is_in_match soit true
      end,
    }
  },
}

supported_roms["sfiii4n"]["functions"] = supported_roms["sfiii3nr1"]["functions"]
