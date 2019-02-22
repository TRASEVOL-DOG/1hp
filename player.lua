
require("input")

player_list = {} -- { id : player }

function create_player(id,x,y)
  
  local s = {
    id                  = id,
  
    animt               = 0,
    anim_state          = "idle",
    update              = update_player,
    draw                = draw_player,
    regs                = {"to_update", "to_draw0", "player"},
    alive               = true,
    score               = 0,
    
    w                   = 6,
    h                   = 4,
    
    time_fire           = .1, -- max cooldown (seconds)  for bullet fire
    timer_fire          = 0, -- cooldown (seconds) left for bullet fire
    
    v                   = { x = 0, y = 0},-- movement vector 
    angle               = 0,
    speed               = 0,
    max_speed           = 1.4*6,
    deceleration        = .5*6*2,
    acceleration        = .9*6*2,
    
    --network stuff
    dx_input            = 0,
    dy_input            = 0,
    shot_input          = false,
    diff_x              = 0,
    diff_y              = 0,
    moved_t             = 0
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
  
  if s.id == my_id then
  
    s.dx_input = 0
    s.dy_input = 0
    
    -- gets angle
    s.angle = atan2(cursor.x - s.x, cursor.y - s.y)
    -- move cam
    cam.follow = {x = lerp(s.x+s.diff_x, cursor.x, .25), y = lerp(s.y+s.diff_y, cursor.y, .25)}
    
    s.speed = dist(s.v.x, s.v.y)
    
    s.shot_input = mouse_btnp(0)
    if s.shot_input then
      client_shoot()
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
  
  if server_only or s.id == my_id then
    
    -- MOVEMENT
    
    local delta_time = delta_time
    if s.delay then
      delta_time = delta_time + 0.5 * delay
    end
    
    local acc = s.acceleration * delta_time * 10
    local dec = s.deceleration * delta_time * 10
    
    if server_only then
      dec = dec * 1.25
    else
      dec = dec * 0.75
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
    
    -- accelerate on input
    s.v.x = s.v.x + acc * s.dx_input
    s.v.y = s.v.y + acc * s.dy_input
       
    -- Collisions
          
    -- local other_player = collide_objgroup(s,"player")
    -- if(other_player) then
      -- s.v.x = sgn(s.x - other_player.x) * 10
    -- end
    local destroyable = collide_objgroup(s,"destroyable")
    if destroyable and destroyable.alive then  -- Remy was here: made this use delta time (and acceleration)
      s.v.x = s.v.x + sgn(s.x - destroyable.x) * acc * 0.5
      s.v.y = s.v.y + sgn(s.y - destroyable.y) * acc * 0.5
    end
    
    -- cap speed
    s.speed = dist(s.v.x, s.v.y)
    if s.speed > s.max_speed then
      s.v.x = s.v.x / s.speed * s.max_speed
      s.v.y = s.v.y / s.speed * s.max_speed
      s.speed = s.max_speed
    end
    
  else
  
    -- we need the speed to figure out state on draw_player
    s.speed = dist(s.v.x, s.v.y)
  
  end
  
  if not server_only then
    if s.id == my_id then-- and s.rx then
      --local dx = s.x - s.rx
      --local dy = s.y - s.ry
      --
      --local dd = mid(1 - (s.speed / s.max_speed) - abs(s.dx_input) - abs(s.dy_input), 0, 1)
      --
      --if abs(dx) >= 1 then
      --  s.v.x = s.v.x - (sgn(dx) * 0.75 + dd * dx/2) * s.acceleration * delta_time * 5
      --end
      --if abs(dy) >= 1 then
      --  s.v.y = s.v.y - (sgn(dy) * 0.75 + dd * dy/2) * s.acceleration * delta_time * 5
      --end
      --s.speed = dist(s.v.x, s.v.y) -- update speed
      
      if abs(s.dx_input) + abs(s.dy_input) > 0 then
        s.moved_t = delay*4
      else
        s.moved_t = max(s.moved_t - delta_time, 0)
      end
      
      local dd = mid(1 - (s.speed / s.max_speed) - (s.moved_t/delay*4-3), 0, 1)
      
      local odx, ody = s.diff_x, s.diff_y
      
      s.diff_x = lerp(s.diff_x, 0, (dd + 0.01) * 10 * delta_time)
      s.diff_y = lerp(s.diff_y, 0, (dd + 0.01) * 10 * delta_time)
      
      local diff_x = s.diff_x-odx
      local diff_y = s.diff_y-ody
      local ndiff = dist(diff_x, diff_y)
      if ndiff > s.max_speed then
        diff_x = diff_x / ndiff * s.max_speed
        diff_y = diff_y / ndiff * s.max_speed
        s.diff_x = odx + diff_x
        s.diff_y = ody + diff_y
      end
      
      s.speed = dist(s.v.x + diff_x, s.v.y + diff_y)
    else
      s.diff_x = lerp(s.diff_x, 0, 20*delta_time)
      s.diff_y = lerp(s.diff_y, 0, 20*delta_time)
    end
  end
  
  -- translate vector to position according to delta (30 fps)
  update_move_player(s)
  
  if server_only or s.id == my_id then
    if s.shot_input and s.timer_fire < 0 then  -- Remy was here: moved the timer check here, also the screen-shake
      local p = create_bullet(s.id)
      s.timer_fire = s.time_fire
      add_shake()
      s.score = s.score + 1
    end 
  end
end

function update_move_player(s)
  -- client syncing stuff
  local apply_diff = (s.id == my_id and abs(s.dx_input) + abs(s.dy_input) > 0)
  if apply_diff then
    s.x, s.y = s.x + s.diff_x, s.y + s.diff_y
  end
  
  -- actual move update
  local nx = s.x + s.v.x * delta_time * 10
  local col = check_mapcol(s,nx)
  if col then
    local tx = flr((nx + col.dir_x * s.w * 0.5) / 8)
    s.x = tx * 8 + 4 - col.dir_x * (8 + s.w + 0.5) * 0.5
    
    col = check_mapcol(s,nx,nil,true) or col
    s.v.y = s.v.y - 1* col.dir_y * s.acceleration * delta_time * 10
  else
    s.x = nx
  end
  
  local ny = s.y + s.v.y * delta_time * 10
  local col = check_mapcol(s,nil,ny)
  if col then
    local ty = flr((ny + col.dir_y * s.h * 0.5) / 8)
    s.y = ty * 8 + 4 - col.dir_y * (8 + s.h + 0.5) * 0.5
    
    col = check_mapcol(s,nil,ny,true) or col
    s.v.x = s.v.x - 1* col.dir_x * s.acceleration * delta_time * 10
  else
    s.y = ny
  end
  
  -- more client syncing bullshit
  if apply_diff then
    s.x, s.y = s.x - s.diff_x, s.y - s.diff_y
  end
end

function draw_player(s)
  local x = s.x + s.diff_x
  local y = s.y + s.diff_y

--  line(x + (s.w) * cos(s.angle), y + (s.h) * sin(s.angle), x + (s.w)*1.5 * cos(s.angle), y + (s.h)*1.5 * sin(s.angle), 3)
  
  local state = "idle"
  if s.speed > 0.5 then
    state = "run"
  end
  local a = cos(s.angle) < 0
  local animt = s.animt * (s.v.x > 0 == a and -1 or 1)
  draw_anim_outline(x, y-2, "player", state, animt, 0, 0, a)
  
  -- drawing arm
  pal(1,0)
  spr(200, x, y-1.5, 1, 1, s.angle, false, a, 1/8, 5/8)
  pal(1,1)
  
  -- drawing rest of body
  draw_anim(x, y-2, "player", state, animt, 0, a)

  -- syncing debug
  if debug_mode then
    all_colors_to(1)
    --if s.id == my_id then
    --  draw_anim(s.rx, s.ry-2, "player", state, s.animt * (s.v.x > 0 == a and -1 or 1), 0, 0, a)
    --else
      draw_anim(s.x, s.y-2, "player", state, s.animt * (s.v.x > 0 == a and -1 or 1), 0, 0, a)
    --end
    all_colors_to()
  end
end

function kill_player(s)
  s.alive = false
end

function resurrect(s)
  s.alive = true
end