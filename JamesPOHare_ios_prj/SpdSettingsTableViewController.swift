//
//  SpdSettingsTableViewController.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import UIKit

class SpdSettingsTableViewController: UITableViewController, DarkModeChgDelegate {
    

    override func viewDidAppear(_ animated: Bool) {
        spdAudioEnableRef.isOn = settings.spdAudioEnable
        darkModeChg(darkMode: settings.darkMode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spdAudioEnableRef.isOn = settings.spdAudioEnable
        spdMinPeriodStprRef.value = Double(settings.spdMinPeriod)
        spdMinPeriodTboxRef.text = String(settings.spdMinPeriod)
        spdMaxPeriodStprRef.value = Double(settings.spdMaxPeriod)
        spdMaxPeriodTboxRef.text = String(settings.spdMaxPeriod)
        let idx:Int  = SpdIntervalLUTbl.firstIndex(of: settings.spdInterval)!
        spdIntervalStprRef.value = Double(idx)
        spdIntervalTboxRef.text = String(settings.spdInterval)
        spdIntervalTboxRef.allowsEditingTextAttributes = false
        
        spdIndicateTrendRef.isOn = settings.spdIndicateTrend
        spdIndicateTrendSignalRef.isOn = settings.spdIndicateTrendSignal
        spdTrendPosTextRef.text = settings.spdTrendPosText
        spdTrendNegTextRef.text = settings.spdTrendNegText
        settings.darkModeChgDelegate = self
        darkModeChg(darkMode: settings.darkMode)
        mphKnotsSwitchRef.isOn = settings.mphKnots
        
        if mphKnotsSwitchRef.isOn {
             mphKnotsRef.text = "MPH/Knots : MPH"
         } else {
             mphKnotsRef.text = "MPH/Knots : Knots"
         }
    }
    
    @IBOutlet weak var tblView: UITableView!
    func darkModeChg(darkMode: Bool) {
        print("Spd settings darkMode: \(darkMode)")
        if !darkMode {
            self.view.backgroundColor = UIColor.white
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            settings.mainTabBarController?.tabBar.barTintColor = UIColor.white
            for cell in tblView.visibleCells {
                cell.backgroundColor = UIColor.white
                if let cellLbl = cell.contentView.subviews[0] as? UILabel {
                        cellLbl.textColor = UIColor.black
                }
            }
        } else {
            self.view.backgroundColor = UIColor.black
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            settings.mainTabBarController?.tabBar.barTintColor = UIColor.black
            for cell in tblView.visibleCells {
                cell.backgroundColor = UIColor.black
                if let cellLbl = cell.contentView.subviews[0] as? UILabel{
                        cellLbl.textColor = UIColor.white
                }
            }
        }
    }
    
    @IBOutlet weak var spdAudioEnableRef: UISwitch!
    
    @IBAction func spdAudioEnable(_ sender: Any) {
    settings.spdSettingUpdate(setting: .audioEnable, value: spdAudioEnableRef.isOn)
    }
    
    @IBOutlet weak var spdMinPeriodTboxRef: UITextField!
    @IBOutlet weak var spdMinPeriodStprRef: UIStepper!
    @IBAction func spdMinPeriodStpr(_ sender: Any) {
        
        spdMinPeriodTboxRef.text = String(Int(spdMinPeriodStprRef.value))
        settings.spdSettingUpdate(setting: .minPeriod, value: Int(spdMinPeriodStprRef.value))
    }
    
    @IBAction func spdMinPeriodTboxValChg(_ sender: UITextField) {
        spdMinPeriodStprRef.value = Double(spdMinPeriodTboxRef.text!) ?? 5.0
        settings.spdSettingUpdate(setting: .minPeriod, value: Int(spdMinPeriodTboxRef.text!) ?? Int(5.0))
    }
    
    @IBAction func spdTboxReturn(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    @IBOutlet weak var spdMaxPeriodTboxRef: UITextField!
    
    @IBOutlet weak var spdMaxPeriodStprRef: UIStepper!
    
    @IBAction func spdMaxPeriodStpr(_ sender: Any) {
        
        spdMaxPeriodTboxRef.text = String(Int(spdMaxPeriodStprRef.value))
        settings.spdSettingUpdate(setting: .minPeriod, value: Int(spdMaxPeriodStprRef.value))
    }
    
    @IBAction func spdMaxPeriodTboxValChg(_ sender: UITextField) {
        spdMaxPeriodStprRef.value = Double(spdMaxPeriodTboxRef.text!) ?? 25.0
        settings.spdSettingUpdate(setting: .maxPeriod, value: Int(spdMaxPeriodTboxRef.text!) ?? Int(25.0))
    }
    
    @IBOutlet weak var spdIntervalTboxRef: UITextField!
    
    @IBOutlet weak var spdIntervalStprRef: UIStepper!
    @IBAction func spdIntervalStpr(_ sender: Any) {
        spdIntervalTboxRef.text = String(SpdIntervalLUTbl[Int(spdIntervalStprRef.value)])
        settings.spdSettingUpdate(setting: .interval, value: SpdIntervalLUTbl[Int(spdIntervalStprRef.value)])
    }
    

    @IBOutlet weak var spdIndicateTrendSignalRef: UISwitch!
    
    @IBAction func spdIndicateTrendSignal(_ sender: Any) {
        
        settings.spdSettingUpdate(setting: .indicateTrendSignal, value: spdIndicateTrendSignalRef.isOn)
    }
    
    @IBOutlet weak var spdIndicateTrendRef: UISwitch!
    
    @IBAction func spdIndicateTrend(_ sender: Any) {
        
        settings.spdSettingUpdate(setting: .indicateTrend, value: spdIndicateTrendRef.isOn)
    }
    
    @IBOutlet weak var spdTrendPosTextRef: UITextField!
    
    @IBAction func spdTrendPosText(_ sender: Any) {
        
        settings.spdSettingUpdate(setting: .trendPosText, value: (spdTrendPosTextRef.text ?? SpdTrendPosText))
    }
    
    @IBOutlet weak var spdTrendNegTextRef: UITextField!
    
    @IBAction func spdTrendNegText(_ sender: Any) {
        
        settings.spdSettingUpdate(setting: .trendNegText, value: (spdTrendNegTextRef.text!))
    }
    
    @IBOutlet weak var mphKnotsRef: UILabel!
    
    @IBOutlet weak var mphKnotsSwitchRef: UISwitch!
    @IBAction func mphKnotsSwitch(_ sender: Any) {
        settings.mphKnotsSettingUpdate(value: mphKnotsSwitchRef.isOn)
        if mphKnotsSwitchRef.isOn {
            mphKnotsRef.text = "MPH/Knots : MPH"
        } else {
            mphKnotsRef.text = "MPH/Knots : Knots"
        }
    }
}
