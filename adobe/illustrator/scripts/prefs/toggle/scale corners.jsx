/// by @krasnovpro
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
(function () {
  var n = "policyForPreservingCorners"
    , m = "Scale corners"
    , state = (app.preferences.getIntegerPreference(n) == 1)? 2 : 1;
  app.preferences.setIntegerPreference(n, state);
  return m + ": " + (state != 2? "On" : "Off");
})()
