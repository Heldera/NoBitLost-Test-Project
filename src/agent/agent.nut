#require "JSONEncoder.class.nut:2.0.0"
#require "JSONParser.class.nut:1.0.0"

const INTERVAL_SECONDS = 3;
const PUSH_DATA_URL = "https://dweet.io/dweet/for/Owl01";
const RECIEVE_FEEDBACK_URL = "https://dweet.io/get/dweets/for/Owl01_callback";

function httpPostWrapper (url, headers, string) {
    local request = http.post(url, headers, string);
    local response = request.sendsync();
    return response;
}

function logMessage(data) {
    local str = JSONEncoder.encode(data);
	httpPostWrapper(PUSH_DATA_URL, {"Content-Type" : "application/json"}, str);
}

function httpGetWrapper (url, header) {
    local request = http.get(url, header);
    local response = request.sendsync();
    return response;
}

function updateMode(){
    local callback = httpGetWrapper(RECIEVE_FEEDBACK_URL, {"Content-Type" : "application/json"});
    
    local callbackMode = (JSONParser.parse(callback.body)).with[0].content.mode;
    device.send("updateMode", callbackMode);
    imp.wakeup(INTERVAL_SECONDS, updateMode);
}

device.on("senddata", logMessage);
updateMode();