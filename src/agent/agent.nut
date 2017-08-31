@include "github:electricimp/JSONEncoder/JSONEncoder.class.nut"
@include "github:electricimp/JSONParser/JSONParser.class.nut"

const INTERVAL_SECONDS = 3;
const PUSH_DATA_URL = "https://dweet.io/dweet/for/Owl01";
const RECIEVE_FEEDBACK_URL = "https://dweet.io/get/dweets/for/Owl01_callback";

class AgentClass {

    lastModeChanged ="random";

    _http = null;
    _logger = null;

    constructor(httpClient, logger) {
        this._http = httpClient;
        this._logger = logger;
    }

    function _httpPostWrapper(url, headers, string) {
        local request = _http.post(url, headers, string);
        local response = request.sendsync();
        return response;
    }

    function logMessage(data) {
        local str = JSONEncoder.encode(data);
        _httpPostWrapper(PUSH_DATA_URL, {"Content-Type" : "application/json"}, str);
    }

    function _httpGetWrapper(url, header) {
        local request = _http.get(url, header);
        local response = request.sendsync();
        return response;
    }

    function updateMode() {
        local callback = _httpGetWrapper(RECIEVE_FEEDBACK_URL, {"Content-Type" : "application/json"});
        if(callback.statuscode == 200){
            local responsObj = (JSONParser.parse(callback.body));
            if (responsObj.rawin("with")) {
                if (responsObj.with.len() > 0) {
                    local callbackMode = responsObj.with[0].content.mode;
                    if(lastModeChanged != callbackMode){
                        device.send("updateMode", callbackMode);
                        lastModeChanged = callbackMode;
                    }
                } else {
                    _logger.log("Field \"with\" is empty");   
                }
            } else {
                _logger.log("Field \"with\" is missing");
            }
        } else {
            _logger.log("dweet statuscode : " + callback.statuscode);
        }
        
        imp.wakeup(INTERVAL_SECONDS, updateMode.bindenv(this));
    }
}

_ac <- AgentClass(http, server);
device.on("senddata", _ac.logMessage.bindenv(_ac));
