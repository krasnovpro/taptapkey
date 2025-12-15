/*
  パスを延長   Copyright (c) koji sakai
  https://gist.github.com/S4K4K0/62896e92287b40fded0d7f1614082d22

  プレビュー部分やUIは以下のサンプルを元にしています
  https://qiita.com/shspage/items/441ccf61394d9c504beb
  
  * HOW TO USE
  選択して実行するとスライダーが表示され、始端か終端のセグメントに対して指定した比率でBezier曲線のパラメータが延長されます
  （サイズや長さがそのままk倍になるわけではありません）
  もとのパスのハンドルの状態によっては意図どおりに伸びません（ハンドルの長さが極端に違う、ハンドルが交差している等）。
  Bezier曲線の性質とご理解ください。
  また、今のところ直線に対してはうまく機能しません。
  
  このスクリプトを用いた結果として生じたいかなる損害・不利益について責任は持てません（いちおう）。

  2017/11/15
  2017/11/17 延長した側のアンカーのハンドル位置に不具合が生じていたのを修正
*/

main();
function main(){
    // 設定リストです。
    // ダイアログの初期値の設定や、外部処理に値をまとめて渡すために使用しています。
    var conf = {
        rate : "1.0",
        maxSliderValue : 2.0,
        reversed : false
    }

    // 選択範囲からパスだけを取得します。
    var paths = extractPathsInSelection();
    // パスがない場合は終了です。
    if(paths.length < 1) {
        alert("no path in the selection");
        return;
    }
    // 対象とするパスがなくても終了
    if(!isValid(paths)) {
        alert("please select open path");
        return;
    }

    // プレビュー中に true にするフラグです。
    var previewed = false;

    var clearPreview = function(){
        if( previewed ){
            // ↑プレビューフラグが立っているとき（プレビューされているとき）
            // のみ実行されます。
            try{
                undo();
                // 次の redraw をしないとクラッシュする場合があります。
                // 大丈夫な場合も多いのですが。理由はまだよくわかっていません。
                redraw();
            } catch(e){
                // 万一エラーが発生した場合は警告を表示します。
                alert(e);
            } finally {
                // プレビュー中フラグをリセットします。
                previewed = false;
            }
        }
    }

    var drawPreview = function(){
        // プレビューを描画します。外部のメソッドに処理を回します。
        if(conf.rate > 1.0){
            try{
                // try でくくっていても、メイン処理中でエラーになると
                // ダイアログがフリーズ状態になることがありますので、
                // 外部のメソッドは事前に単独で十分テストしてください。
                extendPaths(conf, paths);
            } finally {
                // プレビュー中フラグを立てます。
                previewed = true;
            }
        }
    }

    // ダイアログの表示 ----------------------------
    var win = new Window("dialog", "Extend Paths" );
    win.alignChildren = "fill";

    // スライダー
    win.rateSliderPanel = win.add("panel", undefined, "rate");
    win.rateSliderPanel.orientation = "row";
    win.rateSliderPanel.alignChildren = "fill";
    win.rateSliderPanel.rateSlider = win.rateSliderPanel.add(
        "slider", undefined, conf.rate, 1.0, conf.maxSliderValue);
    win.rateSliderPanel.valueText = win.rateSliderPanel.add(
        "statictext", undefined, conf.rate);  // 冒頭で設定した rate を初期値にしています。
    win.rateSliderPanel.valueText.characters = 4;

    // チェックボックス
    win.chkGroup = win.add("group");
    win.chkGroup.alignment = "center";
    win.chkGroup.reverseChk = win.chkGroup.add("checkbox", undefined, "reverse");
    win.chkGroup.previewChk = win.chkGroup.add("checkbox", undefined, "preview");
    win.chkGroup.previewChk.value = true;



    // ボタン
    win.btnGroup = win.add("group", undefined );
    win.btnGroup.alignment = "center";
    win.btnGroup.okBtn = win.btnGroup.add("button", undefined, "OK");
    win.btnGroup.cancelBtn = win.btnGroup.add("button", undefined, "Cancel");

    var getValues = function(){
        // 入力値を設定リストに割り当てます。
        conf.rate = win.rateSliderPanel.valueText.text;
        conf.reversed = win.chkGroup.reverseChk.value;
    }

    var processPreview = function( is_preview ){
        // プレビュー処理をします。
        // 引数の is_preview は、プレビューのとき true
        // OK ボタンを押して処理を確定するとき false です。
        if( ! is_preview || win.chkGroup.previewChk.value){
            try{
                // プレビュー中にダイアログの操作をされないように、enabled を設定します。
                win.enabled = false;
                // 入力値を取得します。
                getValues();
                // プレビュー中の場合はいったん元に戻します。
                clearPreview();
                // プレビューの描画を行います。
                drawPreview();
                // プレビューの場合は、画面を強制的に再描画します。
                if( is_preview ) redraw();
            } catch(e){
                alert(e);
            } finally{
                win.enabled = true;
            }
        }
    }

    win.rateSliderPanel.rateSlider.onChanging = function(){
        // スライダーを動かしているときの処理。
        // 実際の処理を行うと重くなるため、スライダー脇の値のみ変更しています。
        win.rateSliderPanel.valueText.text = this.value.toFixed( 1 );
    }
    win.rateSliderPanel.rateSlider.onChange = function(){
        // スライダーを動かし終えたときの処理。プレビュー処理を行います。
        win.rateSliderPanel.valueText.text = this.value.toFixed( 1 );
        processPreview( true );
    }

    win.chkGroup.previewChk.onClick = function(){
        // プレビューチェックボックスをクリックしたときの処理。
        if( this.value == true ){
            // チェックを入れた場合。
            processPreview( true );
        } else {
            // チェックを外した場合。プレビュー中の場合は元に戻します。
            if( previewed ){
                clearPreview();
                redraw();
            }
        }
    }

    win.chkGroup.reverseChk.onClick = function(){
        //プレビューチェックボックスをクリックしたときの処理。
            conf.reversed = win.chkGroup.reverseChk.value;
            processPreview( true );
            redraw();
    }


    win.btnGroup.okBtn.onClick = function(){
        // OK ボタンをクリックしたときの処理。
        // プレビュー中の場合は、何もせず終了。
        // そうでない場合はプレビュー描画時と同じ処理をしてから終了します。
        if(!previewed) processPreview( false );
        win.close();
    }

    win.btnGroup.cancelBtn.onClick = function(){
        // キャンセルボタンをクリックした時の処理。
        // プレビュー中の場合は元に戻します。
        try{
            win.enabled = false;
            clearPreview();
        } catch(e){
            alert(e);
        } finally {
            win.enabled = true;
        }
        win.close();
    }

    // ダイアログを表示します。
    win.show();
}
// --------------------------------------
// メインの処理です。

function extendPaths(conf, paths) {
    for (var i = 0; i < paths.length; i++) {
        var len = paths[i].pathPoints.length;

        var bp; // bezier control points
        if (conf.reversed) {

            bp = [
                paths[i].pathPoints[1].anchor,
                paths[i].pathPoints[1].leftDirection,
                paths[i].pathPoints[0].rightDirection,
                paths[i].pathPoints[0].anchor,
            ]
            paths[i].pathPoints[1].anchor         = cPnt(0, 0, conf.rate, bp);
            paths[i].pathPoints[1].leftDirection  = cPnt(1, 0, conf.rate, bp);
            paths[i].pathPoints[0].rightDirection = cPnt(2, 0, conf.rate, bp);
            paths[i].pathPoints[0].anchor         = paths[i].pathPoints[0].leftDirection  = cPnt(3, 0, conf.rate, bp);

        } else {

            bp = [
                paths[i].pathPoints[len-2].anchor,
                paths[i].pathPoints[len-2].rightDirection,
                paths[i].pathPoints[len-1].leftDirection,
                paths[i].pathPoints[len-1].anchor,
            ]
            paths[i].pathPoints[len-2].anchor          = cPnt(0, 0, conf.rate, bp);
            paths[i].pathPoints[len-2].rightDirection  = cPnt(1, 0, conf.rate, bp);
            paths[i].pathPoints[len-1].leftDirection   = cPnt(2, 0, conf.rate, bp);
            paths[i].pathPoints[len-1].anchor          = paths[i].pathPoints[len-1].rightDirection   =  cPnt(3, 0, conf.rate, bp);

        }
    }
}

// --------------------------------------
// 選択範囲からパスのみを配列に入れて返します。
function extractPathsInSelection(sels, paths){
    if(!sels) sels = app.activeDocument.selection;
    if(!paths) paths = [];

    for(var i = 0; i < sels.length; i++){
        if(sels[i].typename == "PathItem"){
            paths.push(sels[i]);
        } else if(sels[i].typename == "GroupItem"){
            extractPathsInSelection(sels[i].pageItems, paths);
        } else if(sels[i].typename == "CompoundPathItem"){
            extractPathsInSelection(sels[i].pathItems, paths);
        }
    }
    return paths;
}

// --------------------------------------
// 延長可能な（孤立点でない かつ クローズパスではない）パスが一つ以上あることを確認
function isValid(paths){
    var result = false;
    for (var i = 0; i < paths.length; i++){
        if (paths[i].pathPoints.length > 1 && !paths[i].closed) result = true;
    }
    return result;
}

// --------------------------------------
// 延長したベジェ曲線のコントロールポイントを返す [x, y]
function cPnt(i, j, t, p) {  // i: order, j: index, t: ratio, p: array of bezier points (length=4)
   if (i == 0) return p[j]
   return [cPnt(i-1, j, t, p)[0] + t*(cPnt(i-1, j+1, t, p)[0] - cPnt(i-1, j, t, p)[0]),   // x
           cPnt(i-1, j, t, p)[1] + t*(cPnt(i-1, j+1, t, p)[1] - cPnt(i-1, j, t, p)[1])]   // y
}


// おわり