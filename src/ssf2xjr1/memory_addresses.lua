addresses = {
  global = {
    -- [byte][read/write] hex value is the decimal display
    character_select_timer = 0x020154FB,
    frame_number = 0xFF801D,
    screen_x = 0xFF8ED4,
    screen_y = 0xFF8ED8,
    round_timer = 0xFF8DCE,
    turbo = 0xFF8CD3,
    slowdown = 0xFF82F2,
  },
  players = {
    {
      base = 0xFF844E,
      input = 0xFF8086,
    },
    {
      base = 0xFF884E,
      input = 0xFF808A,
    }
  }
}

for i = 1, 2 do
  addresses.players[i].state          = addresses.players[i].base + 0x03  -- byte
  addresses.players[i].substate       = addresses.players[i].base + 0x04  -- byte
  addresses.players[i].pos_x          = addresses.players[i].base + 0x06  -- wordsigned
  addresses.players[i].pos_y          = addresses.players[i].base + 0x0A  -- wordsigned
  addresses.players[i].flip_x         = addresses.players[i].base + 0x12  -- byte
  addresses.players[i].animation_ptr  = addresses.players[i].base + 0x1A  -- dword
  addresses.players[i].hitbox_ptr     = addresses.players[i].base + 0x34  -- dword
  addresses.players[i].life           = addresses.players[i].base + 0x2A  -- word
  addresses.players[i].life_backup    = addresses.players[i].base + 0x2C  -- word
  addresses.players[i].life_hud       = addresses.players[i].base + 0x1BC -- word
  addresses.players[i].stun           = addresses.players[i].base + 0x5F  -- byte
  addresses.players[i].char_select    = addresses.players[i].base + 0x80  -- byte
  addresses.players[i].char           = addresses.players[i].base + 0x391 -- byte
  addresses.players[i].char_old       = addresses.players[i].base + 0x3B6 -- byte
  addresses.players[i].gauge_addr     = addresses.players[i].base + 0x2B4 -- byte
  addresses.players[i].airborn        = addresses.players[i].base + 0x181 -- byte
  addresses.players[i].hitstun_counter  = addresses.players[i].base + 0x11D -- byte
end
  -- 0xFF8008 -> 0 = char select, 10 = ingame, 6/8 = before/between rounds, 4 = intro
  --~ 0xFF8C4F -> stage

