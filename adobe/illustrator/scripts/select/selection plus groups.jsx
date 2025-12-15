/*
  SelectEntireObjectsWithGroups.jsx for Adobe Illustrator
  Description: Selects entire objects that were partially selected with the Direct Selection or Lasso tools, entire parent group.
  Date: August, 2022
  Author: Sergey Osokin, email: hi@sergosokin.ru

  Installation: https://github.com/creold/illustrator-scripts#how-to-run-scripts

  Release notes:
  0.1 Initial version
  0.2 Added selection of a parent group
  0.3 Added Compound Shape selection, but it is unstable due to limited API

  Donate (optional):
  If you find this script helpful, you can buy me a coffee
  - via DonatePay https://new.donatepay.ru/en/@osokin
  - via Donatty https://donatty.com/sergosokin
  - via YooMoney https://yoomoney.ru/to/410011149615582
  - via QIWI https://qiwi.com/n/OSOKIN
  - via PayPal (temporarily unavailable) http://www.paypal.me/osokin/usd

  NOTICE:
  Tested with Adobe Illustrator CC 2018-2022 (Mac), 2022 (Win).
  This script is provided "as is" without warranty of any kind.
  Free to use, not for sale

  Released under the MIT license
  http://opensource.org/licenses/mit-license.php

  Check other author's scripts: https://github.com/creold
*/

//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

function main() {
  if (!selection.length || selection.typename === 'TextRange') return;

  var sel = selection, isIsoMode = isIsolationMode();

  app.executeMenuCommand('deselectall');

  if (isIsoMode) {
    // UUID supported in Adobe Illustrator CC 2020 and above
    var container = getTopParent( isType(sel[0].parent, 'compound') ? sel[0].parent : sel[0] ),
        uuid = isType(container, 'group') ? container.uuid : null;
  }

  var item, parent;
  for (var i = 0; i < sel.length; i++) {
    item = isType(sel[i].parent, 'compound') ? sel[i].parent : sel[i];
    item.selected = true;
    parent = getTopParent(item, uuid);
    if (isType(parent, 'group')) {
      selectGroup(parent);
    } else if (isType(parent, 'plugin')) {
      parent.selected = true;
    }
  }

  redraw();
}

// Is isolation mode
function isIsolationMode() {
  try {
    var tmpLayer = activeDocument.layers.add();
    tmpLayer.remove();
  } catch(e) {
    return true;
  }
  return false;
}

// Get topmost item container
function getTopParent(item, exId) {
  if (arguments.length == 1) var exId = null;
  if ( item.parent.uuid !== exId && !isType(item.parent, 'layer|plugin') ) {
    return getTopParent(item.parent, exId);
  } else {
    return item;
  }
}

// Select a group by skipping a hidden or locked objects
function selectGroup(group) {
  for (var i = 0, len = group.pageItems.length; i < len; i++) {
    var item = group.pageItems[i];
    if (!item.hidden && !item.locked) {
      if (isType(item, 'group')) {
        selectGroup(item);
      } else {
        item.selected = true;
      }
    }
  }
}

// Check the item typename by short name
function isType(item, type) {
  var regexp = new RegExp(type, 'i');
  return regexp.test(item.typename);
}

// Run script
try {
  main();
} catch (e) {}