/// created by @krasnovpro 2025.11.26
(function (arguments) {

  app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

  // var colors = {
  //   '0.000': 'dark',
  //   '0.500': 'medium dark',
  //   '0.510': 'medium light',
  //   '1.000': 'light'
  // };

  var locale = app.locale;

  var kysPreset = app.preferences.getIntegerPreference(
    'plugin/KBSCShortcutFile/IsPreset'
  );

  var kysProfile = app.preferences.getStringPreference(
    'plugin/KBSCShortcutFile/FileName'
  );

  var pinchToZoom = (
    app.preferences.getBooleanPreference(
      'aiSwapAltControlWithScrollWheel'
    ) ? '^' : '!'
  );

  // var uiColor = colors[
  //   parseFloat(
  //     app.preferences.getRealPreference(
  //       'uiBrightness'
  //     )
  //   ).toFixed(3)
  // ];

  var uiScaling = parseFloat(
    app.preferences.getRealPreference(
      'UIPreferences/appScaleFactor'
    ) || 1
  ).toFixed(2);

  return '{ "locale": "'      + locale
       + '", "kysPreset": "'   + kysPreset
       + '", "kysProfile": "'  + kysProfile
       + '", "pinchToZoom": "' + pinchToZoom
      //  + '", "uiColor": "'     + uiColor
       + '", "uiScaling": "'   + uiScaling
       + '" }';

})(arguments);
