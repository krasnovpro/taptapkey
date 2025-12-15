//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

/// set constrain angle
/// created by @krasnovpro 2019.08.02

//deg = prompt("Degree:", 0, "Enter degree")
deg = 150;
rad = deg * Math.PI / 180;
cos = Math.cos(rad).toFixed(14);
sin = Math.sin(rad).toFixed(14);

app.preferences.setRealPreference("constrain/angle", deg);
app.preferences.setRealPreference("constrain/cos", cos);
app.preferences.setRealPreference("constrain/sin", sin);