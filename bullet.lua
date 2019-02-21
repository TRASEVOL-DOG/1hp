
bullet_list = {} -- { id : bullet }
local bullet_nextid = 1

function create_bullet(player_id, id)
  local s = {
    from                = player_id, -- player id
    w                   = 4,
    h                   = 4,
    animt               = 0,
    anim_state          = "stopped",
    kill_anim_t         = .1,
    update              = update_bullet,
    draw                = draw_bullet,
    regs                = {"to_update", "to_draw1", "bullet"},
    speed               = 18, -- per second
    speed_lost_rebound  = 1/4,
    v                   = { x = 0, y = 0}, -- movement vector
    time_despawn        = 0.8, -- seconds a bullet would have at spawn before despawn
    timer_despawn       = 0, -- seconds remaining before despawn
    time_hold           = player_id == my_id and delay or 0, -- time to hold the bullet before it shoots off (should make server sync look smoother)
    diff_x              = 0, -- difference with server position (used to smoothen syncing)
    diff_y              = 0  -- ^^^
  }
  
  local player = player_list[player_id]
  if not player then return end
  
  -- setting id
  
  if id then -- assigned by server
    if bullet_list[id] then
      deregister_object(bullet_list[id])
    end
  
    s.id = id
    bullet_nextid = max(bullet_nextid, id + 1)
    
  else       -- assigning id now - probably running server
    s.id = bullet_nextid
    bullet_nextid = bullet_nextid + 1
  end
  bullet_list[s.id] = s
  
  --spawn according to vector

  local angle = player.angle - .015 + rnd(.03)
  
  s.v.x = cos(angle)
  s.v.y = sin(angle)
  s.x = player.x + (player.w + s.w) * s.v.x 
  s.y = player.y + (player.h + s.h) * s.v.y - 2 -- offset to line up with gun
    
  -- check if in wall
  s.anim_state = "stopped"
  
  local col = check_mapcol(s,s.x,s.y)
  if col then
    if (angle > .25 or angle < .75) then
      angle = angle -.5
    else
      angle = angle +.5
    end
    s.v.x = cos(angle)
    s.v.y = sin(angle)
    s.x = player.x + (player.w + s.w) * s.v.x 
    s.y = player.y + (player.h + s.h) * s.v.y
  
  end
  
  s.timer_despawn = s.time_despawn
  register_object(s)
  
  return s
end

function update_bullet(s)
  if s.time_hold > 0 then
    s.time_hold = s.time_hold - delta_time
    return
  end
  
  if not server_only then
    s.diff_x = lerp(s.diff_x, 0, 7*delta_time)
    s.diff_y = lerp(s.diff_y, 0, 7*delta_time)
  end
  

  s.timer_despawn = s.timer_despawn - delta_time
  
  
  if( s.timer_despawn < 0 and s.anim_state ~= "killed") then 
    kill_bullet(s)
  elseif( s.timer_despawn >  s.time_despawn - 0.05 ) then 
    s.anim_state = "stopped" 
  elseif s.anim_state == "killed" then 
    s.kill_anim_t = s.kill_anim_t - delta_time
    if s.kill_anim_t < 0 then
      deregister_bullet(s)
    end
  else
    s.anim_state = "moving"
    update_move_bullet(s)
  end
  
  
  -- Collisions
  -- local player = collide_objgroup(s,"player")
  -- if(player) then
    -- if player.is_enemy then
      -- player.alive = false
      -- kill_bullet(s)
    -- end
  -- end
  
  local destr = all_collide_objgroup(s,"destroyable")
  if(#destr>0) then
    for i=1, #destr do
      if destr[i].alive then
        kill_destroyable(destr[i])
        kill_bullet(s)
      end
    end
  end
      
end

function update_move_bullet(s)
  local nx = s.x + s.v.x * s.speed * delta_time * 10
  local col = check_mapcol(s,nx)
  if col then
    local tx = flr((nx + col.dir_x * s.w * 0.5) / 8)
    s.x = tx * 8 + 4 - col.dir_x * (8 + s.w + 0.5) * 0.5
    s.v.x = s.v.x *-1
    s.speed = s.speed * ( 1 - s.speed_lost_rebound )
  else
    s.x = nx
  end
  
  local ny = s.y + s.v.y * s.speed * delta_time * 10
  local col = check_mapcol(s,s.x,ny)
  if col then
    local ty = flr((ny + col.dir_y * s.h * 0.5) / 8)
    s.y = ty * 8 + 4 - col.dir_y * (8 + s.h + 0.5) * 0.5
    s.v.y = s.v.y *-1
    s.speed = s.speed * ( 1 - s.speed_lost_rebound )
  else
    s.y = ny
  end
end

function draw_bullet(s)
  local x = s.x + s.diff_x
  local y = s.y + s.diff_y - 1

  if s.anim_state == "stopped" then
    spr(56, x, y, 1, 1, atan2(s.v.x, s.v.y))
  elseif s.anim_state == "killed" then 
    spr(59, x, y, 1, 1, atan2(s.v.x, s.v.y))
  else
    spr(57, x, y, 2, 1, atan2(s.v.x, s.v.y))
  end
  
  if debug_mode then
    all_colors_to(1)
    spr(57, s.x, s.y-2, 2, 1, atan2(s.v.x, s.v.y))
    all_colors_to()
  end
end

function kill_bullet(s)
  s.anim_state = "killed"
  -- s.kill_anim_t = .2
end
-- function kill_bullet2(s)
  -- s.anim_state = "killed"
  -- s.kill_anim_t = .2
-- end

function deregister_bullet(s)
  deregister_object(s)
end