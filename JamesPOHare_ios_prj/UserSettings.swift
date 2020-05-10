//
//  UserSettings.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import Foundation
import UIKit

enum TalkingScalarSetting {
    
    case audioEnable
    case minPeriod
    case maxPeriod
    case interval
    case indicateTrend
    case indicateTrendSignal
    case trendPosText
    case trendNegText
    case damping
}

enum SpeechSetting {
    
    case rate
    case pitch
    case volume
    case postDelay
}

enum SimSetting {
    
    case heading
    case hdgAmpl
    case hdgPeriod
    case speed
    case spdAmpl
    case spdPeriod
}

protocol UserHdgSettingsUpdateDelegate {
    
    func hdgSettingsChg( setting: TalkingScalarSetting, value: Bool )
    func hdgSettingsChg( setting: TalkingScalarSetting, value: String )
    func hdgSettingsChg( setting: TalkingScalarSetting, value: Float )
    func hdgSettingsChg( setting: TalkingScalarSetting, value: Int )
}

protocol UserSpdSettingsUpdateDelegate {

    func spdSettingsChg( setting: TalkingScalarSetting, value: Bool )
    func spdSettingsChg( setting: TalkingScalarSetting, value: String )
    func spdSettingsChg( setting: TalkingScalarSetting, value: Float )
    func spdSettingsChg( setting: TalkingScalarSetting, value: Int )
}

protocol DarkModeChgDelegate {
    
    func darkModeChg( darkMode: Bool )
}

// InitialMaxPeriod used in place of MaxPeriod following an
// interval crossing
let InitialMaxPeriod: Int = 10

let HdgMinPeriod: Int = 4
let HdgMaxPeriod: Int = 25
let HdgIntervalLUTbl:[Float] = [1.0, 2.0, 5.0, 10.0, 20.0]
let HdgIntervalIdx = 2
let HdgInterval: Float = 5.0
let HdgTrendPosText: String = "right"
let HdgTrendNegText: String = "left"
let HdgDamping: Int = 3

let SpdMinPeriod: Int = 10
let SpdMaxPeriod: Int = 40
let SpdIntervalLUTbl:[Float] = [0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0]
let SpdIntervalIdx = 3
let SpdInterval: Float = 0.25
let SpdTrendPosText: String = "up"
let SpdTrendNegText: String = "down"

let SpeechRate: Float = 0.58
let SpeechPitch: Float = 0.75
let SpeechVolume: Float = 0.85
let SpeechPostDelay: Float = 0.5
var SpeechIsSpeaking: Bool = false

let SimHeading: Float = 360
let SimHdgAmpl: Float = 40
let SimHdgPeriod: Float = 26
let SimSpeed: Float = 10.0
let SimSpdAmpl: Float = 2.0
let SimSpdPeriod: Float = 25

let TimerFreq: Int = 6

var settings = UserSettings()

class UserSettings {

    var hdgAudioEnable: Bool
    var hdgMinPeriod: Int
    var hdgMaxPeriod: Int
    var hdgInterval: Float
    var hdgIndicateTrend: Bool
    var hdgIndicateTrendSignal: Bool
    var hdgTrendPosText: String
    var hdgTrendNegText: String
    var hdgDamping: Int

    var spdAudioEnable: Bool
    var spdMinPeriod: Int
    var spdMaxPeriod: Int
    var spdInterval: Float
    var spdIndicateTrend: Bool
    var spdIndicateTrendSignal: Bool
    var spdTrendPosText: String
    var spdTrendNegText: String

    var speechRate: Float
    var speechPitch: Float
    var speechVolume: Float
    var speechPostDelay: Float
    
    var simEnable: Bool
    var simHeading: Float
    var simHdgAmpl: Float
    var simHdgPeriod: Float
    var simSpeed: Float
    var simSpdAmpl: Float
    var simSpdPeriod: Float
    
    var running: Bool = false
    var timer = Timer()
    var timerFreq = TimerFreq
    var trendTimer = Timer()
    var darkMode: Bool
    var mphKnots: Bool

    var hdgDelegate: UserHdgSettingsUpdateDelegate?
    var spdDelegate: UserSpdSettingsUpdateDelegate?
    var darkModeChgDelegate: DarkModeChgDelegate?
    
    var mainTabBarController: UITabBarController?
    
    let defaults = UserDefaults.standard

 init() {
     
    hdgAudioEnable = defaults.bool(forKey:"hdgAudioEnable") 
     
     if defaults.float(forKey: "hdgMinPeriod").isZero {
         defaults.set(Float(Int(HdgMinPeriod)), forKey: "hdgMinPeriod")
     }
     hdgMinPeriod = Int(defaults.float(forKey: "hdgMinPeriod"))
     
     //hdgMinPeriod = defaults.float(forKey: "hdgMinPeriod")
     if defaults.float(forKey: "hdgMaxPeriod").isZero {
         defaults.set(Float(Int(HdgMaxPeriod)), forKey: "hdgMaxPeriod")
     }
     hdgMaxPeriod = Int(defaults.float(forKey: "hdgMaxPeriod"))
     
     //hdgMaxPeriod = defaults.float(forKey: "hdgMaxPeriod")
     if defaults.float(forKey: "hdgInterval").isZero {
         defaults.set(Float(HdgInterval), forKey: "hdgInterval")
     }
     hdgInterval = defaults.float(forKey: "hdgInterval")
     hdgIndicateTrend = defaults.bool(forKey:"hdgIndicateTrend")
     hdgIndicateTrendSignal = defaults.bool(forKey:"hdgIndicateTrendSignal")
     
     if defaults.string(forKey: "hdgTrendPosText") == nil {
         defaults.set(HdgTrendPosText, forKey: "hdgTrendPosText")
     }
     hdgTrendPosText = defaults.string(forKey: "hdgTrendPosText") ?? "error"
     
     if defaults.string(forKey: "hdgTrendNegText") == nil {
         defaults.set(HdgTrendNegText, forKey: "hdgTrendNegText")
     }
     hdgTrendNegText = defaults.string(forKey: "hdgTrendNegText") ?? "error"
    
    if defaults.float(forKey: "hdgDamping").isZero {
        defaults.set(Float(Int(HdgDamping)), forKey: "hdgDamping")
    }
    hdgDamping = Int(defaults.float(forKey: "hdgDamping"))

    spdAudioEnable = defaults.bool(forKey:"spdAudioEnable")
   
    if defaults.float(forKey: "spdMinPeriod").isZero {
        defaults.set(Float(Int(SpdMinPeriod)), forKey: "spdMinPeriod")
    }
    spdMinPeriod = Int(defaults.float(forKey: "spdMinPeriod"))
   
    if defaults.float(forKey: "spdMaxPeriod").isZero {
        defaults.set(Float(Int(SpdMaxPeriod)), forKey: "spdMaxPeriod")
    }
    spdMaxPeriod = Int(defaults.float(forKey: "spdMaxPeriod"))
   
    if defaults.float(forKey: "spdInterval").isZero {
        defaults.set(Float(SpdInterval), forKey: "spdInterval")
    }
    spdInterval = defaults.float(forKey: "spdInterval")
    spdIndicateTrend = defaults.bool(forKey:"spdIndicateTrend")
    spdIndicateTrendSignal = defaults.bool(forKey:"spdIndicateTrendSignal")
   
    if defaults.string(forKey: "spdTrendPosText") == nil {
        defaults.set(SpdTrendPosText, forKey: "spdTrendPosText")
    }
    spdTrendPosText = defaults.string(forKey: "spdTrendPosText") ?? "error"
       
    if defaults.string(forKey: "spdTrendNegText") == nil {
        defaults.set(SpdTrendNegText, forKey: "spdTrendNegText")
    }
    spdTrendNegText = defaults.string(forKey: "spdTrendNegText") ?? "error"
       
    if defaults.float(forKey: "speechRate").isZero {
        defaults.set(SpeechRate, forKey: "speechRate")
    }
    speechRate = defaults.float(forKey: "speechRate")

    if defaults.float(forKey: "speechPitch").isZero {
        defaults.set(SpeechRate, forKey: "speechPitch")
    }
    speechPitch = defaults.float(forKey: "speechPitch")
        
    if defaults.float(forKey: "speechVolume").isZero {
        defaults.set(SpeechVolume, forKey: "speechVolume")
    }
    speechVolume = defaults.float(forKey: "speechVolume")
        
    if defaults.float(forKey: "speechPostDelay").isZero {
        defaults.set(SpeechPostDelay, forKey: "speechPostDelay")
    }
    speechPostDelay = defaults.float(forKey: "speechPostDelay")
    
    simEnable = defaults.bool(forKey:"simEnable")
    
    if defaults.float(forKey: "simHeading").isZero {
        defaults.set(SimHeading, forKey: "simHeading")
    }
    simHeading = defaults.float(forKey: "simHeading")
    
    if defaults.float(forKey: "simHdgAmpl").isZero {
        defaults.set(SimHdgAmpl, forKey: "simHdgAmpl")
    }
    simHdgAmpl = defaults.float(forKey: "simHdgAmpl")
    
    if defaults.float(forKey: "simHdgPeriod").isZero {
        defaults.set(SimHdgPeriod, forKey: "simHdgPeriod")
    }
    simHdgPeriod = defaults.float(forKey: "simHdgPeriod")
    
    if defaults.float(forKey: "simSpeed").isZero {
        defaults.set(SimSpeed, forKey: "simSpeed")
    }
    simSpeed = defaults.float(forKey: "simSpeed")
    
    if defaults.float(forKey: "simSpdAmpl").isZero {
        defaults.set(SimSpdAmpl, forKey: "simSpdAmpl")
    }
    simSpdAmpl = defaults.float(forKey: "simSpdAmpl")
    
    if defaults.float(forKey: "simSpdPeriod").isZero {
        defaults.set(SimSpdPeriod, forKey: "simSpdPeriod")
    }
    simSpdPeriod = defaults.float(forKey: "simSpdPeriod")
    
    darkMode = defaults.bool(forKey:"darkMode")
    
    mphKnots = defaults.bool(forKey:"mphKnots")
}

func hdgSettingUpdate( setting: TalkingScalarSetting, value: Bool) {
        
    switch setting {
            
    case .audioEnable:
        hdgAudioEnable = value
        defaults.set(value, forKey:"hdgAudioEnable")
            
    case .indicateTrend:
        hdgIndicateTrend = value
        defaults.set(value, forKey:"hdgIndicateTrend")
            
    case .indicateTrendSignal:
        hdgIndicateTrendSignal = value
        defaults.set(value, forKey:"hdgIndicateTrendSignal")
        
    default:
        print("Bad setting: \(setting) in hdgUserSettingUpdate")
        return
    }
    hdgDelegate?.hdgSettingsChg( setting: setting, value: value )
    print("hdg settings update: \(setting) : \(value)")
}

func hdgSettingUpdate( setting: TalkingScalarSetting, value: Int) {

    switch setting {
        
    case .minPeriod:
        hdgMinPeriod = value
        defaults.set(value, forKey:"hdgMinPeriod")
        
    case .maxPeriod:
        hdgMaxPeriod = value
        defaults.set(value, forKey:"hdgMaxPeriod")
        
    case .damping:
        hdgDamping = value
        defaults.set(value, forKey:"hdgDamping")

    default:
        print("Bad setting: \(setting) : \(value) in hdgUserSettingUpdate")
    }
    hdgDelegate?.hdgSettingsChg( setting: setting, value: value )
    print("hdg settings update: \(setting): \(value)")
}

func hdgSettingUpdate( setting: TalkingScalarSetting, value: Float) {

    switch setting {
         
    case .interval:
        
        hdgInterval = value
        defaults.set(value, forKey:"hdgInterval")

     default:
         print("Bad setting: \(setting) in hdgUserSettingUpdate")
        return
     }
    hdgDelegate?.hdgSettingsChg( setting: setting, value: value )
    print("hdg settings update: \(setting) : \(value)")
}

func hdgSettingUpdate( setting: TalkingScalarSetting, value: String) {
    
    switch setting {
         
    case .trendPosText:
        hdgTrendPosText = value
        defaults.set(value, forKey:"hdgTrendPosText")
        
    case .trendNegText:
        hdgTrendNegText = value
        defaults.set(value, forKey:"hdgTrendNegText")
        
     default:
         print("Bad setting: \(setting) in hdgUserSettingUpdate")
        return
     }
    hdgDelegate?.hdgSettingsChg( setting: setting, value: value )
    print("hdg settings update: \(setting) : \(value)")
}

func spdSettingUpdate( setting: TalkingScalarSetting, value: Bool) {
    
    switch setting {
             
     case .audioEnable:
         spdAudioEnable = value
         defaults.set(value, forKey:"spdAudioEnable")
             
     case .indicateTrend:
         spdIndicateTrend = value
        defaults.set(value, forKey:"spdIndicateTrend")
             
     case .indicateTrendSignal:
         spdIndicateTrendSignal = value
         defaults.set(value, forKey:"spdIndicateTrendSignal")
        
     default:
         print("Bad setting: \(setting) in spdUserSettingUpdate")
         return
     }
     spdDelegate?.spdSettingsChg( setting: setting, value: value )
     print("spd settings update: \(setting) : \(value)")
}

func spdSettingUpdate( setting: TalkingScalarSetting, value: Int) {

    switch setting {
        
    case .minPeriod:
        spdMinPeriod = value
        defaults.set(value, forKey:"spdMinPeriod")
        
    case .maxPeriod:
        spdMaxPeriod = value
        defaults.set(value, forKey:"spdMaxPeriod")

    default:
        print("Bad setting: \(setting) in spdUserSettingUpdate")
    }
    spdDelegate?.spdSettingsChg( setting: setting, value: value )
    print("spd settings update: \(setting) : \(value)")
}


func spdSettingUpdate( setting: TalkingScalarSetting, value: Float) {
    
    switch setting {
         
    case .interval:
        
        spdInterval = value
        defaults.set(value, forKey:"spdInterval")

     default:
         print("Bad setting: \(setting) in spdUserSettingUpdate")
        return
     }
    spdDelegate?.spdSettingsChg( setting: setting, value: value )
    print("spd settings update: \(setting) : \(value)")
}

func spdSettingUpdate( setting: TalkingScalarSetting, value: String) {
    
    switch setting {
          
     case .trendPosText:
         spdTrendPosText = value
         defaults.set(value, forKey:"spdTrendPosText")
         
     case .trendNegText:
         spdTrendNegText = value
         defaults.set(value, forKey:"spdTrendNegText")
         
      default:
          print("Bad setting: \(setting) in spdUserSettingUpdate")
         return
      }
     spdDelegate?.spdSettingsChg( setting: setting, value: value )
     print("spd settings update: \(setting) : \(value)")
}

func speechSettingUpdate( setting: SpeechSetting, value: Float) {
        
        switch setting {
             
        case .pitch:
            speechPitch = value
            defaults.set(speechPitch, forKey: "speechPitch")
            
        case .postDelay:
            speechPostDelay = value
            defaults.set(speechPostDelay, forKey: "speechPostDelay")
            
        case .rate:
            speechRate = value
            defaults.set(speechRate, forKey: "speechRate")
            
        case .volume:
            speechVolume = value
            defaults.set(speechVolume, forKey: "speechVolume")
         }
    }
    
    func darkModeUpdate( value: Bool){
        
        darkMode = value
        defaults.set(darkMode, forKey: "darkMode")
        darkModeChgDelegate?.darkModeChg(darkMode: value)
    }
    
    func mphKnotsSettingUpdate( value: Bool){
        
        mphKnots = value
        defaults.set(mphKnots, forKey: "mphKnots")
    }
    
    func simSettingUpdate( setting: SimSetting, value: Float) {
        
        switch setting {
             
        case .heading:
            simHeading = value
            defaults.set(simHeading, forKey: "simHeading")
            
        case .hdgAmpl:
            simHdgAmpl = value
            defaults.set(simHdgAmpl, forKey: "simHdgAmpl")
            
        case .hdgPeriod:
            simHdgPeriod = value
            defaults.set(simHdgPeriod, forKey: "simHdgPeriod")
            
        case .speed:
            simSpeed = value
            defaults.set(simSpeed, forKey: "simSpeed")
                
        case .spdAmpl:
            simSpdAmpl = value
            defaults.set(simSpdAmpl, forKey: "simSpdAmpl")
                
        case .spdPeriod:
            simSpdPeriod = value
            defaults.set(simSpdPeriod, forKey: "simSpdPeriod")
         }
    }
    
}
