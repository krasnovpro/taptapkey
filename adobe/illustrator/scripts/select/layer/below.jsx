#target Illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

if (app.documents.length > 0) {
  doc = app.activeDocument;
  var currentlayer = doc.activeLayer;
  var currentlayernum = currentlayer.zOrderPosition;
  if (currentlayernum != 1) {
    doc.activeLayer = doc.layers[doc.layers.length - currentlayernum + 1];
  }
}