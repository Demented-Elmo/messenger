import { WebSocketServer } from 'ws';

const server = new WebSocketServer({ port: 8080 });
let leftCount = 1;
let conId = 0;
let list = 0;
let loc = [];
let connectionMap = new Map();
let hasMessage = true;

function getDistance(coord1, coord2) {
  const lat1 = coord1.latitude;
  const lon1 = coord1.longitude;
  const lat2 = coord2.latitude;
  const lon2 = coord2.longitude;

  const R = 6371;

  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  const distance = R * c;
  console.log(distance);
  return distance;
}

server.on('connection', function connection(ws) {
  list += 1;
  server.clients.forEach(function each(client) {
    client.send(list);
  });

  ws.connectionId = conId;
  connectionMap.set(conId, ws);
  conId++;

  if (leftCount > 0) {
    leftCount--;
  }

  ws.on('message', function incoming(data) {
    try {
      var incomingData = JSON.parse(data);
      var message = incomingData.message;
      var location = incomingData.location;

      if (location) {
        loc.push({
          key: location,
          value: ws.connectionId,
        });
        console.log("User Locations:", loc);

        loc.forEach((userLoc) => {
          if (userLoc.value !== ws.connectionId) {
            const distance = getDistance(location, userLoc.key);
            if (distance <= 0.001) {
              const otherUser = connectionMap.get(userLoc.value);
              if (otherUser && otherUser.readyState === WebSocket.OPEN) {
                otherUser.send("m" + message);
              }
            }
          }
        });
      }

      if (hasMessage && message) {
        console.log(message);
        server.clients.forEach(function each(client) {
          if (client !== ws && client.readyState === WebSocket.OPEN) {
            //client.send("m" + message);
          }
        });
      } else {
        hasMessage = true;
      }
    } catch (error) {
      console.log(error + "\n");
      console.log('OUTDATED MESSAGE FORMAT!');
      console.log('Received message: ' + data);

      server.clients.forEach(function each(client) {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send("m" + data);
        }
      });
    }
  });

  ws.on('close', () => {
    let removeId = ws.connectionId;
    connectionMap.delete(removeId);
    for (i = 0; i < conId; i++) {
      const filter = i;
      const filtered = filter - 1;
      if (filter > removeId) {
        connectionMap.set(filtered, connectionMap.get(filter));
      }
    }

    removeId = ws.connectionId - leftCount;
    loc = loc.filter((item) => item.value !== removeId);
    loc.forEach((item) => {
      if (item.value > removeId) {
        item.value -= 1;
        leftCount++;
      }
    });

    list--;
    conId--;
    if (list == 0) {
      loc = [];
      leftCount = 1;
      conId = 0;
    }
    console.log("User Locations:", loc);
    server.clients.forEach(function each(client) {
      client.send(list);
    });
  });
});