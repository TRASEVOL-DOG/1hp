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
require("destroyable")
require("bullet")
require("wind")
require("leaderboard")

my_name = "[*.*]"

function _init()
  eventpump()
  
  init_network()
  
  init_menu_system()
  
  init_object_mgr(
    "player",
    "bullet",
    "destroyable",
    "wind"
  )

  t = 0
  
  if not server_only then
    cursor = create_cursor()
    cam = create_camera(256,256)
  end
  
  init_map()
  
  init_game()
  
  if not server_only then
    main_menu()
  end
end

function _update(dt)
  if btnp(6) then
    refresh_spritesheets()
  end
  
  if btnp(5) then
    debug_mode = not debug_mode
  end

  t = t + dt
  
  if not server_only and chance(10) then
    if chance(0.2) then windgoright = not windgoright end
    create_wind()
  end

  update_objects()
  
  update_leaderboard()
  
  if btnp(7) or btnp(8) then
    local curmenu = querry_menu()
    if not curmenu then
      pause_menu()
    elseif curmenu == "pause" or curmenu == "settings" then
      menu_back()
      in_pause = false
    end
  end
  
  update_menu()
  
  update_network()
end

function _draw()
  cls(2)
  camera()
  draw_map()
  
  apply_camera()

  draw_objects()
  
  camera()

  draw_debug()
  
  draw_leaderboard()
  
  local menu = querry_menu()
  if menu == "mainmenu" then
    draw_title()
  elseif menu == "gameover" then
    draw_gameover()
  elseif in_pause then
    draw_pause_background()
  end
  
  draw_menu()
  
  cursor:draw()
end

function _on_resize()

end



function update_cursor(s)
  s.animt = s.animt + delta_time
  s.sprite_t = max(s.sprite_t - dt30f, 0)
  
  local x, y = mouse_pos() 
  s.x = x + cam.x
  s.y = y + cam.y
  
  if mouse_btnp(0) then
    s.sprite_t = 4
  end
end

function draw_cursor(s)
  local sp = 130+ceil(s.sprite_t)*2
  local camx, camy = get_camera_pos()

  spr(sp, s.x-camx, s.y-camy, 2, 2)
end

function create_cursor()
  local s = {
    animt    = 0,
    sprite_t = 0,
    update   = update_cursor,
    draw     = draw_cursor,
    regs     = {"to_update"}
  }
  
  s.x, s.y = mouse_pos()
  
  register_object(s)
  
  return s
end




function apply_camera()
  local shk = cam.shkp/100
  camera(round(cam.x+cam.shkx*shk), round(cam.y+cam.shky*shk))
end

function get_camera_pos()
  local shk = cam.shkp/100
  return cam.x+cam.shkx*shk, cam.y+cam.shky*shk
end

function add_shake(p)
  if server_only then return end

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



function main_menu()
  local scrnw, scrnh = screen_size()
  menu("mainmenu")
end

function draw_title()
  local scrnw, scrnh = screen_size()
  
  local x = 0.5 * scrnw
  local y = 0.2 * scrnh
end

function pause_menu() -- not an actual pause - access to settings & restart & main menu
  local scrnw, scrnh = screen_size()
  menu("pause")
  in_pause = true
end

function draw_pause_background()
  local scrnw,scrnh=screen_size()
  color(1)
  for i=0,scrnh+scrnw,2 do
    line(i,0,i-scrnh,scrnh)
  end
end

function game_over()
  menu_back()
  menu_back()
  
  add_shake(8)
  local scrnw, scrnh = screen_size()
  menu("gameover")
  in_pause = false
end

function draw_gameover()
  local scrnw, scrnh = screen_size()
  
  font("big")
  
  local str = "* G A M E   O V E R *"
  local w = str_width(str)
  
  local x = scrnw/2-w/2
  local y = 0.25 * scrnh
  
  for i = 1,#str do
    local st = str:sub(i,i)
    if st ~= ' ' then
      local yy = y + (4+2*sin(t*0.41+i*0.13))*cos(t*0.25+i*0.1)
      draw_text(st, x, yy, 0, 0,3,3)
    end
    x = x + str_width(st)
  end
  
  local x = 0.5 * scrnw
  local y = 0.4 * scrnh
  draw_text("You got shot.", x, y, 1, 3, 2, 0)
end



debuggg = ""
function draw_debug()
  local scrnw, scrnh = screen_size()
  
  font("small")
  draw_text("debug: "..debuggg, scrnw, scrnh-16, 2, 3)
  
  if client.connected then
    draw_text("Connected as #"..client.id, 2, 2, 0, 3)
    draw_text("Ping: "..client.getPing(), 2, 10, 0, 3)
  else
    draw_text("Not Connected", 2, 2, 0, 3)
    if castle and castle.isLoggedIn then
      draw_text("Please wait...", 2, 10, 0, 3)
    else
      draw_text("Please sign into Castle to connect", 2, 10, 0, 3)
    end
  end
end

function init_game()

  if server_only then
    for _,p in pairs(cacti_spawn_points) do
      if chance(90) then
        create_destroyable(nil, p.x+irnd(5)-3, p.y+irnd(5)-3)
      end
    end
  end
  
end

function define_menus()
  local menus={
    mainmenu={
      {"Play", function() menu_back() connecting = true end},
      {"Player Name", function(str) my_name = str end, "text_field", 8, my_name},
      {"Settings", function() menu("settings") end},
--      {"Join the Castle Discord!", function() love.system.openURL("https://discordapp.com/invite/4C7yEEC") end}
    },
    cancel={
      {"Go Back", function() connecting=false main_menu() end}
    },
    settings={
      {"Fullscreen", fullscreen},
      {"Screenshake", function(v) if cam then cam.shkp = v add_shake(4) return cam.shkp end return 100 end,"slider",200},
      {"Master Volume", master_volume,"slider",100},
      {"Music Volume", music_volume,"slider",100},
      {"Sfx Volume", sfx_volume,"slider",100},
      {"Back", menu_back}
    },
    pause={
      {"Resume", function() menu_back() in_pause = false end},
      {"Restart", function() menu_back() in_pause = false restarting = true end},
      {"Settings", function() menu("settings") end},
      {"Back to Main Menu", function() menu_back() main_menu() in_pause = false end},
    },
    gameover={
      {"Restart", function() restarting = true end},
      {"Back to Main Menu", main_menu}
    }
  }
  
  set_menu_linespace("settings", 10)
  
  menu_position("mainmenu",0.5,0.6)
  menu_position("gameover",0.5,0.75)
  
  if not (castle or network) then
    add(menus.mainmenu, {"Quit", function() love.event.push("quit") end})
  end
  
  return menus
end


function chance(a) return rnd(100)<a end
