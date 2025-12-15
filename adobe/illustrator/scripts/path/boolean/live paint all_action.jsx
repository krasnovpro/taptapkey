/// live paint make, style expand...
/// created by @krasnovpro 2021.07.14
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

if (app.documents.length > 0) {
  app.executeMenuCommand("deselectall");
  app.executeMenuCommand("selectall");
  if (selection.length > 0) {
    app.executeMenuCommand("ungroup");
    var noColor = new NoColor();
    for (var i = 0, len = selection.length; i < len; i++) {
      app.activeDocument.graphicStyles[0].applyTo(selection[i]);
      selection[i].fillColor = noColor;
    }
    app.executeMenuCommand("Make Planet X");

    defaultFillAndStroke();

    app.executeMenuCommand("selectall");
    app.executeMenuCommand("Expand Planet X");
    app.executeMenuCommand("ungroup");
    selection[0].remove();
    app.executeMenuCommand("ungroup");
    for (var i = 0, len = selection.length; i < len; i++)
      app.activeDocument.graphicStyles[0].applyTo(selection[i]);
  }
}

function defaultFillAndStroke() {
  if (app.documents.length = 0) return;
  var ActionString = '''
    /version 3
    /name [ 14
      4c697665205061696e7420416c6c
    ]
    /isOpen 1
    /actionCount 1
    /action-1 {
      /name [ 23
        64656661756c742066696c6c20616e64207374726f6b65
      ]
      /keyIndex 0
      /colorIndex 0
      /isOpen 1
      /eventCount 1
      /event-1 {
        /useRulersIn1stQuadrant 0
        /internalName (ai_plugin_setColor)
        /localizedName [ 9
          53657420636f6c6f72
        ]
        /isOpen 1
        /isOn 1
        /hasDialog 0
        /parameterCount 1
        /parameter-1 {
          /key 1836349808
          /showInPalette -1
          /type (enumerated)
          /name [ 23
            44656661756c742066696c6c20616e64207374726f6b65
          ]
          /value 6
        }
      }
    }
  ''';

  app.userInteractionLevel = UserInteractionLevel.DONTDISPLAYALERTS;
  try {app.unloadAction("Live Paint All", "")} catch (e) {};
  createAction(ActionString);
  app.userInteractionLevel = UserInteractionLevel.DISPLAYALERTS;
  var ActionString = null;
  app.doScript("default fill and stroke", "Live Paint All", false);
  app.unloadAction("Live Paint All", "");
}

function createAction(str) {
  var f = new File("~/Live Paint All.aia");
  f.open("w");
  f.write(str);
  f.close();
  app.loadAction(f);
  f.remove();
}
