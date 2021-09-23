-- # api

screen_width = 383
screen_height = 223

-- push a persistent set of hitboxes to be drawn on the screen each frame
function print_hitboxes(_pos_x, _pos_y, _flip_x, _boxes, _filter, _dilation)
  local _g = {
    type = "hitboxes",
    x = _pos_x,
    y = _pos_y,
    flip_x = _flip_x,
    boxes = _boxes,
    filter = _filter,
    dilation = _dilation
  }
  table.insert(printed_geometry, _g)
end

-- push a persistent point to be drawn on the screen each frame
function print_point(_pos_x, _pos_y, _color)
  local _g = {
    type = "point",
    x = _pos_x,
    y = _pos_y,
    color = _color
  }
  table.insert(printed_geometry, _g)
end

function clear_printed_geometry()
  printed_geometry = {}
end

-- draw a set of hitboxes
function draw_hitboxes(_pos_x, _pos_y, _flip_x, _boxes, _filter, _dilation)
  _dilation = _dilation or 0
  local _px, _py = game_to_screen_space(_pos_x, _pos_y)

  for __, _box in ipairs(_boxes) do
    if _filter == nil or _filter[_box.type] == true then
      local _c = 0x0000FFFF
      if (_box.type == "attack") then
        _c = 0xFF0000FF
      elseif (_box.type == "throwable") then
        _c = 0x00FF00FF
      elseif (_box.type == "throw") then
        _c = 0xFFFF00FF
      elseif (_box.type == "push") then
        _c = 0xFF00FFFF
      elseif (_box.type == "ext. vulnerability") then
        _c = 0x00FFFFFF
      end

      local _l, _r
      if _flip_x == 0 then
        _l = _px + _box.left
      else
        _l = _px - _box.left - _box.width
      end
      local _r = _l + _box.width
      local _b = _py - _box.bottom
      local _t = _b - _box.height

      _l = _l - _dilation
      _r = _r + _dilation
      _b = _b + _dilation
      _t = _t - _dilation

      gui.box(_l, _b, _r, _t, 0x00000000, _c)
    end
  end
end

-- draw a point
function draw_point(_x, _y, _color)
  local _cross_half_size = 4
  local _l = _x - _cross_half_size
  local _r = _x + _cross_half_size
  local _t = _y - _cross_half_size
  local _b = _y + _cross_half_size

  gui.box(_l, _y, _r, _y, 0x00000000, _color)
  gui.box(_x, _t, _x, _b, 0x00000000, _color)
end


require "gd"

img_1_dir_big = gd.createFromPng("images/big/1_dir.png"):gdStr()
img_2_dir_big = gd.createFromPng("images/big/2_dir.png"):gdStr()
img_3_dir_big = gd.createFromPng("images/big/3_dir.png"):gdStr()
img_4_dir_big = gd.createFromPng("images/big/4_dir.png"):gdStr()
img_5_dir_big = gd.createFromPng("images/big/5_dir.png"):gdStr()
img_6_dir_big = gd.createFromPng("images/big/6_dir.png"):gdStr()
img_7_dir_big = gd.createFromPng("images/big/7_dir.png"):gdStr()
img_8_dir_big = gd.createFromPng("images/big/8_dir.png"):gdStr()
img_9_dir_big = gd.createFromPng("images/big/9_dir.png"):gdStr()
img_no_button_big = gd.createFromPng("images/big/no_button.png"):gdStr()
img_L_button_big = gd.createFromPng("images/big/L_button.png"):gdStr()
img_M_button_big = gd.createFromPng("images/big/M_button.png"):gdStr()
img_H_button_big = gd.createFromPng("images/big/H_button.png"):gdStr()
img_dir_big = {
  img_1_dir_big,
  img_2_dir_big,
  img_3_dir_big,
  img_4_dir_big,
  img_5_dir_big,
  img_6_dir_big,
  img_7_dir_big,
  img_8_dir_big,
  img_9_dir_big
}

img_1_dir_small = gd.createFromPng("images/small/1_dir.png"):gdStr()
img_2_dir_small = gd.createFromPng("images/small/2_dir.png"):gdStr()
img_3_dir_small = gd.createFromPng("images/small/3_dir.png"):gdStr()
img_4_dir_small = gd.createFromPng("images/small/4_dir.png"):gdStr()
img_5_dir_small = gd.createFromPng("images/small/5_dir.png"):gdStr()
img_6_dir_small = gd.createFromPng("images/small/6_dir.png"):gdStr()
img_7_dir_small = gd.createFromPng("images/small/7_dir.png"):gdStr()
img_8_dir_small = gd.createFromPng("images/small/8_dir.png"):gdStr()
img_9_dir_small = gd.createFromPng("images/small/9_dir.png"):gdStr()
img_LP_button_small = gd.createFromPng("images/small/LP_button.png"):gdStr()
img_MP_button_small = gd.createFromPng("images/small/MP_button.png"):gdStr()
img_HP_button_small = gd.createFromPng("images/small/HP_button.png"):gdStr()
img_LK_button_small = gd.createFromPng("images/small/LK_button.png"):gdStr()
img_MK_button_small = gd.createFromPng("images/small/MK_button.png"):gdStr()
img_HK_button_small = gd.createFromPng("images/small/HK_button.png"):gdStr()
img_dir_small = {
  img_1_dir_small,
  img_2_dir_small,
  img_3_dir_small,
  img_4_dir_small,
  img_5_dir_small,
  img_6_dir_small,
  img_7_dir_small,
  img_8_dir_small,
  img_9_dir_small
}

-- draw a controller representation
function draw_controller_big(_entry, _x, _y)
  gui.image(_x, _y, img_dir_big[_entry.direction])

  local _img_LP = img_no_button_big
  local _img_MP = img_no_button_big
  local _img_HP = img_no_button_big
  local _img_LK = img_no_button_big
  local _img_MK = img_no_button_big
  local _img_HK = img_no_button_big
  if _entry.buttons[1] then _img_LP = img_L_button_big end
  if _entry.buttons[2] then _img_MP = img_M_button_big end
  if _entry.buttons[3] then _img_HP = img_H_button_big end
  if _entry.buttons[4] then _img_LK = img_L_button_big end
  if _entry.buttons[5] then _img_MK = img_M_button_big end
  if _entry.buttons[6] then _img_HK = img_H_button_big end

  gui.image(_x + 13, _y, _img_LP)
  gui.image(_x + 18, _y, _img_MP)
  gui.image(_x + 23, _y, _img_HP)
  gui.image(_x + 13, _y + 5, _img_LK)
  gui.image(_x + 18, _y + 5, _img_MK)
  gui.image(_x + 23, _y + 5, _img_HK)
end

-- draw a controller representation
function draw_controller_small(_entry, _x, _y, _is_right)
  local _x_offset = 0
  local _sign = 1
  if _is_right then
    _x_offset = _x_offset - 9
    _sign = -1
  end

  gui.image(_x + _x_offset, _y, img_dir_small[_entry.direction])
  _x_offset = _x_offset + _sign * 2


  local _interval = 8
  _x_offset = _x_offset + _sign * _interval

  if _entry.buttons[1] then
    gui.image(_x + _x_offset, _y, img_LP_button_small)
    _x_offset = _x_offset + _sign * _interval
  end

  if _entry.buttons[2] then
    gui.image(_x + _x_offset, _y, img_MP_button_small)
    _x_offset = _x_offset + _sign * _interval
  end

  if _entry.buttons[3] then
    gui.image(_x + _x_offset, _y, img_HP_button_small)
    _x_offset = _x_offset + _sign * _interval
  end

  if _entry.buttons[4] then
    gui.image(_x + _x_offset, _y, img_LK_button_small)
    _x_offset = _x_offset + _sign * _interval
  end

  if _entry.buttons[5] then
    gui.image(_x + _x_offset, _y, img_MK_button_small)
    _x_offset = _x_offset + _sign * _interval
  end

  if _entry.buttons[6] then
    gui.image(_x + _x_offset, _y, img_HK_button_small)
    _x_offset = _x_offset + _sign * _interval
  end

end

-- draw a gauge
function draw_gauge(_x, _y, _width, _height, _fill_ratio, _fill_color, _bg_color, _border_color, _reverse_fill)
  _bg_color = _bg_color or 0x00000000
  _border_color = _border_color or 0xFFFFFFFF
  _reverse_fill = _reverse_fill or false

  _width = _width + 1
  _height = _height + 1

  gui.box(_x, _y, _x + _width, _y + _height, _bg_color, _border_color)
  if _reverse_fill then
    gui.box(_x + _width, _y, _x + _width - _width * clamp01(_fill_ratio), _y + _height, _fill_color, 0x00000000)
  else
    gui.box(_x, _y, _x + _width * clamp01(_fill_ratio), _y + _height, _fill_color, 0x00000000)
  end
end

-- # system
printed_geometry = {}
screen_x = 0
screen_y = 0
scale = 1

function display_draw_printed_geometry()
  -- printed geometry
  for _i, _geometry in ipairs(printed_geometry) do
    if _geometry.type == "hitboxes" then
      draw_hitboxes(_geometry.x, _geometry.y, _geometry.flip_x, _geometry.boxes, _geometry.filter, _geometry.dilation)
    elseif _geometry.type == "point" then
      draw_point(_geometry.x, _geometry.y, _geometry.color)
    end
  end
end

function display_draw_hitboxes()
  -- players
  for _id, _obj in pairs(gamestate.player_objects) do
    draw_hitboxes(_obj.pos_x, _obj.pos_y, _obj.flip_x, _obj.boxes)
  end
  -- projectiles
  for _id, _obj in pairs(projectiles) do
    draw_hitboxes(_obj.pos_x, _obj.pos_y, _obj.flip_x, _obj.boxes)
  end
end


function display_draw_life(_player_object)
  local _x = 0
  local _y = 20

  local _t = string.format("%d/160", _player_object.life)

  if _player_object.id == 1 then
    _x = 13
  elseif _player_object.id == 2 then
    _x = screen_width - 11 - get_text_width(_t)
  end

  gui.text(_x, _y, _t, 0xFFFB63FF)
end


function display_draw_meter(_player_object)
  local _x = 0
  local _y = 214

  local _gauge = _player_object.meter_gauge

  if _player_object.meter_count == _player_object.max_meter_count then
    _gauge = _player_object.max_meter_gauge
  end

  local _t = string.format("%d/%d", _gauge, _player_object.max_meter_gauge)

  if _player_object.id == 1 then
    _x = 53
  elseif _player_object.id == 2 then
    _x = screen_width - 51 - get_text_width(_t)
  end

  gui.text(_x, _y, _t, 0x00FFCEFF, 0x001433FF)
end


function display_draw_stun_gauge(_player_object)
  local _x = 0
  local _y = 29

  local _t = string.format("%d/%d", _player_object.stun_bar, _player_object.stun_max)

  if _player_object.id == 1 then
    _x = 118
  elseif _player_object.id == 2 then
    _x = screen_width - 116 - get_text_width(_t)
  end

  gui.text(_x, _y, _t, 0xE70000FF, 0x001433FF)
end

function display_draw_bonuses(_player_object)

  if _player_object.damage_bonus > 0 then
    local _x = 0
    local _y = 7

    local _t = string.format("+%d dmg", _player_object.damage_bonus)

    if _player_object.id == 1 then
      _x = 43
    elseif _player_object.id == 2 then
      _x = screen_width - 40 - get_text_width(_t)
    end

    gui.text(_x, _y, _t, 0xFF7184FF, 0x392031FF)
  end

  if _player_object.defense_bonus > 0 then

    local _x = 0
    local _y = 7

    local _t = string.format("+%d def", _player_object.defense_bonus)

    if _player_object.id == 1 then
      _x = 10
    elseif _player_object.id == 2 then
      _x = screen_width - 7 - get_text_width(_t)
    end

    gui.text(_x, _y, _t, 0xD6E3EFFF, 0x000029FF)
  end

  if _player_object.stun_bonus > 0 then

    local _x = 0
    local _y = 33

    local _t = string.format("+%d stun", _player_object.stun_bonus)

    if _player_object.id == 1 then
      _x = 81
    elseif _player_object.id == 2 then
      _x = screen_width - 79 - get_text_width(_t)
    end

    gui.text(_x, _y, _t, 0xD6E3EFFF, 0x000029FF)
  end

end

-- # tools
function game_to_screen_space(_x, _y)
  local _px = _x - screen_x + emu.screenwidth()/2
  local _py = emu.screenheight() - (_y - screen_y) - rom.ground_offset
  return _px, _py
end


function get_text_width(_text)
  if #_text == 0 then
    return 0
  end

  return #_text * 4
end
