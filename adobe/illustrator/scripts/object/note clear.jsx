//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
if (app.documents.length > 0 && selection.length > 0)
  for (var i = 0; i < selection.length; i++) 
    selection[i].note = "";