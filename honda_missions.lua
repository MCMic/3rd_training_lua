require("src/startup")

print("-----------------------------")
print("  3rd_training.lua - "..script_version.."")
print("  Training mode for "..rom.name.."")
print("  Last tested Fightcade version: "..fc_version.."")
print("  project url: https://github.com/Grouflon/3rd_training_lua")
print("-----------------------------")
print("")
print("Command List:")
print("- Enter training menu by pressing \"Start\" while in game")
print("- Enter/exit recording mode by double tapping \"Coin\"")
print("- In recording mode, press \"Coin\" again to start/stop recording")
print("- In normal mode, press \"Coin\" to start/stop replay")
print("- Lua Hotkey 1 (alt+1) to return to character select screen")
print("")

-- Includes
require("src/tools")
require("src/display")
require("src/menu_widgets")
require("src/framedata")
require("src/gamestate")
require("src/frame_advantage")
require("src/character_select")
require("src/input")
require("src/ssf2xjr1/honda_missions/common")
require("src/ssf2xjr1/honda_missions/dragons")
require("src/ssf2xjr1/honda_missions/supers")
require("src/ssf2xjr1/honda_missions/dosukoi")

training_settings = {
}

debug_settings = {
  show_predicted_hitbox = false,
  record_framedata = false,
  record_idle_framedata = false,
  record_wakeupdata = false,
  debug_character = "",
  debug_move = "",
}

mission_scores = {}
mission_scores_file = 'honda_missions.json'

-- save/load
function save_mission_scores()
  if not write_object_to_json_file(mission_scores, saved_path..mission_scores_file) then
    print(string.format("Error: Failed to save mission scores to \"%s\"", saved_path..mission_scores_file))
  end
end

function load_mission_scores()
  mission_scores = read_object_from_json_file(saved_path..mission_scores_file)
  if (mission_scores == nil) then
    mission_scores = {}
  end
end

-- GUI DECLARATION

main_menu = make_menu(
  50, 50, 383 - 50, 223 - 50, -- screen size 383,223
  {
    button_menu_item("Punish the dragons", missionPunishDragons),
    button_menu_item("Punish the supers", missionPunishSupers),
    button_menu_item("Dosukoi the reckless", missionDosukoi),
    -- also mission to go forward in lots of projectiles with neutral jump + bulldog
  }
)

function retryMission()
  mission = previous_mission
  mission.init()
end

function openMainMenu()
  is_menu_open = true
  menu_stack_clear()
  menu_stack_push(main_menu)
end

lost_menu = make_menu(
  --~ 23, 15, 360, 195, -- screen size 383,223
  40, 170, 383 - 40, 223 - 10, -- screen size 383,223
  {
    button_menu_item("Retry mission", retryMission),
    button_menu_item("Back to menu", openMainMenu),
  }
)

win_menu = make_menu(
  40, 170, 383 - 40, 223 - 10, -- screen size 383,223
  {
    button_menu_item("Back to menu", openMainMenu),
  }
)

-- PROGRAM

function on_load_state()
  gamestate.reset_player_objects()
  frame_advantage_reset()

  gamestate.read()

  clear_printed_geometry()
  emu.speedmode("normal")
end

function on_start()
  load_frame_data()
  emu.speedmode("normal")

  --~ savestate.load(savestate.create("data/"..rom_name.."/savestates/honda_mission1.fs"))
  is_menu_open = true
  menu_stack_push(main_menu)
  --~ missionPunishSupers()

  --~ if not developer_mode then
    --~ start_character_select_sequence()
  --~ end
end

input.registerhotkey(1, hotkey1)

function before_frame()
  gamestate.read_screen_information()

  -- gamestate
  gamestate.read()

  local _write_game_vars_settings =
  {
    freeze = is_menu_open,
    infinite_time = false,
    music_volume = training_settings.music_volume,
  }
  gamestate.write_game_vars(_write_game_vars_settings)

  write_player_vars(gamestate.player_objects[1])
  write_player_vars(gamestate.player_objects[2])

  -- input
  local _input = joypad.get()
  if gamestate.is_in_match and not is_menu_open and swap_characters then
    swap_inputs(_input)
  end

  if not swap_characters then
    player = gamestate.player_objects[1]
    dummy = gamestate.player_objects[2]
  else
    player = gamestate.player_objects[2]
    dummy = gamestate.player_objects[1]
  end

  -- frame advantage
  frame_advantage_update(player, dummy)

  process_pending_input_sequence(gamestate.player_objects[1], _input)
  process_pending_input_sequence(gamestate.player_objects[2], _input)

  if gamestate.is_in_match then
  else
    frame_advantage_reset()
  end

  -- character select
  --~ update_character_select(_input, training_settings.fast_forward_intro)

  previous_input = _input

  if (mission ~= nil) then
      --~ print(memory.readwordsigned(addresses.players[1].pos_x))
      --~ print(memory.readwordsigned(addresses.players[2].pos_x))
    if mission.iswon() then
      -- TODO enregistrer les missions gagnées
      -- TODO afficher dans le menu les missions gagnées
      print("You won")
      previous_mission = mission -- ?
      mission = nil
      savestate.load(savestate.create("data/"..rom_name.."/savestates/ehonda_won.fs"))
      is_menu_open = true
      menu_stack_push(win_menu)
    elseif mission.islost() then
      previous_mission = mission
      mission = nil
      print("You lost")
      savestate.load(savestate.create("data/"..rom_name.."/savestates/ehonda_lost.fs"))
      is_menu_open = true
      menu_stack_push(lost_menu)
    else
      mission.logic(_input)
    end
  end

  joypad.set(_input)

  update_framedata_recording(gamestate.player_objects[1], projectiles)
  update_idle_framedata_recording(gamestate.player_objects[2])
  update_projectiles_recording(projectiles)
  update_wakeupdata_recording(player, dummy)

  log_update()
end

is_menu_open = false

function on_gui()

  if gamestate.P1.input.pressed.start then
    clear_printed_geometry()
  end

  draw_character_select()

  if gamestate.is_in_match then

    display_draw_printed_geometry()

    -- hitboxes
    --~ if training_settings.display_hitboxes then
      --~ display_draw_hitboxes()
    --~ end

    -- input history
    --~ if training_settings.display_p1_input_history_dynamic and training_settings.display_p1_input_history then
      --~ if gamestate.player_objects[1].pos_x < 320 then
        --~ input_history_draw(input_history[1], screen_width - rom.inputhistory.x, rom.inputhistory.y, true)
      --~ else
        --~ input_history_draw(input_history[1], rom.inputhistory.x, rom.inputhistory.y, false)
      --~ end
    --~ else
      --~ if training_settings.display_p1_input_history then input_history_draw(input_history[1], rom.inputhistory.x, rom.inputhistory.y, false) end
      --~ if training_settings.display_p2_input_history then input_history_draw(input_history[2], screen_width - rom.inputhistory.x, rom.inputhistory.y, true) end
    --~ end

    --~ for i,_player_obj in pairs(gamestate.player_objects) do
      --~ gui.text(10, 10*_player_obj.id, string.format("%04X %04X",
        --~ memory.readword(_player_obj.addresses.base + 0x392),
        --~ memory.readword(_player_obj.addresses.base + 0x394)
      --~ ), text_default_color, text_default_border_color)
    --~ end
    --~ gui.text(10, 100, string.format("%d %d",
      --~ memory.readword(addresses.global.screen_x),
      --~ memory.readword(addresses.global.screen_y)
    --~ ), text_default_color, text_default_border_color)
  end

  if log_enabled then
    log_draw()
  end

  if gamestate.is_in_match then
    local _should_toggle = gamestate.P1.input.pressed.start
    if log_enabled then
      _should_toggle = gamestate.P1.input.released.start
    end
    _should_toggle = not log_start_locked and _should_toggle

    if _should_toggle then
      is_menu_open = (not is_menu_open)
      if is_menu_open then
        menu_stack_push(main_menu)
      else
        menu_stack_clear()
      end
    end
  else
    --~ is_menu_open = false
    --~ menu_stack_clear()
  end

  if is_menu_open then
    local _horizontal_autofire_rate = 4
    local _vertical_autofire_rate = 4

    local _current_entry = menu_stack_top():current_entry()
    if _current_entry ~= nil and _current_entry.autofire_rate ~= nil then
      _horizontal_autofire_rate = _current_entry.autofire_rate
    end

    local _input =
    {
      down = check_input_down_autofire(gamestate.player_objects[1], "down", _vertical_autofire_rate),
      up = check_input_down_autofire(gamestate.player_objects[1], "up", _vertical_autofire_rate),
      left = check_input_down_autofire(gamestate.player_objects[1], "left", _horizontal_autofire_rate),
      right = check_input_down_autofire(gamestate.player_objects[1], "right", _horizontal_autofire_rate),
      validate = gamestate.P1.input.pressed.LP,
      reset = gamestate.P1.input.pressed.MP,
      cancel = gamestate.P1.input.pressed.LK,
    }

    menu_stack_update(_input)

    menu_stack_draw()
  end

  if (mission ~= nil) then
    mission.ongui()
  end

  gui.box(0,0,0,0,0,0) -- if we don't draw something, what we drawed from last frame won't be cleared
end

-- registers
load_mission_scores()
emu.registerstart(on_start)
emu.registerbefore(before_frame)
gui.register(on_gui)
savestate.registerload(on_load_state)
