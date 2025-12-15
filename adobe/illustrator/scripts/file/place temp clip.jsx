//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

if (app.documents.length > 0) {
  var clip = new File(Folder.temp + '/clip.png');
  if (clip.exists) {
    doc = app.activeDocument;
    var placedItem = doc.placedItems.add();
    placedItem.file = clip;
    placedItem.embed();
  } else 
    alert("File '%temp%/clip.png' not found", "Error", true);
}