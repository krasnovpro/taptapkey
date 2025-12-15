/*
  ToggleShowArtboardName.jsx for Adobe Illustrator
  Description: Toggle Preferences > Selection & Anchor Display > Show Artboard name on canvas
  Requirements: Adobe Illustrator CC 2026 and later
  Date: November, 2025
  Author: Sergey Osokin, email: hi@sergosokin.ru

  Installation: https://github.com/creold/illustrator-scripts#how-to-run-scripts

  Released under the MIT license
  http://opensource.org/licenses/mit-license.php

  Check other author's scripts: https://github.com/creold

  changed by: @krasnovpro
*/

//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false); // Fix drag and drop a .jsx file

(function() {
  if (parseFloat(app.version) < 30) return;
  var n = "showArtboardLabelOnCanvas"
    , m = "Artboard label on canvas"
    , state = app.preferences.getBooleanPreference(n) ? 0 : 1;
  app.preferences.setBooleanPreference(n, state);

  // Update view
  app.executeMenuCommand('artboard');
  app.executeMenuCommand('artboard');

  return m + ": " + (state? "On" : "Off");
}());
