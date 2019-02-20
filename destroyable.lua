
function create_destroyable()
  local s = {
    id                  = 0,
    update              = update_destroyable,
    draw                = draw_destroyable,
    regs                = {"to_update", "to_draw0", "destroyable"},
    alive               = true,
    skin                = 0 -- 48 ~ 48 + 3 and 54 -- 48 + 4 ~ 48 + 6 and 55
  }
  
  s.skin = 47 + irnd(6)
  
  q = pick_and_remove(spawn_points)
  if q == nil then
    return
  end
  s.x = q.x
  s.y = q.y
  s.w = 8
  s.h = 8
  
  register_object(s)
  
  return s
end

function update_destroyable(s)
  
end

function draw_destroyable(s)
  all_colors_to(0)
  spr(s.skin, s.x-1, s.y-2)
  spr(s.skin, s.x+1, s.y-2)
  spr(s.skin, s.x, s.y-3)
  all_colors_to()
  spr(s.skin, s.x, s.y-2)

end

function kill_destroyable(s)
  if s.alive then
    s.alive = false
    s.skin = 53 + irnd(2)
  end
end