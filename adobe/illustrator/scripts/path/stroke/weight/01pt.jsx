// TODO: Посмотреть selSwatches = doc.swatches.getSelected()
// TODO: рефакторинг функции setStroke()

// setStroke.jsx for Adobe Illustrator
// Description: The script sets the stroke with the specified parameters for the objectю
//              If the object already had a stroke, then its color does not change.
// Date: August, 2018
// Author: Sergey Osokin, email: hi@sergosokin.ru
// The setStroke() function is based on the code by MaratShagiev (https://github.com/dumbm1), 2015
// ==========================================================================================
// Installation:
// 1. Place script in:
//    Win (32 bit): C:\Program Files (x86)\Adobe\Adobe Illustrator [vers.]\Presets\en_GB\Scripts\
//    Win (64 bit): C:\Program Files\Adobe\Adobe Illustrator [vers.] (64 Bit)\Presets\en_GB\Scripts\
//    Mac OS: <hard drive>/Applications/Adobe Illustrator [vers.]/Presets.localized/en_GB/Scripts
// 2. Restart Illustrator
// 3. Choose File > Scripts > setStroke
// ==========================================================================================
// NOTICE:
// Tested with Adobe Illustrator CC 2017 (Mac), CS6 (Win).
// This script is provided "as is" without warranty of any kind.
// Free to use, not for sale.
// ==========================================================================================
// Released under the MIT license.
// http://opensource.org/licenses/mit-license.php

#target Illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
app.userInteractionLevel = UserInteractionLevel.DONTDISPLAYALERTS;

// Global variables & constants
if (app.documents.length > 0) {
  var doc = app.activeDocument;
  var mySelection = doc.selection;
  var width = 0.1 // unit: pt
}

function main() {
  if (app.documents.length == 0) {
    alert('Error: \nOpen a document and try again.');
    return;
  }

  if (mySelection.length == 0) {
    alert('Error: \nPlease select atleast one object.');
    return;
  }

  // Create color for new stroke. If item has a stroke, then color not apply
  if (doc.documentColorSpace == DocumentColorSpace.RGB) {
    var newColor = new RGBColor();
    newColor.red = 0;
    newColor.green = 0;
    newColor.blue = 0;
  } else {
    var newColor = new CMYKColor();
    newColor.cyan = 0;
    newColor.magenta = 0;
    newColor.yellow = 0;
    newColor.black = 100;
  }

  for (var i = 0; i < mySelection.length; i++) {
    var item = mySelection[i];
    // Change stroke width & color
    setStroke(item, width, newColor);
  }
}

function setStroke(obj, width, color) {
  try {
    switch (obj.typename) {
      case 'GroupItem':
        for (var j = 0; j < obj.pageItems.length; j++) {
          setStroke(obj.pageItems[j], width, color);
        }
        break;

      case 'PathItem':
        if (obj.stroked == true) {
          obj.strokeWidth = width;
        } else {
          obj.stroked = true;
          obj.strokeWidth = width;
          obj.strokeColor = color;
        }
        obj.strokeCap = StrokeCap.ROUNDENDCAP; // options: BUTTENDCAP || ROUNDENDCAP || PROJECTINGENDCAP
        obj.strokeJoin = StrokeJoin.ROUNDENDJOIN;  // options: BEVELENDJOIN || ROUNDENDJOIN || MITERENDJOIN
        break;

      case 'CompoundPathItem':
        if (obj.pathItems[0].stroked == true) {
          obj.pathItems[0].strokeWidth = width;
        } else {
          obj.pathItems[0].stroked = true;
          obj.pathItems[0].strokeWidth = width;
          obj.pathItems[0].strokeColor = color;
        }
        obj.pathItems[0].strokeCap = StrokeCap.ROUNDENDCAP; // options: BUTTENDCAP || ROUNDENDCAP || PROJECTINGENDCAP
        obj.pathItems[0].strokeJoin = StrokeJoin.ROUNDENDJOIN;  // options: BEVELENDJOIN || ROUNDENDJOIN || MITERENDJOIN
        break;

      default:
        break;
    }
  } catch (e) { }
}

// Run script
try {
  main();
} catch (e) {
  alert('Error: ' + e.message + '\rin line #' + e.line);
}