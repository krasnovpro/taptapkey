if (!String.prototype.trim)
  String.prototype.trim = function () {
    return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
  }

if (documents.length && selection.length && selection[0].uRL.length) {
  var f = File(Folder.temp + '/aiOpenURL.url')
    , url = selection[0].uRL.trim().replace(/^http.*?:\/\//i, '');
  f.open('w');
  f.write('[InternetShortcut]' + '\r' + 'URL=http://' + url + '\r');
  f.close();
  f.execute();
}