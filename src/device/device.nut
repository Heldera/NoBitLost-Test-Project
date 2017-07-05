#require "ws2812.class.nut:3.0.0"
#require "Si702x.class.nut:1.0.0"
// How long to wait between taking readings
const INTERVAL_SECONDS = 10;

// Set up global variables
spi <- null;
led <- null;
colors <- null;
current <- 0;
currentMode <- null;
currentColor <- null;

enum modes{
	blink,          //(0,0,0) -> (1,1,1) -> (0,0,0)
	sequential,     //(0,0,0) -> (0,0,1) -> (0,1,0) -> (0,1,1) -> (1,0,0) ->(1,0,1) -> (1,1,0) -> (1,1,1)
	overlay,        //(0,0,0) -> (1,0,0) -> (1,1,0) -> (1,1,1) -> (0,1,1) ->(0,0,1) -> (0,0,0)
	random          //depends on time
};
currentMode = "random";

// Instance the Si702x and save a reference in tempHumidSensor
hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);
local tempHumidSensor = Si702x(hardware.i2c89);

// Set up the SPI bus the RGB LED connects to
spi = hardware.spi257;
spi.configure(MSB_FIRST, 7500);
hardware.pin1.configure(DIGITAL_OUT, 1);

// Set up the RGB LED
led = WS2812(spi, 1);

//Fill array of led color
colors = {};
colors[0] <- [0,0,0];
colors[1] <- [0,0,255];
colors[2] <- [0,255,0];
colors[3] <- [0,255,255];
colors[4] <- [255,0,0];
colors[5] <- [255,0,255];
colors[6] <- [255,255,0];
colors[7] <- [255,255,255];

currentColor = colors[0];

function getNextColor(mode){
	switch(mode){
		case "blink" : 
			blink(); 
			break;
		case "sequential": 
			sequential(); 
			break;
		case "overlay" : 
			overlay(); 
			break;
		default : 
			getRandomColor();
	}
	return colors[current];
}

function blink(){
	if(current == 0){
		current = 7;
	} else {
		current = 0;
	}
}

function sequential(){
	if(current == 7){
		current = 0;
	}else{
		current++;
	}
}

function overlay(){
	switch(current){
		case 0 : current = 4; break;
		case 4 : current = 6; break;
		case 6 : current = 7; break;
		case 7 : current = 3; break;
		case 3 : current = 1; break;
		default : current = 0;
	}
}

function getRandomColor(){
    local t = time();
    current = t % 8;
}

function reportData(data) {
    agent.send("senddata", data );
}

function updateLedMode(mode){
    if(mode != currentMode){
        currentMode = mode;
    }
}

function setLedState(colorRGB) {
    led.set(0, colorRGB).draw();
    server.log("New color is: " + colorRGB[0] + " " + colorRGB[1] + " " + colorRGB[2]);
}

function getData(){
    currentColor <- getNextColor(currentMode);
    setLedState(currentColor);
    
    tempHumidSensor.read(getLedStatusAndReportTemp);
    //sec
    imp.wakeup(INTERVAL_SECONDS, getData);
}

function getLedStatusAndReportTemp(reading) {
    if ("err" in reading) {
            // if an error is detected, log the error message so we can fix it
            server.error("Error reading temperature: " + reading.err);
        } else {

            local data = {};
    
            data.ledColor  <- currentColor;
            
            data.ledMode <- currentMode;
            // Send the imp's unique device ID as the key for our data stream
            data.id <- hardware.getdeviceid();
        
            data.temp <- reading.temperature;
        
            
            reportData(data);
        }
}

agent.on("updateMode", updateLedMode);
getData();