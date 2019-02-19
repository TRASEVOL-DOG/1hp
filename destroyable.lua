
function create_destroyable()
  local s = {
    id                  = 0,
    update              = update_destroyable,
    draw                = draw_destroyable,
    regs                = {"to_update", "to_draw2"},
    alive               = 0,
    skin                = 0
  }
  
  q = pick_and_remove(spawn_points)
  
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
  circfill(s.x, s.y, 3, 0)
end