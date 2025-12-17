//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
(function() {
  if ((app.documents.length > 0) && (app.activeDocument.fullName !== null)) {
    return app.activeDocument.fullName.fsName;
  }
})();