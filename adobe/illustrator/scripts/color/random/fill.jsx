//@target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false); // Fix drag and drop a .jsx file

// Main function
function main() {
  if (!documents.length) return;
  if (selection.length == 0 || selection.typename == 'TextRange') return;
  var swatches = activeDocument.swatches.getSelected();
  var items = getItems(selection);
  fillRandom(items, swatches);
}

function getItems(coll) {
  var out = [];
  for (var i = 0; i < coll.length; i++) {
    var item = coll[i];
    if (item.pageItems && item.pageItems.length) {
      out = [].concat(out, getItems(item.pageItems));
    } else if (/compound/i.test(item.typename) && item.pathItems.length) {
      out = [].concat(out, getItems(item.pathItems));
    } else if (/pathitem|text/i.test(item.typename)) {
      out.push(item);
    }
  }
  return out;
}

function fillRandom(coll, swatches) {
  var hasSwatches = swatches.length > 1;
  var color;
  for (var i = 0, len = coll.length; i < len; i++) {
    color = hasSwatches ? getRandomSwatches(swatches) : generateColor();
    if (/text/i.test(coll[i].typename)) {
      coll[i].textRange.characterAttributes.fillColor = color;
    } else {
      coll[i].filled = true;
      coll[i].fillColor = color;
    }
  }
}

function getRandomSwatches(swatches) {
  var idx = Math.round(Math.random() * (swatches.length - 1));
  if (swatches[idx].color == '[NoColor]') return getRandomSwatches(swatches);
  return swatches[idx].color;
}

function generateColor() {
  var isRGB = activeDocument.documentColorSpace == DocumentColorSpace.RGB;
  var newColor = isRGB ? new RGBColor() : new CMYKColor();
  if (isRGB) {
    newColor.red = Math.min(rndInt(0, 255, 8), 255);
    newColor.green = Math.min(rndInt(0, 255, 8), 255);
    newColor.blue = Math.min(rndInt(0, 255, 8), 255);
  } else {
    newColor.cyan = rndInt(0, 100, 5);
    newColor.magenta = rndInt(0, 100, 5);
    newColor.yellow = rndInt(0, 100, 5);
    newColor.black = 0;
  }
  return newColor;
}

function rndInt(min, max, step) {
  var rand = min - 0.5 + Math.random() * (max - min + 1)
  return Math.round(rand / step) * step;
}

// Run script
try {
  main();
} catch (e) {}