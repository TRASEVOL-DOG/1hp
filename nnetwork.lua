
network_t = 0
delay = 0

my_faction = nil

local shot_id, shot_ids
local my_player

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
  
end

function client_output()
--  if not (client and client.connected) then
--    return
--  end
  
  client.home[1] = love.timer.getTime()
  
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
end

function client_disconnect()
  castle_print("Disconnected from server!")
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

  player_data = server.share[2]
  for id,p in pairs(player_list) do
    player_data[id] = {
      p.x, p.y,
      p.vx, p.vy,
      p.alive,
      p.angle,
      p.score
    }
  end
  
--  bullet_data = server.share[3]
--  for id,b in pairs(bullet_list) do
--    bullet_data[id] = {
--      b.x, b.y,
--      b.vx, b.vy
--    }
--  end
--  
--  destroyable_data = server.share[3]
--  for id,d in pairs(destroyable_list) do
--    destroyable_data[id] = {
--      d.x, d.y,
--      d.alive
--    }
--  end
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



