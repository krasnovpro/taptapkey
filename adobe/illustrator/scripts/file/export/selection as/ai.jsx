#target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

function main() {
  var fileName = "export.ai";
  var myFile = File(Folder.temp.absoluteURI + "/" + fileName);
  var sel = app.activeDocument.selection;
  if (sel.length > 0) {
    saveSelection(sel, myFile);
  } else {
    alert('Selection is empty');
  }
}

// Copy selection to a new document, and save it as an AI file.
function saveSelection(sel, file) {
  var doc = app.documents.add(DocumentColorSpace.RGB);
  app.coordinateSystem = CoordinateSystem.ARTBOARDCOORDINATESYSTEM;
  copyObjectsTo(sel, doc);

  // Resize the artboard to the object
  selectAll(doc);
  doc.artboards[0].artboardRect = doc.visibleBounds;

  // Save as AI
  doc.saveAs(file, IllustratorSaveOptions);
  doc.close();
}

// Duplicate objects and add them to a document.
function copyObjectsTo(objects, destinationDocument) {
  for (var i = 0; i < objects.length; i++) {
    objects[i].duplicate(destinationDocument.activeLayer, ElementPlacement.PLACEATBEGINNING);
  }
}

// Selects all PageItems in the doc
function selectAll(doc) {
  var pageItems = doc.pageItems,
    numPageItems = doc.pageItems.length;
  for (var i = 0; i < numPageItems; i++) {
    pageItems[i].selected = true;
  }
}

try {
  if (app.documents.length > 0) {
    main();
  } else {
    alert('There are no documents open.');
  }
} catch (e) { }