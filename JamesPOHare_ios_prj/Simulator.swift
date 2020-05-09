//
//  Simulator.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/23/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import Foundation

class Simulator {
    
    var timerFreq: Int = 5
    
    var hdgCounter: Int = 0
    var spdCounter: Int = 0
    
    init( tmrFreq: Int){
        
        timerFreq = tmrFreq
    }
    
    func getSimHeading() -> Float {
        
        let heading = settings.simHeading
        let hdgAmpl = settings.simHdgAmpl
        let hdgPeriod = settings.simHdgPeriod
        let simHeadingChg = (sin( (Float((hdgCounter / timerFreq)) / hdgPeriod) * .pi ) * hdgAmpl)
        let simHeading = addModulo(addend1: heading, addend2: simHeadingChg, modulo: 360)
        hdgCounter += 1
        //print("simHeading: \(simHeading)")
        return simHeading
    }
    
    func getSimSpeed() -> Float {
        
        let speed = settings.simSpeed
        let spdAmpl = settings.simSpdAmpl
        let spdPeriod = settings.simSpdPeriod
        let simSpeedChg = (sin( (Float((spdCounter / timerFreq)) / spdPeriod) * .pi ) * spdAmpl)
        //print("speed: \(speed), simSpeedChg: \(simSpeedChg)")
        let simSpeed = speed + simSpeedChg
        spdCounter += 1
        //print("simSpeed: \(simSpeed)")
        return simSpeed
    }
}
