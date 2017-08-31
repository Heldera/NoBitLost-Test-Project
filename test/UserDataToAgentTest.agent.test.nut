class UserDataToAgentTest extends ImpTestCase {    

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
    _testMockedHttpClient = null;
    _testMockedLogger     = null;
    
    //----------------------------------------
    // Group of system BDD methods required 
    // for writing fancy tests
    //----------------------------------------
    
    //----------------------------------------
    // Preconditions (Givens)
    //----------------------------------------
    function givenHttpClientReturningNotFound() {
        this._testMockedHttpClient = {
            function get(url, header) {
                return {
                    function sendsync() {
                        return {
                            statuscode = 404
                        }
                    }
                }
            }
        }
    }

    function givenHttpClientReturningResponseWithoutWithField() {
        this._testMockedHttpClient = {
            function get(url, header) {
                return {
                    function sendsync() {
                        return {
                            statuscode = 200,
                            body = "{}"
                        }
                    }
                }
            }
        }
    }

    function givenHttpClientReturningResponseWithEmptyWithField() {
        this._testMockedHttpClient = {
            function get(url, header) {
                return {
                    function sendsync() {
                        return {
                            statuscode = 200,
                            body = 
                              "{\"with\":[]}"
                        }
                    }
                }
            }
        }
    }
    
    function givenTestMockedLogger() {
        this._testMockedLogger =
                    MockedServerLogger();    
    }

    //----------------------------------------
    // Under-test invocations (Whens)
    //----------------------------------------
    function whenUpdateModeIsCalled() {
        local testAC = AgentClass(this._testMockedHttpClient, 
                             this._testMockedLogger);
        testAC.updateMode();
    }
    
    //----------------------------------------
    // Validations (Thens)
    //----------------------------------------
    function thenLoggerCalledWithMessageContainingStatusCodeNotFound() {
        assertTrue(
            this._testMockedLogger.methodWasCalledMessagePart(
                                        "log", 
                                        "404"));
    }
    
    function thenLoggerCalledWithMessageAboutMissingWithField() {
        assertTrue(
            this._testMockedLogger.methodWasCalledMessagePart(
                                        "log", 
                                        "Field \"with\" is missing"));
    }
    
    function thenLoggerCalledWithMessageAboutEmptyWithField() {
        assertTrue(
            this._testMockedLogger.methodWasCalledMessagePart(
                                        "log", 
                                        "Field \"with\" is empty"));
    }
    
    //----------------------------------------
    // BDD tests methods section
    //----------------------------------------
    function testAgentShouldLogStatusCodeIfHttpRequestWasNotSuccessful() {
        givenHttpClientReturningNotFound();
        givenTestMockedLogger();
        
        whenUpdateModeIsCalled();
        
        thenLoggerCalledWithMessageContainingStatusCodeNotFound();
    }
    
    function testAgentShouldLogErrorProperlyIfDweetResponseHasNoWithField() {
        givenHttpClientReturningResponseWithoutWithField();
        givenTestMockedLogger();
        
        whenUpdateModeIsCalled();
        
        thenLoggerCalledWithMessageAboutMissingWithField();
    }
    
    function testAgentShouldLogErrorProperlyIfDweetResponseHasEmptyWithField() {
        givenHttpClientReturningResponseWithEmptyWithField();
        givenTestMockedLogger();
        
        whenUpdateModeIsCalled();
        
        thenLoggerCalledWithMessageAboutEmptyWithField();
    }

	function tearDown() {
        // Clean-up here
    }
}
