/*
JET_MarqueeDeselectPartials.jsx
A Javascript for Illustrator CS2 by James E. Talmage

Modification by Sergey Osokin (https://github.com/creold)
Changelog: Hold down the Alt key to deselect partially selected groups

Purpose:
When making marquee selections in Illustrator, all objects crossed or touched by the selection marquee are selected.
Unlike most other drawing programs, Illustrator does not provide a Contact Sensitive toggle setting to cause marquee selection
to select only objects which are fully enclosed by the marquee.
This script deselects paths in the current selection which are only partially selected.

To Use:
Make a marquee or lasso selection which completely surrounds the paths desired for selection. Then run the script.
Additional paths which were only partially selected become deselected.
*/
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

function main() {
  /// var isAltPressed = ScriptUI.environment.keyboardState.altKey ? true : false;
  deselectPartialPaths();
  /// if (isAltPressed) 
  deselectPartialGroups();
}

function deselectPartialPaths() {
  for (var i = selection.length - 1; i >= 0; i--) {
    var item = selection[i];
    var unSelecteds = 0;
    if ( isType(item, '^path') ) {
      for (p = item.pathPoints.length - 1; p >= 0; p--) {
        var pointRef = item.pathPoints[p];
        if (pointRef.selected != PathPointSelection.ANCHORPOINT) {
          unSelecteds += 1;
        }
      }
    }
    if (unSelecteds > 0) item.selected = false;
  }
}

function deselectPartialGroups() {
  if (isIsolationMode()) {
    var container = getTopParent(selection[0]);
    var containerId = isType(container, 'group') ? container.uuid : null;
  }

  var i = selection.length;
  while (i--) {
    var item = selection[i];
    var parent = getTopParent(item, containerId);
    if ( isType(parent, 'group') ) {
      var childs = getChilds(parent.pageItems);
      for (var j = 0; j < childs.length; j++) {
        if (!childs[j].selected) {
          parent.selected = false;
          i = selection.length;
          break;
        }
      }
    }
  }
}

// Is Isolation Mode
function isIsolationMode() {
  try {
    var tmp = activeDocument.layers.add();
    tmp.remove();
  } catch (e) {
    return true;
  }
  return false;
}

// Get topmost item container
function getTopParent(item, exId) {
  if (arguments.length == 1) var exId = null;
  if ( item.parent.uuid !== exId && !isType(item.parent, 'layer') ) {
    return getTopParent(item.parent, exId);
  } else {
    return item;
  }
}

// Get single items
function getChilds(collection) {
  var out = [];
  for (var i = 0; i < collection.length; i++) {
    var item = collection[i];
    if (isType(item, 'group') && item.pageItems.length) {
      out = [].concat(out, getChilds(item.pageItems));
    } else if (!item.hidden && !item.locked) {
      out.push(item);
    } else {
      item.selected = false;
    }
  }
  return out;
}

// Check the item typename by short name
function isType(item, type) {
  var regexp = new RegExp(type, 'i');
  return regexp.test(item.typename);
}

// Run script
try {
  main();
} catch (e) {}