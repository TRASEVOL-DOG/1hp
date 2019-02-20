
windgoright = false

function create_wind()
 local s = {
    animt               = 0,
    anim_state          = "a",
    update              = update_wind,
    draw                = draw_wind,
    flipx               = 0,
    flipy               = 0,
    regs                = {"to_update", "to_draw0", "wind"},
    alive               = true,
    skin                = 0 -- 48 ~ 48 + 3 and 54 -- 48 + 4 ~ 48 + 6 and 55
  }
  
  local q = pick(ground)
  s.x = q.x
  s.y = q.y
  
  local state = irnd(3)
  if state == 3 then
    s.anim_state = "a"
    s.a_t = 0.06 * 15
  elseif state == 2 then
    s.anim_state = "b"
    s.a_t = 0.06 * 15
  else
    s.anim_state = "c"
    s.a_t = 0.06 * 10
  end
  
  s.flipx = windgoright
  s.flipy = irnd(2) - 1
  state = anim_info["wind"][s.anim_state]
  s.a_t = state.dt * #state.sprites
  
  register_object(s)
  
  return s
end

function update_wind(s)

  s.animt = s.animt + delta_time
  
  if s.animt > s.a_t then
    deregister_object(s)  
  end
end

function draw_wind(s)
  -- all_colors_to(0)
  -- spr(s.skin, s.x-1, s.y-2)
  -- spr(s.skin, s.x+1, s.y-2)
  -- spr(s.skin, s.x, s.y-3)
  -- all_colors_to()
  -- spr(s.skin, s.x, s.y-2)

  draw_anim_outlined(s.x, s.y-2, "wind", s.anim_state, s.animt, 0, 0, s.flipx == true, s.flipy == 1)
end