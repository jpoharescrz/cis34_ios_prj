//
//  HomeViewController.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreData

// var settings = UserSettings()
protocol headingUpdateDelegate {
    
    func headingUpdate( newHeading: Float )
}
protocol speedUpdateDelegate {
    
    func speedUpdate( newSpeed: Float )
}

class HomeViewController: UIViewController, AVSpeechSynthesizerDelegate, CLLocationManagerDelegate, AVAudioPlayerDelegate, RemoteStartStopDelegate, DarkModeChgDelegate {
    

    let speechSynthesizer = AVSpeechSynthesizer()
    var speechUtterance = AVSpeechUtterance()
    var audioPlayer = AVAudioPlayer()
    var timer = Timer()
    let TimerFreq: Int = 5  // timer runs every 250 ms
    
    var trendTimer = Timer()
    let trendTimerFreq: Int = 10 // timer runs every 100 ms
    var trendTimerCnt: Float = 0
    let trendTimerNewTrendInit: Int = 12 // signals after 1.2 seconds
    let trendTimerMaxInit: Int = 50         // max period 5.0 seconds
    let trendPeriodReductionMax: Int = 34
    let trendTimerFactor: Int = 6
    let maxTrendTimerDownCountEnhancement: Float = 1.1
    
    var locManager = CLLocationManager.init()
    
    let trendSigEnhancedRptFactor:Float = 0.5
    let hdgSpeechRateAdjustFactor:Float = 0.11
    
    let spdSpeechRateAdjustFactor:Float = 0.2
    let spdSpeechPitchAdjust: Float = 0.17
    
    let maxSpeechRate = 0.67
    let maxSpeechPitch = 0.85
    
    var hdgSampleRcvd:Bool = false
    var myNewHeading: Float = 0.0
    var curHeading: Float = 0.0
    var prevHeading: Float = 0.0
    var curHeadingInitCnt: Int = 0
    
    var curSpeed: Float = 0.0
    var curSpeedInitCnt: Int = 0
    var lastSpokenScaler: String = ""
    
    let metersPerSecToMPH = 2.236936
    let metersPerSecToKnots:Float = 1.943844
    
    var hdgManager = HeadingManager()
    var spdManager = SpeedManager()
    
    var simulator: Simulator?
    
    var hdgUpdateDelegate: headingUpdateDelegate?
    var spdUpdateDelegate: speedUpdateDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("Home view appearred")
        if settings.running {
            startBtnRef.setTitle("Stop", for: UIControl.State.normal)
        } else {
            startBtnRef.setTitle("Start", for: UIControl.State.normal)
        }
        
        hdgMutedLabel.isHidden = settings.hdgAudioEnable
        print("settings.hdgAudioEnable: \(settings.hdgAudioEnable)")
        
        spdMutedLabel.isHidden = settings.spdAudioEnable
        
        darkModeChg(darkMode: settings.darkMode)
        
        if settings.mphKnots {
            mphKnotsLbl.text = "MPH"
        } else {
            mphKnotsLbl.text = "Knots"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        speechSynthesizer.delegate = self
        audioPlayer.delegate = self

        locManager.desiredAccuracy = kCLLocationAccuracyBest
                
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        locManager.headingOrientation = .portrait
        locManager.headingFilter = kCLHeadingFilterNone
        locManager.delegate = self // you forgot to set the delegate
        
        hdgManager.timerFreq = TimerFreq
        spdManager.timerFreq = TimerFreq
        
        simulator = Simulator( tmrFreq: TimerFreq)
        
        // Setup to get start/stop updates from graphics screen
        if let graphicsTab = self.tabBarController?.viewControllers?[1] as? GraphicsViewController {
            
            graphicsTab.remStartStopDelegate = self
        }
 
        var tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.hdgTapFunction))
        hdgLabel.addGestureRecognizer(tap)
        hdgLabel.isUserInteractionEnabled = true
        
        tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.spdTapFunction))
        spdLabel.addGestureRecognizer(tap)
        spdLabel.isUserInteractionEnabled = true
        
        settings.darkModeChgDelegate = self
        settings.mainTabBarController = self.tabBarController
        
        if settings.mphKnots {
            mphKnotsLbl.text = "MPH"
        } else {
            mphKnotsLbl.text = "Knots"
        }
    }
    
    @IBOutlet weak var mphKnotsLbl: UILabel!
    @IBOutlet weak var screenView: UIView!
    
    func darkModeChg(darkMode: Bool) {
        print("Home darkMode: \(darkMode), visible cells: \(screenView.subviews.count)")
        if !darkMode {
            self.tabBarController?.tabBar.barTintColor = UIColor.white

            self.view.backgroundColor = UIColor.white
            for view in screenView.subviews {
                if let cellLbl = view as? UILabel {
                    if cellLbl.tag == 1 {
                        cellLbl.textColor = UIColor.black
                    }
                }
            }
        } else {
            self.tabBarController?.tabBar.barTintColor = UIColor.black

            self.view.backgroundColor = UIColor.black
            for view in screenView.subviews {
                if let cellLbl = view as? UILabel {
                    if cellLbl.tag == 1 {
                        cellLbl.textColor = UIColor.white
                    }
                }
            }
        }
    }
    @IBOutlet weak var hdgLabel: UILabel!
        
    @IBOutlet weak var spdLabel: UILabel!
    
    @IBOutlet weak var hdgMutedLabel: UILabel!
    @objc func hdgTapFunction(sender:UITapGestureRecognizer) {
        
        settings.hdgSettingUpdate( setting: .audioEnable, value: !settings.hdgAudioEnable)
        hdgMutedLabel.isHidden = hdgManager.audioEnabled
        
        print("hdg tap working")
    }
    
    @IBOutlet weak var spdMutedLabel: UILabel!
    @objc func spdTapFunction(sender:UITapGestureRecognizer) {
        
        settings.spdSettingUpdate( setting: .audioEnable, value: !settings.spdAudioEnable)
        spdMutedLabel.isHidden = spdManager.audioEnabled
        
        print("spd tap working")
    }
 
    // Periodic timer function
    // Enables update of location and heading
    // Also checks if previous sample arrived in time
    @objc func tmrFired(){
        
        var report:Bool
        var textToSpeak: String = ""
        var rateAdjust: Float
        
        //print("timer fired!")
        if hdgSampleRcvd == true {

            if curHeadingInitCnt > 0 {
                curHeadingInitCnt -= 1
            }
            
            if settings.simEnable {
                myNewHeading = (simulator?.getSimHeading() ?? 0) as Float
            }
            ( report, textToSpeak, curHeading ) = hdgManager.procHeading(myNewHeading, lastScalarSpeaker: lastSpokenScaler, initCnt: curHeadingInitCnt)
            //print("curHeading: \(curHeading)")
            hdgLabel.text = String( format: "%03.0f", Float(Int(curHeading)) )
            hdgUpdateDelegate?.headingUpdate(newHeading: curHeading)
                 
             if report {

                rateAdjust = abs(hdgManager.trend) * hdgSpeechRateAdjustFactor
                speakText( textToSpeak, pitchAdjust: 0, rateAdjust: rateAdjust)
                 lastSpokenScaler = hdgManager.name
                 print("heading \(textToSpeak) spoken")
             }
            if !settings.simEnable {
                locManager.startUpdatingHeading()
                hdgSampleRcvd = false
            }
        }
        else {
            print( "Error: missed heading sample!")
        }
        
        if settings.simEnable {
            curSpeed = (simulator?.getSimSpeed() ?? 0) as Float
        } else {
            let loc = locManager.location
            curSpeed = Float(loc?.speed ?? 0)
        }
 
        //print("curSpeed: \(curSpeed)")
        if settings.mphKnots {
            curSpeed = curSpeed * Float(Double(metersPerSecToMPH))
        } else {
            curSpeed = curSpeed * Float(Double(metersPerSecToKnots))
        }
        spdLabel.text = String(format: "%.1f", curSpeed )
        spdUpdateDelegate?.speedUpdate(newSpeed: Float(curSpeed))
           
        ( report, textToSpeak ) = spdManager.procSpeed(Float(curSpeed), lastScalarSpeaker: lastSpokenScaler, initCnt: curSpeedInitCnt)
           
        if report {
            
            rateAdjust = abs(spdManager.trend) * spdSpeechRateAdjustFactor
            speakText( textToSpeak, pitchAdjust: spdSpeechPitchAdjust, rateAdjust: rateAdjust ) // higher pitch
                                                        //voice for speed
            lastSpokenScaler = spdManager.name
            print("Speed \(textToSpeak) Spoken")
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////
     // Trend indicator Periodic timer function
     // Counts down trendTmrCnt and issues trend indicator if zero
     // Only used on heading
     @objc func trendTmrFired(){
        
        var newTrend: Bool = false
        var trendSignal = "ready"
        
        if hdgManager.audioEnabled && hdgManager.indicateTrendSignal {
            
            (newTrend, trendSignal) = hdgManager.getTrend()
            
            if (newTrend && (trendTimerCnt > Float(trendTimerNewTrendInit))) {
                trendTimerCnt = Float(trendTimerNewTrendInit) // new trend delay before signal
            }
            if (trendTimerCnt <= 0) {
             
                switch trendSignal {
                    case "up":
                        playSound("Sounds/delta_stbd-1")
                    case "down":
                        playSound("Sounds/delta_port-1")
                    default:
                        playSound("Sounds/delta_steady-2")
                }
                trendTimerCnt = Float(trendTimerMaxInit)
                let trendPeriodReduction = abs(hdgManager.trend * Float(TimerFreq)) * Float(trendTimerFactor)
                trendTimerCnt -= Float(min( trendPeriodReduction ,Float(trendPeriodReductionMax)))
                
            } else if curHeadingInitCnt == 0 { // No trend signals for first few samples
                //trendTimerCnt -= 1
                let trendTimerDownCountEnhancement = min((abs(hdgManager.trend) * trendSigEnhancedRptFactor), maxTrendTimerDownCountEnhancement)
                //print("trendTimerDownCountEnhancement:  \(trendTimerDownCountEnhancement)")
                trendTimerCnt -= Float(1 + trendTimerDownCountEnhancement)
            }
        }
    }
    
    // Function to start receiving compass/speed data
    func start() {
        
        settings.timer = Timer.scheduledTimer(timeInterval: (1.0 / Double( TimerFreq )), target: self, selector: #selector(tmrFired), userInfo: nil, repeats: true)
        // Since it's the first sample, pretend all is well
        hdgSampleRcvd = true
        curHeadingInitCnt = 6 // Suppress damping for first 6 samples
        curSpeedInitCnt = 6 // Suppress damping for first 6 samples
        if !settings.simEnable {
            locManager.startUpdatingLocation()
        }
        
        // Setup the trend indictor timer
        settings.trendTimer = Timer.scheduledTimer(timeInterval: (1.0 / Double(trendTimerFreq)), target: self, selector: #selector(trendTmrFired), userInfo: nil, repeats: true)
    }
    
    // Function to stop receiving compass/speed data
    func stop() {
        settings.timer.invalidate()
        settings.trendTimer.invalidate()
        if !settings.simEnable {
            locManager.stopUpdatingLocation()
            locManager.stopUpdatingHeading()
        }
    }
    
    // Reference and action buttons for Start/Stop button
    @IBOutlet weak var startBtnRef: UIButton!
    @IBAction func startBtn(_ sender: Any) {
        
        if (String(startBtnRef.currentTitle!) == "Start") {
            
            start()
            startBtnRef.setTitle("Stop", for: UIControl.State.normal)
            settings.running = true
        
        } else {
            stop()
            startBtnRef.setTitle("Start", for: UIControl.State.normal)
            settings.running = false
        }
        print("\(String(startBtnRef.currentTitle!)) pressed")
    }
        
    func startStopUpdate(run: Bool) {
        if run {
            start()
        } else {
            stop()
        }
    }
    // This function will be called whenever your heading is updated. Since you asked for best
    // accuracy, this function will be called a lot of times. Better make it very efficient
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            
        hdgSampleRcvd = true
        myNewHeading = Float(newHeading.magneticHeading)
    }
        
    // ocation manager calls this to update location, and speed in our case
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: CLLocation) {
        
        //let newSpeed = locations.speed
        //spdLabel.text = String(format: "%02.1f", newSpeed)
        //print( "Current speed: \(newSpeed)" )
    }
    
    // MARK: -
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed: \(error)")
    }

    // Heading readings tend to be widely inaccurate until the system has calibrated itself
    // Return true here allows iOS to show a calibration view when iOS wants to improve itself
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
            return true
    }
    
    // Speaks whatever text is passed to it
    func speakText(_ textToSpeak: String, pitchAdjust:Float, rateAdjust: Float) {
         
        // let signal = AVSpeechUtterance()
        let speechUtterance = AVSpeechUtterance(string: textToSpeak)
        speechUtterance.rate = min(settings.speechRate + rateAdjust, Float(maxSpeechRate))
        speechUtterance.pitchMultiplier = min(settings.speechPitch + pitchAdjust, Float(maxSpeechPitch))
        speechUtterance.volume = settings.speechVolume
        speechUtterance.postUtteranceDelay = Double(settings.speechPostDelay)
         
        //if speechSynthesizer.isSpeaking == false {
        speechSynthesizer.speak(speechUtterance)
        hdgManager.isSpeaking = true
        spdManager.isSpeaking = true
        //}
    }
     
    //  Called whenever speaking is completed
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance){
         //print("Speech Done!")
        hdgManager.isSpeaking = false
        spdManager.isSpeaking = false
    }
        
    // Plays a sound file
    func playSound(_ wav_file_name: String){
            
        let wavFile = Bundle.main.path(forResource: wav_file_name, ofType: "wav")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: wavFile!))
            audioPlayer.delegate = self
            if speechSynthesizer.isSpeaking {
                audioPlayer.volume = 0.5    // lower volume if speaking
            } else {
                audioPlayer.volume = min(((settings.speechVolume) + 0.15), 1.00)
            }
            
            audioPlayer.rate = 1.00
            audioPlayer.play()
            audioPlayer.numberOfLoops = 1
            hdgManager.isSoundPlaying = true
            spdManager.isSoundPlaying = true
            }
        catch {
            // catch any errors
            print("Error playing sound \(wav_file_name).wav")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                              successfully flag: Bool){
        //print("audioPlayerDidFinishPlaying")
        hdgManager.isSoundPlaying = false
        spdManager.isSoundPlaying = false
    }
}
