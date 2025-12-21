//crazy-dash v3.jsx

/*
	this script makes a line or group of lines dashed, with random values within a user defined range
	it's kind of fun to use on lots and lots of lines at once. Why not use it with the spiderweb script or wall blazer?
	After all, who doesn't love a little randomness?
*/

//@target illustrator
var values = {
	maxdash: 20, //maxumum dash length
	mindash: 2, //minimum dash length
	maxgap: 20, //maxumum gap length
	mingap: 2,  //minimum gap length
	minStroke: 1, // minstroke and maxstroke define the range for the randomized stroke
	maxStroke: 3,
	dashes: 6	//this seems to be the maximum number of different dashes and gaps illustrator can use
};

var sel = app.activeDocument.selection;

if(sel.length == 0) {
	alert('Please select one or more paths and execute the script again.');	
} else {
	// specify values by prompt
	// 	values = {
	// 	maxdash: prompt("Maximum Dash (in points)", values.maxdash),
	// 	mindash: prompt("Minimum Dash (in points)", values.mindash),
	// 	maxgap: prompt("Maximum Gap (in points)", values.maxgap),
	// 	mingap: prompt("Miminimum Gap (in points)", values.mingap),
	// 	minStroke: prompt("Minimum stroke width (in points)", values.minStroke),
	// 	maxStroke: prompt("Maximum stroke width (in points)", values.maxStroke),
	// 	dashes: prompt("Amount of dashes", values.dashes)
	// };

	for (var i = 0; i < sel.length; i++) { //this loop cycles through all selected items
			var item = sel[i];
			item.strokeDashes = randomarray(); //apply a random stroke to the line
			item.strokeWidth = values.minStroke + Math.random() * (values.maxStroke - values.minStroke); // sets the random stroke
	}
}

function randomarray(){ //function for making an array of random numbers
	for (var i = 0; i < values.dashes; i+=2){
		var dasharray = [];
		dasharray.push(Math.random() * (values.maxdash - values.mindash) + values.mindash); //random value for the dash, between the numbers mindash and maxdash
		dasharray.push(Math.random() * (values.maxgap - values.mingap) + values.mingap); //random value for the dash, between the numbers mingap and maxgap
	}
	return dasharray;
}
