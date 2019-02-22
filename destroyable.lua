
destroyable_list = {} -- { id : destroyable }
local destroyable_nextid = 1

function create_destroyable(id, x, y)
  local s = {
    w                   = 6,  -- Remy was here: moved w and h and lowered them both
    h                   = 6,
    update              = update_destroyable,
    draw                = draw_destroyable,
    regs                = {"to_update", "to_draw0", "destroyable"},
    alive               = true,
    t_respawn           = 0,
    skin                = 0 -- 48 ~ 48 + 3 and 54 -- 48 + 4 ~ 48 + 6 and 55
  }
  
  s.skin = 47 + irnd(6)
  
  -- setting position
  if x and y then  -- position is provided by server
    s.x = x
    s.y = y
  else             -- seeking position
    q = pick_and_remove(spawn_points)
    if q == nil then
      return
    end
    s.x = q.x
    s.y = q.y
  end
  
  -- setting id
  if id then -- assigned by server
    if destroyable_list[id] then
      deregister_object(destroyable_list[id])
    end
  
    s.id = id
    destroyable_nextid = max(destroyable_nextid, id + 1)
    
  else       -- assigning id now - probably running server
    s.id = destroyable_nextid
    destroyable_nextid = destroyable_nextid + 1
  end
  destroyable_list[s.id] = s
  
  
  register_object(s)
  
  return s
end

function update_destroyable(s)
  if not s.alive then 
    s.t_respawn = s.t_respawn - delta_time 
    if s.t_respawn < 0 then respawn_destroyable(s) end
  end
end

function draw_destroyable(s)
  all_colors_to(0)
  spr(s.skin, s.x-1, s.y-2)
  spr(s.skin, s.x+1, s.y-2)
  spr(s.skin, s.x, s.y-3)
  all_colors_to()
  pal(1,0)
  spr(s.skin, s.x, s.y-2)
  pal(1,1)
end

function kill_destroyable(s)
  if s.alive then
    s.alive = false
    s.skin = (s.skin < 52) and 54 or 55
    s.t_respawn = 10 + rnd(5)
  end
end
function respawn_destroyable(s)
  if not s.alive then
    s.alive = true
    s.skin = 47 + irnd(6)
  end
end