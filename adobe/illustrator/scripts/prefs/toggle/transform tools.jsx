/// by @krasnovpro
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
(function () {
  var n = "smartGuides/showToolGuides"
    , m = "Transform tools"
    , state = app.preferences.getBooleanPreference(n)? 0 : 1;
  app.preferences.setBooleanPreference(n, state);
  return m + ": " + (state? "On" : "Off");
})()
