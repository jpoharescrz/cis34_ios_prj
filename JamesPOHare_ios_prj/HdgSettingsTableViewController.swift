//
//  HdgSettingsTableViewController.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import Foundation
import UIKit

class HdgSettingsTableViewController: UITableViewController, DarkModeChgDelegate {
    
    var mainTabBarController: UITabBarController?

    override func viewDidAppear(_ animated: Bool) {
        hdgAudioEnableRef.isOn = settings.hdgAudioEnable
        darkModeChg(darkMode: settings.darkMode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hdgAudioEnableRef.isOn = settings.hdgAudioEnable
        hdgMinPeriodStprRef.value = Double(settings.hdgMinPeriod)
        hdgMinPeriodTboxRef.text = String(settings.hdgMinPeriod)
        hdgMaxPeriodStprRef.value = Double(settings.hdgMaxPeriod)
        hdgMaxPeriodTboxRef.text = String(settings.hdgMaxPeriod)
        let idx = HdgIntervalLUTbl.firstIndex(of: settings.hdgInterval)
        hdgIntervalStprRef.value = Double(idx ?? HdgIntervalIdx)
        hdgIntervalTboxRef.text = String(settings.hdgInterval)
        hdgIndicateTrendRef.isOn = settings.hdgIndicateTrend
        hdgIndicateTrendSignalRef.isOn = settings.hdgIndicateTrendSignal
        hdgTrendPosTextRef.text = settings.hdgTrendPosText
        hdgTrendNegTextRef.text = settings.hdgTrendNegText
        settings.darkModeChgDelegate = self
    }
    
    @IBOutlet weak var tblView: UITableView!
    
    func darkModeChg(darkMode: Bool) {
        print("Hdg settings darkMode: \(darkMode), visible cells: \(tblView.visibleCells.count)")
        if !darkMode {
            self.view.backgroundColor = UIColor.white
            settings.mainTabBarController?.tabBar.barTintColor = UIColor.white
            mainTabBarController?.tabBar.barTintColor = UIColor.white
            for cell in tblView.visibleCells {
                cell.backgroundColor = UIColor.white
                //print( "Hdg settings subview count: \(cell.contentView.subviews.count)")
                if cell.contentView.subviews.count > 0 {
                    for subview in cell.contentView.subviews {
                        if let cellLbl = subview as? UILabel {
                            cellLbl.textColor = UIColor.black
                            //print(String(cellLbl.text ?? "N/A"))
                        }
                    }
                }
            }
        } else {
            self.view.backgroundColor = UIColor.black
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            settings.mainTabBarController?.tabBar.barTintColor = UIColor.black
            for cell in tblView.visibleCells {
                cell.backgroundColor = UIColor.black
                //print( "Hdg settings subview count: \(cell.contentView.subviews.count)")
                if cell.contentView.subviews.count > 0 {
                    for subview in cell.contentView.subviews {
                        if let cellLbl = subview as? UILabel {
                            cellLbl.textColor = UIColor.white
                            //print(String(cellLbl.text ?? "N/A"))
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var hdgAudioEnableRef: UISwitch!
    @IBAction func hdgAudioEnable(_ sender: Any) {
        settings.hdgSettingUpdate(setting: .audioEnable, value: hdgAudioEnableRef.isOn)
    }
    
    @IBOutlet weak var hdgMinPeriodStprRef: UIStepper!
    @IBAction func hdgMinPeriodStpr(_ sender: Any) {
        
        hdgMinPeriodTboxRef.text = String(Int(hdgMinPeriodStprRef.value))
        settings.hdgSettingUpdate(setting: .minPeriod, value: Int(hdgMinPeriodStprRef.value))
    }
    
    @IBOutlet weak var hdgMinPeriodTboxRef: UITextField!
    @IBAction func hdgMinPeriodTboxValChg(_ sender: UITextField) {
        print("hdgMinPeriodTboxValChg")
        hdgMinPeriodStprRef.value = Double(hdgMinPeriodTboxRef.text!) ?? 5.0
        settings.hdgSettingUpdate(setting: .minPeriod, value: Int(hdgMinPeriodTboxRef.text!) ?? Int(5.0))
    }
    
    @IBAction func hdgTboxReturn(_ sender: UITextField) {
        
        _ = sender.resignFirstResponder()
    }
    
    
    @IBOutlet weak var hdgMaxPeriodStprRef: UIStepper!
    @IBAction func hdgMaxPeriodStpr(_ sender: Any) {
        
        hdgMaxPeriodTboxRef.text = String(Int(hdgMaxPeriodStprRef.value))
        settings.hdgSettingUpdate(setting: .maxPeriod, value: Int(hdgMaxPeriodStprRef.value))
    }
    
    @IBOutlet weak var hdgMaxPeriodTboxRef: UITextField!
    @IBAction func hdgMaxPeriodTboxValChg(_ sender: UITextField) {
        hdgMaxPeriodStprRef.value = Double(hdgMaxPeriodTboxRef.text!) ?? 25.0
        settings.hdgSettingUpdate(setting: .maxPeriod, value: Int(hdgMaxPeriodTboxRef.text!) ?? Int(25.0))
    }
    
    @IBOutlet weak var hdgIntervalStprRef: UIStepper!
    @IBAction func hdgIntervalStpr(_ sender: Any) {
        
        hdgIntervalTboxRef.text = String(HdgIntervalLUTbl[Int(hdgIntervalStprRef.value)])
        settings.hdgSettingUpdate(setting: .interval, value: HdgIntervalLUTbl[Int(hdgIntervalStprRef.value)])
    }
    @IBOutlet weak var hdgIntervalTboxRef: UITextField!
    
    @IBOutlet weak var hdgIndicateTrendSignalRef: UISwitch!
    @IBAction func hdgIndicateTrendSignal(_
        sender: Any) {
        
        settings.hdgSettingUpdate(setting: .indicateTrendSignal, value: hdgIndicateTrendSignalRef.isOn)
    }
    
    @IBOutlet weak var hdgIndicateTrendRef: UISwitch!
    @IBAction func hdgIndicateTrend(_ sender: Any) {
        settings.hdgSettingUpdate(setting: .indicateTrend, value: hdgIndicateTrendRef.isOn)
    }
    
    @IBOutlet weak var hdgTrendPosTextRef: UITextField!
    @IBAction func hdgTrendPosText(_ sender: Any) {
        
        settings.hdgSettingUpdate(setting: .trendPosText, value: (hdgTrendPosTextRef.text ?? HdgTrendPosText))
    }
    
    @IBOutlet weak var hdgTrendNegTextRef: UITextField!
    @IBAction func hdgTrendNegText(_ sender: Any) {
        
        settings.hdgSettingUpdate(setting: .trendNegText, value: (hdgTrendNegTextRef.text ?? HdgTrendNegText))
    }
}
