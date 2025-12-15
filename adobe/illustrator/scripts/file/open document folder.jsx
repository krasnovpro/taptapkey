//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
if (app.documents.length > 0)
  new Folder(app.activeDocument.path.fsName).execute();