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



function _init()
--  fullscreen()
  eventpump()
  
  init_menu_system()
  
  init_object_mgr(
    "player"
  )

--  shkx,shky = 0,0
--  xmod,ymod = 0,0
  
  t = 0
  
  if not server_only then
    cursor = create_cursor()
  end
  
  init_game()
end

network_t = 0
function _update(dt)
  if btnp(6) then
    refresh_spritesheets()
  end

  t = t + dt

--  update_shake()
  
  update_objects()
end

debuggg = ""
function _draw()
  cls(0)
  camera(0,0)

  draw_objects()

  draw_debug()
  
  cursor:draw()
end

function _on_resize()

end



function update_cursor(s)
  s.animt = s.animt + delta_time
  s.x, s.y = mouse_pos()

end

function draw_cursor(s)
  circfill(s.x, s.y, 2, 3)
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



function draw_debug()
  local scrnw, scrnh = screen_size()
  
  font("small")
  draw_text("debug: "..debuggg, scrnw, scrnh-8, 2, 3)
end


function init_game()

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
