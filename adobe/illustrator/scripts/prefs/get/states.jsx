/// created by @krasnovpro 2025.03.09
(function (arguments) {

  // app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

  var p = app.preferences;
  return ''
      + '{ "scaleStrokes": '
        + p.getIntegerPreference('scaleLineWeight')

      + ', "scaleCorners": '
        + (+(p.getIntegerPreference('policyForPreservingCorners') != 2))

      + ', "previewBounds": '
        + p.getIntegerPreference('includeStrokeInBounds')

      + ', "selectByPathOnly": '
        + p.getIntegerPreference('hitShapeOnPreview')

      + ', "typeSelectByPathOnly": '
        + p.getIntegerPreference('hitTypeShapeOnPreview')

      + ', "selectObjectBehind": '
        + p.getIntegerPreference('selectBehind')

      + ', "showLockIcon": '
        + p.getIntegerPreference('showLockIcon')

      + ', "transformTools": '
        + p.getIntegerPreference('smartGuides/showToolGuides')

      + ', "jsxWarning": '
        + p.getIntegerPreference('ShowExternalJSXWarning')

      + ', "transformObjectOnly": '
        + (+((p.getIntegerPreference('transformPatterns') == 0)
              && (p.getIntegerPreference('onlyTransformPatterns') == 0)))

      + ', "transformPatternOnly": '
        + (+((p.getIntegerPreference('transformPatterns') == 1)
              && (p.getIntegerPreference('onlyTransformPatterns') == 1)))

      + ', "transformBoth": '
        + (+((p.getIntegerPreference('transformPatterns') == 1)
              && (p.getIntegerPreference('onlyTransformPatterns') == 0)))

      + ' }';

})(arguments);
