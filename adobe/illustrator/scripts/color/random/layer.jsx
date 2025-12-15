/**
 * ai.jsx ©MaratShagiev m_js@bk.ru 04.03.2016
 */

 /// changed by @krasnovpro 27.11.2025

app.preferences.setBooleanPreference("ShowExternalJSXWarning", false);

(function recolor_visionless_layers() {
  if (app.documents.length === 0) {
    alert("Open the document before running the script.");
    return;
  }

  var doc = app.activeDocument;

  function exitIsolationIfNeeded() {
    if (doc.layers.length > 0 && doc.layers[0].name == "Isolation Mode") {
      app.userInteractionLevel = UserInteractionLevel.DONTDISPLAYALERTS;

      var tempSetName = "TempSet";
      var tempActionName = "Exit Isolation";

      var actionStr = '''/version 3
        /name [ ''' + tempSetName.length + ' ' + ascii2hex(tempSetName) + ''' ]
        /isOpen 1
        /actionCount 1
        /action-1 {
          /name [ ''' + tempActionName.length + ' ' + ascii2hex(tempActionName) + ''' ]
          /keyIndex 0
          /colorIndex 0
          /isOpen 1
          /eventCount 1
          /event-1 {
            /useRulersIn1stQuadrant 0
            /internalName (ai_plugin_Layer)
            /localizedName [ 5 4c61796572 ]
            /isOpen 0
            /isOn 1
            /hasDialog 0
            /parameterCount 1
            /parameter-1 {
              /key 1836411236
              /showInPalette -1
              /type (integer)
              /value 25
            }
          }
        }''';
      var tempAction = new File(Folder.temp + "/ExitIsolation.aia");
      tempAction.open('w');
      tempAction.write(actionStr);
      tempAction.close();
      app.loadAction(tempAction);
      app.doScript(tempActionName, tempSetName, false);
      app.unloadAction(tempSetName, "");
      tempAction.remove();

      app.userInteractionLevel = UserInteractionLevel.DISPLAYALERTS;
      if (doc.layers.length > 0 && doc.layers[0].name == "Isolation Mode") {
        return false;
      }
    }
    return true;
  }

  if (!exitIsolationIfNeeded()) {
    return;
  }

  var lays = doc.layers;

  for (var i = 0; i < lays.length; i++) {
    /// if ( /// only gray and black
    ///   (lays[i].color.red == 255 && lays[i].color.green == 255) ||
    ///   (lays[i].color.red == lays[i].color.green &&
    ///     lays[i].color.blue == lays[i].color.green)
    /// ) {

    var wasLocked = lays[i].locked; // Remember the lock state

    // Temporarily unlock the layer if it was locked
    if (wasLocked) {
      lays[i].locked = false;
    }

    // Generate random color and assign FULL object to avoid 'PARM' error
    var col = _makeRandRGB();
    lays[i].color = col;

    // Restore the original lock state
    if (wasLocked) {
      lays[i].locked = true;
    }
    /// }
  }

  app.redraw();

  function ascii2hex(hex) {
    return hex.replace(/./g, function(a) {
      return a.charCodeAt(0).toString(16);
    });
  }

  function _makeRandRGB() {
    var cols = [];

    cols.push(_genRGB(255,   0,   0)); // reds
    cols.push(_genRGB(255,  51,   0));
    cols.push(_genRGB(255, 102,   0));
    cols.push(_genRGB(204,   0,   0));
    cols.push(_genRGB(255,  51,  51));
    cols.push(_genRGB(204,  51,   0));
    cols.push(_genRGB(153,  51,   0));
    cols.push(_genRGB(153,   0,   0));
    cols.push(_genRGB(255,   0, 153));
    cols.push(_genRGB(255,  51, 153));
    cols.push(_genRGB(255,   0, 204));

    cols.push(_genRGB(  0, 255,   0)); // greens
    cols.push(_genRGB(  0, 204,   0));
    cols.push(_genRGB(  0, 153,   0));
    cols.push(_genRGB(  0, 102,   0));
    cols.push(_genRGB(153, 255,   0));
    cols.push(_genRGB(102, 255,   0));
    cols.push(_genRGB( 51, 255,   0));
    cols.push(_genRGB( 51, 153,   0));
    cols.push(_genRGB(  0, 255,  51));

    cols.push(_genRGB(  0, 255, 255)); // blues
    cols.push(_genRGB(  0, 204, 255));
    cols.push(_genRGB(  0, 102, 204));
    cols.push(_genRGB(  0, 102, 255));
    cols.push(_genRGB(  0,   0, 204));
    cols.push(_genRGB( 51,   0, 255));
    cols.push(_genRGB( 51,   0, 204));

    cols.push(_genRGB(153, 255,   0)); // violettes
    cols.push(_genRGB(153, 204,   0));
    cols.push(_genRGB(102,   0, 153));
    cols.push(_genRGB(153,   0, 204));
    cols.push(_genRGB(204,   0, 204));
    cols.push(_genRGB(153,   0, 153));

    return cols[_randomInteger(0, cols.length - 1)];

    function _genRGB(r, g, b) {
      var col = new RGBColor();
      col.red = r;
      col.green = g;
      col.blue = b;
      return col;
    }

    function _randomInteger(min, max) {
      var rand = min - 0.5 + Math.random() * (max - min + 1);
      rand = Math.round(rand);
      return rand;
    }
  }
})();