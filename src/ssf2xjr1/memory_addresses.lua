addresses = {
  global = {
    -- [byte][read/write] hex value is the decimal display
    character_select_timer = 0x020154FB,
    frame_number = 0xFF801D,
    screen_x = 0xFF8ED4,
    screen_y = 0xFF8ED8,
    round_timer = 0xFF8DCE,
  },
  players = {
    {
      base = 0xFF844E,
      -- [byte][read/write] from 0 to 6
      character_select_row = 0x020154CF,

      -- [byte][read/write] from 0 to 2
      character_select_col = 0x0201566B,

      -- [byte] used to overwrite shin gouki id
      character_select_id = 0x02011387,
    },
    {
      base = 0xFF884E,
      character_select_row = 0x020154D1,
      character_select_col = 0x0201566D,
      character_select_id = 0x02011388
    }
  }
}

for i = 1, 2 do
  addresses.players[i].pos_x          = addresses.players[i].base + 0x06  -- wordsigned
  addresses.players[i].pos_y          = addresses.players[i].base + 0x0A  -- wordsigned
  addresses.players[i].flip_x         = addresses.players[i].base + 0x12  -- byte
  addresses.players[i].animation_ptr  = addresses.players[i].base + 0x1A  -- word
  addresses.players[i].hitbox_ptr     = addresses.players[i].base + 0x34  -- word
  addresses.players[i].char_select    = addresses.players[i].base + 0x80  -- byte
  addresses.players[i].char           = addresses.players[i].base + 0x390 -- word
  addresses.players[i].char_old       = addresses.players[i].base + 0x3B6 -- byte
end
  -- 0xFF8008 -> 0 = char select, 10 = ingame, 6/8 = before/between rounds, 4 = intro
  --~ 0xFF8C4F -> stage

