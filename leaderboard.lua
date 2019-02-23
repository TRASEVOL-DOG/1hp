
leaderboard = {is_large = false}

function get_list_leaderboard()
  
  local list_player = get_group_copy("player")
  local sorted_list = {}
  
  local my_id = my_id or 1
  my_place = 0
  local rank = 1
  
  for i = 1, #list_player do -- defined above
  
    local maxi = 0
    local index = 1
    
    for j, v in pairs(list_player) do
      if v.score > maxi then 
        maxi = v.score
        index = j
      end
      if v.id == my_id then
        my_place = rank
      end
    end
    
    local lrank = rank or 1
    local lname = list_player[index].name or ""
    local lscore = list_player[index].score or 1
    
    add(sorted_list, {  rank = lrank, 
                        name = lname,
                        score = lscore})
    delat(list_player, index)
    rank = rank + 1
    
    
  end 
   
  return sorted_list -- array of string with players according to score
end

function get_victim()
  return { "playerthree" } -- array of string with players according to score
end

function get_victimest()
  return { "playertwo" } -- array of string with players according to score
end

function get_killer()
  return { "playerthree" } -- array of string with players according to score
end

function init_leaderboard()

  leaderboard.is_large = false

end

function draw_leaderboard()
  
  local sx, sy = screen_size()
  
  local y = 8
  local x = 70
    
  local size = #leaderboard.list
  
  y = 8
  if not leaderboard.is_large then
    size = size > 5 and 5 or size
    y = - 13
    x = leaderboard.maxi
  else
    rectfill(sx - x - 2, y + 1, sx - 2 , y + 12 , 0)
    rectfill(sx - x - 1, y + 2, sx - 3 , y + 11 , 1)
    draw_text_oultined(" Leaderboard", sx - x, y - 2, 0)
    rectfill(sx - x - 2, y + 13     , sx - 2 , y + 10 + (size+1) * 8    , 0)
    rectfill(sx - x - 1, y + 13 + 1 , sx - 3 , y + 10 + (size+1) * 8 - 1, 1)
    sx = sx - 4
    
    
  end
   
  -- if big, will display everything
  -- if small and player <= 5th, will display 5 first
  -- if small and player >  5th, will display 3 first, "..." + the player on the 5th line
 
  for i = 1, size do
  
    local player = leaderboard.list[i]
    local c = my_place == i and 2 or 0
    local str = player.rank .. "." .. player.name .. "(" .. player.score .. ")"
    
    if leaderboard.is_large then    
      str = player.rank .. "." .. player.name .. "(" .. player.score .. ")"
    else 
      if i == 4 and my_place > 5  then
        str = "..."
      end
      if i == 5 and my_place > 5  then        
        player = leaderboard.list[my_place]
        str = player.rank .. "." .. player.name .. "(" .. player.score .. ")"
        c = 2        
      end
    end
    
    draw_text_oultined(str, sx - leaderboard.width - 19 , y + 3 + i*8 , c)
  end
  --[[ needs to be implemented in the network
  y = sy - 60
  draw_text_oultined("Last victim :", sx - str_width("Last victim : "), y, 0)
  y = y + 8
  draw_text_oultined(leaderboard.victim, sx - x, y)
  
  y = y + 10
  draw_text_oultined("Most killed :", sx - str_width("Most killed : "), y)
  y = y + 8
  draw_text_oultined(leaderboard.victimest, sx - x, y)
  
  y = y + 10
  draw_text_oultined("Last killer :", sx - str_width("Last Killer : "), y)
  y = y + 8
  draw_text_oultined(leaderboard.killer, sx - x, y)
  --]]
end

function update_leaderboard()

  if btnp(10) then leaderboard.is_large = not leaderboard.is_large end
  
  leaderboard.list = get_list_leaderboard()
  leaderboard.width = get_length_leaderboard()
  --[[
  leaderboard.victim = get_victim() -- Last player killed

  leaderboard.victimest = get_victimest() -- Player killed the most:

  leaderboard.killer = get_killer() -- Last Killer
  --]]
  
end

function draw_text_oultined(str, x, y, c1)
  c1 = c1 or 0
  
  color(3)
  print(str, x+1, y-1)
  print(str, x+1, y)
  print(str, x+1, y+1)
  
  print(str, x-1, y-1)
  print(str, x-1, y)
  print(str, x-1, y+1)
  
  print(str, x, y-1)
  print(str, x, y+1)
    
  color(c1)
  print(str, x, y)
  color(3)
end

function get_length_leaderboard()
  local maxi = 0
  if (graphics) then
    for i = 1, #leaderboard.list do
      local name = leaderboard.list[i].name or ""
      local length = str_width(name)
      if length > maxi then
        maxi = length
      end  
    end
  end
  return maxi
end