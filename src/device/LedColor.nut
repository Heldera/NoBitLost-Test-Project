enum modes {
		blink = "blink",          //(0,0,0) -> (1,1,1) -> (0,0,0)
		sequential = "sequential",     //(0,0,0) -> (0,0,1) -> (0,1,0) -> (0,1,1) -> (1,0,0) ->(1,0,1) -> (1,1,0) -> (1,1,1)
		overlay = "overlay",        //(0,0,0) -> (1,0,0) -> (1,1,0) -> (1,1,1) -> (0,1,1) ->(0,0,1) -> (0,0,0)
		random = "random"          //depends on time
}

local LedColor = {
	current = 0,

	function getNextColor(mode) {
		switch(mode) {
			case modes.blink : 
				_blink(); 
				break;
			case modes.sequential : 
				_sequential(); 
				break;
			case modes.overlay : 
				_overlay(); 
				break;
			default : 
				_getRandomColor();
		}
		
		return Color.getColorByID(current);
	},
	
	// -------------------- PRIVATE METHODS -------------------- //

	function _blink() {
		if (current == 0) {
			current = 7;
		} else {
			current = 0;
		}
	},

	function _sequential() {
		if (current == 7){
			current = 0;
		} else {
			current++;
		}
	},

	function _overlay() {
		switch(current) {
			case 0 : current = 4; break;
			case 4 : current = 6; break;
			case 6 : current = 7; break;
			case 7 : current = 3; break;
			case 3 : current = 1; break;
			default : current = 0;
		}
	},

	function _getRandomColor() {
	    local t = time();
	    current = t % 8;
	}
}