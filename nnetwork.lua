
network_t = 0
delay = 0

my_faction = nil

local shot_id, shot_ids
local my_player

function init_network()
  if server_only then
    shot_ids = {}
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
    
    if my_player.shoot_input then
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
  

end


function server_output()
--  if not server then
--    return
--  end
  
  server.share[1] = {} -- timestamps
  for id,h in pairs(server.homes) do
    server.share[1][id] = h[1]
  end

  
end

function server_new_client(id)
  castle_print("New client: #"..id)
end

function server_lost_client(id)
  castle_print("Client #"..id.." disconnected.")
end



