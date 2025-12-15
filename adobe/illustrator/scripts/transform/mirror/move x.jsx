/*
  MirrorMove-X.jsx for Adobe Illustrator
  Description: Mirror movement the object or points by X axis using the last values of the Object > Transform > Move...
  Date: May, 2022
  Author: Sergey Osokin, email: hi@sergosokin.ru

  Installation: https://github.com/creold/illustrator-scripts#how-to-run-scripts

  Release notes:
  0.1 Initial version

  Donate (optional):
  If you find this script helpful, you can buy me a coffee
  - via YooMoney https://yoomoney.ru/to/410011149615582
  - via QIWI https://qiwi.com/n/OSOKIN
  - via Donatty https://donatty.com/sergosokin
  - via PayPal http://www.paypal.me/osokin/usd

  NOTICE:
  Tested with Adobe Illustrator CC 2018-2022 (Mac), 2022 (Win).
  This script is provided "as is" without warranty of any kind.
  Free to use, not for sale

  Released under the MIT license
  http://opensource.org/licenses/mit-license.php

  Check other author's scripts: https://github.com/creold
*/

//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false); // Fix drag and drop a .jsx file

// Main function
function main() {
  var CFG = {
        aiVers: parseInt(app.version),
        axis  : 'X', // XY, X, Y
        ratio : 1.0, // Movement ratio
      };

  if (!documents.length) {
    alert('Error\nOpen a document and try again');
    return;
  }

  if (CFG.aiVers < 16) {
    alert('Error\nSorry, script only works in Illustrator CS6 and later');
    return;
  }

  if (selection.length == 0 || selection.typename == 'TextRange') {
    alert('Error\nPlease, select one or more paths or path points');
    return;
  }

  var items = getItems(selection),
      isX = /x/i.test(CFG.axis),
      isY = /y/i.test(CFG.axis),
      oldPos = getPositions(items); // Save current point positions

  app.executeMenuCommand('transformagain');

  // Update items positions
  items = getItems(selection);
  var newPos = getPositions(items);

  // Reduce operations in the Illustrator history
  app.undo();
  items = getItems(selection);

  for (var i = 0, len = oldPos.length; i < len; i++) {
    if (!isEqualArr(oldPos[i], newPos[i])) {
      move(items[i], oldPos[i], newPos[i], isX, isY, CFG.ratio);
    }
  }
}

/**
 * Get single item and points from selection
 * @param {(Object|Array)} collection - Set of items
 * @return {Array} out - Items 
 */
function getItems(collection) {
  var out = [];

  for (var i = 0; i < collection.length; i++) {
    var item = collection[i];
    if (item.pageItems && item.pageItems.length) {
      out = [].concat(out, getItems(item.pageItems));
    } else if (/compound/i.test(item.typename) && item.pathItems.length) {
      out = [].concat(out, getItems(item.pathItems));
    } else if (/pathitem/i.test(item.typename)) {
      out = out.concat(getPoints(item));
    } else {
      out.push(item);
    }
  }

  return out;
}

/**
 * Get selected points
 * @param {Object} item - Current object
 * @return {Array} out - Selected points 
 */
function getPoints(item) {
  var out = [];

  if (item.pathPoints && item.pathPoints.length > 1) {
    var points = item.pathPoints;
    for (var i = 0, len = points.length; i < len; i++) {
      if (isSelected(points[i])) out.push(points[i]);
    }
  }

  return out;
}

/**
 * Check PathPoint
 * @param {Object} item - Current object
 * @return {boolean} PathPoint or not
 */
function isPoint(item) {
  return /point/i.test(item.typename);
}

/**
 * Check PathPoint is selected
 * @param {Object} point - Current point
 * @return {boolean} Selected or not 
 */
function isSelected(point) {
  return point.selected == PathPointSelection.ANCHORPOINT;
}

/**
 * Get selected points on paths
 * @param {Array} items - Objects and points
 * @return {Array} out - Items coordinate pairs
 */
function getPositions(items) {
  var out = [];

  for (var i = 0, len = items.length; i < len; i++) {
    if (isPoint(items[i])) {
      out[i] = items[i].anchor;
    } else {
      out[i] = items[i].position;
    }
  }

  return out;
}

/**
 * Compare arrays
 * @param {Array} a
 * @param {Array} b
 * @return {boolean} Equal or not
 */
function isEqualArr(a, b) {
  if (a.length !== 0 && a.length === b.length) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] !== b[i]) return false;
    }
    return true;
  }
  return false;
}

/**
 * Move item to position
 * @param {Object} item - Object or point
 * @param {Array} pos1 - Old position
 * @param {Array} pos2 - Current position
 * @param {boolean} isX - X-axis move
 * @param {boolean} isY - Y-axis move
 * @param {number} ratio - Movement ratio
 */
function move(item, pos1, pos2, isX, isY, ratio) {
  var x = (isX ? 1 : -1) * ratio * (pos1[0] - pos2[0]),
      y = (isY ? 1 : -1) * ratio * (pos1[1] - pos2[1]);

  if (isPoint(item)) {
    with (item) {
      anchor = [anchor[0] + x, anchor[1] + y];
      leftDirection = [leftDirection[0] + x, leftDirection[1] + y];
      rightDirection = [rightDirection[0] + x, rightDirection[1] + y];
    }
  } else {
    item.translate(x, y);
  }
}

// Run script
try {
  main();
} catch (e) {}