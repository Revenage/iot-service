const mosca = require("mosca");

const ascoltatore = {
  type: "redis",
  redis: require("redis"),
  db: 12,
  port: 6379,
  return_buffers: true, // to handle binary payloads
  host: "localhost"
};

const moscaSettings = {
  port: 1883,
  backend: ascoltatore,
  persistence: {
    factory: mosca.persistence.Redis
    // host: 'your redis host',
    //port: 'your redis port'
  }
};

const server = new mosca.Server(moscaSettings);
server.on("ready", setup);

server.on("clientConnected", function(client) {
  console.log("client connected", client.id);
});

// fired when a message is received
server.on("published", function(packet, client) {
  console.log("Published", packet.topic, packet.payload.toString("utf-8"));
});

server.on("subscribed", function(topic, client) {
  console.log("subscribed : ", topic);
  // console.log("subscribed client: ", client.id);
});
// fired when a client unsubscribes to a topic
server.on("unsubscribed", function(topic, client) {
  console.log("unsubscribed : ", topic);
});
// fired when a client is disconnecting
server.on("clientDisconnecting", function(client) {
  console.log("clientDisconnecting : ", client.id);
});
// fired when a client is disconnected
server.on("clientDisconnected", function(client) {
  console.log("clientDisconnected : ", client.id);
});

// var authenticate = function(client, username, password, callback) {
//   var authorized = username === "alice" && password.toString() === "secret";
//   if (authorized) client.user = username;
//   callback(null, authorized);
// };

// // In this case the client authorized as alice can publish to /users/alice taking
// // the username from the topic and verifing it is the same of the authorized user
// var authorizePublish = function(client, topic, payload, callback) {
//   console.log("authorizePublish", client.user, topic);
//   callback(null, client.user == topic.split("/")[1]);
// };

// // In this case the client authorized as alice can subscribe to /users/alice taking
// // the username from the topic and verifing it is the same of the authorized user
// var authorizeSubscribe = function(client, topic, callback) {
//   console.log("authorizeSubscribe", client.user, topic);
//   callback(null, client.user == topic.split("/")[1]);
// };

// fired when the mqtt server is ready
function setup() {
  console.log("Mosca server is up and running");
  // server.authenticate = authenticate;
  // server.authorizePublish = authorizePublish;
  // server.authorizeSubscribe = authorizeSubscribe;
}
