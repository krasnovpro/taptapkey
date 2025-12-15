(function (arguments) {
  if ((app.version.substr(0, 2) * 1) < 16) {
    alert('Sorry, the Action Reloader script only works in CS6 and above.');
  } else {
    var errorFlag = false;
    if (!arguments.length) {
      alert('missing arguments');
      return 0;
    } else {
      var actionSet = arguments[0];
      var actionSetFile = arguments[1];

      while (!errorFlag)
        try {
          app.unloadAction(actionSet, '')
        } catch (e) {
          errorFlag = true;
        }
      try {
        app.loadAction(new File(actionSetFile));
        return 1;
      } catch (e) {
        return 0;
      }
    }
  }
})(arguments)