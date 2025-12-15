/// by @krasnovpro
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

var fpath = Folder.temp,
    fileout = fpath.fsName + "/ai_state.txt";

function read(file) {
  var txtFile = new File(file);
  txtFile.open("r");
  text = txtFile.read();
  txtFile.close();
  //txtFile.remove();
  return text;
}

function write(file, output) {
  var txtFile = new File(file);
  txtFile.open("w");
  txtFile.write(output);
  txtFile.close();
}

function main() {
  result = (selection.typename === 'TextRange')? 1 : 0;

  if (arguments.length)
    return result
  else
    write(fileout, result);
}

main();
