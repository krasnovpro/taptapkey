/**
 * Swap of fill and stroke for multiple objects
 * @author skillful_Wish8049
 * @discussion https://community.adobe.com/t5/illustrator-discussions/swapping-fill-and-stroke-on-multiple-objects/td-p/2233202
 */

app.preferences.setBooleanPreference("ShowExternalJSXWarning", false);
var v_selection = app.activeDocument.selection;

Swap(v_selection);

function Swap(selection) {
    var ob_keep = null;
    
    for (var k = 0; k < selection.length; k++) {
        var subSelelction = selection[k];
        
        if (subSelelction.typename == 'PathItem') {
            var c_fill = subSelelction.fillColor;
            var c_stroke = subSelelction.strokeColor;
            subSelelction.fillColor = c_stroke;
            if(!subSelelction.stroked) {
                subSelelction.stroked = true;
            }
            subSelelction.strokeColor = c_fill;                 
        }
        else {
            if(ob_keep == null) {
                ob_keep = new Array();
                ob_keep.push(subSelelction);
            } else {
                ob_keep.push(subSelelction);
            }           
        }
    }
    
    if (ob_keep != null) {
        for (var n = 0; n < ob_keep.length; n++) {
            if (ob_keep[n] && ob_keep[n].typename == 'GroupItem')
            {
                Swap(ob_keep[n].pageItems);
            }
            else if (ob_keep[n] && ob_keep[n].typename == 'CompoundPathItem') {
                Swap(ob_keep[n].pathItems);
            }
        }
    }
}

redraw();