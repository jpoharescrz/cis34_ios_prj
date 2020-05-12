//
//  TalkingScalars.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import Foundation

// Base class for speakable scalars
class SpeakableScalar {
    
    var name: String
    var minTimer: Float
    var minPeriod: Int
    var maxTimer: Int
    var maxPeriod: Int
    var timerFreq: Int
    var prevMarkedValue: Float
    var prevDirCrossed: Int
    var interval: Float
    var lastSample: Float
    var perSecTrend: Float
    let trendEnhancedRptFactor: Float = 0.12
    let trendThreshToIndicate: Float = 0.25
    var prevTrendSignal: String
    var indicateTrend: Bool
    var indicateTrendSignal: Bool
    var trendTextPos: String
    var trendTextNeg: String
    var modulo: Int
    var audioEnabled: Bool
    var damping: Int
    var isSpeaking: Bool = false
    var isSoundPlaying: Bool = false

    init(frNm Nm: String) {
        name = Nm
        minTimer = 15
        minPeriod = 15
        maxTimer = 15
        maxPeriod = 15
        timerFreq = 1
        prevMarkedValue = 0
        prevDirCrossed = 1
        lastSample = 0
        perSecTrend = 0
        prevTrendSignal = "steady"
        indicateTrend = false
        indicateTrendSignal = false
        trendTextPos = "up"
        trendTextNeg = "down"
        interval = 1
        modulo = 0
        audioEnabled = false
        damping = 3
    }
    
    // Subtracts subtrahend from minuend
     // if diff > modulo/2 then
     // return (modulo - diff) * -1
     // if diff < (modulo/2)*-1 then
     // return (modulo - diff )
     func getModuloDifference( minuend: Float, subtrahend: Float, modulo: Int) -> Float {
         
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
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Takes the heading and determines if an interval was crossed
    func chkIntervalCrossed(_ dataSample: Float) -> (Bool, Float, Int, Bool) {
          
        var crossed: Bool = false
        var intervalCrossed: Float = 0.0
        var dirCrossed: Int = 1 // 1 == positive direction, -1 neg dir
        var dirChanged: Bool = false
        var roundUp: Bool = false
           
        let diff = getModuloDifference(minuend: dataSample, subtrahend: prevMarkedValue, modulo: modulo)
        let absDiff = abs( diff )
           
        // if change from previously reported value is
        // greater than the interval
        if absDiff > interval {
            if diff < 0 {
                roundUp = true
                dirCrossed = -1
            }
            crossed = true
        }
        // if more than 15% of interval
        else if absDiff > (interval / 6) {
            // if cross back negative when previous cross was positive
            if (diff < 0) && (prevDirCrossed == 1){
    
                roundUp = true
                dirCrossed = -1
                crossed = true
                dirChanged = true
            }
            // if cross back positive when previous cross was negative
            else if (diff > 0) && (prevDirCrossed == -1){
    
                crossed = true
                dirChanged = true
            }
        }
        if crossed {
            intervalCrossed = round(dataSample, roundUp: roundUp, interval: interval, modulo: modulo)
        }
        return (crossed, intervalCrossed, dirCrossed, dirChanged)
    }
    
    func procNewSample(_ sample: Float ) -> (report:Bool, sampleToSpeak: Float, crossed: Bool, dirCrossed: Int) {
        
        var report: Bool = false
        var crossed: Bool = false
        var sampleToSpeak: Float = 0.0
        var dirCrossed: Int = 1 // 1 == positive direction, -1 neg dir
        var dirChanged: Bool = false
        
        
        // Get the trend, then dampen it
        //let dampFactor: Int = 1 // 1 means no damping of trend
        let rawTrend = getModuloDifference(minuend: sample, subtrahend: lastSample, modulo: modulo)
        /*
        trend = (((trend * Float((timerFreq * dampFactor) - 1))) + rawTrend )
            / Float(timerFreq * dampFactor) */
        perSecTrend = rawTrend * Float(timerFreq)
        lastSample = sample
        
        // update the timers
        maxTimer -= 1
        minTimer -= 1
        //minTimer -= Float(1 + (abs(perSecTrend) * trendEnhancedRptFactor))
        
        let isSpeakingOrPlayingSound = isSpeaking || isSoundPlaying
        
        if isSpeakingOrPlayingSound {

            return (report, sample, crossed, dirCrossed)
        }
        
        if (minTimer <= 0) {  // if minimum period passed,
                            // check for interval crossing
            (crossed, sampleToSpeak, dirCrossed, dirChanged) =
                chkIntervalCrossed( sample )
            
            if crossed {
     
                prevDirCrossed = dirCrossed
                prevMarkedValue = sampleToSpeak
                
                if !dirChanged {
                    minTimer = Float(minPeriod * timerFreq)
                } else {
                    //minTimer = 0 // stay verbose if perSecTrend changed
                    minTimer = Float(minPeriod * timerFreq)/2 // stay verbose if perSecTrend changed
                }
                // First full report after interval crossing
                // happens in InitialMaxPeriod instead of MaxPeriod
                //maxTimer = max((InitialMaxPeriod * timerFreq),((minPeriod+3) * timerFreq))
                maxTimer = maxPeriod * timerFreq
                //print("MinPeriod: \(minPeriod)")
                report = true
            }
        }
        if (maxTimer <= 0) { // maxTimer going to zero means report regardless
                 
            report = true
            maxTimer = maxPeriod * timerFreq
            //minTimer = Float( minPeriod * timerFreq )
            sampleToSpeak = sample
            //print("MinPeriod: \(minPeriod)")
        }
        
        if audioEnabled == false {
            report = false
        }
        return (report, sampleToSpeak, crossed, dirCrossed)
    }
}

// Class to handle heading values
class HeadingManager: SpeakableScalar, UserHdgSettingsUpdateDelegate {
    
    let Modulo = 360
    let TrendThresh: Float = 0.25
    
    init(){
        super.init(frNm: "Heading")
        minPeriod = settings.hdgMinPeriod
        maxPeriod = settings.hdgMaxPeriod
        interval = settings.hdgInterval
        modulo = Modulo
        indicateTrend = settings.hdgIndicateTrend
        indicateTrendSignal = settings.hdgIndicateTrendSignal
        trendTextPos = settings.hdgTrendPosText
        trendTextNeg = settings.hdgTrendNegText
        settings.hdgDelegate = self
        audioEnabled = settings.hdgAudioEnable
        damping = settings.hdgDamping
    }

    
    func procHeading(_ hdg: Float, lastScalarSpeaker: String, initCnt: Int) -> (report: Bool, textToSpeak: String, dampedHeading: Float){
        
        var report: Bool
        var headingToSpeak: Float
        var curHeading: Float
        var crossed: Bool = false
        var dirCrossed: Int = 1 // 1 == positive direction, -1 neg dir
        var textToSpeak: String = ""
        
        if initCnt > 0 {
            lastSample = hdg
        }
        // Get the change in heading
        let hdgDiff =
            subtractModulo(minuend: Float(hdg) ,subtrahend: lastSample, modulo: 360)
          
        if initCnt > 0 {
            // Apply it to previous heading with no damping to get a new heading
            curHeading = addModulo( addend1: lastSample, addend2: (Float(hdgDiff)), modulo: 360)
        } else {
            // Apply it to previous heading with some damping to get a new heading
            curHeading = addModulo( addend1: lastSample, addend2: (Float(hdgDiff) / Float(damping)), modulo: 360)
        }
        
        (report, headingToSpeak, crossed, dirCrossed) = procNewSample(curHeading)
        
        // print("Trend: \(trend)")
        // if we can report this heading
        if report {
            
            textToSpeak = String(format: "%03.0f", headingToSpeak)
            
            // if non-zero MSB, insert space after MSB
            // so that 'hundred' is not uttered
            //if (textToSpeak[idx_0] != "0") {
            textToSpeak = insertCharAtIndex(str: textToSpeak, chr: " ", idx: 1)
            //}
            
            // if interval mark crossed, indicate by
            // appending up/down
            if crossed {
                
                if indicateTrend &&
                    ((abs(perSecTrend) > trendThreshToIndicate)){ // trend changed
                    
                    if dirCrossed == 1 { // crossed positively
                        //textToSpeak += " ," + trendTextPos
                        textToSpeak += ", " + trendTextPos
                     }
                     else { // crossed negatively
                        //textToSpeak += " ," + trendTextNeg
                        textToSpeak += ", " + trendTextNeg
                     }
                    
                }
 
                if name != lastScalarSpeaker {
                     textToSpeak = "Heading " + textToSpeak
                }
            }
            else {
                textToSpeak = "Heading " + textToSpeak + " degrees"
            }

        }
        return( report: report, textToSpeak: textToSpeak, dampedHeading: curHeading )
    }
    
    func getTrend() -> (Bool, String) {
        
        var trendSignal: String = "steady"
        var newTrend: Bool = false
        
        //print(trend)
        
        if perSecTrend > (TrendThresh) {
            trendSignal = "up"
        }
        else if perSecTrend < (TrendThresh * -1) {
            trendSignal = "down"
        }
        else {
            trendSignal = "steady"
        }
        if (trendSignal != prevTrendSignal) && (trendSignal != "steady") {
            newTrend = true
        }
        prevTrendSignal = trendSignal
        
        return (newTrend, trendSignal)
    }
    
    func hdgSettingsChg(setting: TalkingScalarSetting, value: Bool) {
        
        switch setting {
            case .audioEnable:
                audioEnabled = value
            case .indicateTrend:
                indicateTrend = value
            case .indicateTrendSignal:
                indicateTrendSignal = value
            default:
                print("Bad setting in hdgSettingsChg() ")
        }
        print("Setting hdg.\(setting): \(value)")
    }
    
    func hdgSettingsChg(setting: TalkingScalarSetting, value: String) {
        
        switch setting {
            case .trendPosText:
                trendTextPos = value
            case .trendNegText:
                trendTextNeg = value
            default:
                print("Bad setting in hdgSettingsChg() ")
        }
        print("Setting hdg.\(setting): \(value)")
    }
    
    func hdgSettingsChg(setting: TalkingScalarSetting, value: Float) {
        
        switch setting {
            case .interval:
                interval = value
             default:
                 print("Bad setting in hdgSettingsChg() ")
         }
        print("Setting hdg.\(setting): \(value)")
    }
    
    func hdgSettingsChg(setting: TalkingScalarSetting, value: Int) {
        
        switch setting {
            case .minPeriod:
                minPeriod = value
            case .maxPeriod:
                maxPeriod = value
            case .damping:
                damping = value
            default:
                print("Bad setting in hdgSettingsChg() ")
        }
        print("Setting hdg.\(setting): \(value)")
    }
}

// Class to handle heading values
class SpeedManager: SpeakableScalar, UserSpdSettingsUpdateDelegate {
    
    let MinPeriod = Int(SpdMinPeriod)
    let MaxPeriod = Int(SpdMaxPeriod)
    let MarkInterval = SpdInterval
    let Modulo = 0
    
    init(){
        super.init(frNm: "Speed")
        minPeriod = settings.spdMinPeriod
        maxPeriod = settings.spdMaxPeriod
        interval = settings.spdInterval
        indicateTrend = settings.spdIndicateTrend
        indicateTrendSignal = settings.spdIndicateTrendSignal
        trendTextPos = settings.spdTrendPosText
        trendTextNeg = settings.spdTrendNegText
        modulo = Modulo
        settings.spdDelegate = self
        audioEnabled = settings.spdAudioEnable
    }
    
    func spdSettingsChg(setting: TalkingScalarSetting, value: Bool) {
        
        switch setting {
            case .audioEnable:
                audioEnabled = value
            case .indicateTrend:
                indicateTrend = value
            case .indicateTrendSignal:
                indicateTrendSignal = value
            default:
                print("Bad setting in spdSettingsChg() ")
        }
        print("Setting spd.\(setting): \(value)")
    }
    
    func spdSettingsChg(setting: TalkingScalarSetting, value: String) {
        
        switch setting {
             case .trendPosText:
                 trendTextPos = value
             case .trendNegText:
                 trendTextNeg = value
             default:
                 print("Bad setting in spdSettingsChg() ")
         }
        print("Setting spd.\(setting): \(value)")
    }
    
    func spdSettingsChg(setting: TalkingScalarSetting, value: Float) {
        
        switch setting {
             case .interval:
                 interval = value
              default:
                  print("Bad setting in spdSettingsChg() ")
          }
        print("Setting spd.\(setting): \(value)")
    }
    
    func spdSettingsChg(setting: TalkingScalarSetting, value: Int) {
        
        switch setting {
             case .minPeriod:
                 minPeriod = value
             case .maxPeriod:
                 maxPeriod = value
             default:
                 print("Bad setting in spdSettingsChg() ")
         }
        print("Setting spd.\(setting): \(value)")
    }
    
    func procSpeed(_ spd: Float, lastScalarSpeaker: String, initCnt: Int) -> (report: Bool, textToSpeak: String){
        
        var report: Bool
        var speed: Float
        var crossed: Bool = false
        var dirCrossed: Int = 1 // 1 == positive direction, -1 neg dir
        var textToSpeak: String = ""
        
        if initCnt > 0 {
            lastSample = spd
        }
        (report, speed, crossed, dirCrossed) = procNewSample(spd)
        
        //print("Speed Max Timer: \(maxTimer)")
        
        // if we can report this heading
        if report {
            
            //print("MinPeriod: \(minPeriod)")
            textToSpeak = String(format: "%.1f", speed)

            // if hatch mark crossed, indicate by
            // appending up/down
            if crossed {

                if indicateTrend {
                    
                    if dirCrossed == 1 { // crossed positively
                         textToSpeak += ", " + trendTextPos
                     }
                     else { // crossed negatively
                         textToSpeak += ", " + trendTextNeg
                     }
                }

                if name != lastScalarSpeaker {
                    textToSpeak = "Speed " + textToSpeak
                }
            }
            else {
                if !settings.mphKnots {
                    textToSpeak = "Speed " + textToSpeak + " knots"
                } else {
                    textToSpeak = "Speed " + textToSpeak + " miles per hour"
                }
            }
        }
        return( report: report, textToSpeak: textToSpeak )
    }
}

