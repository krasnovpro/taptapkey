// Re_Corner_2018.jsx for Adobe Illustrator
// Author: Umezawa (www.pictrix.jp)
// Description: Convert selected anchor points to corner.
// How to use: Choose the anchor point you want to corner. Run script. You can process only one corner.
//
// Modification: Convert selected path segment using Direct Selection Tool (A) to corner.
// Authors: Oleg Krasnov (www.behance.net/krasnovpro), Sergey Osokin (email: hi@sergosokin.ru), Jul 2018
//
// ============================================================================
// Installation:
// 1. Place script in:
//    Win (32 bit): C:\Program Files (x86)\Adobe\Adobe Illustrator [vers.]\Presets\en_GB\Scripts\
//    Win (64 bit): C:\Program Files\Adobe\Adobe Illustrator [vers.] (64 Bit)\Presets\en_GB\Scripts\
//    Mac OS: <hard drive>/Applications/Adobe Illustrator [vers.]/Presets.localized/en_GB/Scripts
// 2. Restart Illustrator
// 3. Choose File > Scripts > Re_Corner_2018
// ============================================================================
//
// NOTICE:
// Modification tested with Adobe Illustrator CC 2018 (Win), CC 2017 (Mac).
// This script is provided "as is" without warranty of any kind.
// ============================================================================
#target illustrator
app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

if (documents.length > 0 && activeDocument.pathItems.length > 0 && activeDocument.selection.length) {
  var SelObj = activeDocument.selection[0],
    SelPts = SelObj.pathPoints.length;

  var aPoint = new Array(),
    p1 = new Array(),
    p2 = new Array(),
    p3 = new Array(),
    p4 = new Array(),
    pos = new Array();

  var sted = 0,
    count = 0;

  chkCount();

  // If number of selected points <2 then the points located on the active segment are selected
  if (count < 2) {
    if (SelObj.typename = "PathItem") {
      points = SelObj.selectedPathPoints;
      for (var j = 0; j < points.length; j++) {
        points[j].selected = PathPointSelection.ANCHORPOINT;
      }
      chkCount();
    }
  }
  var last = count - 1;
  if (SelObj.closed && sted == 2) {
    for (var i = 0; i < last; i++) {
      if (aPoint[i + 1] != aPoint[i] + 1) {
        aPoint2 = aPoint[i];
        aPoint1 = aPoint2 + 1;
        break;
      }
    }

    for (var i = last; i >= 0; i--) {
      if (aPoint[i - 1] != aPoint[i] - 1) {
        aPoint3 = aPoint[i];
        aPoint4 = aPoint3 - 1;
        break;
      }
    }

    for (i = 0; i < last; i++) {
      for (j = i + 1; j <= last; j++) {
        if (aPoint[i] > aPoint[j]) {
          wk = aPoint[i];
          aPoint[i] = aPoint[j];
          aPoint[j] = wk;
        }
      }
    }

  } else {
    aPoint2 = aPoint[0];
    aPoint3 = aPoint[last];
    aPoint1 = (aPoint2 == 0) ? SelPts - 1 : aPoint2 - 1;
    aPoint4 = (aPoint3 == SelPts - 1) ? 0 : aPoint3 + 1;
  }

  p2 = SelObj.pathPoints[aPoint2].anchor;
  p3 = SelObj.pathPoints[aPoint3].anchor;
  p1 = SelObj.pathPoints[aPoint1].anchor;
  p4 = SelObj.pathPoints[aPoint4].anchor;

  err = inter(pos, p3, p4, p1, p2);
  if (!err) {
    newPoint = SelObj.pathPoints[aPoint2];
    newPoint.anchor = pos;
    newPoint.leftDirection = pos;
    newPoint.rightDirection = pos;

    for (i = last; i >= 0; i--) {
      if (aPoint[i] != aPoint2) SelObj.pathPoints[aPoint[i]].remove();
    }
  /// } else {
    /// alert("error");
  }
}

function chkCount() {
  for (var i = 0; i < SelPts; i++) {
    if (SelObj.pathPoints[i].selected == PathPointSelection.ANCHORPOINT) {
      if (i == 0 || i == SelPts - 1) sted++;
      aPoint[count++] = i;
    }
  }
}

function inter(ret, p3, p4, p1, p2) {
  var v1 = new Array;
  var v2 = new Array;
  var d1, d2, wk;

  VNORM3(v1, p2, p1);
  VNORM3(v2, p4, p3);

  wk = v2[0];
  v2[0] = v2[1];
  v2[1] = wk;
  if (v2[0]) v2[0] = -v2[0];
  else v2[1] = -v2[1];

  d1 = v2[0] * (p1[0] - p3[0]) + v2[1] * (p1[1] - p3[1]);
  d2 = v1[0] * v2[0] + v1[1] * v2[1];

  if (d2 > -0.009 && d2 < 0.009) {
    return -1;
  } else {

    ret[0] = p1[0] - v1[0] * (d1 / d2);
    ret[1] = p1[1] - v1[1] * (d1 / d2);
    return 0;
  }
}

function VNORM3(v3, v1, v2) {
  VSUB3(v3, v1, v2);
  VDIV(v3, VLEN(v3));
}

function VDIV(v1, s) {
  v1[0] /= s;
  v1[1] /= s;
}

function VSUB3(v3, v1, v2) {
  v3[0] = v1[0] - v2[0];
  v3[1] = v1[1] - v2[1];
}

function VLEN(v) {
  return (Math.sqrt(v[0] * v[0] + v[1] * v[1]));
}