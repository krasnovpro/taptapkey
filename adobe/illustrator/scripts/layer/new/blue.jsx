//script by chegr
//adds a new lyer and assigns a specified color to it (blue is 79,128,255)
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

#target Illustrator

if (app.documents.length > 0) {

    doc = app.activeDocument;

    var newLayer = doc.layers.add();

    newLayer.color.red   = 79;
    newLayer.color.green = 128;
    newLayer.color.blue  = 255;
}