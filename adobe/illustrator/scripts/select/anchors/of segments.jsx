// Select anchors of selected segments of path
//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false); // Fix drag and drop a .jsx file

function main() {
  if (!app.documents.length) return;

  var selPaths = getPaths(app.selection);

  var selPoints = [];
  for (var i = 0; i < selPaths.length; i++) {
    selPoints = [].concat(selPoints, selPaths[i].selectedPathPoints);
  }

  app.selection = null;

  for (var j = 0; j < selPoints.length; j++) {
    selPoints[j].selected = PathPointSelection.ANCHORPOINT;
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
    } else {
      item.selected = false;
    }
  }
  return out;
}

// Run script
try {
  main();
} catch (e) {}