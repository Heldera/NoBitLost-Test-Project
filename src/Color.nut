local Color = {
	
	_colors = null,
	_currentColor = null,
	
	function getCurrentColor() {
		return _currentColor;
	},

	function setCurrentColor(color){
		this._currentColor = color;
	}

	/**
	* This method returns...
	* @param...
	* @return ...
	*/
	function getColorByID(i) {
		
		if(_colors == null){
			_colors = _fillColorsArray();
		}
		
		if((0 <= i) && (i < _colors.len())){
			_currentColor = _colors[i];
		}

		return _currentColor;
	},

	function printColorByID(i) {
		local color = getColorByID(i);
		
		if(color == null){
			//???
		} 
		
		return _toString(color);
	},

	

	function printCurrentColor() {
		return _toString(_currentColor);
	},

	// -------------------- PRIVATE METHODS -------------------- //
	
	//Fill array of led color
	function _fillColorsArray() {
		local _colors = {};
		server.log("color array was updated");
		_colors[0] <- [0,0,0];
		_colors[1] <- [0,0,255];
		_colors[2] <- [0,255,0];
		_colors[3] <- [0,255,255];
		_colors[4] <- [255,0,0];
		_colors[5] <- [255,0,255];
		_colors[6] <- [255,255,0];
		_colors[7] <- [255,255,255];
		
		return _colors;
	},

	function _toString(color) {
		/*We can trust to recieved argument, because it is private function 
		and before we keep its value from another private method*/

		return " red : " + color[0] 
			+ " green : " + color[1]
			+ " blue : " + color[2];
	}
}
