app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
/**
 * Delete Selected Anchors
 * https://github.com/Inventsable/Delete-Selected-Anchors
 *
 * NOTES:
 *  - You must have anchors selected to remove them, this script ignores handles/directions
 */

// Polyfills to make scripting more like modern JS
Array.prototype.forEach = function (callback) {
  for (var i = 0; i < this.length; i++) callback(this[i], i, this);
};
Array.prototype.forEachReversed = function (callback) {
  for (var i = this.length - 1; i >= 0; i--) callback(this[i], i, this);
};
Array.prototype.filter = function (callback) {
  var filtered = [];
  for (var i = 0; i < this.length; i++)
    if (callback(this[i], i, this)) filtered.push(this[i]);
  return filtered;
};
function get(type, parent, deep) {
  if (arguments.length == 1 || !parent) {
    parent = app.activeDocument;
    deep = false;
  }
  var result = [];
  if (!parent[type]) return [];
  for (var i = 0; i < parent[type].length; i++) {
    result.push(parent[type][i]);
    if (parent[type][i][type] && deep)
      result = [].concat(result, get(type, parent[type][i]));
  }
  return result || [];
}

// Main
function deleteSelectedAnchors() {
  if (!app.selection || !app.selection.length) {
    alert("Must have a selection to use this script");
    return null;
  }
  get("selection")
    .filter(function (item) {
      return /path/i.test(item.typename);
    })
    .forEach(function (shape) {
      get("pathPoints", shape)
        .filter(function (point) {
          return /anchor/i.test(point.selected + "");
        })
        .forEachReversed(function (point) {
          point.remove();
        });
    });
}
deleteSelectedAnchors();
