// top view isometric piece
#target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

var deg = Math.PI / 180;
var cos30 = Math.cos(30 * deg); // var cos30 = 0.866;
var tan30 = Math.tan(30 * deg); // var tan30 = 0.577;

var doc = app.activeDocument;
var rotationAngle = 30;
var resizeRatio = 100 / cos30;
var im = app.getIdentityMatrix();
im.mValueC = - tan30;

for (i = 0; i < doc.selection.length; i++) {
  sel = doc.selection[i];
  sel.rotate(rotationAngle);
  sel.transform(im, true, true, true, true, 1, undefined);
  sel.resize(100, resizeRatio);
}

