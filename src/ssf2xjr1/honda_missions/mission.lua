-- Base class for missions

Mission = {}

function Mission:new (o)
  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

function Mission:init()
  is_menu_open = false
  menu_stack_clear()
  self.wait = 0
  self.lost = false
  self.won = false
end

function Mission:logic(_input)
  if (not gamestate.is_in_match) then
    return
  end
  if (self.wait > 0) then
    self.wait = self.wait - 1
    return
  end
  self:mainLogic(_input)
end

function Mission:formatHelp()
  return ""
end

function Mission:showHelp(_help)
  if (_help ~= nil) then
    gui.box(1, 1, string.len(_help) * 4.1 + 2, 15, gui_box_bg_color, gui_box_outline_color)
    gui.text(5, 5, _help)
  end
end

function Mission:ongui()
  self:showHelp(self:formatHelp())
end

function Mission:islost()
  if (not gamestate.is_in_match) then
    return false
  end
  if (self.wait > 0) then
    return false
  end
  return self.lost
end

function Mission:iswon()
  if (not gamestate.is_in_match) then
    return false
  end
  if (self.wait > 0) then
    return false
  end
  return self.won
end

function Mission:updateScore(mission_scores)
  local _score = self:getScore()
  print(_score)
  if ((mission_scores[self.id] == nil) or (mission_scores[self.id] < _score)) then
    mission_scores[self.id] = _score
  end
end

function Mission:getScore()
  return 0
end
