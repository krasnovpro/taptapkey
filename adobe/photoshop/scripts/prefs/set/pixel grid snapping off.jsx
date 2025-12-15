// Disable Pixel Grid Snapping - Adobe Photoshop Script
// Description: disable Preferences > Tools > "Snap Vector Tools and Transforms to Pixel Grid"
// Requirements: Adobe Photoshop CC 2015, or higher
// Version: 0.2.2, 15/Aug/2016
// Author: Trevor Morris (trevor@morris-photographics.com)
// Website: http://morris-photographics.com/
// ============================================================================
// Installation:
// 1. Place script in:
//    PC(32):  C:\Program Files (x86)\Adobe\Adobe Photoshop ##\Presets\Scripts\
//    PC(64):  C:\Program Files\Adobe\Adobe Photoshop ## (64 Bit)\Presets\Scripts\
//    Mac:     <hard drive>/Applications/Adobe Photoshop ##/Presets/Scripts/
// 2. Restart Photoshop
// 3. Choose File > Scripts > Disable Pixel Grid Snapping
// ============================================================================

// enable double-clicking from Mac Finder or Windows Explorer
#target photoshop

// bring application forward for double-click events
app.bringToFront();

// test initial conditions prior to running main function
if (isRequiredVersion()) {
	snapToPixelGrid(false);
}

///////////////////////////////////////////////////////////////////////////////
// snapToPixelGrid - toggle "Snap Vector Tools and Transforms to Pixel Grid"
///////////////////////////////////////////////////////////////////////////////
function snapToPixelGrid(snapEnabled) {

	// action descriptor
	var desc1 = new ActionDescriptor();
	var ref1 = new ActionReference();
	ref1.putProperty(cTID('Prpr'), sTID('toolsPreferences'));
	ref1.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));
	desc1.putReference(cTID('null'), ref1);
	var desc2 = new ActionDescriptor();
	desc2.putBoolean(sTID('transformsSnapToPixels'), snapEnabled);
	desc1.putObject(cTID('T   '), sTID('toolsPreferences'), desc2);

	try {
		app.executeAction(cTID('setd'), desc1, DialogModes.NO);
	}
	// something went wrong...
	catch(e) {
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// isRequiredVersion - check for the required version of Adobe Photoshop
///////////////////////////////////////////////////////////////////////////////
function isRequiredVersion() {

	if (parseInt(version, 10) >= 16) {
		return true;
	}
	else {
		alert(
			'This script requires Adobe Photoshop CC 2015 or higher.',
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
