;created by @tema104
;changed by @krasnovpro

/*
 * Library of JS-like functions for AutoHotKey v2.
 *
 * ## for Array:
 *   ### JS-like functions:
 *     Array.Prototype.concat()
 *     Array.Prototype.forEach()
 *     Array.Prototype.map()
 *     Array.Prototype.filter()
 *     Array.Prototype.reduce()
 *     Array.Prototype.join()
 *     Array.Prototype.values()
 *     Array.Prototype.keys()
 *     Array.Prototype.some()
 *     Array.Prototype.includes()
 *     Array.Prototype.indexOf()
 *     Array.Prototype.reverse()
 *     Array.Prototype.every()
 *     Array.Prototype.ToString()
 *
 * ## for Map:
 *   ### JS-like functions:
 *     Map.Prototype.concat()
 *     Map.Prototype.swapKeyVal()
 *     Map.Prototype.forEach()
 *     Map.Prototype.map()
 *     Map.Prototype.filter()
 *     Map.Prototype.values()
 *     Map.Prototype.keys()
 *     Map.Prototype.some()
 *     Map.Prototype.includes()
 *     Map.Prototype.indexOf()
 *     Map.Prototype.every()
 *     Map.Prototype.ToString()
 *
 *   ### Addition functions:
 *     Map.Prototype.toObject()
 *
 * ## for Object:
 *   ### JS-like functions:
 *     Object.merge()
 *     Object.values()
 *     Object.keys()
 *     Object.Prototype.ToString()
 *
 *   ### Addition functions:
 *     Object.toMap()
 */


/*
  Example:

  a := [1,2,3]
  b := Map("sas", "bas", 1, "heh")
  c := {
    kek: "lek"
  }

  MsgBox String(a.filter(x => x > 1).reverse())
    . "`n`n" String(b.keys().map(x => x . x))
    . "`n`n" String(c)
    . "`n`n" "Index of 3 in a: " . a.indexOf(3)
*/

registerLikeJSEnumerableFunctions()
registerLikeJSEnumerableFunctions() {
  static once := false
  if once {
    return
  }
  once := true

  /*
   * helpers
   */
  _wrapVariadicFunctionCall(fun, requiredParamsCount, params*) {
    if fun.MaxParams < requiredParamsCount {
      throw ValueError(, "Too few params for callback")
    }
    newParams := []
    for k, param in params {
      if k > fun.MaxParams {
        break
      }
      newParams.Push(param)
    }
    return fun(newParams*)
  }

  _registerFuncFor(obj, name, fun) {
    if !obj.HasOwnProp(name) {
      obj.DefineProp(name, {
        call: fun
      })
    }
  }
  /*
   * End of: helpers
   */

  /*
   * Array
   */

  ____concatArray(thisArray, arraysToConcat*) {
    result := thisArray.clone()
    for arr in arraysToConcat
      result.push(arr*)
    return result
  }
  _registerFuncFor Array.Prototype, 'concat', ____concatArray

  ____forEachArray(thisArray, cb) {
    for k, v in thisArray {
      _wrapVariadicFunctionCall(cb, 0, v, k, thisArray)
    }
    return thisArray
  }
  _registerFuncFor Array.Prototype, 'forEach', ____forEachArray

  ____mapArray(thisArray, cb) {
    result := []
    for k, v in thisArray {
      result.Push(_wrapVariadicFunctionCall(cb, 0, v, k, thisArray))
    }
    return result
  }
  _registerFuncFor Array.Prototype, 'map', ____mapArray

  ____filterArray(thisArray, cb) {
    result := []
    for k, v in thisArray {
      if _wrapVariadicFunctionCall(cb, 0, v, k, thisArray) {
        result.Push(v)
      }
    }
    return result
  }
  _registerFuncFor Array.Prototype, 'filter', ____filterArray

  ____reduceArray(thisArray, cb, initialValue := "") {
    result := initialValue
    for k, currentValue in thisArray {
      result := _wrapVariadicFunctionCall(cb, 2, result, currentValue, k, thisArray)
    }
    return result
  }
  _registerFuncFor Array.Prototype, 'reduce', ____reduceArray

  ____joinArray(thisArray, separator := ",") {
    if !thisArray.Length
      return

    result := ""
    loop thisArray.Length - 1 {
      result .= thisArray[A_Index] . separator
    }
    result .= thisArray[thisArray.Length]
    return result
  }
  _registerFuncFor Array.Prototype, 'join', ____joinArray

  _registerFuncFor Array.Prototype, 'values', thisArray => thisArray.Clone()

  ____keysArray(thisArray) {
    result := []
    for k, v in thisArray {
      result.Push(k)
    }
    return result
  }
  _registerFuncFor Array.Prototype, 'keys', ____keysArray

  ____someArray(thisArray, cb) {
    for k, v in thisArray {
      if _wrapVariadicFunctionCall(cb, 1, v, k, thisArray) {
        return true
      }
    }
    return false
  }
  _registerFuncFor Array.Prototype, 'some', ____someArray

  ____includesArray(thisArray, val) {
    for _, v in thisArray {
      if v = val {
        return true
      }
    }
    return false
  }
  _registerFuncFor Array.Prototype, 'includes', ____includesArray

  ____indexOfArray(thisArray, val) {
    for k, v in thisArray {
      if v = val {
        return k
      }
    }
    return 0
  }
  _registerFuncFor Array.Prototype, 'indexOf', ____indexOfArray

  ____reverseArray(thisArray) {
    result := []
    for k, v in thisArray {
      result.InsertAt(1, v)
    }
    return result
  }
  _registerFuncFor Array.Prototype, 'reverse', ____reverseArray

  ____everyArray(thisArray, cb) {
    for k, v in thisArray {
      if !_wrapVariadicFunctionCall(cb, 1, v, k, thisArray) {
        return false
      }
    }
    return true
  }
  _registerFuncFor Array.Prototype, 'every', ____everyArray

  _registerFuncFor Array.Prototype, 'ToString'
    , thisArray => '[' . thisArray.map(x => String(x)).join(', ') . ']'
  /*
   * End of: Array
   */


  /*
   * Map
   */

  ____concatMap(thisMap, mapsToMerge*) {
    result := thisMap.clone()
    for arr in mapsToMerge
      for k, v in arr
        result.Set(k,v)
    return result
  }
  _registerFuncFor Map.Prototype, 'concat', ____concatMap

  ____swapKeyValMap(thisMap) {
    result := Map()
    for k, v in thisMap
      result[v] := k
    return result
  }
  _registerFuncFor Map.Prototype, 'swapKeyVal', ____swapKeyValMap

  ____forEachMap(thisMap, cb) {
    for k, v in thisMap {
      _wrapVariadicFunctionCall(cb, 0, v, k, thisMap)
    }
    return thisMap
  }
  _registerFuncFor Map.Prototype, 'forEach', ____forEachMap

  ____mapMap(thisMap, cb) {
    result := Map()
    for k, v in thisMap {
      result[k] := _wrapVariadicFunctionCall(cb, 0, v, k, thisMap)
    }
    return result
  }
  _registerFuncFor Map.Prototype, 'map', ____mapMap

  ____filterMap(thisMap, cb) {
    result := Map()
    for k, v in thisMap {
      if _wrapVariadicFunctionCall(cb, 0, v, k, thisMap) {
        result[k] := v
      }
    }
    return result
  }
  _registerFuncFor Map.Prototype, 'filter', ____filterMap

  ____valuesMap(thisMap) {
    result := []
    for _, v in thisMap {
      result.Push(v)
    }
    return result
  }
  _registerFuncFor Map.Prototype, 'values', ____valuesMap

  ____keysMap(thisMap) {
    result := []
    for k, v in thisMap {
      result.Push(k)
    }
    return result
  }
  _registerFuncFor Map.Prototype, 'keys', ____keysMap

  ____someMap(thisMap, cb) {
    for k, v in thisMap {
      if _wrapVariadicFunctionCall(cb, 1, v, k, thisMap) {
        return true
      }
    }
    return false
  }
  _registerFuncFor Map.Prototype, 'some', ____someMap

  ____includesMap(thisMap, val) {
    for _, v in thisMap {
      if v = val {
        return true
      }
    }
    return false
  }
  _registerFuncFor Map.Prototype, 'includes', ____includesMap

  ____indexOfMap(thisMap, val) {
    for k, v in thisMap {
      if v = val {
        return {hasValue:true, value:k}
      }
    }
    return {hasValue:false, value:""}
  }
  _registerFuncFor Map.Prototype, 'indexOf', ____indexOfMap

  ____everyOfMap(thisMap, cb) {
    for k, v in thisMap {
      if !_wrapVariadicFunctionCall(cb, 1, v, k, thisMap) {
        return false
      }
    }
    return true
  }
  _registerFuncFor Map.Prototype, 'every', ____everyOfMap

  ____toObjectMap(thisMap) {
    result := {}
    for k, v in thisMap {
      result.DefineProp(k, {
        value: v
      })
    }
    return result
  }
  _registerFuncFor Map.Prototype, 'toObject', ____toObjectMap

  _registerFuncFor Map.Prototype, 'ToString'
    , thisMap => 'Map( ' . thisMap.map((v, k) => String(k)
                 . ': ' . String(v)).values().join(', ') . ')'
  /*
   * End of: Map
   */


  /*
   * Object
   */

  ____mergeObj(_type, thisObj, arg*) {
    result := thisObj
    loop arg.Length
      for k, v in arg[A_Index].OwnProps()
        result.%k% := v
    return result
  }
  _registerFuncFor Object, 'merge', ____mergeObj

  ____valuesObj(_type, thisObj) {
    result := []
    for _, v in thisObj.OwnProps() {
      result.Push(v)
    }
    return result
  }
  _registerFuncFor Object, 'values', ____valuesObj

  ____keysObj(_type, thisObj) {
    result := []
    for k in thisObj.OwnProps() {
      result.Push(k)
    }
    return result
  }
  _registerFuncFor Object, 'keys', ____keysObj

  ____toMapObj(_type, thisObj) {
    result := Map()
    for k, v in thisObj.OwnProps() {
      result[k] := v
    }
    return result
  }
  _registerFuncFor Object, 'toMap', ____toMapObj

  _registerFuncFor Object.Prototype, 'ToString'
    , objsss => '{ ' . Object.toMap(objsss).map((v, k) => String(k)
              . ': ' . String(v)).values().join(', ') . ' }'
  /*
   * End of: Object
   */
}

; Filter array keeping only items that contain literals like "OWL.ToolbarNN"
; where NN is any decimal number (one or more digits).
FilterOWLToolbars(arr) {
  return arr.filter(item => RegExMatch("" . item, "OWL\.Toolbar\d+"))
}

; Example usage:
; sample := ["OWL.Toolbar1", "abc", "foo OWL.Toolbar23 bar", "OWL.ToolbarA", 123, "OWL.Toolbar007"]
; filtered := FilterOWLToolbars(sample)
; MsgBox String(filtered)