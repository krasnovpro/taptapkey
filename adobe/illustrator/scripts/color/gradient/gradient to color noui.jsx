app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
/*
  GradientToFlat.jsx for Adobe Illustrator
  Description: Convert a gradient to an interpolated solid color
  Date: April, 2021
  Author: Sergey Osokin, email: hi@sergosokin.ru

  Installation: https://github.com/creold/illustrator-scripts#how-to-run-scripts

  Versions:
  0.1 Initial version

  Donate (optional):
  If you find this script helpful, you can buy me a coffee
  - via PayPal http://www.paypal.me/osokin/usd
  - via QIWI https://qiwi.com/n/OSOKIN​
  - via YooMoney https://yoomoney.ru/to/410011149615582​

  NOTICE:
  Tested with Adobe Illustrator CC 2018-2021 (Mac), 2021 (Win).
  This script is provided "as is" without warranty of any kind.
  Free to use, not for sale.

  Released under the MIT license.
  http://opensource.org/licenses/mit-license.php

  Check other author's scripts: https://github.com/creold
*/

//@target illustrator

var defs = {
      isFill: true, // Convert fill color
      isStroke: true // Convert stroke color
    };

// Main function
function main() {
  if (app.documents.length == 0) {
    alert(lang.errDoc);
    return;
  }

  if (!selection.length || selection.typename == 'TextRange') {
    alert(lang.errSel);
    return;
  }

  var doc = app.activeDocument,
      isRgbProfile = (doc.documentColorSpace == DocumentColorSpace.RGB) ? true : false,
      selPaths = [],
      tmp = []; // Array of temp paths for fix compound paths

  getPaths(selection, selPaths, tmp);

  // Processing
  for (var i = 0, selLen = selPaths.length; i < selLen; i++) {
    var currItem = selPaths[i];

    // Convert fill color
    if (defs.isFill && currItem.filled && isGradient(currItem.fillColor)) {
      var fColor = currItem.fillColor.gradient;
      currItem.fillColor = interpolateColor(fColor, isRgbProfile);
    }

    // Convert stroke color
    if (defs.isStroke && currItem.stroked && isGradient(currItem.strokeColor)) {
      var sColor = currItem.strokeColor.gradient;
      currItem.strokeColor = interpolateColor(sColor, isRgbProfile);
    }
  }

  // Clear changes in compound paths
  for (var j = 0, tmpLen = tmp.length; j < tmpLen; j++) { tmp[j].remove(); }
}

/**
 * Get paths from selection
 * @param {object} item collection of items
 * @param {array} arr output array of single paths
 * @param {array} tmp output array of temporary paths in compounds
 */
function getPaths(item, arr, tmp) {
  for (var i = 0, iLen = item.length; i < iLen; i++) {
    var currItem = item[i];
    try {
      switch (currItem.typename) {
        case 'GroupItem':
          getPaths(currItem.pageItems, arr);
          break;
        case 'PathItem':
          arr.push(currItem);
          break;
        case 'CompoundPathItem':
          // Fix compound path created from groups
          if (!currItem.pathItems.length) {
            tmp.push(currItem.pathItems.add());
          }
          arr.push(currItem.pathItems[0]);
          break;
        default:
          break;
      }
    } catch (e) {}
  }
}

/**
 * Color interpolation by moody allen (moodyallen7@gmail.com)
 * @param {object} color current gradient color
 * @param {boolean} isRgb document profile
 * @return {object} solid color
 */
function interpolateColor(color, isRgb) {
  var gStopsLength = color.gradientStops.length,
      cSum = {}; // Sum of color channels
  for (var j = 0; j < gStopsLength; j++) {
    var c = color.gradientStops[j].color;
    if (c.typename === 'SpotColor') c = c.spot.color;
    if (c.typename === 'GrayColor') c.red = c.green = c.blue = c.black = c.gray;
    for (var key in c) {
      if (typeof c[key] === 'number') {
        if (cSum[key]) cSum[key] += c[key];
        else cSum[key] = c[key];
      }
    }
  }
  var iColor = isRgb ? new RGBColor() : new CMYKColor();
  for (var key in cSum) { iColor[key] = cSum[key] / gStopsLength; }
  return iColor;
}

function isGradient(color) {
  return color.typename === 'GradientColor';
}

// Debugging
function showError(err) {
  alert(err + ': on line ' + err.line, 'Script Error', true);
}

try {
  main();
} catch (e) {
  // showError(e);
}