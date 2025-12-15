(function () {
  try {
    var doc = app.activeDocument;
    var selectedItems = doc.selection;
    if (!selectedItems || selectedItems.length === 0) {
      alert('No objects selected.');
      return;
    }

    var docColorSpace = (doc.documentColorSpace === DocumentColorSpace.RGB) ? DocumentColorSpace.RGB : DocumentColorSpace.CMYK;

    // Get size from first artboard as a safe initial canvas for the temp doc
    var abRect = doc.artboards[0].artboardRect;
    var abLeft = abRect[0];
    var abTop = abRect[1];
    var abRight = abRect[2];
    var abBottom = abRect[3];
    var abWidth = Math.abs(abRight - abLeft) || 1000;
    var abHeight = Math.abs(abTop - abBottom) || 1000;

    // Create one temporary document and duplicate all selected items into it
    var temDoc = app.documents.add(docColorSpace, abWidth, abHeight);

    for (var i = 0; i < selectedItems.length; i++) {
      try {
        selectedItems[i].duplicate(temDoc.layers[0], ElementPlacement.PLACEATEND);
      } catch (dupErr) {
        // Ignore single-item duplication errors and continue
      }
    }

    // Ensure the temp document is active, then fit artboard tightly to artwork bounds
    app.activeDocument = temDoc;
    app.executeMenuCommand('Fit Artboard to artwork bounds');

    var fp = Folder.temp.absoluteURI + '/export.svg';
    var fileSpec = new File(fp);

    var exportOptions = new ExportOptionsSVG();
    exportOptions.embedRasterImages = true;
    exportOptions.coordinatePrecision = 3;
    exportOptions.documentEncoding = SVGDocumentEncoding.UTF8;
    exportOptions.DTD = SVGDTDVersion.SVG1_0;
    exportOptions.cssProperties = SVGCSSPropertyLocation.STYLEELEMENTS;

    var type = ExportType.SVG;
    temDoc.exportFile(fileSpec, type, exportOptions);
    temDoc.close(SaveOptions.DONOTSAVECHANGES);

    // Restore the original document as active
    try {
      app.activeDocument = doc;
    } catch (e) {}
  } catch (e) {
    alert(e.message + '(' + e.line + ')');
  }
})();