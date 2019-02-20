
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
    client.home[2] = my_player.dx_input --(btn(0) and -1) + (btn(1) and 1)
    client.home[3] = my_player.dy_input --(btn(2) and -1) + (btn(3) and 1)
    
    if my_player.shot_input then
      shot_id = shot_id + 1
      client.home[4] = shot_id
    end
    
    client.home[5] = my_player.aim_input
  end
end

function client_connect()
  castle_print("Connected to server!")
  
  my_id = client.id
end

function client_disconnect()
  castle_print("Disconnected from server!")
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
      create_player(id, p_d[1], p_d[2])
    end
    local p = player_list[id]
    
    p.vx = p_d[3]
    p.vy = p_d[4]
    
    local x = p_d[1] + delay*p.vx
    local y = p_d[2] + delay*p.vy
    p.x = x
    p.y = y
    
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
      kill_bullet(b)
      bullet_list[b] = nil
    end
  end
  
  for id,b_d in pairs(bullet_data) do  -- syncing players with server data
    if not bullet_list[id] then
      create_bullet(b_d[5], id)
    end
    local b = bullet_list[id]
    
    b.vx = b_d[3]
    b.vy = b_d[4]
    
    local x = b_d[1] + delay*b.vx
    local y = b_d[2] + delay*b.vy
    b.x = x
    b.y = y
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
      player.dx_input = ho[2]
      player.dy_input = ho[3]
      player.shot_input = (ho[4] > shot_ids[id])
      shot_ids[id] = ho[4]
      player.angle = ho[5]
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
      p.vx, p.vy,
      p.alive,
      p.angle,
      p.score
    }
  end
  
  local bullet_data = server.share[3]
  for id,b in pairs(bullet_list) do
    bullet_data[id] = {
      b.x, b.y,
      b.vx, b.vy,
      b.from
    }
  end
  
  local destroyable_data = server.share[3]
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
end

function server_lost_client(id)
  castle_print("Client #"..id.." disconnected.")
  
  local player = player_list[s.id]
  if player then
    kill_player(player)
    deregister_player(player)
    player_list[s.id] = nil
    server.share[2][s.id] = nil
  end
end



