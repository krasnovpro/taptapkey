//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false); // Fix drag and drop a .jsx file

function main() {
  if (!app.documents.length) return;

  var selPaths = getPaths(app.selection);
  if (!selPaths.length) return;

  for (var i = 0, len = selPaths.length; i < len; i++) {
    if (!selPaths[i].hasOwnProperty('pathPoints')) {
      continue;
    }
    // Deselect first point
    selPaths[i].pathPoints[0].selected = PathPointSelection.NOSELECTION;
  }
}

// Get paths from selection
function getPaths(coll) {
  var out = [];
  for (var i = 0; i < coll.length; i++) {
    var item = coll[i];
    if (item.pageItems && item.pageItems.length) {
      out = [].concat(out, getPaths(item.pageItems));
    } else if (/compound/i.test(item.typename) && item.pathItems.length) {
      out = [].concat(out, getPaths(item.pathItems));
    } else if (/pathitem/i.test(item.typename)) {
      out.push(item);
    ///} else {
    ///item.selected = false;
    }
  }
  return out;
}

// Run script
try {
  main();
} catch (e) {}