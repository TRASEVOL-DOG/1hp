
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
    max_speed           = 2*6,
    deceleration        = .2*6,
    acceleration        = .6*6
  }
  
  x, y = screen_size()
  s.x, s.y = x/2 , y/2
  s.w = 8
  s.h = 8
  
  register_object(s)
  
  return s
end

function update_player(s)

  -- locals to clear code
  local acc = s.acceleration * delta_time * 10
  local dec = s.deceleration * delta_time * 10

  -- cooldown firing gun
  s.fire_cooldown_left = s.fire_cooldown_left - delta_time
  
  -- left   = 0
  -- right  = 1
  -- up     = 2
  -- down   = 3
  
  -- add speed to vector according to button pushed
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
  
  -- decelerate speed every frame
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
    
  -- cap speed 
  local d = dist(s.v.x, s.v.y)
  if d > s.max_speed then
    s.v.x = s.v.x / d * s.max_speed
    s.v.y = s.v.y / d * s.max_speed
  end
  
  -- gets angle
  s.angle = atan2(cursor.x - s.x, cursor.y - s.y)
  
  -- move cam
  -- cam.follow = {x = (s.x + cursor.x + cam.x)/2, y = (s.y + cursor.y + cam.y)/2}
  cam.follow = {x = lerp(s.x, cursor.x + cam.x, .25), y = lerp(s.y, cursor.y + cam.y, .25)}
  -- w,h = screen_size()
  -- cam.follow = {x = s.x + lerp(0, 50, ((s.x + cursor.x + cam.x)/2)/w ), y = s.y + lerp(0, 50, ((s.y + cursor.y + cam.y)/2)/h)}
  
  -- translate vector to position according to delta (30 fps)
  s.x = s.x + s.v.x * delta_time * 10
  s.y = s.y + s.v.y * delta_time * 10
  
end

function draw_player(s)
  line(s.x + (s.w) * cos(s.angle), s.y + (s.h) * sin(s.angle), s.x + (s.w)*1.5 * cos(s.angle), s.y + (s.h)*1.5 * sin(s.angle), 3)
  -- circfill(s.x, s.y, 2, 3)
  -- rectfill(s.x - s.w/2, s.y-s.w/2, s.x + s.w/2, s.y + s.h/2)
  spr(0, s.x, s.y)
end