
character_specific.ken.specials = {
  {
    name = "Shoryuken",
    memory_map = {
      {0x98, 0x04}
    },
    input = { {"forward"}, {"down"}, {"down", "forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}

character_specific.guile.specials = {
  {
    name = "Sonic Boom",
    memory_map = {
      {0x80, 0x06}
    },
    input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}

function do_special_move (_input, _player_obj, _special, _variation)
  for i, byte in pairs(_special.memory_map) do
    memory.writebyte(_player_obj.base + byte[1], byte[2])
  end

  -- Cancel all input
  clear_player_input(_input, _player_obj.id, false)

  for i, _move in pairs(_special.input[#_special.input]) do
    _input[_player_obj.prefix .. " " .. sequence_input_to_key(_move, _player_obj.flip_input)] = true
  end

  for i, _move in pairs(_special.input_variations[_variation]) do
    _input[_player_obj.prefix .. " " .. sequence_input_to_key(_move, _player_obj.flip_input)] = true
  end
end
