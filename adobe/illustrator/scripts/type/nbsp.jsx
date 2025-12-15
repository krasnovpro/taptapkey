//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

/// created by @krasnovpro

// based on:
// http://forum.rudtp.ru/threads/vydelenie-teksta-na-dva-simvola-vlevo-i-vpravo-ot-polozhenija-kursora.66940/#post-904865
// https://github.com/dumbm1/ai_scripts/blob/master/jsx/noBreak.jsx
// also thanks to Sergey Osokin https://github.com/creold

//add non-breaking space at caret
var s = selection;
if (s && s.typename === 'TextRange') {  
  s.parent.insertionPoints[s.start].characters.add(' ');
  try {
    s.characterOffset = s.characterOffset - 1;
    s.length = 2;
    s.select();
    s.characterAttributes.noBreak = true;
    s.deSelect();
  } catch(e) {}
}