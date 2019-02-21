
network_t = 0
delay = 0
my_id = nil

local shot_id, shot_ids

function init_network()
  if server_only then
    shot_ids = {}
    server.share[2] = {} -- players
    server.share[3] = {} -- bullets
    server.share[4] = {} -- destroyables
  else
    shot_id = 0
    client.home[4] = shot_id
  end
end

function update_network()
  network_t = network_t - delta_time
  if network_t > 0 then
    return
  end
  
  if server_only then
    server_output()
  else
    client_output()
  end
  
  network_t = 0.05
end



function client_input(diff)
--  if not (client and client.connected) then
--    return
--  end
  my_id = client.id
  
  if client.share[1] then
    local timestamp = client.share[1][client.id]
    if timestamp then
      delay = (love.timer.getTime() - timestamp) / 2
    end
  end
  
  sync_players(client.share[2])
  sync_bullets(client.share[3])
  sync_destroyables(client.share[4])
end

function client_output()
--  if not (client and client.connected) then
--    return
--  end
  
  client.home[1] = love.timer.getTime()
  
  local my_player = player_list[client.id]
  if my_player then
    client.home[2] = my_player.dx_input
    client.home[3] = my_player.dy_input
    
    --if my_player.shot_input then
    --  shot_id = shot_id + 1
    --  client.home[4] = shot_id
    --  debuggg = "shoot!"
    --end
    
    client.home[5] = my_player.angle
  end
end

function client_connect()
  castle_print("Connected to server!")
  
  my_id = client.id
end

function client_disconnect()
  castle_print("Disconnected from server!")
end

function client_shoot()
  shot_id = shot_id + 1
  client.home[4] = shot_id
end

function sync_players(player_data)
  if not player_data then return end
  
  for id,p in pairs(player_list) do  -- checking if any player no longer exists
    if not player_data[id] then
      kill_player(p)
      deregister_object(p)
      player_list[p.id] = nil
    end
  end
  
  for id,p_d in pairs(player_data) do  -- syncing players with server data
    if not player_list[id] then
      castle_print("New player: id="..id)
      debuggg = "New player: id="..id
      create_player(id, p_d[1], p_d[2])
    end
    local p = player_list[id]
    
    local x = p_d[1] + delay * p_d[3]
    local y = p_d[2] + delay * p_d[4]
    
    if id == my_id then
      p.rx = x
      p.ry = y
    else
      p.v.x = p_d[3]
      p.v.y = p_d[4]
      
      local x = p_d[1] + delay * p_d[3]
      local y = p_d[2] + delay * p_d[4]
      
      p.diff_x = p.diff_x + p.x - x
      p.diff_y = p.diff_y + p.y - y
      
      p.x = x
      p.y = y
    end
    
    if p.alive and not p_d[5] then
      kill_player(p)
    end
    
    p.score = p_d[6]
  end
end

function sync_bullets(bullet_data)
  if not bullet_data then return end
  
  for id,b in pairs(bullet_list) do  -- checking if any player no longer exists
    if not bullet_data[id] then
--      kill_bullet(b)
--      bullet_list[b] = nil
    end
  end
  
  for id,b_d in pairs(bullet_data) do  -- syncing players with server data
    if not bullet_list[id] then
      create_bullet(b_d[5], id)
    end
    local b = bullet_list[id]
    
    if b then
      b.v.x = b_d[3]
      b.v.y = b_d[4]
      
      local x = b_d[1] + delay*b.v.x
      local y = b_d[2] + delay*b.v.y
      b.diff_x = b.diff_x + b.x - x
      b.diff_y = b.diff_y + b.y - y
      b.x = x
      b.y = y
    end
  end
end

function sync_destroyables(destroyable_data)
  if not destroyable_data then return nil end

  for id,d_d in pairs(destroyable_data) do  -- syncing players with server data
    if not destroyable_list[id] then
      create_destroyable(id, d_d[1], d_d[2])
    end
    local d = destroyable_list[id]
    
    d.alive = d_d[3]
  end
end




function server_input()
--  if not server then
--    return
--  end
  
  for id,ho in pairs(server.homes) do
    local player = player_list[id]
    if player then
      player.dx_input = ho[2] or 0
      player.dy_input = ho[3] or 0
      
      if ho[4] > shot_ids[id] then
        castle_print("Player #"..id.." shot! "..ho[4])
      end
      
      player.shot_input = (ho[4] > shot_ids[id])
      shot_ids[id] = ho[4] or 0
      player.angle = ho[5] or 0
    end
  end
end

function server_output()
--  if not server then
--    return
--  end
  
  server.share[1] = {} -- timestamps
  for id,ho in pairs(server.homes) do
    server.share[1][id] = ho[1]
  end
  
  local player_data = server.share[2]
  for id,p in pairs(player_list) do
    player_data[id] = {
      p.x, p.y,
      p.v.x, p.v.y,
      p.alive,
      p.angle,
      p.score
    }
  end
  
  local bullet_data = server.share[3]
  for id,b in pairs(bullet_list) do
    bullet_data[id] = {
      b.x, b.y,
      b.v.x, b.v.y,
      b.from
    }
  end
  
  local destroyable_data = server.share[4]
  for id,d in pairs(destroyable_list) do
    destroyable_data[id] = {
      d.x, d.y,
      d.alive
    }
  end
end

function server_new_client(id)
  castle_print("New client: #"..id)
  
  create_player(id)
  shot_ids[id] = 0
end

function server_lost_client(id)
  castle_print("Client #"..id.." disconnected.")
  
  local player = player_list[id]
  if player then
    kill_player(player)
    deregister_object(player)
    player_list[id] = nil
    server.share[2][id] = nil
  end
end



