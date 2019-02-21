
leaderboard = {}
my_place = 0

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
  local size = #list_player
  local while_condition = leaderboard.small and 5 or size -- we either want 5 entries or the entire list of players
  
  while while_condition > 0 do -- defined above
  
    local maxi = 0
    local index = 1
    
    for i, v in pairs(list_player) do
      if v.score > maxi then 
        maxi = v.score
        index = i
      end
      if v.id == my_id then
        my_place = index
      end
    end
    add(sorted_list, { rank = index, name = list_player[index].score})
    delat(list_player, index)
    
    while_condition = while_condition - 1
    
  end 
  
  if leaderboard.small then
    if my_place > 6 and #sorted_list > 3 then
        sorted_list[4].rank = "..."
      for i, v in pairs(list_player) do
        if v.id == my_id then sorted_list[4] = { rank = i, name = list_player[i]} end
      end 
    end
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

  leaderboard.small = true

end

function draw_leaderboard()
  
  local sx, sy = screen_size()
  
  local y = 3
  local x = 70
  draw_text_oultined("Leaderboard", sx - x, y)
    
  y = 8
  for i = 1, #leaderboard.list do
  
    local player = leaderboard.list[i]
    local c = my_place == i and 2 or 0
    local str = ""
    
    if player.rank ~= "..." then
        str = player.rank .. "." .. player.name
    else
        str = player.rank
    end
    draw_text_oultined(str, sx - x, y + i*8, c)
  end
  
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

end

function update_leaderboard()

  if btnp(5) then leaderboard.small = not leaderboard.small end
  
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





