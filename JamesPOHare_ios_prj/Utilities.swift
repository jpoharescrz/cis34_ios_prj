//
//  Utilities.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import UIKit

func getViewController( sboard: String, id: String ) -> UIViewController {
    let storyboard: UIStoryboard = UIStoryboard(name: sboard, bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: id)
    return vc
}

// rounds a float up/down to an interval
func round(_ value:Float, roundUp:Bool, interval: Float, modulo: Int) -> Float {
    
    if interval == 0 { // bail
        return 0.0
    }
    // calculate the round down value
    let roundDnVal = Float(Int( value / interval )) * interval
    
    // If we're rounding up and value != round_down_value
    if roundUp && (value != roundDnVal) {
        var roundUpVal = roundDnVal + interval // temp = round up value
        
        // if we're using modulo and temp exceeds or
        // equals modulo => subtract modula
        if (modulo > 0) && (roundUpVal >= Float(modulo)){
            roundUpVal -= Float(modulo)
        }
        return roundUpVal
    }
    return roundDnVal
}

// Subtracts subtrahend from minuend
// if diff > modulo/2 then
// return (modulo - diff) * -1
// if diff < (modulo/2)*-1 then
// return (modulo - diff )
func subtractModulo( minuend: Float, subtrahend: Float, modulo: Int) -> Float {
    
    let dif = minuend - subtrahend
    let half_mod = Float(Int(modulo/2))
    var result: Float = dif
    
    if modulo > 0 {
        
        if dif > half_mod {
            result = -1 * (Float(modulo) - dif )
        }
        else if dif < (-1 * half_mod){
            result = (Float(modulo) - abs(dif))
        }
    }
    return result
}


// Adds two floats and adjusts for modulo
func addModulo( addend1: Float, addend2: Float, modulo: Int) -> Float {
    
    var sum: Float = addend1
    var addend: Float = addend2
    
    while addend >= Float(modulo) {
        addend -= Float(modulo)
    }
    
    sum += addend
    
    if sum > Float(modulo) {
        sum -= Float(modulo)
    }
    else if sum < 0 {
        sum += Float(modulo)
    }
    return sum
}

// function to insert a character at spec'd index
func insertCharAtIndex( str: String, chr: Character, idx: Int) -> String {
    
    var newStr: String = str
    let idx_0 = str.startIndex
    newStr.insert( chr, at: newStr.index( idx_0, offsetBy: idx))
    
    return newStr
}
