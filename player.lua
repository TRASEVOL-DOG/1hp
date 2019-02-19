
require("input")
-- spawn_players={{x = 0, y = 0}}

function kill_player(s)
end


function create_player()
  
  local s = {
    id                  = 0,
    animt               = 0,
    anim_state          = "idle",
    update              = update_player,
    draw                = draw_player,
    regs                = {"to_update", "to_draw1"},
    
    alive               = true,
    time_fire           = .1, -- max cooldown (seconds)  for bullet fire
    timer_fire          = 0, -- cooldown (seconds) left for bullet fire
    v                   = { x = 0, y = 0},
    angle               = 0,
    max_speed           = 1.4*6,
    deceleration        = .5*6,
    acceleration        = .9*6
  }
  
  q = pick(spawn_points)
  
  s.x = q.x
  s.y = q.y
  s.w = 8
  s.h = 8
  
  register_object(s)
  
  return s
end

function update_player(s)

  -- cooldown firing gun
  s.timer_fire = s.timer_fire - delta_time
  
  -- change anime time
  s.animt = s.animt + delta_time
  
  -- MOVEMENT
    
    -- locals to clear code
    local acc = s.acceleration * delta_time * 10
    local dec = s.deceleration * delta_time * 10
    
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
       
    -- COLLISIONS
    
      -- make player collide with wall           send position
      check_collide(s)
      
      other_player = collide_objgroup(s,"player")
      if(other_player) then
        s.v.x = sign(player.x - other_player.x) * 10
      end
      
      
      collide_objgroup(s,"enemy_bullets")
      collide_objgroup(s,"destroyables")
      
      -- make player collide with player         collide_objgroup
      -- make player collide with ennemy_bullet  collide_objgroup
      -- make player collide with misc           collide_objgroup
      
    -- END COLLISIONS
  
    -- translate vector to position according to delta (30 fps)
    -- s.x = s.x + s.v.x * delta_time * 10
    -- s.y = s.y + s.v.y * delta_time * 10
    
  -- END MOVEMENT
  
  
  -- gets angle
  s.angle = atan2(cursor.x - s.x, cursor.y - s.y)
  
  -- move cam
  cam.follow = {x = lerp(s.x, cursor.x, .25), y = lerp(s.y, cursor.y, .25)}
    
  -- create bullet
  if mouse_btnp(0) and s.timer_fire < 0 then
    create_bullet(s)
    s.timer_fire = s.time_fire
    add_shake()
  end
end

function draw_player(s)
  line(s.x + (s.w) * cos(s.angle), s.y + (s.h) * sin(s.angle), s.x + (s.w)*1.5 * cos(s.angle), s.y + (s.h)*1.5 * sin(s.angle), 3)
  spr(0, s.x, s.y)
end