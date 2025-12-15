/*
  ToggleTextStrikethrough.jsx for Adobe Illustrator
  Description: Toggle strikethrough on selected text or text frame
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
  Tested with Adobe Illustrator CC 2019-2026 (Mac/Win).
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

  if (app.selection.typename === 'TextRange') {
    toggleStrikeThrough(app.selection)
  } else  {
    var tfs = getTextFrames(app.selection);
    if (!tfs.length) {
      alert('Texts not found\nPlease select at least one text and try again', 'Script error');
      return;
    }
    for (var i = 0, len = tfs.length; i < len; i++) {
      toggleStrikeThrough(tfs[i]);
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
 * Toggle strikeThrough attribute for all characters in a text range
 * @param {Object} text - The text range to modify
 */
function toggleStrikeThrough(text) {
  if (!text || !text.characters || !text.characters.length) return;
  var _chars = text.characters;
  var isCurrStrikeThrough = _chars[0].characterAttributes.strikeThrough;
  if (text.typename === 'TextRange') {
    text.characterAttributes.strikeThrough = !isCurrStrikeThrough;
  } else {
    text.textRange.characterAttributes.strikeThrough = !isCurrStrikeThrough;
  }
}

// Run script
try {
  main();
} catch (err) {}