require("src/roms")

script_version = "v0.10 dev"
fc_version = "v2.0.97.44"
saved_path = "saved/"
rom_name = emu.romname()

if supported_roms[rom_name] ~= nil then
  rom = supported_roms[rom_name]
else
  print("-----------------------------")
  print("WARNING: You are not using a rom supported by this script. Some of the features might not be working correctly.")
  print("-----------------------------")
  rom_name = "sfiii3nr1"
end
