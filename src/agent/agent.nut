#require "Dweetio.class.nut:1.0.1"

// Create a Dweet instance
local client = DweetIO();

// Log the URLs we need
server.log("Turn LED On: " + http.agenturl() + "?led=1");
server.log("Turn LED Off: " + http.agenturl() + "?led=0");

function logMessage(data) {
    server.log("I'm happy owl with temp = " + data.temp);
    client.dweet("Owl01", data, function(response) {
    server.log(response.statuscode + ": " + response.body);
});
}

device.on("senddata", logMessage);
