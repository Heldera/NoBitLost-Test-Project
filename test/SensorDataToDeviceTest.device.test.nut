class SensorDataToDeviceTest extends ImpTestCase {    

     /**
     * This class provides a mock implementation of a
     * server logger allowing to check calls to logger
     * in methods under test
     */
    MockedServerLogger = class {

        callsStats = {};
        
        constructor() {
            callsStats = {};
        }
    
        /**
         * Mock implementation of log method
         */
        function log(message) {
            _logCall("log", message);
        }
        
        /**
         * Private method that count calls to the 
         * mocked methods
         */
        function _logCall(method, message) {
            if (!this.callsStats.rawin(method)) {
                this.callsStats.rawset(method, array());
            }
                
            this.callsStats[method].append(message);
            
        }
        
        /**
         * Method allows checking were some
         * methods called or not
         */
        function methodWasCalled(method) {
            local result = false;
            
            if (this.callsStats.rawin(method)) {
                result = true;
            }
            
            return result;
        }
        
        /**
         * This method allows to check were there any calls
         * for mocked method with specified sub-string in
         * the logged message
         */
        function methodWasCalledMessagePart(method, messagePart) {
            local result = false;
            
            if (this.callsStats.rawin(method)) {
                local callsCount = this.callsStats[method].len();
                for (local i = 0; i < callsCount; i++) {
                    if (this.callsStats[method][i].find(messagePart) != null) {
                        result = true;
                    }
                }
            }
            
            return result;
        }
    }

    //----------------------------------------
    // Internal members of the test class to
    // be used during tests execution
    //----------------------------------------
    _testTempHumidSensor = null;
    _testLed             = null;
    _testLogger          = null;

    //----------------------------------------
    // Group of system BDD methods required 
    // for writing fancy tests
    //----------------------------------------
    
    //----------------------------------------
    // Preconditions (Givens)
    //----------------------------------------

    function givenTestMockedLogger() {
        this._testLogger =
                    MockedServerLogger();    
    }

    function givenTestHumidSensorReadCorrectData(){
        this._testTempHumidSensor = {
            function read(callback){
                local data = {temperature = 10};
                callback(data);
            }
        };
    }

    function givenTestProperlyWorkingLed(){
        this._testLed = {
            function set(a,b){
                return {
                    function draw(){

                    }
                }
            }
        };
    }

    //----------------------------------------
    // Under-test invocations (Whens)
    //----------------------------------------

    function whenGetDataIsCalled(){
        local testDC = DeviceClass( this._testTempHumidSensor, 
                                    this._testLed, 
                                    this._testLogger
                                    );
        testDC.getData();
    }

    //----------------------------------------
    // Validations (Thens)
    //----------------------------------------

    function thenLedColorChangeProperlyLogged(){
        assertTrue(this._testLogger.methodWasCalledMessagePart(
                                        "log", 
                                        "New color is: "));
    }

    //----------------------------------------
    // BDD tests methods section
    //----------------------------------------

    function testGetDataWithCorrectSensorAndLed(){
        givenTestHumidSensorReadCorrectData();
        givenTestProperlyWorkingLed();
        givenTestMockedLogger();

        whenGetDataIsCalled();

        thenLedColorChangeProperlyLogged();
    }

    function testMe() {
        this.assertTrue(true); 
    }
    
    function tearDown() {
        // Clean-up here
    }
}
