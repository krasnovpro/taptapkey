main(arguments.length? arguments[0] : 'Taptapkey');

function del(name) { try {app.deleteWorkspace(name)} catch (e) {} }
function main(name) {
  var temp = '_temp';
  del(temp);
  app.saveWorkspace(temp);
  del(name);
  app.saveWorkspace(name);
  del(temp);
}
