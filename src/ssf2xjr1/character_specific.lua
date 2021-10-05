----------------------------------------------------------------------
---- Pour les persos à charge, peut-être indiquer la position
---- neutre après la charge
----------------------------------------------------------------------
character_specific.blanka.specials = {
  {
    name = "Normal roll",
    memory_map = {
      {0xB9, 0x06}
    },
    input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Vertical Roll",
    memory_map = {
      {0xB0, 0x06} -- Ne fonctionne pas
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Rainbow Roll",
    memory_map = {
      {0xB9, 0x06} -- 0xB9 à vérifier
    },
    input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Electric Thunder",
    memory_map = {
      {} -- A voir.
    },
    input = {},
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Forward Dash",
    memory_map = {
      {} -- A voir.
    },
    input = { {"forward"} },
    input_variations = {{"LK", "MK", "HK"}},
  },
  {
    name = "Backward Dash",
    memory_map = {
      {} -- A voir.
    },
    input = { {"back"} },
    input_variations = {{"LK", "MK", "HK"}},
  },
  {
    name = "Ground Shave Roll",
    memory_map = {
      {0xC1, 0x0A}
    },
    input = { {"back", "h_charge"}, {"forward"}, {"back"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}
----------------------------------------------------------------------------
character_specific.boxer.specials = {
  {
    name = "Ground Straight",
    memory_map = {
      {0x80, 0x06}
    },
    input = { {"back", "h_charge"}, {"forward", "down"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Ground Upper",
    memory_map = {
      {0x86, 0x06}
    },
    input = { {"back", "h_charge"}, {"forward", "down"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Straight",
    memory_map = {
      {0xDD, 0x06}
    },
	input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Upper Dash",
    memory_map = {
      {0xD6, 0x06}
    },
  input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Buffalo Headbutt",
    memory_map = {
      {0xC0, 0x06}
    },
	input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "TAP",
    memory_map = {
      {} -- A voir
    },
	input = {},
    input_variations = {{"LP", "MP", "HP"}},
  },
  {
    name = "Crazy Buffalo", -- Voir comment intégrer les différentes phases de la super ?
    memory_map = {
      {0xD4, 0x0A}
    },
    input = { {"back", "h_charge"}, {"forward"}, {"back"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}, {"LK"}, {"MK"}, {"HK"}},
  }
}
----------------------------------------------------------------------------
character_specific.cammy.specials = {
  {
    name = "Spin Knuckle",
    memory_map = {
      {0xA2, 0x04}
    },
    input = { {"back"}, {"back", "down"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Cannon Spike",
    memory_map = {
      {0x92, 0x04}
    },
    input = { {"forward"}, {"down"}, {"forward", "down"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Spiral Arrow",
    memory_map = {
      {0x96, 0x04}
    },
    input = { {"down"}, {"forward", "down"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Hooligan Combination", -- Compléter pour avoir les deux variations
    memory_map = {
      {0xA9, 0x06}
    },
    input = { {"back"}, {"down"}, {"forward", "down"}, {"up", "forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Spin Drive Smasher",
    memory_map = {
      {0xA6, 0x08}
    },
     input = { {"down"}, {"forward", "down"}, {"forward"}, {"down"}, {"forward", "down"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  }
}
------------------------------------------------------------------------------
character_specific.chunli.specials = {
  {
    name = "Kikouken",
    memory_map = {
      {0x80, 0x06} -- Ne fonctionne pas
    },
  input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Up Kicks",
    memory_map = {
      {0xBA, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Spinning Bird Kick",
    memory_map = {
      {0xB0, 0x06}
    },
  input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Hyakuretsu Kyaku",
    memory_map = {
      {} -- A voir
    },
	input = {},
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Senretsu Kyaku",
    memory_map = {
      {0xBF, 0x0A}
    },
    input = { {"back", "h_charge"}, {"forward"}, {"back"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  }
}
----------------------------------------------------------------------------------
character_specific.claw.specials = {
  {
    name = "Wall Dive (Kick)",
    memory_map = {
      {0x80, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Wall Dive (Punch)",
    memory_map = {
      {0x90, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Crystal Flash",
    memory_map = {
      {0x94, 0x06}
    },
  input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Flip Kick",
    memory_map = {
      {0x9D, 0x06}
    },
    input = { {"down", "back", "h_charge"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Back Flip (Kick)",
    memory_map = {
      {} -- A voir
    },
    input = {},
    input_variations = {{"LK", "MK", "HK"}},
  },
  {
    name = "Back Flip (Punch)",
    memory_map = {
      {} -- A voir
    },
    input = {},
    input_variations = {{"LP", "MP", "HP"}},
  },
  {
    name = "Rolling Izuna Drop",
    memory_map = {
      {0x99, 0x0A}
    },
    input = { {"down", "h_charge"}, {"forward"}, {"back"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  }
}
---------------------------------------------------------------------------------
character_specific.deejay.specials = {
  {
    name = "Air Slasher",
    memory_map = {
      {0x92, 0x06}
    },
	input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Sobat Kick",
    memory_map = {
      {0xA6, 0x06}
    },
	input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Jack Knife",
    memory_map = {
      {0x96, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Machine Gun Upper",
    memory_map = {
      {0xAB, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Sobat Carnival",
    memory_map = {
      {0xAF, 0x0A}
    },
     input = { {"back", "h_charge"}, {"forward"}, {"back"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  }
}
--------------------------------------------------------------------------------
character_specific.dhalsim.specials = {
  {
    name = "Yoga Blast",
    memory_map = {
      {0x84, 0x08}
    },
    input = { {"back"}, {"forward", "down"}, {"down"}, { "forward", "down"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Yoga Flame",
    memory_map = {
      {0x9A, 0x04}
    },
    input = { {"back"}, {"back", "down"}, {"down"}, {"forward", "down"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Yoga Fire",
    memory_map = {
      {0x80, 0x08}
    },
    input = { {"down"}, {"forward", "down"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Yoga Teleport (Forward)",
    memory_map = {
      {0xE0, 0x06} -- Autre valeur à rajouter
    },
   input = { {"forward"}, {"down"}, {"forward", "down"} },
    input_variations = {{"LP", "MP", "HP"},{"LK", "MK", "HK"}},
  },
  {
    name = "Yoga Teleport (Back)",
    memory_map = {
      {0xE0, 0x05} -- Autre valeur à rajouter
    },
   input = { {"back"}, {"down"}, {"back", "down"} },
    input_variations = {{"LP", "MP", "HP"},{"LK", "MK", "HK"}},
  },
  {
    name = "Yoga Inferno",
    memory_map = {
      {0x96, 0x10}
    },
    input = { {"back"},{"back", "down"},{"down"},{"forward", "down"},{"back"},{"back", "down"},{"down"},{"forward", "down"},{"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}
---------------------------------------------------------------------------------------------------
character_specific.dictator.specials = {
  {
    name = "Scissor Kick",
    memory_map = {
      {0x80, 0x06}
    },
	input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Head Stomp", -- Ne fonctionne pas
    memory_map = {
      {0x91, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Devil's Reverse",
    memory_map = {
      {0xAB, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Psycho Crusher",
    memory_map = {
      {0x80, 0x06}
    },
  input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Knee Press Knightmare",
    memory_map = {
      {0xC5, 0x0A}
    },
    input = { {"back", "h_charge"}, {"forward"}, {"back"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  }
}
---------------------------------------------------------------------------------
character_specific.feilong.specials = {
  {
    name = "Rekka",
    memory_map = {
      {0x90, 0x04}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Rekka 2",
    memory_map = {
      {0xA0, 0x04}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Flame Kick",
    memory_map = {
      {0x94, 0x04}
    },
    input = { {"back"}, {"down"}, {"down", "back"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Chicken Wing",
    memory_map = {
      {0xB4, 0x06}
    },
    input = { {"back"}, {"down"}, {"forward", "down"}, {"forward", "up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Rekka Sinken",
    memory_map = {
      {0xB0, 0x0A}
    },
     input = { {"down"}, {"down", "forward"}, {"forward"}, {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}
-------------------------------------------------------------------------------------------
character_specific.guile.specials = {
  {
    name = "Sonic Boom",
    memory_map = {
      {0x80, 0x06}
    },
    input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Flash Kick",
    memory_map = {
      {0x86, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Double Somersault", -- A voir
    memory_map = {
      {0x94, 0x0A}
    },
    input = { {"down", "h_charge"}, {"forward"}, {"back"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  }
}
----------------------------------------------------------------------
character_specific.ehonda.specials = {
  {
    name = "Flying Headbutt",
    memory_map = {
      {0x94, 0x06}
    },
     input = { {"back", "h_charge"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Butt Drop",
    memory_map = {
      {0x90, 0x06}
    },
    input = { {"down", "h_charge"}, {"up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Oichio Throw",
    memory_map = {
      {0x96, 0x06}
    },
    input = { {"forward"}, {"forward", "down"}, {"down"}, {"back"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Hundred Hands Slap",
    memory_map = {
      {} -- A voir
    },
    input = {},
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Double Headbutt",
    memory_map = {
      {0x94, 0x08}
    },
    input = { {"back", "h_charge"}, {"forward"}, {"back"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
  }
-----------------------------------------------------------------------
character_specific.thawk.specials = {
  {
    name = "Mexican Typhoon", -- A voir
    memory_map = {
      {}
    },
    input = { },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Tomahawk",
    memory_map = {
      {0x8D, 0x04}
    },
  input = { {"forward"}, {"down"}, {"down", "forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Double Typhoon", -- A voir
    memory_map = {
      {}
    },
    input = {},
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}
--------------------------------------------------------------------
character_specific.ken.specials = {
  {
    name = "Hadouken",
    memory_map = {
      {0x94, 0x04}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Shoryuken",
    memory_map = {
      {0x98, 0x04}
    },
    input = { {"forward"}, {"down"}, {"down", "forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Hurricane Kick",
    memory_map = {
      {0x90, 0x04}
    },
    input = { {"down"}, {"down", "back"}, {"back"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Crazy Kick 1",
    memory_map = {
      {0xE6, 0x04}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Crazy Kick 2",
    memory_map = {
      {0xE8, 0x04}
    },
    input = { {"forward"}, {"down", "forward"}, {"down"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Crazy Kick 3",
    memory_map = {
      {0xEA, 0x08}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"}, {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Shoryureppa",
    memory_map = {
      {0xA0, 0x08}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"}, {"down"}, {"down", "forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}
----------------------------------------------------------------------
character_specific.ryu.specials = {
  {
    name = "Hadouken",
    memory_map = {
      {0x94, 0x04}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Hurricane Kick",
    memory_map = {
      {0x90, 0x04}
    },
    input = { {"down"}, {"down", "back"}, {"back"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Shoryuken",
    memory_map = {
      {0x98, 0x04}
    },
    input = { {"forward"}, {"down"}, {"down", "forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Red Hadouken",
    memory_map = {
      {0xE0, 0x08}
    },
    input = { {"back"}, {"back", "forward"}, {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Shinku Hadouken",
    memory_map = {
      {0xA0, 0x0A}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"}, {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}
----------------------------------------------------------------------------------------
character_specific.sagat.specials = {
  {
    name = "Tiger Shot",
    memory_map = {
      {0x94, 0x04}
    },
    input = { {"down"}, {"down", "forward"}, {"forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}, {"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Tiger Knee",
    memory_map = {
      {0x84, 0x04}
    },
    input = { {"down"}, {"forward"}, {"forward", "up"} },
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Tiger Uppercut",
    memory_map = {
      {0x80, 0x04}
    },
   input = { {"forward"}, {"down"}, {"down", "forward"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Tiger Genocide",
    memory_map = {
      {0x9E, 0x08}
    },
    input = { {"down"}, {"forward", "down"}, {"forward"}, {"down"}, {"forward", "down"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}, {"LK"}, {"MK"}, {"HK"}},
  }
}
------------------------------------------------------------------------
character_specific.zangief.specials = {
  {
    name = "Bear Grab", -- A voir
    memory_map = {
      {}
    },
    input = {},
    input_variations = {{"LK"}, {"MK"}, {"HK"}},
  },
  {
    name = "Spinning Pile Driver", -- A voir
    memory_map = {
      {}
    },
    input = {},
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Banishing Flat",
    memory_map = {
      {0xB3, 0x0A}
    },
    input = { {"forward"}, {"forward", "down"}, {"down"} },
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  },
  {
    name = "Lariat",
    memory_map = {
      {} -- A voir
    },
    input = {},
    input_variations = {{"LP","MP","HP"}, {"LK","MK","HK"}},
  },
  {
    name = "Final Atomic Buster", -- A voir
    memory_map = {
      {}
    },
    input = {},
    input_variations = {{"LP"}, {"MP"}, {"HP"}},
  }
}
---------------------------------------------------------------------------------

function do_special_move (_input, _player_obj, _special, _variation)
  print(_special.name)
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
