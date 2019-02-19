
function create_bullet(player)
  local s = {
    id                  = 0,
    animt               = 0,
    anim_state          = "idle",
    update              = update_bullet,
    draw                = draw_bullet,
    regs                = {"to_update", "to_draw2"},
    speed               = 14, -- per second
    v                   = { x = 0, y = 0}, -- movement vector 
    timer_despawn       = 0.5, -- seconds remaining before despawn
    despawn             = false
  }
  
  
  -- get vector
  local angle = player.angle - .015 + rnd(.03)
  s.v.x = cos(angle) * s.speed
  s.v.y = sin(angle) * s.speed
  
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
  
  if( s.timer_despawn < 0 ) then kill_bullet(s) end
  
  --Collisions
  local player = collide_objgroup(s,"player")
  if(player) then
    if player.is_enemy then
      player.alive = false
    end
    kill_bullet(s)
  end
  
  local destroyable = collide_objgroup(s,"destroyable")
  if(destroyable) then
    destroyable.alive = false
  end
      
end

function draw_bullet(s)
  if s.timer_despawn > .5 * 9 / 10 then
    spr(56, s.x, s.y-2, 1, 1, atan2(s.v.x, s.v.y))
  
  elseif s.timer_despawn < .5* 2/ 10 then
    spr(59, s.x, s.y-2, 1, 1, atan2(s.v.x, s.v.y))
  else
    spr(57, s.x, s.y-2, 2, 1, atan2(s.v.x, s.v.y))
  end
end

function kill_bullet(s)
  deregister_object(s)
end