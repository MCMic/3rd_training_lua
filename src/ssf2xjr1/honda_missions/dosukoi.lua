
  -- positions should be a bit random?
  -- feintes?
  -- Seul le dosukoi est autorisé

  -- in tap
  -- in barcelona?
  -- in tatsu?
  -- in superman punch?
  -- in drills?
  -- shoto dragon
  -- chunli dragon

local attacks = {
  {
    p2 = "ehonda",
    pos = {},
    help = "Dosukoi LP",
    special = 1,
    variations = {1,2,3},
  },
  -- TODO: tap
  {
    p2 = "dictator",
    pos = {},
    help = "Dosukoi LP",
    special = 4,
    variations = {1,2,3},
  },
  {
    p2 = "sagat",
    pos = {},
    help = "Dosukoi HP",
    special = 2,
    variations = {1,2,3},
  },
  {
    p2 = "claw",
    pos = {},
    help = "Dosukoi LP",
    special = 3,
    variations = {1,2,3},
  },
  {
    p2 = "feilong",
    pos = {},
    help = "Dosukoi LP",
    special = 3,
    variations = {1},
  },
}

function missionDosukoi()
  missionAttacks("Dosukoi the attack", attacks)
end
