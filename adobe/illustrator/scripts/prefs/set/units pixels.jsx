//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

/// set unit type to pixels
/// created by @krasnovpro 2016.10.23

var p = app.preferences;

var unitsIndex = {
      inches      :0
    , millimeters :1
    , points      :2
    , picas       :3
    , centimeters :4
    , custom      :5
    , pixels      :6
    };

var units = {
      millimeters : 72 / 25.4
    , pixels      : 1
    }

var unit = units.pixels;

// var rulerType = p.getIntegerPreference("rulerType");

// units: general
p.setIntegerPreference("rulerType", unitsIndex.pixels);
// general: keyboard increment
p.setRealPreference("cursorKeyLength", 1.0 * unit);
// general: corner radius
p.setRealPreference("ovalRadius", 5.0 * unit);
// guides & grid: grid every
p.setRealPreference("Grid/Horizontal/Spacing", 10.0 * unit);
p.setRealPreference("Grid/Vertical/Spacing", 10.0 * unit);
// guides & grid: subdivisions
p.setRealPreference("Grid/Horizontal/Ticks", 10.0 * unit);
p.setRealPreference("Grid/Vertical/Ticks", 10.0 * unit);
// guides & grid: style = dots
p.setBooleanPreference("Grid/Style", true);
