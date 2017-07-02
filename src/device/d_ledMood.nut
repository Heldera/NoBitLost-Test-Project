colors <- null;
current <- 0;

enum modes{
	blink, //(0,0,0) -> (1,1,1) -> (0,0,0)
	sequential, //(0,0,0) -> (1,0,0) -> (0,1,0) -> (0,0,1) -> (0,0,0)
	overlay, //(0,0,0) -> (1,0,0) -> (1,1,0) -> (1,1,1) -> (0,1,1) ->(0,0,1) -> (0,0,0)
	random //depends on time
};

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


function getColor(modes mode){
	switch(mode){
		case blink : 
			blink(); 
			break;
		case sequential : 
			sequential(); 
			break;
		case overlay : 
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
    return colors[t % 8];
}