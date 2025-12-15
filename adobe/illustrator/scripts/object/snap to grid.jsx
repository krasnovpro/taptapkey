#target illustrator

// jooSnapToDocumentGrid.jsx v1.0
//
// Copyright (c) 2016 Janne Ojala
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// modified by chegr to work with
// groups, compound paths, point text objects,
// and also handles, guides, clips as customizable options


// choose your options here
snap_text    = true;
snap_guides  = true;
snap_clips   = true;
snap_handles = false; // gets redefined in a confirm dialog below
point_limit  = 0; // 2 ignores lines with 2 points, 1 ignores single points, 0 disables limit

main();

function main() {
    var grid = getDocumentGrid();

    var sp = [];
    getPathItemsInSelection(0, sp);

    snap_handles = confirm("Current options are:\nText " + snap_text + ", Guides " + snap_guides + ", Clips " + snap_clips + ", Point limit " + point_limit + "\nSnap Handles to grid?");

    if (snap_text) {
        var st = [];
        getTypeItemsInSelection(st);
        snapSelectedTextToDocumentGrid(st, grid);

        snapSelectedPathToDocumentGrid(sp, grid);
        if ((sp.length < 1) && (st.length < 1)) return;
    } else {
        snapSelectedPathToDocumentGrid(sp, grid);
        if (sp.length < 1) return;
    }
}

function getDocumentGrid() {
    var prf = app.preferences;
    var ticks = prf.getIntegerPreference('Grid/Horizontal/Ticks');
    var spacing = prf.getRealPreference('Grid/Horizontal/Spacing');

    // PLACEBO fix: sometimes the script seems to not read prefs correctly
    prf.setIntegerPreference('Grid/Horizontal/Ticks', ticks);
    prf.setRealPreference('Grid/Horizontal/Spacing', spacing);

    return spacing / ticks;
}

function snapSelectedPathToDocumentGrid(sel, grid) {
    for (var i = 0; i < sel.length; i++) {
        var pp = sel[i].pathPoints;
        for (var j = 0; j < pp.length; j++) {
            var p = pp[j];
            if (p.selected == PathPointSelection.NOSELECTION)
                continue;
            else if (p.selected == PathPointSelection.ANCHORPOINT ||
                p.selected == PathPointSelection.LEFTRIGHTPOINT) {
                if (snap_handles) {
                    p.leftDirection  = nearestGrid(p.leftDirection,  grid);
                    p.rightDirection = nearestGrid(p.rightDirection, grid);
                } else {
                    p.leftDirection  = applyDelta(p.leftDirection,  getDelta(p.anchor, grid));
                    p.rightDirection = applyDelta(p.rightDirection, getDelta(p.anchor, grid));
                }
                p.anchor = nearestGrid(p.anchor, grid);
            }
        }
    }
}

// the anchor is read only, but its position is not,
// so we move a text to a difference between anchor position and the goal
function snapSelectedTextToDocumentGrid(sel, grid) {
    for (var i = 0; i < sel.length; i++) {
        var t = sel[i];
        t.position = [nearestGrid(t.anchor, grid)[0] - (t.anchor[0] - t.position[0]), (t.position[1] - t.anchor[1]) + nearestGrid(t.anchor, grid)[1]];
    }
}

function nearestGrid(anchor, grid) {
    return [Math.round(anchor[0] / grid) * grid,
        Math.round(anchor[1] / grid) * grid
    ];
}

function getDelta(anchor, grid) {
    return [Math.round(anchor[0] / grid) * grid - anchor[0],
        Math.round(anchor[1] / grid) * grid - anchor[1]];
}

function applyDelta(anchor, delta) {
    return [anchor[0] + delta[0],
        anchor[1] + delta[1]];
}

// look for point text objects in the selection
// and put them into the separate array "st"
function getTypeItemsInSelection(texts) {
    var s = activeDocument.selection;
    for (var i = 0; i < s.length; i++) {
        var t = s[i];
        if (t.typename == "TextFrame") {
            if (t.kind == TextType.POINTTEXT) {
                texts.push(t);
            }
        }
    }
}

// functions below taken from
// Cut At Selected Anchors
// cuts selected puthes at each selected anchor
// test env: Adobe Illustrator CS3, CS6 (Windows)
// Copyright(c) 2005-2013 Hiroyuki Sato
// https://github.com/shspage
// This script is distributed under the MIT License.
// See the LICENSE file for details.
// Wed, 30 Jan 2013 07:04:30 +0900

// extract PathItems from the selection which length of PathPoints
// is greater than "n"
function getPathItemsInSelection(n, paths) {
    if (documents.length < 1) return;

    var s = activeDocument.selection;

    if (!(s instanceof Array) || s.length < 1) return;

    extractPaths(s, n, paths);
}

// extract PathItems from "s" (Array of PageItems -- ex. selection),
// and put them into an Array "paths".
// If "pp_limit" is specified, this function extracts PathItems
// which PathPoints length is greater than this number.
function extractPaths(s, pp_limit, paths) {
    for (var i = 0; i < s.length; i++) {
        if (s[i].typename == "PathItem") {
            if (pp_limit && s[i].pathPoints.length <= pp_limit) {
                continue;
            }
            if ( (!s[i].guides && !s[i].clipping) ||
                 (s[i].guides && snap_guides) ||
                 (s[i].clipping && snap_clips) ) {
                paths.push(s[i]);
            }

        } else if (s[i].typename == "GroupItem") {
            // search for PathItems in GroupItem, recursively
            extractPaths(s[i].pageItems, pp_limit, paths);

        } else if (s[i].typename == "CompoundPathItem") {
            // searches for pathitems in CompoundPathItem, recursively
            // ( ### Grouped PathItems in CompoundPathItem are ignored ### )
            extractPaths(s[i].pathItems, pp_limit, paths);
        }
    }
}