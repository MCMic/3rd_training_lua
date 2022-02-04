
  -- positions should be a bit random
  -- wait should be random
  -- feintes?
  -- implémenter lifeloss
  -- refuser les coups avant super, ou saut avant freeze

  -- punish ken super (2 distances, one where he stays on front, one where not
  -- avoid claw super?
local supers = {
  --~ {
    --~ p2 = "boxer", This one needs honda in the corner
    --~ pos = {
      --~ 312,
      --~ {500,600},
    --~ },
    --~ help = "Oicho in the gap",
    --~ lifeloss = true,
  --~ },
  {
    p2 = "blanka", -- todo garder un temps aléatoire lp enfoncé
    pos = {
      --~ 312,
      --~ {400,600},
    },
    help = "Oicho when he's close",
    lifeloss = false,
  },
  {
    p2 = "boxer",
    pos = {
      --~ 312,
      --~ {400,500},
    },
    help = "Sumopress MK after the freeze, or Dosukoi LP after first hit whiff",
    lifeloss = false,
  },
  {
    p2 = "chunli",
    pos = {},
    help = "Sumopress MK after the freeze",
    lifeloss = false,
  },
  {
    p2 = "dhalsim",
    pos = {
      --~ 312,
      --~ {500,600},
    },
    help = "Walk back out of range, Dosukoi HP after the super",
    lifeloss = false,
  },
  {
    p2 = "ehonda",
    pos = {
      --~ 312,
      --~ {500,600},
    },
    help = "Dosukoi LP after first hit",
    lifeloss = true,
  },
  {
    p2 = "deejay", -- TODO setup un deuxième où il faut dosukoi dans le trou
    pos = {},
    help = "Sumopress MK or Dosukoi LP after the freeze",
    lifeloss = false,
  },
  {
    p2 = "ryu",
    pos = {},
    help = "Sumopress MK after the freeze",
    lifeloss = false,
  },
  {
    p2 = "feilong",
    pos = {},
    help = "Sumopress MK after the freeze, Oicho from the other side",
    lifeloss = false,
  },
  {
    p2 = "dictator",
    pos = {},
    help = "Jump back MK",
    lifeloss = false,
  },
  {
    p2 = "guile",
    pos = {},
    help = "Dosukoi HP or Hands",
    lifeloss = true,
  },
  {
    p2 = "cammy",
    pos = {},
    help = "Dosukoi HP or Hands",
    lifeloss = true,
  },
  {
    p2 = "sagat",
    pos = {},
    help = "Dosukoi HP",
    lifeloss = true,
  },
}

function missionPunishSupers()
  missionAttacks("Punish the super", supers, "supers")
end
