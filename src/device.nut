@include "github:electricimp/WS2812/WS2812.class.nut"
@include "github:electricimp/Si702x/Si702x.class.nut"
@include "github:electricimp/HTS221/HTS221.device.lib.nut"

@include "src/Color.nut"
@include "src/LedColor.nut"

// How long to wait between taking readings
const INTERVAL_SECONDS = 10;

class DeviceClass {

    _tempHumidSensor = null;
    _led = null;
    _logger = null;
    _currentMode = "random";
    
    constructor(tempHumidSensor, led, logger){
        this._tempHumidSensor = tempHumidSensor;        
        this._led = led;
        this._logger = logger;

    }

    function updateLedMode(mode) {
    	_logger.log("last mode " + _currentMode);
    	_logger.log("new mode " + mode);
        if(mode != _currentMode) {
            _currentMode = mode;
        }
    }

    function getData() {
        local color = LedColor.getNextColor(_currentMode);
        Color.setCurrentColor(color);
        _setLedState(color);
        
        _tempHumidSensor.read(_getLedStatusAndReportTemp.bindenv(this));

        imp.wakeup(INTERVAL_SECONDS, getData.bindenv(this));
    }

    // -------------------- PRIVATE METHODS -------------------- //

    function _setLedState(colorRGB) {
        _logger.log("New color is: " + Color.printCurrentColor());
        _led.set(0, colorRGB).draw();
    }

    function _getLedStatusAndReportTemp(reading) {
        if ("err" in reading) {
            // if an error is detected, log the error message so we can fix it
            _logger.error("Error reading temperature: " + reading.err);
        } else {

            local data = {};
        
            data.ledColor  <- Color.getCurrentColor();
                
            data.ledMode <- _currentMode;
            // Send the imp's unique device ID as the key for our data stream
            data.id <- hardware.getdeviceid();
            
            data.temp <- reading.temperature;
                
            _reportData(data);
        }
    }

    function _reportData(data) {
        agent.send("senddata", data);
    }
}

function getHumidSensorHardwareConfiguration(){
    // Instance the Si702x and save a reference in tempHumidSensor
    hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);
    local tempHumidSensor = HTS221(hardware.i2c89);
    tempHumidSensor.setMode(HTS221_MODE.ONE_SHOT, 0);
    return tempHumidSensor;
}

function getLedHardwareConfiguration(){
    // Set up the SPI bus the RGB LED connects to
    local spi = hardware.spi257;
    spi.configure(MSB_FIRST, 7500);
    hardware.pin1.configure(DIGITAL_OUT, 1);
    // Set up the RGB LED
    return WS2812(spi, 1);
}

_dc <- DeviceClass(getHumidSensorHardwareConfiguration(), 
                    //HTS221(hardware.i2c89),
                    getLedHardwareConfiguration()
                    server
                    );
_dc.getData();

agent.on("updateMode", _dc.updateLedMode.bindenv(_dc));
