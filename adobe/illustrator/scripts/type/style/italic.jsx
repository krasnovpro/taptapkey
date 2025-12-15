/*
  ToggleTextItalic.jsx for Adobe Illustrator
  Description: Toggle Italic <-> Normal on selected text or text frame
  Date: October, 2025
  Author: Sergey Osokin, email: hi@sergosokin.ru

  Installation: https://github.com/creold/illustrator-scripts#how-to-run-scripts

  Release notes:
  0.1 Initial version

  Donate (optional):
  If you find this script helpful, you can buy me a coffee
  - via Buymeacoffee: https://www.buymeacoffee.com/aiscripts
  - via Donatty https://donatty.com/sergosokin
  - via DonatePay https://new.donatepay.ru/en/@osokin
  - via YooMoney https://yoomoney.ru/to/410011149615582

  NOTICE:
  Tested with Adobe Illustrator CC 2019-2025 (Mac/Win).
  This script is provided "as is" without warranty of any kind.
  Free to use, not for sale

  Released under the MIT license
  http://opensource.org/licenses/mit-license.php

  Check my other scripts: https://github.com/creold
*/

//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

function main() {
  if (!/illustrator/i.test(app.name)) {
    alert('Wrong application\nRun script from Adobe Illustrator', 'Script error');
    return;
  }

  if (!app.documents.length) {
    alert('No documents\nOpen a document and try again', 'Script error');
    return;
  }

  if (!app.selection.length) {
    alert('Few objects are selected\nPlease select at least one text and try again', 'Script error');
    return false;
  }

  var fonts = app.textFonts;

  if (app.selection.typename === 'TextRange') {
    toggleItalic(app.selection, fonts);
  } else  {
    var tfs = getTextFrames(app.selection, fonts);
    if (!tfs.length) {
      alert('Texts not found\nPlease select at least one text and try again', 'Script error');
      return;
    }
    for (var i = 0, len = tfs.length; i < len; i++) {
      toggleItalic(tfs[i], fonts);
    }
  }
}

/**
 * Get an array of TextFrames from a given collection
 * @param {Array} coll - The collection to search for TextFrames
 * @returns {Array} textFrames - An array containing TextFrames found in the collection
 */
function getTextFrames(coll) {
  var results = [];
  if (/textrange/i.test(coll.typename)) {
    return [];
  } else {
    for (var i = 0, len = coll.length; i < len; i++) {
      if (/text/i.test(coll[i].typename)) {
        results.push(coll[i]);
      } else if (/group/i.test(coll[i].typename)) {
        results = results.concat(getTextFrames(coll[i].pageItems));
      }
    }
  }
  return results;
}

/**
 * Toggle italic style for selected text
 * @param {Object} text - The text range to process
 * @param {(Object|Array)} fonts - Array of available fonts
 */
function toggleItalic(text, fonts) {
  if (!text || !text.characters || !text.characters.length || !fonts) return;

  var firstFont = text.characters[0].characterAttributes.textFont;
  var isItalic = firstFont.style.toLowerCase().match(/italic/);
  var len = text.characters.length;
  var cache = {};

  for (var i = 0; i < len; i++) {
    var _char = text.characters[i];
    var charFont = _char.characterAttributes.textFont;
    var charFamily = charFont.family;
    var charStyle = charFont.style.toLowerCase();

    // Cache font family styles
    if (!cache[charFamily]) {
      cache[charFamily] = getFamilyStyles(fonts, charFamily);
    }

    var familyData = cache[charFamily];
    var baseStyle = charStyle.replace(/\s*italic\s*/g, '').replace(/^\s+|\s+$/g, '');
    if (!baseStyle.length) baseStyle = 'regular';
    var newFont = isItalic 
      ? findClosestFont(familyData, false, baseStyle)
      : findClosestFont(familyData, true, baseStyle);

    if (newFont) _char.characterAttributes.textFont = newFont;
  }
}

/**
 * Get all styles for a given font family
 * @param {(Object|Array)} fonts - Array of available fonts
 * @param {string} name - Font family name
 * @returns {Array} results - Array of fonts matching the family
 */
function getFamilyStyles(fonts, name) {
  var results = [];
  for (var i = 0; i < fonts.length; i++) {
    if (fonts[i].family === name) results.push(fonts[i]);
  }
  return results;
}

/**
 * Find the closest font style in a family, optionally matching italic variants
 * @param {(Object|Array)} fonts - Array of fonts in the family
 * @param {boolean} toItalic - If true, searches for italic styles
 * @param {string} baseStyle - Base style to match (e.g., 'regular', 'bold').
 * @returns {(Object|null)} Matching font or null
 */
function findClosestFont(fonts, toItalic, baseStyle) {
  var closest = null;

  for (var i = 0; i < fonts.length; i++) {
    var font = fonts[i];
    var style = font.style.toLowerCase();
    var isItalic = style.match(/italic/);
    var currBase = style.replace(/\s*italic\s*/g, '').replace(/^\s+|\s+$/g, '');
    if (!currBase.length) currBase = 'regular';

    if (toItalic && isItalic && currBase === baseStyle) {
      return font;
    }

    if (!toItalic && !isItalic && currBase === baseStyle) {
      closest = font;
    }
  }

  return closest;
}

// Run script
try {
  main();
} catch (err) {}