#target Illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

if (app.documents.length > 0) {
  doc = app.activeDocument;
  var Layername = prompt("Name your layer", "Layer name");
  var newLayer = doc.layers.add();
  newLayer.name = Layername;
  newLayer.zOrder.BRINGTOFRONT;
}