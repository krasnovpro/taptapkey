/*
  The script will select all anchor points facing in or out
  Authors:
  Vitaliy Polyakov, https://mai-tools.com/
  Sergey Osokin, email: hi@sergosokin.ru
  Check my other scripts: https://github.com/creold

  /// changed by @krasnovpro

  Donate (optional):
  If you find this script helpful, you can buy me a coffee
  - via Buymeacoffee: https://www.buymeacoffee.com/osokin
  - via FanTalks https://fantalks.io/r/sergey
  - via DonatePay https://new.donatepay.ru/en/@osokin
  - via YooMoney https://yoomoney.ru/to/410011149615582
*/

//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

// Main function
function main() {
  var paths = getPaths(selection);
  if (documents.length && selection.length && selection.typename !== 'TextRange' && paths.length) {
    selection = null;
    for (var i = 0, len = paths.length; i < len; i++) selectPoints(paths[i], false);
  }
}

function selectPoints(path, isNeedInner) {
  var total = 0;
  var points = path.pathPoints;
  var polarity = /positive/i.test(path.polarity);

  for (var i = 0, len = points.length; i < len; i++) {
    var j = i + 1;
    var k = i + 2;
    if (j >= points.length) j -= points.length;
    if (k >= points.length) k -= points.length;

    var aPoint = points[i];
    var bPoint = points[j];
    var cPoint = points[k];

    var isPointInner = isInnerPoint(aPoint, bPoint, cPoint, polarity);
    if (isPointInner === isNeedInner) {
      bPoint.selected = PathPointSelection.ANCHORPOINT;
      total++;
    }
  }
  return total;
}

function getPaths(coll) {
  var out = [];
  for (var i = 0; i < coll.length; i++) {
    var item = coll[i];
    if (item.pageItems && item.pageItems.length) {
      out = [].concat(out, getPaths(item.pageItems));
    } else if (/compound/i.test(item.typename) && item.pathItems.length) {
      out = [].concat(out, getPaths(item.pathItems));
    } else if (/pathitem/i.test(item.typename)) {
      out.push(item);
    }
  }
  return out;
}

function getAngle(a, b) {
  var dx = b.anchor[0] - a.anchor[0];
  var dy = b.anchor[1] - a.anchor[1];
  var angle;
  if (dx >= 0 && dy >= 0) {
    angle = Math.atan(dy / dx);
  } else if (dx < 0 && dy >= 0) {
    angle = Math.atan(-dx / dy) + Math.PI / 2;
  } else if (dx < 0 && dy < 0) {
    angle = Math.atan(dy / dx) + Math.PI;
  } else {
    angle = Math.atan(-dx / dy) + Math.PI * 1.5;
  }
  return angle;
}

function isInnerPoint(a, b, c, polarity) {
  var angle1 = getAngle(b, a);
  var angle2 = getAngle(b, c);
  if (angle2 < angle1) angle2 += Math.PI * 2;
  var deltaAngle = angle2 - angle1;
  return deltaAngle >= Math.PI ? polarity : !polarity;
}

try {
  main();
} catch (err) {}