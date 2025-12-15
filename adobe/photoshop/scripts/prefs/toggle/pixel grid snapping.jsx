// Toggle Pixel Grid Snapping - Adobe Photoshop Script
// Description: toggle "Snap to Pixel Grid" on/off
// Requirements: Adobe Photoshop CS6 - Photoshop CC 2014
// Version: 0.2.1, 1/Aug/2016
// Author: Trevor Morris (trevor@morris-photographics.com)
// Website: http://morris-photographics.com/
// ============================================================================
// Installation:
// 1. Place script in:
//    PC(32):  C:\Program Files (x86)\Adobe\Adobe Photoshop ##\Presets\Scripts\
//    PC(64):  C:\Program Files\Adobe\Adobe Photoshop ## (64 Bit)\Presets\Scripts\
//    Mac:     <hard drive>/Applications/Adobe Photoshop ##/Presets/Scripts/
// 2. Restart Photoshop
// 3. Choose File > Scripts > Toggle Pixel Grid Snapping
// ============================================================================

// enable double-clicking from Mac Finder or Windows Explorer
#target photoshop

// bring application forward for double-click events
app.bringToFront();

// test initial conditions prior to running main function
if (isRequiredVersion()) {
	toggleSnapToPixelGrid();
}

///////////////////////////////////////////////////////////////////////////////
// toggleSnapToPixelGrid - toggle "Snap to Pixel Grid" on/off
///////////////////////////////////////////////////////////////////////////////
function toggleSnapToPixelGrid() {

	var snapEnabled = !snapToPixelGridEnabled();

	var desc1 = new ActionDescriptor();
	var ref1 = new ActionReference();
	ref1.putProperty(cTID('Prpr'), cTID('GnrP'));
	ref1.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));
	desc1.putReference(cTID('null'), ref1);
	var desc2 = new ActionDescriptor();
	desc2.putBoolean(sTID('transformsSnapToPixels'), snapEnabled);
	desc2.putBoolean(sTID('vectorSelectionModifiesLayerSelection'), true);
	desc1.putObject(cTID('T   '), cTID('GnrP'), desc2);

	try {
		app.executeAction(cTID('setd'), desc1, DialogModes.NO);
	}
	// something went wrong...
	catch(e) {
		return;
	}

	// play system beep when snap is enabled
	if (snapEnabled) {
		app.beep();
	}
}

///////////////////////////////////////////////////////////////////////////////
// snapToPixelGridEnabled - check if "Snap to Pixel Grid" is enabled
///////////////////////////////////////////////////////////////////////////////
function snapToPixelGridEnabled() {
	var ref = new ActionReference();
	ref.putProperty(cTID('Prpr'), cTID('GnrP'));
	ref.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));
	var desc = app.executeActionGet(ref);
	var gnrp = desc.getObjectValue(cTID('GnrP'));
	return gnrp.getBoolean(sTID('transformsSnapToPixels'));
}

///////////////////////////////////////////////////////////////////////////////
// isRequiredVersion - check for the required version of Adobe Photoshop
///////////////////////////////////////////////////////////////////////////////
function isRequiredVersion() {

	if (parseInt(version, 10) >= 13 && parseInt(version, 10) <= 15) {
		return true;
	}
	else {
		alert(
			'This script works with Adobe Photoshop CS6, CC, or CC 2014.',
			'Wrong version',
			false
		);
		return false;
	}
}


///////////////////////////////////////////////////////////////////////////////
// cTID - alias the native app.charIDToTypeID function
// Credit: adapted from xtools <http://ps-scripts.sourceforge.net/xtools.html>
///////////////////////////////////////////////////////////////////////////////
function cTID(s) {
   if (!cTID[s]) {
      cTID[s] = app.charIDToTypeID(s);
   }
   return cTID[s];
}

///////////////////////////////////////////////////////////////////////////////
// sTID - alias the native app.stringIDToTypeID function
// Credit: adapted from xtools <http://ps-scripts.sourceforge.net/xtools.html>
///////////////////////////////////////////////////////////////////////////////
function sTID(s) {
   if (!sTID[s]) {
      sTID[s] = app.stringIDToTypeID(s);
   }
   return sTID[s];
}
