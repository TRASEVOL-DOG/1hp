
require("input")

function create_player()
  local s = {
    animt               = 0,
    update              = update_player,
    draw                = draw_player,
    regs                = {"to_update", "to_draw1"},
    alive               = true,
    fire_cooldown       = 1, -- max cooldown (seconds)  for bullet fire
    fire_cooldown_left  = 1, -- cooldown (seconds) left for bullet fire
    v                   = { x = 0, y = 0},
    max_speed           = 2,
    deceleration        = .2,
    acceleration        = .6
  }
  
  x, y = screen_size()
  s.x, s.y = x/2 , y/2
  
  register_object(s)
  
  return s
end

function update_player(s)
  -- if btn(0) then
    -- s.x = s.x + cos(t)
  -- end
  -- s.y = s.y + sin(t/2)

  s.fire_cooldown_left = s.fire_cooldown_left - delta_time
  
  -- left   = 0
  -- right  = 1
  -- up     = 2
  -- down   = 3
  
  if btn(0) then
    s.v.x = s.v.x - s.acceleration
  end
  if btn(1) then
    s.v.x = s.v.x + s.acceleration
  end
  if btn(2) then
    s.v.y = s.v.y - s.acceleration
  end
  if btn(3) then
    s.v.y = s.v.y + s.acceleration  
  end
  
  if s.v.x > s.deceleration*1.3 then
    s.v.x = s.v.x - s.deceleration
  elseif s.v.x < -s.deceleration*1.3 then
    s.v.x = s.v.x + s.deceleration
  else
    s.v.x = 0
  end
  
  if s.v.y > s.deceleration*1.3 then
    s.v.y = s.v.y - s.deceleration
  elseif s.v.y < -s.deceleration*1.3 then
    s.v.y = s.v.y + s.deceleration
  else
    s.v.y = 0
  end
  
  s.v.x = min(s.v.x, s.max_speed)
  s.v.x = max(s.v.x, -s.max_speed)
  s.v.y = min(s.v.y, s.max_speed)
  s.v.y = max(s.v.y, -s.max_speed)
  
  
  
  s.x = s.x + s.v.x
  s.y = s.y + s.v.y
  
end

function draw_player(s)
  circfill(s.x, s.y, 2, 3)
end