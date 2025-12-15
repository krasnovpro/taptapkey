(function () {
  try {
    var selectedItems = app.activeDocument.selection;
    if (selectedItems.length) {
      for (var selIndex = 0; selIndex < selectedItems.length; selIndex++) {
        var selItem = selectedItems[selIndex];

        var doc = app.activeDocument;

        var docColorSpace = (doc.documentColorSpace === DocumentColorSpace.RGB) ? DocumentColorSpace.RGB : DocumentColorSpace.CMYK;

        var bounds = selItem.geometricBounds;

        var left = bounds[0];
        var top = bounds[1];
        var right = bounds[2];
        var bottom = bounds[3];

        var width = Math.abs(right - left);
        var height = Math.abs(top - bottom);

        // Define maximum safe dimension (in points)
        var MAX_DIMENSION = 16329;

        width = Math.abs(Math.max(1, Math.min(MAX_DIMENSION, Math.round(width))));
        height = Math.abs(Math.max(1, Math.min(MAX_DIMENSION, Math.round(height))));

        var temDoc = app.documents.add(docColorSpace, width, height);
        var nItem = selItem.duplicate(temDoc.layers[0], ElementPlacement.PLACEATEND);
        app.executeMenuCommand('Fit Artboard to artwork bounds')

        // Build timestamp in format yyyy-mm-dd_hh-mm-ss-ms (milliseconds)
        var now = new Date();
        function _pad(num, size) { var s = '000' + num; return s.substr(s.length - size); }
        var yyyy = now.getFullYear();
        var mm = _pad(now.getMonth() + 1, 2);
        var dd = _pad(now.getDate(), 2);
        var hh = _pad(now.getHours(), 2);
        var mi = _pad(now.getMinutes(), 2);
        var ss = _pad(now.getSeconds(), 2);
        var ms = _pad(now.getMilliseconds(), 3);
        var timestamp = yyyy + '-' + mm + '-' + dd + '_' + hh + '-' + mi + '-' + ss + '-' + ms;
        var fp = Folder.desktop.absoluteURI + '/export_' + timestamp + '.svg';

        var fileSpec = File(fp);

        var exportOptions = new ExportOptionsSVG();
        exportOptions.embedRasterImages = true;
        exportOptions.coordinatePrecision = 3;
        exportOptions.documentEncoding = SVGDocumentEncoding.UTF8;
        exportOptions.DTD = SVGDTDVersion.SVG1_0;
        exportOptions.cssProperties = SVGCSSPropertyLocation.STYLEELEMENTS;

        var type = ExportType.SVG;

        temDoc.exportFile(fileSpec, type, exportOptions);

        temDoc.close(SaveOptions.DONOTSAVECHANGES);
      }
    }

  } catch (e) {
    alert(e.message + "(" + e.line + ")");
  }
})();