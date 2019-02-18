
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
    angle               = 0,
    max_speed           = 2*3,
    deceleration        = .2*3,
    acceleration        = .6*3
  }
  
  x, y = screen_size()
  s.x, s.y = x/2 , y/2
  
  register_object(s)
  
  return s
end

function update_player(s)

  local acc = s.acceleration * delta_time * 10
  local dec = s.deceleration * delta_time * 10

  s.fire_cooldown_left = s.fire_cooldown_left - delta_time
  
  -- left   = 0
  -- right  = 1
  -- up     = 2
  -- down   = 3
  
  if btn(0) then
    s.v.x = s.v.x - acc
  end
  if btn(1) then
    s.v.x = s.v.x + acc
  end
  if btn(2) then
    s.v.y = s.v.y - acc
  end
  if btn(3) then
    s.v.y = s.v.y + acc
  end
  
  if s.v.x > dec*1.3 then
    s.v.x = s.v.x - dec
  elseif s.v.x < - dec * 1.3 then
    s.v.x = s.v.x + dec
  else
    s.v.x = 0
  end
  
  if s.v.y > dec * 1.3 then
    s.v.y = s.v.y - dec
  elseif s.v.y < - dec * 1.3 then
    s.v.y = s.v.y + dec
  else
    s.v.y = 0
  end
  
  s.v.x = min(s.v.x, s.max_speed)
  s.v.x = max(s.v.x, -s.max_speed)
  s.v.y = min(s.v.y, s.max_speed)
  s.v.y = max(s.v.y, -s.max_speed)
    
  s.x = s.x + s.v.x * delta_time * 10
  s.y = s.y + s.v.y * delta_time * 10
  
end

function draw_player(s)
  circfill(s.x, s.y, 2, 3)
end