
function create_bullet(player)
  local s = {
    animt               = 0,
    anim_state          = "idle",
    update              = update_bullet,
    draw                = draw_bullet,
    regs                = {"to_update", "to_draw2"},
    speed               = 20, -- per second
    v                   = { x = 0, y = 0},
    timer_despawn       = 2, -- seconds remaining before despawn
    despawn             = false
  }
  
  
  -- get vector
  s.v.x = cos(player.angle) * s.speed
  s.v.y = sin(player.angle) * s.speed
  
  --spawn according to vector
  
  s.x = player.x + player.w / 2 * (s.v.x / s.speed) 
  s.y = player.y + player.h / 2 * (s.v.y / s.speed)
  
  -- , s.y = x/2 , y/2
  s.w = 8
  s.h = 8
  
  register_object(s)
  
  return s
end
function update_bullet(s)
  s.timer_despawn = s.timer_despawn - delta_time
  
  s.x = s.x + s.v.x * s.speed * delta_time
  s.y = s.y + s.v.y * s.speed * delta_time
  
  -- if( timer_despawn < 0 or ) then end
  
  
end
function draw_bullet(s)
  circfill(s.x, s.y, 3, 3)
end