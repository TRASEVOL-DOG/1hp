
leaderboard = {is_large = true}

function get_list_leaderboard()
  
  local list_player = get_group_copy("player")
  
  -- if group_exists("player") and group_size("player") > 0 then 
    -- local grp = "player"
    -- local pos = 0
    
    -- while objs[grp][pos] ~= nil do
      -- add(list_player, { rank = objs[grp][pos].score, name = objs[grp][pos].score})
    -- end
    -- list_player =  group("player")()
  -- else 
    -- return {{rank = my_player.score, name = "my player"}} 
  -- end
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
    local lname = list_player[index].id
    local lscore = list_player[index].score or 1
    
    add(sorted_list, {  rank = lrank, 
                        name = lname,
                        score = lscore})
    delat(list_player, index)
    rank = rank + 1
    
    
  end 
  
  
  -- local l = {}
  -- if leaderboard.small then
    -- for i = 1, 15 do 
      -- add(l, {rank = i, str = "player"..i})
    -- end
  -- else
      -- add(l, {rank = 1, str = "player"..1})
      -- add(l, {rank = 2, str = "player"..2})
      -- add(l, {rank = 3, str = "(".."player"..3})
      -- add(l, {rank = "..."})
      -- add(l, {rank = 8, str = "player"..8})
  -- end
  -- if sorted_list == {} or sorted_list == nil  then 
    -- sorted_list = {rank = "x", name ="no_name"}
  -- end
  
  -- if #sorted_list < 1 and sorted_list == {} or sorted_list == nil then
    -- sorted_list = {rank = "x", name ="no_name"}
  -- end
  
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

  leaderboard.is_large = true

end

function draw_leaderboard()
  
  local sx, sy = screen_size()
  
  local y = 3
  local x = 70
  draw_text_oultined("Leaderboard", sx - x, y, 0)
    
  local size = #leaderboard.list
  
  if not leaderboard.is_large then
    size = size > 5 and 5 or size
  end
 
  -- if big, will display everything
  -- if small and player <=5th, will display 5 first
  -- if small and player > 5th, will display 3 first, "..." + the player on the 5th line
 
  y = 8
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
    
    draw_text_oultined(str, sx - x, y + i*8 , c)
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

  leaderboard.victim = get_victim() -- Last player killed

  leaderboard.victimest = get_victimest() -- Player killed the most:

  leaderboard.killer = get_killer() -- Last Killer
  
  
end



-- leaderboard = {

  -- small = true,
  
  -- list = get_list_leaderboard(),

  -- victim = get_victim(), -- Last player killed

  -- victimest = get_victimest(), -- Player killed the most:

  -- killer = get_killer() -- Last Killer
  
-- }



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





