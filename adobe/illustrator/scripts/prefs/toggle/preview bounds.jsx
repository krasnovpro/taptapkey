//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

/// created by @krasnovpro
(function () {
  var n = "includeStrokeInBounds"
    , m = "Preview bounds"
    , state = app.preferences.getBooleanPreference(n)? 0 : 1;
  app.preferences.setBooleanPreference(n, state);
  return m + ": " + (state? "On" : "Off");
})()