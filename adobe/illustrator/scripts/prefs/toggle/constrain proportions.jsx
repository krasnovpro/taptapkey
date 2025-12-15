//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

/// created by @krasnovpro 2016.10.23

(function () {
  var n = "linkTransform"
    , m = "Constrain proportions"
    , state = app.preferences.getBooleanPreference(n)? 0 : 1;
  app.preferences.setBooleanPreference(n, state);

  app.executeMenuCommand('drover control palette plugin');
  app.executeMenuCommand('drover control palette plugin');
  app.executeMenuCommand('AdobeTransformObjects1');
  app.executeMenuCommand('AdobeTransformObjects1');

  return m + ": " + (state? "On" : "Off");
})()