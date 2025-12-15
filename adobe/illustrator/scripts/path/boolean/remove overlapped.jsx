// Exclude non-unique bezier curves script
// DESCRIPTION:
//  The script compares selected bezier curves and removes those repeating the contour of the very bottom item
// USAGE:
//   https://www.dl.dropboxusercontent.com/s/5584s420vvik8dh/excludeBezier.mp4
// CONTACTS:
//   Email: moodyallen7@gmail.com
//   Telegram: @moodyallen

app.preferences.setBooleanPreference('ShowExternalJSXWarning', false);

// var ht = $.hiresTimer;

var TOLERANCE = 0.5; // The threshold that determines whether a point is lying on the base spline
var MAX_SPAM_GAP = 1; // Maximum gap between two interpolated points. A value of '1' means at least one virtual point on every pt of length  
var MIN_SPAM_GAP = 0.2; ///0.5
var DONT_CLARIFY = true; // If true, only bezier segments that are fully lying on the base spline will be removed; 
var FUZZY_CHECK_PRECISION = 0.1; // The lesser value, the more reliable fuzzy check will be while sorting segments by categories. Do not set bigger than 0.1
var STATUS = { save: 0, clarify: 1, remove: 2 }; // Kinds of bezier segments
var IMAGE_ITEM = null; // Donor of settings for the segments to be drawn

if (selection.length > 1) {
    IMAGE_ITEM = selection[0]; 
}

function moduleDiff(a, b){
    return Math.abs(a - b);
}

function comparePoints(a, b){
    return a.anchor[0] === b.anchor[0] && a.anchor[1] === b.anchor[1];
}

function getBezierPoints(aiPointA, aiPointB){
    return { 
        p0: aiPointA.anchor,
        p1: aiPointA.rightDirection,    
        p2: aiPointB.leftDirection,
        p3: aiPointB.anchor
    }
}

function pointInLine(a, b, t) {
    var c = [];
    c[0] = a[0] - ((a[0] - b[0]) * t);
    c[1] = a[1] - ((a[1] - b[1]) * t);
    return c;
}

function interpolate(bezier, t){
    var a = pointInLine(bezier.p0, bezier.p1, t);
    var b = pointInLine(bezier.p1, bezier.p2, t);
    var c = pointInLine(bezier.p2, bezier.p3, t);
    var d = pointInLine(a, b, t);
    var e = pointInLine(b, c, t);
    var f = pointInLine(d, e, t);
    return { anchor: f, left: d, right: e };
}

function lineDistance(a, b){
    var x1 = a[0], x2 = b[0];
    var y1 = a[1], y2 = b[1];
    return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
}

function spamMiddleTPoints(bezier){
    
    var points = [];
    var p0 = bezier.p0, p1 = bezier.p1, p2 = bezier.p2, p3 = bezier.p3;
    var t = 0.5;

    if (lineDistance(p0, p3) > MAX_SPAM_GAP){
        var m = interpolate(bezier, t);
        points.push(m.anchor);
        var bezierLeft = { p0: p0, p1: pointInLine(p0, p1, t), p2: m.left, p3: m.anchor };
        var bezierRight = { p0: m.anchor, p1: m.right, p2: pointInLine(p2, p3, t), p3: p3 };
        points = points.concat(spamMiddleTPoints(bezierLeft));
        points = points.concat(spamMiddleTPoints(bezierRight));
    }

    return points;
}

function spamSegmentPoints(aiPointA, aiPointB){
    var bezier = getBezierPoints(aiPointA, aiPointB);
    return [].concat([bezier.p0], spamMiddleTPoints(bezier), [bezier.p3]);
}

function spamSplinePoints(item){
    
    var i = 0;
    var points = [];
    var pp = item.pathPoints;

    while (i+1 < pp.length) {
        var sp = spamSegmentPoints(pp[i], pp[++i]);
        points = points.concat(sp);
    }
    
    if (item.closed){
        var sp = spamSegmentPoints(pp[i], pp[0]);
        points = points.concat(sp);
    }

    return points;
}

function binarySearch (arr, targetPoint, threshold) { // arr = array of points [x, y] sorted by x;

    var up = arr.length - 1;
    var down = 0;
    
    while (down <= up) {
        
        var i = Math.floor( (down + up) / 2);
        
        if (arr[i][0] > targetPoint[0]) {
            up = i - 1;
        } 
        
        else if (arr[i][0] < targetPoint[0]){
            down = i + 1;
        }

        if (moduleDiff(targetPoint[0], arr[i][0]) <= threshold) {
            return i;
        }

    }

    return null;  // no points within threshold
}

function getPointsWithinXThreshold(arr, targetPoint, threshold){ // arr = array of points [x, y] sorted by x;
    
    var startIndex = binarySearch(arr, targetPoint, threshold);
    if (startIndex === null) return [];
    
    var result = [];
    var down = startIndex;
    var up = startIndex + 1;
    
    do{
        
        var resultL = result.length;
        
        if (down > -1 && moduleDiff(targetPoint[0], arr[down][0]) <= threshold){
            result.push(arr[down--]);
        }
    
        if (up < arr.length && moduleDiff(targetPoint[0], arr[up][0]) <= threshold){
            result.push(arr[up++]);
        }

    }
    while (result.length > resultL)
    
    return result;

}

function isPointOnSpline(splinePoints, point, threshold){ // splinePoints = array of points [x, y] sorted by x;
    
    var pwxt = getPointsWithinXThreshold(splinePoints, point, threshold);

    var i = 0;
    while (i < pwxt.length){
        if (lineDistance(point, pwxt[i++]) <= threshold) return true;
    }

    return false;
} 

function fuzzyCheck (bezier){

    // var arr = [bezier.p0];
    var points = [];
    var gap = FUZZY_CHECK_PRECISION;
    var t = gap;

    while(t < 1){
        points.push(interpolate(bezier, t).anchor);
        t += gap;
    }
    // arr.push(bezier.p3);

    var j = 0;
    var isOn = isPointOnSpline(BASE_SPLINE, points[j++], TOLERANCE);
    var sure = true;

    while (sure && j < points.length){
        sure = (isOn === isPointOnSpline(BASE_SPLINE, points[j++], TOLERANCE));
    }

    if (!sure){
        return 1; // segment to clarify
    }
    
    else if (isOn){ 
        return 2; // segment to delete 
    }

    return 0; // do nothing
}

function filterSegments (item) {

    var toDelete = [];  
    var toClarify = [];
    var pp = item.pathPoints;

    var i = 0;
    while (i+1 < pp.length) {

        var a = pp[i];
        var b = pp[++i];
        var bezier = getBezierPoints(a, b);
        var result = fuzzyCheck(bezier);
        
        if (result === STATUS.clarify){
            toClarify.push([a, b]);
        }
        
        else if (result === STATUS.remove){
            toDelete.push([a, b]);
        }

    }

    if (item.closed){

        var a = pp[i];
        var b = pp[0];
        var bezier = getBezierPoints(a, b);
        var result = fuzzyCheck(bezier);
        
        if (result === STATUS.clarify){
            toClarify.push([a, b]);
        }

        else if (result === STATUS.remove){
            toDelete.push([a, b]);
        }
    }

    return { toDelete: toDelete, toClarify: toClarify };

}

function getPointsHash(segments) { // segments = array of [aiPointA, aiPointB] 
    
    function hashId(point){
        return point.anchor.toString() + point.parent.absoluteZOrderPosition;
    }

    var hash = {};
    var i = 0;

    do{
        var a = segments[i][0];
        var b = segments[i][1];
        var aId = hashId(a);
        var bId = hashId(b);
        var parent = a.parent;
        var pp = parent.pathPoints;
        
        if (hash[aId] === undefined) {
            hash[aId] = { 
                aiPoint: a, 
                state: ( !parent.closed && aId === hashId(pp[0]) )? 0 : 1 
            };
        }
        
        else {
            hash[aId].state = 0;
        }
        
        if (hash[bId] === undefined) {
            hash[bId] = { 
                aiPoint: b, 
                state: ( !parent.closed && bId === hashId(pp[pp.length-1]) )? 0 : -1 
            };
        }

        else {
            hash[bId].state = 0;
        }

    }
    while (++i < segments.length)

    return hash;

}

function interpolateWithGap(bezier, startPoint, startT){

    var t = 0;
    var tplus = startT || 0.5;
    var a = startPoint;

    while(true){

        var sum = t + tplus;

        if (sum > 1) sum = 1;

        var b = interpolate(bezier, sum);
        var d = lineDistance(a, b.anchor);
        
        if (d > MAX_SPAM_GAP){
            tplus = tplus/2;
        } 

        else if (d < MIN_SPAM_GAP && sum < 1){
            t = sum;
        }

        else{
            t = sum;
            break;
        }

    }

    return { anchor: b.anchor, left: b.left, right: b.right, t: t }

}


function retriveUniqueParts(bezier){

    var unique = [];
    var p0 = bezier.p0, p1 = bezier.p1, p2 = bezier.p2, p3 = bezier.p3;

    var a = { anchor: p0, left: p0, right: p1 };
    var b = a;
    var lastIsOn = isPointOnSpline(BASE_SPLINE, p0, TOLERANCE);
    var isOn = lastIsOn;
    var t = 0.5;

    loop: while(true){

        while(isOn === lastIsOn && t < 1){
            var p = interpolateWithGap({ p0: p0, p1: p1, p2: p2, p3: p3 }, b.anchor, t);
            isOn = isPointOnSpline(BASE_SPLINE, p.anchor, TOLERANCE);
            t = p.t;
            b = { anchor: p.anchor, left: p.left, right: p.right };
        }
    
        if (lastIsOn === false) unique.push([{ anchor: p0, left: p0, right: pointInLine(p0, p1, t) }, b]);
        if (t === 1) break;
        
        p0 = b.anchor;
        p1 = b.right;
        p2 = pointInLine(p2, p3, t);
        lastIsOn = isOn;
        t = 0.5;
        a = b;

        var result = fuzzyCheck({ p0: p0, p1: p1, p2: p2, p3: p3 });
        
        if (result === STATUS.clarify) continue loop;
        
        if (result === STATUS.save) unique.push([a, { anchor: p3, left: p2, right: p3 }]);
        
        break;
    }
    
    return unique;
}

function drawSegment(segment){
    var item = app.activeDocument.pathItems.add();
    var i = 0;
    
    if (IMAGE_ITEM !== null){
        item.stroked = IMAGE_ITEM.stroked;
        item.strokeWidth = IMAGE_ITEM.strokeWidth;
        item.strokeCap = IMAGE_ITEM.strokeCap;
        item.strokeColor = IMAGE_ITEM.strokeColor;
        item.strokeDashes = IMAGE_ITEM.strokeDashes;
        item.strokeDashOffset = IMAGE_ITEM.strokeDashOffset;
        item.strokeJoin = IMAGE_ITEM.strokeJoin;
        item.strokeMiterLimit = IMAGE_ITEM.strokeMiterLimit;
        item.strokeOverprint = IMAGE_ITEM.strokeOverprint;
        item.filled = IMAGE_ITEM.filled;
        item.fillColor = IMAGE_ITEM.fillColor;
        item.fillOverprint = IMAGE_ITEM.fillOverprint;
        item.opacity = IMAGE_ITEM.opacity;
    }

    while(i < segment.length){
        var p = item.pathPoints.add();
        p.anchor = segment[i].anchor;
        p.leftDirection = segment[i].left;
        p.rightDirection = segment[i].right;
        i++;
    }
}


var BASE_SPLINE = [];

function main (){

    if(selection.length < 2) {
        alert('At least two items should be selected!');
        return;
    }

    var basePath = selection[selection.length-1];

    if (basePath.typename === "CompoundPathItem"){

        var pI = basePath.pathItems;
        for (var i = 0; i < pI.length; i++) {
            BASE_SPLINE = BASE_SPLINE.concat(spamSplinePoints(pI[i]));
        }
        
    }

    else {
        BASE_SPLINE = spamSplinePoints(basePath);
    }

    BASE_SPLINE.sort(function (a, b){
        return a[0] - b[0];
    });

    // $.writeln(baseSpline.length);

    var sel = app.activeDocument.selection;
    var selL = sel.length-1;
    var toDelete = [];
    var toClarify = [];
    var toDraw = [];

    for (var i = 0; i < selL; i++) {
        var item = sel[i];
        var segments = filterSegments(item);
        toDelete = toDelete.concat(segments.toDelete);
        toClarify = toClarify.concat(segments.toClarify);
    }

    if (toClarify.length > 0 && !DONT_CLARIFY){

        for (var i = 0; i < toClarify.length; i++) {
            var segment = toClarify[i];
            var bezier = getBezierPoints(segment[0], segment[1]);
            var unique = retriveUniqueParts(bezier);
            toDraw = toDraw.concat(unique);
            toDelete.push(segment);
        }

    }

    if (toDelete.length > 0){
        
        app.activeDocument.selection = null;
        var hash = getPointsHash(toDelete);
        
        for (var key in hash) {
            var p = hash[key];
            if (p.state === -1 /* left */) p.aiPoint.selected = PathPointSelection.LEFTDIRECTION;
            else if (p.state === 0 /* anchor */) p.aiPoint.selected = PathPointSelection.ANCHORPOINT;
            else if (p.state === 1 /* right */) p.aiPoint.selected = PathPointSelection.RIGHTDIRECTION;
        }
        
        app.cut();

    }

    if (toDraw.length > 0){
        
        var l = toDraw.length;
        while (l--) drawSegment(toDraw[l]); 

    }

}

main();
    
// $.writeln($.hiresTimer/1000 + ' ms');
// $.gc();