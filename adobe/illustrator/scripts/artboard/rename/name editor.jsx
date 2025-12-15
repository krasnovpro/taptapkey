app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);
/*
  Artboard_Name_Editor.jsx for Adobe Illustrator
  Description: Script for batch renaming artboards manually or by placeholders
  Date: November, 2020

  Original idea by Qwertyfly:
  http://https://community.adobe.com/t5/illustrator/is-there-a-way-to-batch-rename-artboards-in-illustrator-cc/td-p/7243666?page=1

  Co-author: Sergey Osokin, email: hi@sergosokin.ru
  
  Installation: https://github.com/creold/illustrator-scripts#how-to-run-scripts
  
  Versions:
  0.1 Initial version by Qwertyfly (27/5/2015)
  0.2 Added scrollbar (needed full rework) by Qwertyfly (7/6/2015)
  0.2.1 by Qwertyfly (10/6/2015)
    - Bug fix, forgot to initiate the "pre" "nam" & "suf" arrays.
    - Added user var for Seperators
  1.0 (09/11/2020) by Sergey Osokin
    - Fixed variables, scrollbar
    - Added 'Select all' checkboxes, 'Find and Replace' algorithm
    — Addedd save and load user settings
    - Added placeholders for batch rename 
  
  Donate (optional): If you find this script helpful, you can buy me a coffee
                     via PayPal http://www.paypal.me/osokin/usd
  
  NOTICE:
  This script is provided "as is" without warranty of any kind.
  Free to use, not for sale.
  
  Released under the MIT license.
  http://opensource.org/licenses/mit-license.php
  
  Check other author's scripts: https://github.com/creold
*/

//@target illustrator

//  User set variable
var SCRIPT_NAME = 'Artboard Name Editor',
    SCRIPT_VERSION = 'v.1.0',
    SETTINGS_FILE = {
      name: SCRIPT_NAME.replace(/\s/g, '_') + '_data.ini',
      folder: Folder.myDocuments + '/Adobe Scripts/'
    },
    AB_NAME_PH = '{a}',
    AB_NUM_UP_PH = '{nu:0}',
    AB_NUM_DOWN_PH = '{nd:0}',
    AB_WIDTH_PH = '{w}',
    AB_HEIGHT_PH = '{h}',
    DOC_UNITS_PH = '{u}',
    DOC_DATE_PH = '{d}',
    DOC_COLOR_PH = '{c}',
    AB_ROWS = 6, // Amount of visible rows
    AB_LIST_HEIGHT = AB_ROWS * 32,
    DLG_OPACITY = 0.93,  // UI opacity. Range 0-1
    TMP_LAYER_NAME = 'ARTBOARD_NUMBERS',
    FIND_ON = false, // Default Find and Replace state
    IS_PREVIEW = false; // Don't change

var TXT_ERR_DOC = 'Error\nOpen a document and try again.',
    TXT_AB_NAME = 'Artboard name',
    TXT_AB_NAME_PRVW = 'PREVIEW ON',
    TXT_PRE = 'Prefix',
    TXT_SUFF = 'Suffix',
    TXT_NAME_PH = 'Placeholder: ' + AB_NAME_PH + ' - current artboard name',
    TXT_PRESUFF_PH = 'Placeholders:\n' 
                      + AB_WIDTH_PH + ' - artboard width, '
                      + AB_HEIGHT_PH + ' - artboard height, '
                      + DOC_UNITS_PH + ' - ruler units, '
                      + AB_NUM_UP_PH + ' - auto-number \u2191 with start from, ' // ascending
                      + AB_NUM_DOWN_PH + ' - number \u2193,\n' // descending
                      + DOC_COLOR_PH + ' - doc color space, '
                      + DOC_DATE_PH + ' - current date as YYYYMMDD',
    TXT_FIND = 'Find',
    TXT_RPLC = 'Replace',
    TXT_FIND_ON = 'Enable',
    TXT_FAIL_PRESUFF_1 = 'Enter the ',
    TXT_FAIL_PRESUFF_2 = 'text or disable the checkbox',
    TXT_OK = 'Ok',
    TXT_CANCEL = 'Cancel',
    TXT_DOC_COLOR = 'RGB',
    TXT_CMYK = 'CMYK',
    TXT_COPYRIGHT = '\u00A9 @Qwertyfly & Sergey Osokin, github.com/creold';

function main() {
  if (app.documents.length == 0) {
    alert(TXT_ERR_DOC);
    return;
  }

  var doc = app.activeDocument,
      absArr = [], // Array of statuses in rows
      rowItem = [], // Array of artboards rows
      abName = [], // Array of artboards names
      preArr = [], // Array of prefixes
      suffArr = []; // Array of suffixes

  if (doc.documentColorSpace != DocumentColorSpace.RGB) TXT_DOC_COLOR = TXT_CMYK;

  // Collect prefix and suffix state, artboard name and index
  for (var i = 0; i < doc.artboards.length; i++) {
    absArr.push([false, doc.artboards[i].name, false, i]);
  }

  // Create UI
  var dialog = new Window('dialog', SCRIPT_NAME + ' ' + SCRIPT_VERSION, undefined);
      dialog.opacity = DLG_OPACITY;

  var abListWin = dialog.add('group');
      abListWin.orientation = 'column';
  
  var header = abListWin.add('group');
      header.orientation = 'row';
      header.alignment = 'left';

  var pHeader = header.add('group');
      pHeader.margins = [12, 0, 0, 0];
  var p = pHeader.add('statictext', undefined, TXT_PRE);
  var nHeader = header.add('group');
      nHeader.margins = [90, 0, 0, 0];
  var n = nHeader.add('statictext', undefined, TXT_AB_NAME);
      n.characters = 16;
  var sHeader = header.add('group');
      sHeader.margins = [22, 0, 0, 0];
  var s = sHeader.add('statictext', undefined, TXT_SUFF);

  var headerSelect = abListWin.add('group');
      headerSelect.orientation = 'row';
      headerSelect.alignment = 'left';

  var headerAllPre = headerSelect.add('group');
      headerAllPre.margins = [20, 0, 0, -6];
  var chkAllPre = headerAllPre.add('checkbox');
  
  var headerPrvw = headerSelect.add('group');
      headerPrvw.margins = [106, 0, 0, 0];
  var prvwTitle = headerPrvw.add('statictext');
      prvwTitle.characters = 17;

  var headerAllSuff = headerSelect.add('group');
      headerAllSuff.margins = [18, 0, 0, -6];
  var chkAllSuff = headerAllSuff.add('checkbox');

  var scrollWin = abListWin.add('group');
      scrollWin.alignChildren = 'fill';
  var abListPanel = scrollWin.add('panel');
      abListPanel.alignChildren = 'left';

  if (absArr.length <= AB_ROWS) { // Artboards list without scroll
    for (var i = 0; i < absArr.length; i++) {
      rowItem = abListPanel.add('group');
      addNewRow(i, rowItem);
    }
  } else { // Artboards list with scroll
    abListPanel.maximumSize.height = AB_LIST_HEIGHT;
    var smallList = abListPanel.add('group');
        smallList.orientation = 'column';
        smallList.alignment = 'left';
        smallList.margins = [0, 5, 0, 0];
        smallList.maximumSize.height = absArr.length * 100;
    
    var scroll = scrollWin.add('scrollbar');
        scroll.stepdelta = 25;
        scroll.preferredSize.width = 12;
        scroll.maximumSize.height = abListPanel.maximumSize.height;
    
    for (var i = 0; i < absArr.length; i++) {
      rowItem = smallList.add('group');
      addNewRow(i, rowItem);
    }
   
    // Trick from https://community.adobe.com/t5/indesign/scrollable-panel-group-in-scriptui/td-p/10967644?page=1
    scroll.onChanging = function() {
      smallList.location.y = -1 * this.value;
    }
  }
 
  var preSuffGrp = dialog.add('group');
      preSuffGrp.orientation = 'row';
  var preTitle = preSuffGrp.add('statictext', undefined, TXT_PRE);
  var pre = preSuffGrp.add('edittext', [0, 0, 140, 20], '');
  var suffTitle = preSuffGrp.add('statictext', undefined, TXT_SUFF);
  var suff = preSuffGrp.add('edittext', [0, 0, 140, 20], '');
  
  var preSuffNote = dialog.add('statictext', [0, 0, 350, 60], TXT_PRESUFF_PH, {multiline: true});
  
  // Simulate a dividing line
  var border = dialog.add('panel');
      border.alignment = ['fill', 'fill'];
      border.minimumSize.height = border.maximumSize.height = 2;

  // Add find and replace
  var findRplcGrp = dialog.add('group');
      findRplcGrp.orientation = 'row';  
  var findTitle = findRplcGrp.add('statictext', undefined, TXT_FIND);
  var find = findRplcGrp.add('edittext', [0, 0, 140, 20], '');
      find.enabled = FIND_ON;
  var rplcTitle = findRplcGrp.add('statictext', undefined, TXT_RPLC);
  var rplc = findRplcGrp.add('edittext', [0, 0, 140, 20], '');
      rplc.enabled = FIND_ON;
  
  var findRplcNote = dialog.add('statictext', undefined, TXT_NAME_PH);
  var findRplcOn = dialog.add('checkbox', undefined, TXT_FIND_ON);
      findRplcOn.value = FIND_ON;
  
  var btnsGrp = dialog.add('group');
  btnsGrp.margins = [0, 10, 0, 0];
  btnsGrp.alignment = 'center';
  var preview = btnsGrp.add('button', undefined, 'Preview');
  var cancel = btnsGrp.add('button', undefined, TXT_CANCEL);
  var ok = btnsGrp.add('button', undefined, TXT_OK);

  var copyright = dialog.add('statictext', undefined, TXT_COPYRIGHT);
      copyright.justify = 'center';
      copyright.enabled = false;

  loadSettings();
  
  // Parent container with all rows
  var parent = (absArr.length <= AB_ROWS) ? abListPanel : smallList;

  // Select all prefixes
  chkAllPre.onClick = function () {
    for (var i = 0; i < absArr.length; i++) {
      preArr[i].value = (this.value) ? true : false;
      absArr[i][0] = (this.value) ? true : false;
    }
  }
  
  // Select all suffixes
  chkAllSuff.onClick = function () {
    for (var i = 0; i < absArr.length; i++) {
      suffArr[i].value = (this.value) ? true : false;
      absArr[i][2] = (this.value) ? true : false;
    }
  }

  findRplcOn.onClick = function() {
    find.enabled = rplc.enabled = !find.enabled;
  }

  dialog.onShow = function() {
    scroll.maxvalue = smallList.size.height - abListPanel.size.height + 20;
  };

  // Remove temp layer with artboards numbers
  dialog.onClose = function() {
    try {
      var layerToRm = doc.layers.getByName(TMP_LAYER_NAME);
      layerToRm.remove();
    } catch (e) {}
  }

  // Trick for reset preview
  for (var i = 0; i < parent.children.length; i++) {
    parent.children[i].children[2].onActivate = function() { // children[2] - name input
      if (IS_PREVIEW) {
        prvwTitle.text = '';
        for (var j = 0; j < parent.children.length; j++) {
          parent.children[j].children[2].text = absArr[j][1]; // Restore original name
        }
        IS_PREVIEW = false;
      }
    }
  }
 
  // Preview new artboards names
  preview.onClick = function() {
    IS_PREVIEW = true;
    FIND_ON = findRplcOn.value;
    prvwTitle.text = TXT_AB_NAME_PRVW;
    
    var prvwArr = [];
    
    generateName(absArr, pre.text, suff.text, find.text, rplc.text, prvwArr);
    
    for (var i = 0; i < parent.children.length; i++) {
      parent.children[i].children[2].text = prvwArr[i];
    }
  }
  
  cancel.onClick = function() {
    dialog.close();
  }

  ok.onClick = okClick;

  function okClick() {
    FIND_ON = findRplcOn.value;
    var fail = validatePreSuff(absArr, pre.text, suff.text);
   
    if (fail.p || fail.s) {
      alert(fail.msg);
    } else {
      renameAb(absArr, pre.text, suff.text, find.text, rplc.text);
      saveSettings();
      dialog.close();
    }
  }

  drawAbNumber();
  app.redraw();
  dialog.show();

  // Add row with prefix checkbox, artboard number and name, suffix checkbox
  function addNewRow(idx, row) {
    preArr[idx] = row.add('checkbox');
    preArr[idx].value = absArr[idx][0];
    preArr[idx].label = absArr[idx][3];
    preArr[idx].onClick = function() {
      absArr[this.label][0] = !absArr[this.label][0];
      if (!preArr[idx].value) { chkAllPre.value = false; }
    }

    // Add artboard number for navigation
    var num = row.add('statictext');
        num.text = idx + 1;
    
    abName[idx] = row.add('edittext', [0, 0, 240, 20]);
    abName[idx].characters = 50;
    abName[idx].text = absArr[idx][1];
    abName[idx].label = absArr[idx][3];
    abName[idx].onChange = function() {
      if (isEmpty(this.text)) {
        this.text = doc.artboards[idx].name;
      } else {
        absArr[this.label][1] = this.text;
      }
    }

    suffArr[idx] = row.add('checkbox');
    suffArr[idx].value = absArr[idx][2];
    suffArr[idx].label = absArr[idx][3];
    suffArr[idx].onClick = function() {
      absArr[this.label][2] = !absArr[this.label][2];
      if (!suffArr[idx].value) { chkAllSuff.value = false; }
    }
    
    goToNextPrevName(abName[idx], idx);
  }

  // Moves to the next and previous name using the Up and Down keys
  function goToNextPrevName(item, idx) {
    item.addEventListener('keydown', function (kd) {
      // Go to next name
      if (kd.keyName == 'Down' && (idx + 1) < absArr.length) {
        // Update the scrollbar position when the Down key is pressed
        if (idx != 0 && scroll != undefined) {
          scroll.value = (idx + 1) * (scroll.maxvalue / absArr.length);
          smallList.location.y = -1 * scroll.value;
        }
        // UI trick. Temporarily activate the checkbox and thereafter the name
        parent.children[idx].children[0].active = true;
        parent.children[idx + 1].children[2].active = true;
        dialog.update();
        kd.preventDefault();
      }
      // Go to prefix after last name
      if (kd.keyName == 'Down' && (idx + 1) == absArr.length) {
        parent.children[idx].children[0].active = true;
        pre.active = true;
        dialog.update();
        kd.preventDefault();
      }
      // Go to previous name
      if (kd.keyName == 'Up' && (idx - 1 >= 0)) {
        // Update the scrollbar position when the Up key is pressed
        if ((idx + 1 < absArr.length) && scroll != undefined) {
          scroll.value = (idx - 1) * (scroll.maxvalue / absArr.length);
          smallList.location.y = -1 * scroll.value;
        }
        // UI trick. Temporarily activate the checkbox and thereafter the name
        parent.children[idx].children[0].active = true;
        parent.children[idx - 1].children[2].active = true;
        dialog.update();
        kd.preventDefault();
      }
    });
  }

  // Save prefix, suffix, find and replace values
  function saveSettings() {
    if (!Folder(SETTINGS_FILE.folder).exists) {
      Folder(SETTINGS_FILE.folder).create();
    }
    var $file = new File(SETTINGS_FILE.folder + SETTINGS_FILE.name),
        data = [
          pre.text,
          suff.text,
          find.text,
          rplc.text
        ].join(';');
    $file.open('w');
    $file.write(data);
    $file.close();
  }
  
  // Load prefix, suffix, find and replace values
  function loadSettings() {
    var $file = File(SETTINGS_FILE.folder + SETTINGS_FILE.name);
    if ($file.exists) {
      try {
        $file.open('r');
        var data = $file.read().split('\n'),
            $main = data[0].split(';');
        pre.text  = $main[0];
        suff.text = $main[1];
        find.text = $main[2];
        rplc.text = $main[3];
      } catch (e) {}
      $file.close();
    }
  }
}

function validatePreSuff(abs, pre, suff) {
  var failPre = false,
      failSuff = false,
      failMsg = TXT_FAIL_PRESUFF_1;
 
  for (var i = 0; i < abs.length; i++) {
    if (!failPre && abs[i][0] && isEmpty(pre)) {
      failPre = true;
    }
    if (!failSuff && abs[i][2] && isEmpty(suff)) {
      failSuff = true;
    }
  }

  if (failPre) failMsg += TXT_PRE + ', ';
  if (failSuff) failMsg += TXT_SUFF + ', ';
  failMsg += TXT_FAIL_PRESUFF_2;
  var idx = failMsg.lastIndexOf(',');
  failMsg = failMsg.substring(0, idx) + failMsg.substring(idx + 1);

  return { p: failPre, s: failSuff, msg: failMsg };
}

// Check empty string
function isEmpty(str) {
  return str.replace(/\s/g, '').length == 0;
}

// Print the artboard number as text inside the temp layer
function drawAbNumber() {
  var doc = app.activeDocument,
      tmpLayer;
    
  try {
    tmpLayer = doc.layers.getByName(TMP_LAYER_NAME);
  } catch (e) {
    tmpLayer = doc.layers.add();
    tmpLayer.name = TMP_LAYER_NAME;
  }

  for (var i = 0; i < doc.artboards.length; i++)  {
    doc.artboards.setActiveArtboardIndex(i);
    var currAb = doc.artboards[i],
        abWidth = currAb.artboardRect[2] - currAb.artboardRect[0],
        abHeight = currAb.artboardRect[1] - currAb.artboardRect[3],
        label = doc.textFrames.add(),
        labelSize = (abWidth >= abHeight) ? abHeight / 2 : abWidth / 2;
    label.contents = i + 1;
    // 1296 pt limit for font size in Illustrator
    label.textRange.characterAttributes.size = (labelSize > 1296) ? 1296 : labelSize;
    label.position = [
      currAb.artboardRect[0],
      currAb.artboardRect[1]
    ];
    label.move(tmpLayer, ElementPlacement.PLACEATBEGINNING);
  }
}

// Rename artboard
function renameAb(abs, pre, suff, find, rplc) {
  var nameArr = [];
  generateName(abs, pre, suff, find, rplc, nameArr);

  for (var i = 0; i < nameArr.length; i++) {
    activeDocument.artboards[i].name = nameArr[i];
  }
}

// Generate new artboard name
function generateName(abs, pre, suff, find, rplc, out) {
  var tmpNumUp = AB_NUM_UP_PH.substr(0, 4), // Part of the placeholder before number
      tmpNumDown = AB_NUM_DOWN_PH.substr(0, 4),
      tmpPreSuff = (pre + suff).toLocaleLowerCase();
  
  // Parse number up from string    
  var startIdxNumUp = tmpPreSuff.indexOf(tmpNumUp) + tmpNumUp.length,
      endIdxNumUp = tmpPreSuff.indexOf('}', startIdxNumUp);
  var countUp = 1 * tmpPreSuff.substring(startIdxNumUp, endIdxNumUp);
  if ( isNaN(countUp) ) countUp = 0;
  AB_NUM_UP_PH = tmpNumUp + countUp + '}';
  
  // Parse number down from string    
  var startIdxNumDown = tmpPreSuff.indexOf(tmpNumDown) + tmpNumUp.length,
      endIdxNumDown = tmpPreSuff.indexOf('}', startIdxNumDown);
  var countDown = 1 * tmpPreSuff.substring(startIdxNumDown, endIdxNumDown);
  if ( isNaN(countDown) ) countDown = 0;
  AB_NUM_DOWN_PH = tmpNumDown + countDown + '}';

  for (var i = 0; i < abs.length; i++) {
    var abName = abs[i][1];
    // Find and replace
    if (FIND_ON && (find.length != 0 || find != '')) {
      if (find.match(AB_NAME_PH) != null) {
        abName = rplc;
      } else {
        var regName = new RegExp(find, 'gi');
        abName = abName.replace(regName, rplc);
      }
    }

    var tmpPre = '',
        tmpSuff = '';
    
    // Prefix checkbox is checked
    if (abs[i][0]) {
      tmpPre = replacePlaceholder(abs[i], countUp, countDown, pre);
    }
    // Suffix checkbox is checked
    if (abs[i][2]) { 
      tmpSuff = replacePlaceholder(abs[i], countUp, countDown, suff);
    }

    var regUp = new RegExp(AB_NUM_UP_PH, 'gi'),
        regDown = new RegExp(AB_NUM_DOWN_PH, 'gi');
    if ( (abs[i][0] && pre.match(regUp) != null) ||
         (abs[i][2] && suff.match(regUp) != null) ) {
      countUp++;
    }
    if ( (abs[i][0] && pre.match(regDown) != null) ||
         (abs[i][2] && suff.match(regDown) != null) ) {
      countDown--;
    }
    
    out.push(tmpPre + abName + tmpSuff);
  }
}

// Replace the placeholders in the suffix or prefix with text
function replacePlaceholder(ab, numUp, numDown, str) {
  var absNum = activeDocument.artboards.length,
      currAb = activeDocument.artboards[ab[3]], // ab[3] - artboard index from array
      abWidth = currAb.artboardRect[2] - currAb.artboardRect[0],
      abHeight = currAb.artboardRect[1] - currAb.artboardRect[3];
  
  abWidth = Math.round( convertUnits(abWidth + 'px', getDocUnit()) );
  abHeight = Math.round( convertUnits(abHeight + 'px', getDocUnit()) );
  
  var placeholders = [
    AB_NUM_UP_PH,
    AB_NUM_DOWN_PH,
    AB_WIDTH_PH,
    AB_HEIGHT_PH,
    DOC_UNITS_PH,
    DOC_DATE_PH,
    DOC_COLOR_PH
  ];
  
  for (var i = 0; i < placeholders.length; i++) {
    var reg = new RegExp(placeholders[i], 'gi');
    if (str.match(reg) !== null) {
      var val;
      switch (placeholders[i]) {
        case AB_NUM_UP_PH:
          val = fillZero(numUp, (numUp + absNum).toString().length);
          break;
        case AB_NUM_DOWN_PH:
          val = fillZero(numDown, (numDown + absNum).toString().length);
          break;
        case AB_WIDTH_PH:
          val = abWidth;
          break;
        case AB_HEIGHT_PH:
          val = abHeight;
          break;
        case DOC_UNITS_PH:
          val = getDocUnit();
          break;
        case DOC_DATE_PH:
          val = getTodayDate();
          break;
        case DOC_COLOR_PH:
          val = TXT_DOC_COLOR;
          break;
      }
      str = str.replace(reg, val);
    }
  }
  
  return str;  
}

// Add zero to the file name before the indexes are less then size
function fillZero(number, size) {
  var str = '000000000' + number;
  return str.slice(str.length - size);
}

// Get data as YYYYMMDD format. https://stackoverflow.com/a/3067896
function getTodayDate() {
  var date = new Date();
  var mm = date.getMonth() + 1;
  var dd = date.getDate();

  return [date.getFullYear(),
          (mm > 9 ? '' : '0') + mm,
          (dd > 9 ? '' : '0') + dd
         ].join('');
};

// Units conversion by Alexander Ladygin (https://github.com/alexander-ladygin)
function getDocUnit() {
  var unit = activeDocument.rulerUnits.toString().replace('RulerUnits.', '');
  if (unit === 'Centimeters') unit = 'cm';
  else if (unit === 'Millimeters') unit = 'mm';
  else if (unit === 'Inches') unit = 'in';
  else if (unit === 'Pixels') unit = 'px';
  else if (unit === 'Points') unit = 'pt';
  return unit;
}

function getUnits(value, def) {
  try {
    return 'px,pt,mm,cm,in,pc'.indexOf(value.slice(-2)) > -1 ? value.slice(-2) : def;
  } catch (e) {}
};

function convertUnits(value, newUnit) {
  if (value === undefined) return value;
  if (newUnit === undefined) newUnit = 'px';
  if (typeof value === 'number') value = value + 'px';
  if (typeof value === 'string') {
    var unit = getUnits(value),
        val = parseFloat(value);
    if (unit && !isNaN(val)) {
      value = val;
    } else if (!isNaN(val)) {
      value = val;
      unit = 'px';
    }
  }

  if (((unit === 'px') || (unit === 'pt')) && (newUnit === 'mm')) {
      value = parseFloat(value) / 2.83464566929134;
  } else if (((unit === 'px') || (unit === 'pt')) && (newUnit === 'cm')) {
      value = parseFloat(value) / (2.83464566929134 * 10);
  } else if (((unit === 'px') || (unit === 'pt')) && (newUnit === 'in')) {
      value = parseFloat(value) / 72;
  } else if ((unit === 'mm') && ((newUnit === 'px') || (newUnit === 'pt'))) {
      value = parseFloat(value) * 2.83464566929134;
  } else if ((unit === 'mm') && (newUnit === 'cm')) {
      value = parseFloat(value) * 10;
  } else if ((unit === 'mm') && (newUnit === 'in')) {
      value = parseFloat(value) / 25.4;
  } else if ((unit === 'cm') && ((newUnit === 'px') || (bnewUnit === 'pt'))) {
      value = parseFloat(value) * 2.83464566929134 * 10;
  } else if ((unit === 'cm') && (newUnit === 'mm')) {
      value = parseFloat(value) / 10;
  } else if ((unit === 'cm') && (newUnit === 'in')) {
      value = parseFloat(value) * 2.54;
  } else if ((unit === 'in') && ((newUnit === 'px') || (newUnit === 'pt'))) {
      value = parseFloat(value) * 72;
  } else if ((unit === 'in') && (newUnit === 'mm')) {
      value = parseFloat(value) * 25.4;
  } else if ((unit === 'in') && (newUnit === 'cm')) {
      value = parseFloat(value) * 25.4;
  }
  return parseFloat(value);
}

// Debugging
function showError(err) {
  alert(err + ': on line ' + err.line, 'Script Error', true);
}

try {
  main();
} catch (e) {
  // showError(e);
}