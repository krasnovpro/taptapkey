//@target illustrator

/// created by @krasnovpro
(function () {
  var n = "ShowExternalJSXWarning"
    , m = "JSX warning"
    , state = app.preferences.getBooleanPreference(n)? 0 : 1;
  app.preferences.setBooleanPreference(n, state);
  return m + ": " + (state? "On" : "Off");
})()