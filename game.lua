-- 1hp source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("drawing")
require("maths")
require("table")
require("object")
require("sprite")
require("audio")

--require("nnetwork")

require("menu")

require("fx")

require("map")
require("player")
require("bullet")


function _init()
  eventpump()
  
  init_menu_system()
  
  init_object_mgr(
    "player"
  )

  t = 0
  
  if not server_only then
    cursor = create_cursor()
    cam = create_camera(256,256)
  end
  
  init_map()
  
  init_game()
end

function _update(dt)
  if btnp(6) then
    refresh_spritesheets()
  end

  t = t + dt

  update_objects()
end

function _draw()
  cls(0)
  camera()
  draw_map()
  
  apply_camera()

  draw_objects()
  
  camera()

  draw_debug()
  
  cursor:draw()
end

function _on_resize()

end



function update_cursor(s)
  s.animt = s.animt + delta_time
  local x, y = mouse_pos() 
  s.x = x + cam.x
  s.y = y + cam.y
  
end

function draw_cursor(s)
  circfill(s.x - cam.x, s.y - cam.y, 2, 3)
end

function create_cursor()
  local s = {
    animt   = 0,
    update  = update_cursor,
    draw    = draw_cursor,
    regs    = {"to_update"}
  }
  
  s.x, s.y = mouse_pos()
  
  register_object(s)
  
  return s
end




function apply_camera()
  local shk = cam.shkp/100
  camera(cam.x+cam.shkx*shk, cam.y+cam.shky*shk)
end

function get_camera_pos()
  local shk = cam.shkp/100
  return cam.x+cam.shkx*shk, cam.y+cam.shky*shk
end

function add_shake(p)
  p = p or 3
  local a = rnd(1)
  cam.shkx = p*cos(a)
  cam.shky = p*sin(a)
end

function update_camera(s)
  s.shkt = s.shkt - delta_time
  if s.shkt < 0 then
    if abs(s.shkx)+abs(s.shky) < 0.5 then
      s.shkx, s.shky = 0,0
    else
      s.shkx = s.shkx * (-0.5-rnd(0.2))
      s.shky = s.shky * (-0.5-rnd(0.2))
    end
    
    s.shkt = 1/30
  end
  
  if s.follow then
    local scrnw, scrnh = screen_size()
    s.x = lerp(s.x, s.follow.x-scrnw/2, delta_time*10)
    s.y = lerp(s.y, s.follow.y-scrnh/2, delta_time*10)
  end
end

function create_camera(x, y)
  local s = {
    x      = x or 0,
    y      = y or 0,
    shkx   = 0,
    shky   = 0,
    shkt   = 0,
    shkp   = 100,
    follow = nil,
    update = update_camera,
    regs   = {"to_update"}
  }
  
  register_object(s)
  
  return s
end



debuggg = ""
function draw_debug()
  local scrnw, scrnh = screen_size()
  
  font("small")
  draw_text("debug: "..debuggg, scrnw, scrnh-8, 2, 3)
end

function init_game()
  create_player()
end

function define_menus()
  local menus={
    mainmenu={
      {"Play", function() end},
      {"Player Name", function(str) end, "text_field", 16, my_name},
      {"Settings", function() menu("settings") end},
      {"Join the Castle Discord!", function() love.system.openURL("https://discordapp.com/invite/4C7yEEC") end}
    },
    cancel={
      {"Go Back", function() connecting=false main_menu() end}
    },
    settings={
      {"Fullscreen", fullscreen},
      {"Master Volume", master_volume,"slider",100},
      {"Music Volume", music_volume,"slider",100},
      {"Sfx Volume", sfx_volume,"slider",100},
      {"Back", menu_back}
    },
    pause={
      {"Resume", function() menu_back() end},
      {"Restart", function() end},
      {"Settings", function() menu("settings") end},
      {"Back to Main Menu", main_menu},
    }
  }
  
  if not (castle or network) then
    add(menus.mainmenu, {"Quit", function() love.event.push("quit") end})
  end
  
  return menus
end


function chance(a) return rnd(100)<a end
