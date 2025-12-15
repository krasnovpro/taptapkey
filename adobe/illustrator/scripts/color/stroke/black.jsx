#target Illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
if (app.documents.length > 0) {
	mySelection = activeDocument.selection;
	if (mySelection.length > 0) {
		var doc = app.activeDocument;                  //current document
		var sel = doc.selection;                       //current slection
		var sl = sel.length;                           //number of selected objects
		
    var newRGBColor = makeColor(0, 0, 0);

		for (var i = 0; i < sl; i++) {
			var clearme = sel[i];
			clearme.strokeColor = newRGBColor;
		}
		app.redraw();
		// }else{
		//     alert("Nothing selected!")
	}
}

function makeColor(r, g, b) {
  var c = new RGBColor();
  c.red = r;
  c.green = g;
  c.blue = b;
  return c;
}