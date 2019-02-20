
require("input")
-- spawn_players={{x = 0, y = 0}}

player_list = {} -- { id : player }

function kill_player(s)
end


function create_player(id,x,y)
  
  local s = {
    id                  = id,
  
    animt               = 0,
    anim_state          = "idle",
    update              = update_player,
    draw                = draw_player,
    regs                = {"to_update", "to_draw0", "player"},
    is_enemy            = false,    
    alive               = true,
    
    w                   = 6,
    h                   = 4,
    
    time_fire           = .1, -- max cooldown (seconds)  for bullet fire
    timer_fire          = 0, -- cooldown (seconds) left for bullet fire
    
    v                   = { x = 0, y = 0},-- movement vector 
    angle               = 0,
    speed               = 0,
    max_speed           = 1.4*6,
    deceleration        = .5*6,
    acceleration        = .9*6,
    
    --network stuff
    dx_input            = 0,
    dy_input            = 0,
    shot_input          = 0    
    --
  }
  
  if not id then
    castle_print("/!\\ Creating a player with no id.")
  end
  
  player_list[s.id or 0] = s
  
  
  if x and y then
    s.x = x
    s.y = y
  else
    q = pick_and_remove(spawn_points)
    
    s.x = q.x
    s.y = q.y
  end
  
  
  register_object(s)
  
  return s
end

function update_player(s)
  
  
  -- cooldown firing gun
  s.timer_fire = s.timer_fire - delta_time
  
  -- change anime time
  s.animt = s.animt + delta_time
  
  if(s.is_enemy == false) then
  
    s.shot_input = false
    s.dx_input = 0
    s.dy_input = 0
    
    -- gets angle
    s.angle = atan2(cursor.x - s.x, cursor.y - s.y)
    -- move cam
    cam.follow = {x = lerp(s.x, cursor.x, .25), y = lerp(s.y, cursor.y, .25)}
    
    s.speed = dist(s.v.x, s.v.y)

    -- create bullet    
    if mouse_btnp(0) and s.timer_fire < 0 then
      s.shot_input = true
      add_shake()
    end
    
    -- left   = 0
    -- right  = 1
    -- up     = 2
    -- down   = 3
        
    if btn(0) then s.dx_input =             -1 end
    if btn(1) then s.dx_input = s.dx_input + 1 end
    if btn(2) then s.dy_input =             -1 end
    if btn(3) then s.dy_input = s.dy_input + 1 end    
    
  end
  
  if server_only or (s.is_enemy == false) then
    
    -- MOVEMENT
    
    -- locals to clear code
    local acc = s.acceleration * delta_time * 10
    local dec = s.deceleration * delta_time * 10
    
    s.v.x = s.v.x + acc * s.dx_input
    s.v.y = s.v.y + acc * s.dy_input

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
    if s.speed > s.max_speed then
      s.v.x = s.v.x / s.speed * s.max_speed
      s.v.y = s.v.y / s.speed * s.max_speed
    end
       
    -- Collisions
          
    -- local other_player = collide_objgroup(s,"player")
    -- if(other_player) then
      -- s.v.x = sgn(s.x - other_player.x) * 10
    -- end
    local destroyable = collide_objgroup(s,"destroyable")
    if destroyable and destroyable.alive then
      s.v.x = s.v.x + sgn(s.x - destroyable.x) * .8
      s.v.y = s.v.y + sgn(s.y - destroyable.y) * .8
    end

  end
  
  -- translate vector to position according to delta (30 fps)
  update_move_player(s)
  
  if server_only or (s.is_enemy == false) then
    if s.shot_input --[[ and counter check ]] then
      local p = create_bullet(s)
      s.timer_fire = s.time_fire    
    end 
  end
  -- END MOVEMENT
  
end

function update_move_player(s)
  local nx = s.x + s.v.x * delta_time * 10
  local col = check_mapcol(s,nx)
  if col then
    local tx = flr((nx + col.dir_x * s.w * 0.5) / 8)
    s.x = tx * 8 + 4 - col.dir_x * (8 + s.w + 0.5) * 0.5
    s.v.y = s.v.y - 0.6* col.dir_y * s.acceleration * delta_time * 10
  else
    s.x=nx
  end
  
  local ny = s.y + s.v.y * delta_time * 10
  local col = check_mapcol(s,s.x,ny)
  if col then
    local ty = flr((ny + col.dir_y * s.h * 0.5) / 8)
    s.y = ty * 8 + 4 - col.dir_y * (8 + s.h + 0.5) * 0.5
    s.v.x = s.v.x - 0.6* col.dir_x * s.acceleration * delta_time * 10
  else
    s.y = ny
  end
end

function draw_player(s)
  line(s.x + (s.w) * cos(s.angle), s.y + (s.h) * sin(s.angle), s.x + (s.w)*1.5 * cos(s.angle), s.y + (s.h)*1.5 * sin(s.angle), 3)
  
  local state = "idle"
  if s.speed > 0 then
    state = "run"
  end
  local a = cos(s.angle) < 0
  draw_anim_outlined(s.x, s.y-2, "player", state, s.animt * (s.v.x > 0 == a and -1 or 1), 0, 0, a)
  
end

function kill_player(s)
end