//How it works: https://www.dropbox.com/s/qw1ytr3pbz4ernw/clipping%20mask%20minus%20front.gif?dl=0
//Telegram: @moodyallen
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

var doc=activeDocument;
var sel=doc.selection;
var clipGr;
var clipper;

for(var i=0;i<sel.length;i++){
    if(sel[i].typename=="GroupItem" && sel[i].clipped){
        clipGr=sel[i];
        clipGr.selected=false;
        if(doc.selection.length>1) app.executeMenuCommand('compoundPath');
        clipper=doc.selection[0];
        break;
    }
}
 
if(clipGr){
    
    var pI=clipGr.pageItems;
    var clipItm;
    var arr=[];

    for(var i=0;i<pI.length;i++){
            if(pI[i].clipping){
                clipItm=pI[i];
            }else if(pI[i].typename=="CompoundPathItem"){
                if(pI[i].pathItems[0].clipping) clipItm=pI[i];
        }else{
                arr.push(pI[i]);
            }
    }
    
    doc.selection=clipGr;
    app.executeMenuCommand('releaseMask');
    
    if(clipItm.typename=="CompoundPathItem"){  
        var paI=clipItm.pathItems;
        for(var i=0;i<paI.length;i++) paI[i].filled=true;
    }else{
        clipItm.filled=true;
    }
    
 
    var newGr=doc.activeLayer.groupItems.add();
    clipper.move(newGr, ElementPlacement.PLACEATEND);  
    clipItm.move(newGr, ElementPlacement.PLACEATEND);  
    doc.selection=newGr;

    app.executeMenuCommand('Live Pathfinder Subtract'); 
    app.executeMenuCommand('expandStyle');
    app.executeMenuCommand('ungroup');  
    if(activeDocument.selection.length>1) app.executeMenuCommand('compoundPath');  

    arr.push(doc.selection[0]);
    doc.selection=arr;

    app.executeMenuCommand('makeMask');
    doc.selection=null;
}

