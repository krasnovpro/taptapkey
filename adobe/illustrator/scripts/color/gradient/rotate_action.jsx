/// target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

function notify(text) {
  z = new Window("palette", undefined, undefined, {borderless: true});
  z.size = [500, 50];
  z.opacity = .9;
  msg = z.add('statictext {text: "' + text + '", characters: 0, justify: "center"}');
  msg.graphics.font = ScriptUI.newFont("Arial", "REGULAR", 90);
  z.show();
  z.update();
  $.sleep(600);
  z.close();
}

// Action template
var actionSetName = 'Gradient';
var actionName = 'Rotate';

function sign(number){
  return (number)? ((number < 0)? -1 : 1 ) : 0;
}

function getGradientAngle(color) {
  var m = color.matrix;
  var mA = m.mValueA;
  var mB = m.mValueB;
  var mC = m.mValueC;
  var angle = color.angle;

  if (mB !== mC) {
    var shift = 0;
    if (mA < 0) shift = sign(mB) * 180;
    angle += Math.atan(mB/mA) * 180 / Math.PI + shift;
    if (angle < -180) angle += 360;
    else if (angle > 180) angle += -360;
  }

  return +angle.toFixed(1);
}

// Main function
function main(delta) {
  if (app.documents.length < 1 || selection.length < 1) {
    return;
  }
  var selPaths = [];
  getGradientPaths(selection, selPaths);
  selection = null;

  // notify(delta);
  var keyAngle = getFirstGradientAngle(selPaths);
  createAction(keyAngle - delta, actionSetName, actionName, fpath.fsName);

  for (var i = 0; i < selPaths.length; i++) {
    selPaths[i].selected = true;
  }

  app.doScript(actionName, actionSetName);
  app.unloadAction(actionSetName, '');
}

// Get paths from selection
function getGradientPaths(item, arr) {
  for (var i = 0; i < item.length; i++) {
    var currItem = item[i];
    try {
      switch (currItem.typename) {
        case 'GroupItem':
          getGradientPaths(currItem.pageItems, arr);
          break;
        case 'PathItem':
          if (currItem.filled && currItem.fillColor.gradient.type === GradientType.LINEAR) {
            arr.push(currItem);
          }
          break;
        case 'CompoundPathItem':
          if (currItem.pathItems[0].filled && currItem.pathItems[0].fillColor.gradient.type === GradientType.LINEAR) {
            arr.push(currItem);
          }
          break;
        default:
          currItem.selected = false;
          break;
      }
    } catch (e) {}
  }
}

function getFirstGradientAngle(arr) {
  var angle = 0;
  for (var i = 0; i < arr.length; i++) {
    var item = arr[i];
    if (arr[i].typename === 'CompoundPathItem') {
      item = arr[i].pathItems[0];
    }
    if (item.fillColor.gradient.type === GradientType.LINEAR) {
      angle = getGradientAngle(item.fillColor);
      /// angle = item.fillColor.angle;
      break;
    }
  }
  return angle;
}

function ascii2Hex(hex) {
  return hex.replace(/./g, function(a) {
    return a.charCodeAt(0).toString(16)
  });
}

function createAction(angle, set, name, path) {
  var actionStr = [
    '/version 3',
    '/name [ ' + set.length + ' ' + ascii2Hex(set) + ']',
    '/actionCount 1',
    '/action-1 {',
    '/name [ ' + name.length + ' ' + ascii2Hex(name) + ']',
    '    /eventCount 1',
    '    /event-1 {',
    '        /internalName (ai_plugin_setGradient)',
    '        /parameterCount 14',
    '        /parameter-3 {',
    '            /key 1634625388',
    '            /showInPalette 4294967295',
    '            /type (unit real)',
    '            /value ', angle.toFixed(1),
    '            /unit 591490663',
    '        }',
    '        /parameter-14 {',
    '            /key 1735995441',
    '            /showInPalette 4294967295',
    '            /type (real)',
    '            /value 1.0',
    '        }',
    '    }',
    '}'].join('');

  var f = new File('' + path + '/' + set + '.aia');
  f.open('w');
  f.write(actionStr);
  f.close();
  app.loadAction(f);
  f.remove();
}

// Check Adobe Illustrator version
function isOldAI(){
  var AIversion = app.version.slice(0,2);
  if (AIversion <= "16") {
    return true;
  }
  return false;
}

// Run script
try {
  if (!isOldAI()) {
    main(arguments.length ? parseFloat(arguments[0]) : 0);
  }
} catch (e) { }
