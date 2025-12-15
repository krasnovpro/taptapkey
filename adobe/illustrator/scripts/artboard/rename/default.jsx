app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
function renameArtboards() {

     var docRef = app.activeDocument;
     var aB = docRef.artboards;

     for (var a = 0; a < aB.length; a++) {

          var curAB = aB[a];
          curAB.name = "Artboard " + [a+1];
     }
}
renameArtboards();