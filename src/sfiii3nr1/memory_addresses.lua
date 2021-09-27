addresses = {
  global = {
    -- [byte][read/write] hex value is the decimal display
    character_select_timer = 0x020154FB,
    frame_number = 0x02007F00,
  },
  players = {
    {
      base = 0x02068C6C,
      -- [byte][read/write] from 0 to 6
      character_select_row = 0x020154CF,

      -- [byte][read/write] from 0 to 2
      character_select_col = 0x0201566B,

      -- [byte][read] from 0 to 2
      character_select_sa = 0x020154D3,

      -- [byte][read] from 0 to 6
      character_select_color = 0x02015683,

        -- [byte][read] from 0 to 5
        -- - 0 is no player
        -- - 1 is intro anim
        -- - 2 is character select
        -- - 3 is SA intro anim
        -- - 4 is SA select
        -- - 5 is locked SA
        -- Will always stay at 5 after that and during the match
      character_select_state = 0x0201553D,

      -- [byte] used to overwrite shin gouki id
      character_select_id = 0x02011387,

      gauge_addr = 0x020695B5
      meter_addr = { 0x020286AB, 0x020695BF } -- 2nd address is the master variable
      stun_max_addr = 0x020695F7
      stun_timer_addr = 0x020695F7 + 0x2
      stun_bar_addr = 0x020695F7 + 0x6
      meter_update_flag = 0x020157C8
      score_addr = 0x020113A2
      parry_forward_validity_time_addr = 0x02026335
      parry_forward_cooldown_time_addr = 0x02025731
      parry_down_validity_time_addr = 0x02026337
      parry_down_cooldown_time_addr = 0x0202574D
      parry_air_validity_time_addr = 0x02026339
      parry_air_cooldown_time_addr = 0x02025769
      parry_antiair_validity_time_addr = 0x02026347
      parry_antiair_cooldown_time_addr = 0x0202582D

      charge_1_reset_addr = 0x02025A47 -- Alex_1(Elbow)
      charge_1_addr = 0x02025A49
      charge_2_reset_addr = 0x02025A2B -- Alex_2(Stomp), Urien_2(Knee?)
      charge_2_addr = 0x02025A2D
      charge_3_reset_addr = 0x02025A0F -- Oro_1(Shou), Remy_2(LoVKick?)
      charge_3_addr = 0x02025A11
      charge_4_reset_addr = 0x020259F3 -- Urien_3(headbutt?), Q_2(DashLeg), Remy_1(LoVPunch?)
      charge_4_addr = 0x020259F5
      charge_5_reset_addr = 0x020259D7 -- Oro_2(Yanma), Urien_1(tackle), Chun_4, Q_1(DashHead), Remy_3(Rising)
      charge_5_addr = 0x020259D9
    },
    {
      base = 0x02069104,
      character_select_row = 0x020154D1,
      character_select_col = 0x0201566D,
      character_select_sa = 0x020154D5,
      character_select_color = 0x02015684,
      character_select_state = 0x02015545,
      character_select_id = 0x02011388

      gauge_addr = 0x020695E1
      meter_addr = { 0x020286DF, 0x020695EB} -- 2nd address is the master variable
      stun_max_addr = 0x0206960B
      stun_timer_addr = 0x0206960B + 0x2
      stun_bar_addr = 0x0206960B + 0x6
      meter_update_flag = 0x020157C9
      score_addr = 0x020113AE

      charge_1_reset_addr = 0x02025FF7
      charge_1_addr = 0x02025FF9
      charge_2_reset_addr = 0x0202602F
      charge_2_addr = 0x02026031
      charge_3_reset_addr = 0x02026013
      charge_3_addr = 0x02026013
      charge_4_reset_addr = 0x0202604B
      charge_4_addr = 0x0202604D
      charge_5_reset_addr = 0x02026067
      charge_5_addr = 0x02026069
    }
  }
}

-- Define player 2 parry addresses relative to player 1
addresses.players[2].parry_forward_validity_time_addr = addresses.players[1].parry_forward_validity_time_addr + 0x406
addresses.players[2].parry_forward_cooldown_time_addr = addresses.players[1].parry_forward_cooldown_time_addr + 0x620
addresses.players[2].parry_down_validity_time_addr    = addresses.players[1].parry_down_validity_time_addr + 0x406
addresses.players[2].parry_down_cooldown_time_addr    = addresses.players[1].parry_down_cooldown_time_addr + 0x620
addresses.players[2].parry_air_validity_time_addr     = addresses.players[1].parry_air_validity_time_addr + 0x406
addresses.players[2].parry_air_cooldown_time_addr     = addresses.players[1].parry_air_cooldown_time_addr + 0x620
addresses.players[2].parry_antiair_validity_time_addr = addresses.players[1].parry_antiair_validity_time_addr + 0x406
addresses.players[2].parry_antiair_cooldown_time_addr = addresses.players[1].parry_antiair_cooldown_time_addr + 0x620
