pose = {
  "normal",
  "crouching",
  "jumping",
}
if rom.highjump then
  table.insert(pose, "highjumping")
end

stick_gesture = {
  "none",
  "QCF",
  "QCB",
  "HCF",
  "HCB",
  "DPF",
  "DPB",
  "HCharge",
  "VCharge",
  "360",
  "DQCF",
  "720",
  "forward",
  "back",
  "down",
  "jump",
  "super jump",
  "forward jump",
  "forward super jump",
  "back jump",
  "back super jump",
  "back dash",
  "forward dash",
  "guard jump (See Readme)",
  --"guard back jump",
  --"guard forward jump",
  "Shun Goku Satsu", -- Gouki hidden SA1
  "Kongou Kokuretsu Zan", -- Gouki hidden SA2
}
if rom.is_4rd_strike then
  table.insert(stick_gesture, "Demon Armageddon") -- Gouki SA3
end

button_gesture =
{
  "none",
  "recording",
  "LP",
  "MP",
  "HP",
  "EXP",
  "LK",
  "MK",
  "HK",
  "EXK",
  "LP+LK",
  "MP+MK",
  "HP+HK",
}

fast_wakeup_mode =
{
  "never",
  "always",
  "random",
}

blocking_style =
{
  "block",
}
if (rom.parry) then
  table.insert(blocking_style, "parry")
  table.insert(blocking_style, "red parry")
end

blocking_mode =
{
  "never",
  "always",
  "first hit",
  "random",
}

tech_throws_mode =
{
  "never",
  "always",
  "random",
}

hit_type =
{
  "normal",
  "low",
  "overhead",
}

life_mode =
{
  "no refill",
  "refill",
  "infinite"
}

meter_mode =
{
  "no refill",
  "refill",
  "infinite"
}

stun_mode =
{
  "normal",
  "no stun",
  "delayed reset"
}

standing_state =
{
  "knockeddown",
  "standing",
  "crouched",
  "airborne",
}

players = {
  "Player 1",
  "Player 2",
}

special_training_mode = {
  "none",
  "charge",
}
if (rom.parry) then
  table.insert(special_training_mode, 2, "parry")
end

life_refill_delay_item = integer_menu_item("Life refill delay", training_settings, "life_refill_delay", 1, 100, false, 20)
life_refill_delay_item.is_disabled = function()
  return training_settings.life_mode ~= 2
end

p1_stun_reset_value_gauge_item = gauge_menu_item("P1 Stun reset value", training_settings, "p1_stun_reset_value", 64, 0xFF0000FF)
p2_stun_reset_value_gauge_item = gauge_menu_item("P2 Stun reset value", training_settings, "p2_stun_reset_value", 64, 0xFF0000FF)
p1_stun_reset_value_gauge_item.unit = 1
p2_stun_reset_value_gauge_item.unit = 1
stun_reset_delay_item = integer_menu_item("Stun reset delay", training_settings, "stun_reset_delay", 1, 100, false, 20)
p1_stun_reset_value_gauge_item.is_disabled = function()
  return training_settings.stun_mode ~= 3
end
p2_stun_reset_value_gauge_item.is_disabled = p1_stun_reset_value_gauge_item.is_disabled
stun_reset_delay_item.is_disabled = p1_stun_reset_value_gauge_item.is_disabled

p1_meter_gauge_item = gauge_menu_item("P1 Meter", training_settings, "p1_meter", 2, 0x0000FFFF)
p2_meter_gauge_item = gauge_menu_item("P2 Meter", training_settings, "p2_meter", 2, 0x0000FFFF)
meter_refill_delay_item = integer_menu_item("Meter refill delay", training_settings, "meter_refill_delay", 1, 100, false, 20)

p1_meter_gauge_item.is_disabled = function()
  return training_settings.meter_mode ~= 2
end
p2_meter_gauge_item.is_disabled = p1_meter_gauge_item.is_disabled
meter_refill_delay_item.is_disabled = p1_meter_gauge_item.is_disabled

slot_weight_item = integer_menu_item("Weight", nil, "weight", 0, 100, false, 1)
counter_attack_delay_item = integer_menu_item("Counter-attack delay", nil, "delay", -40, 40, false, 0)
counter_attack_random_deviation_item = integer_menu_item("Counter-attack max random deviation", nil, "random_deviation", -600, 600, false, 0, 1)

parry_forward_on_item = checkbox_menu_item("Forward Parry Helper", training_settings, "special_training_parry_forward_on")
parry_forward_on_item.is_disabled = function() return training_settings.special_training_current_mode ~= 2 end
parry_down_on_item = checkbox_menu_item("Down Parry Helper", training_settings, "special_training_parry_down_on")
parry_down_on_item.is_disabled = parry_forward_on_item.is_disabled
parry_air_on_item = checkbox_menu_item("Air Parry Helper", training_settings, "special_training_parry_air_on")
parry_air_on_item.is_disabled = parry_forward_on_item.is_disabled
parry_antiair_on_item = checkbox_menu_item("Anti-Air Parry Helper", training_settings, "special_training_parry_antiair_on")
parry_antiair_on_item.is_disabled = parry_forward_on_item.is_disabled

charge_overcharge_on_item = checkbox_menu_item("Display Overcharge", training_settings, "special_training_charge_overcharge_on")
charge_overcharge_on_item.is_disabled = function() return training_settings.special_training_current_mode ~= 3 end

hits_before_red_parry_item = integer_menu_item("Hits before Red Parry", training_settings, "red_parry_hit_count", 1, 20, true)
hits_before_red_parry_item.is_disabled = function()
  return training_settings.blocking_style ~= 3
end

display_p2_input_history_item = checkbox_menu_item("Display P2 Input History", training_settings, "display_p2_input_history")
display_p2_input_history_item.is_disabled = function() return training_settings.display_p1_input_history_dynamic end

change_characters_item = button_menu_item("Select Characters", start_character_select_sequence)
change_characters_item.is_disabled = function()
  -- not implemented for 4rd strike yet
  return rom_name ~= "sfiii3nr1"
end

blocking_style_item = list_menu_item("Blocking Style", training_settings, "blocking_style", blocking_style)
blocking_style_item.is_disabled = function()
  return #blocking_style <= 1
end
fastwakeup_item = list_menu_item("Fast Wake Up", training_settings, "fast_wakeup_mode", fast_wakeup_mode)
fastwakeup_item.is_disabled = function()
  return not rom.fastwakeup
end

main_menu = make_multitab_menu(
  23, 15, 360, 195, -- screen size 383,223
  {
    {
      name = "Dummy",
      entries = {
        list_menu_item("Pose", training_settings, "pose", pose),
        blocking_style_item,
        hits_before_red_parry_item,
        list_menu_item("Blocking", training_settings, "blocking_mode", blocking_mode),
        list_menu_item("Tech Throws", training_settings, "tech_throws_mode", tech_throws_mode),
        list_menu_item("Counter-Attack Move", training_settings, "counter_attack_stick", stick_gesture),
        list_menu_item("Counter-Attack Action", training_settings, "counter_attack_button", button_gesture),
        fastwakeup_item,
      }
    },
    {
      name = "Recording",
      entries = {
        checkbox_menu_item("Auto Crop First Frames", training_settings, "auto_crop_recording_start"),
        checkbox_menu_item("Auto Crop Last Frames", training_settings, "auto_crop_recording_end"),
        list_menu_item("Replay Mode", training_settings, "replay_mode", slot_replay_mode),
        list_menu_item("Slot", training_settings, "current_recording_slot", recording_slots_names),
        slot_weight_item,
        counter_attack_delay_item,
        counter_attack_random_deviation_item,
        button_menu_item("Clear slot", clear_slot),
        button_menu_item("Clear all slots", clear_all_slots),
        button_menu_item("Save slot to file", open_save_popup),
        button_menu_item("Load slot from file", open_load_popup),
      }
    },
    {
      name = "Display",
      entries = {
        checkbox_menu_item("Display Controllers", training_settings, "display_input"),
        checkbox_menu_item("Display Gauges Numbers", training_settings, "display_gauges"),
        checkbox_menu_item("Display P1 Input History", training_settings, "display_p1_input_history"),
        checkbox_menu_item("Dynamic P1 Input History", training_settings, "display_p1_input_history_dynamic"),
        display_p2_input_history_item,
        checkbox_menu_item("Display Frame Advantage", training_settings, "display_frame_advantage"),
        checkbox_menu_item("Display Hitboxes", training_settings, "display_hitboxes"),
      }
    },
    {
      name = "Rules",
      entries = {
        change_characters_item,
        checkbox_menu_item("Infinite Time", training_settings, "infinite_time"),
        list_menu_item("Life Refill Mode", training_settings, "life_mode", life_mode),
        life_refill_delay_item,
        list_menu_item("Stun Mode", training_settings, "stun_mode", stun_mode),
        p1_stun_reset_value_gauge_item,
        p2_stun_reset_value_gauge_item,
        stun_reset_delay_item,
        list_menu_item("Meter Refill Mode", training_settings, "meter_mode", meter_mode),
        p1_meter_gauge_item,
        p2_meter_gauge_item,
        meter_refill_delay_item,
        checkbox_menu_item("Infinite Super Art Time", training_settings, "infinite_sa_time"),
        integer_menu_item("Music Volume", training_settings, "music_volume", 0, 10, false, 10),
        checkbox_menu_item("Speed Up Game Intro", training_settings, "fast_forward_intro"),
      }
    },
    {
      name = "Special Training",
      entries = {
        list_menu_item("Mode", training_settings, "special_training_current_mode", special_training_mode),
        checkbox_menu_item("Follow Character", training_settings, "special_training_follow_character"),
        parry_forward_on_item,
        parry_down_on_item,
        parry_air_on_item,
        parry_antiair_on_item,
        charge_overcharge_on_item
      }
    },
  },
  function ()
    save_training_data()
  end,
  function(_menu)
    -- recording slots special display
    if _menu.main_menu_selected_index == 2 then
      local _t = string.format("%d frames", #recording_slots[training_settings.current_recording_slot].inputs)
      gui.text(_menu.left + 83, _menu.top + 23 + 3 * menu_y_interval, _t, text_disabled_color, text_default_border_color)
    end
  end
)

debug_move_menu_item = map_menu_item("Debug Move", debug_settings, "debug_move", frame_data, nil)
if developer_mode then
  local _debug_settings_menu = {
    name = "Debug",
    entries = {
      checkbox_menu_item("Show Predicted Hitboxes", debug_settings, "show_predicted_hitbox"),
      checkbox_menu_item("Record Frame Data", debug_settings, "record_framedata"),
      checkbox_menu_item("Record Idle Frame Data", debug_settings, "record_idle_framedata"),
      checkbox_menu_item("Record Wake-Up Data", debug_settings, "record_wakeupdata"),
      button_menu_item("Save Frame Data", save_frame_data),
      map_menu_item("Debug Character", debug_settings, "debug_character", _G, "frame_data"),
      debug_move_menu_item
    }
  }
  table.insert(main_menu.content, _debug_settings_menu)
end
