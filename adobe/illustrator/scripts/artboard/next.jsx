/*
3flab-view_next_artboard.jsx

Date Created: 2014/12/07
Date Modified: 2015/11/13
Version: 1.0

Copyright (c) 2015 Seiji Miyazawa @3flab inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

if (documents.length > 0){
	var doc = app.activeDocument
	var artboards = doc.artboards;
	var saverulerOrigin = doc.rulerOrigin;
	var zoom = doc.activeView.zoom;
	var lastAbNum = artboards.length - 1;
	var selAbNum = artboards.getActiveArtboardIndex();
	var selAb = artboards[selAbNum];
	var prevAbNum = selAbNum - 1;
	var nextAbNum = selAbNum + 1;
	if (nextAbNum > lastAbNum){
		artboards.setActiveArtboardIndex(0);
		selAbNum = artboards.getActiveArtboardIndex();
		selAb = artboards[selAbNum]; 
	} else {
		artboards.setActiveArtboardIndex(nextAbNum);
		selAbNum = artboards.getActiveArtboardIndex();
		selAb = artboards[selAbNum]; 
	}
		doc.rulerOrigin = [0,0];
	var artoboardW = selAb.artboardRect[2] - selAb.artboardRect[0];
	var artoboardH = selAb.artboardRect[1] - selAb.artboardRect[3];
		doc.activeView.centerPoint = [artoboardW/2, artoboardH/2];
		doc.activeView.zoom = 1;
		doc.activeView.zoom = zoom;
}