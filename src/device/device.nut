#require "ws2812.class.nut:3.0.0"
#require "Si702x.class.nut:1.0.0"
// How long to wait between taking readings
const INTERVAL_SECONDS = 10;

// Set up global variables
spi <- null;
led <- null;
colors <- null;

// Instance the Si702x and save a reference in tempHumidSensor
hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);
local tempHumidSensor = Si702x(hardware.i2c89);

// Set up the SPI bus the RGB LED connects to
spi = hardware.spi257;
spi.configure(MSB_FIRST, 7500);
hardware.pin1.configure(DIGITAL_OUT, 1);

// Set up the RGB LED
led = WS2812(spi, 1);

function reportTemp(temp) {
    agent.send("senddata", temp );
}

// Define the loop flash function
function setLedState(state, colorRGB) {
    local color = state ? colorRGB : [0,0,0];
    led.set(0, color).draw();
    server.log("New color is: " + color[0] + " " + color[1] + " " + color[2]);
}

function getTemp() {
    // Create a Squirrel table to hold the data - handy if we 
    // later want to package up other data from other sensors
    local data = {};

    data.ledColor <- getColor(modes.blink);
    setLedState(true, data.ledColor);
    // Log the led color for debug
    server.log("Led setted color: " + data.ledColor[0]+" "+ data.ledColor[1]+" "+data.ledColor[2]);
    tempHumidSensor.read(function(reading) {
        // The read() method is passed a function which will be
        // called when the temperature data has been gathered.
        // This 'callback' function also needs to handle our
        // housekeeping: flash the LED to show a reading has
        // been taken; send the data to the agent; 
        // put the device to sleep
        
        // Check for errors returned from the sensor class
        // This can occur if hardware is defective or improperly connected
        if ("err" in reading) {
            // if an error is detected, log the error message so we can fix it
            server.error("Error reading temperature: "+reading.err);
        } else {
            // Get the temperature using the Si7020 object’s readTemp() method
            // Add the temperature using Squirrel’s 'new key' operator
            data.temp <- reading.temperature;
    
            // Send the imp's unique device ID as the key for our data stream
            data.id <- hardware.getdeviceid();
            
            // Log the temperature for debug
            server.log(format("Got temperature: %0.1f deg C", data.temp));
            
            
            // make owl happy
            reportTemp(data);
        }
    });

    //sec
    imp.wakeup(INTERVAL_SECONDS, getTemp);
}

getTemp();