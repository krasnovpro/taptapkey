var tempPath = $.getenv("TEMP");
var filePath = tempPath + "/clip.png";

var file = new File(filePath);
if (!file.exists) {
  alert("File not found: " + filePath);
  throw new Error("Missing file");
}

if (app.documents.length === 0) {
  app.documents.add();
}

var doc = app.activeDocument;

function placeEmbedded(fileObj) {
  var desc = new ActionDescriptor();
  desc.putPath(charIDToTypeID("null"), fileObj);
  executeAction(stringIDToTypeID("placeEvent"), desc, DialogModes.NO);

  try {
    var idconfirm = charIDToTypeID("Ok  ");
    executeAction(idconfirm, undefined, DialogModes.NO);
  } catch (e) {

  }
}

placeEmbedded(file);
