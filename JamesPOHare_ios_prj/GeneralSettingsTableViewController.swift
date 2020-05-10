//
//  SpeechSettingsTableViewController.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import Foundation
import UIKit

class GeneralSettingsTableViewController: UITableViewController, DarkModeChgDelegate {
    
    let sliderOffsetFromRightMargin = 20
    let sliderYPosition = 10
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //print("Will Transition to size \(size) from super view size \(self.view.frame.size)")
        
        print("Gen Settings viewWillTransition()")
        if self.isViewLoaded {
            adjustSlidersPosition(width: size.width)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.isViewLoaded {
            adjustSlidersPosition(width: self.view.frame.width)
        }
        settings.darkModeChgDelegate = self
        darkModeChg(darkMode: settings.darkMode)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spchRateRef.value = settings.speechRate
        spchRateLbl.text = String(format: "Rate: %.2f",spchRateRef.value)
        spchPitchRef.value = settings.speechPitch
        spchPitchLbl.text = String(format: "Pitch: %.2f",spchPitchRef.value)
        spchVolumeRef.value = settings.speechVolume
        spchVolumeLbl.text = String(format: "Volume: %.2f",spchVolumeRef.value)
        //spchPostDelayRef.value = settings.speechPostDelay
        //spchPostDelayLbl.text = String(format: "Post Delay: %.2f",spchPostDelayRef.value)
        hdgDampingRef.value = Float(settings.hdgDamping)
        hdgDampingLbl.text = String(format: "Hdg Damping: %.0f",hdgDampingRef.value)
        simRef.isOn = settings.simEnable
        adjustSlidersPosition(width: self.view.frame.width)
        darkModeRef.isOn = settings.darkMode
        settings.darkModeChgDelegate = self
        darkModeChg(darkMode: settings.darkMode)
    }
    
    func adjustSlidersPosition(width: CGFloat) {
        
        spchRateRef.frame.origin.x = width -
            spchRateRef.frame.width - CGFloat(sliderOffsetFromRightMargin)
        spchRateRef.frame.origin.y = CGFloat(sliderYPosition)
        spchPitchRef.frame.origin.x = width -
            spchPitchRef.frame.width - CGFloat(sliderOffsetFromRightMargin)
        spchPitchRef.frame.origin.y = CGFloat(sliderYPosition)
        spchVolumeRef.frame.origin.x = width -
            spchVolumeRef.frame.width - CGFloat(sliderOffsetFromRightMargin)
        spchVolumeRef.frame.origin.y = CGFloat(sliderYPosition)
        //spchPostDelayRef.frame.origin.x = width -
         //   spchPostDelayRef.frame.width - CGFloat(sliderOffsetFromRightMargin)
        //spchPostDelayRef.frame.origin.y = CGFloat(sliderYPosition)
        hdgDampingRef.frame.origin.x = width -
            hdgDampingRef.frame.width - CGFloat(sliderOffsetFromRightMargin)
        hdgDampingRef.frame.origin.y = CGFloat(sliderYPosition)
    }
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var spchCell: UITableViewCell!
    @IBOutlet weak var spchCellText: UILabel!
    
    func darkModeChg(darkMode: Bool) {
        print("Gen settings darkMode: \(darkMode)")
        if !darkMode {
            self.view.backgroundColor = UIColor.white
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
            settings.mainTabBarController?.tabBar.barTintColor = UIColor.white
         
            //self.tabBarController?.tabBar
            for cell in tblView.visibleCells {
                cell.backgroundColor = UIColor.white
                if let cellLbl = cell.contentView.subviews[0] as? UILabel {
                    cellLbl.textColor = UIColor.black
                }
            }
        } else {
            self.view.backgroundColor = UIColor.black
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
            settings.mainTabBarController?.tabBar.barTintColor = UIColor.black
            
            for cell in tblView.visibleCells {
                cell.backgroundColor = UIColor.black
                if let cellLbl = cell.contentView.subviews[0] as? UILabel{
                        cellLbl.textColor = UIColor.white
                    }
             }
        }
     }
    
    @IBOutlet weak var spchRateLbl: UILabel!
    @IBOutlet weak var spchRateRef: UISlider!
    @IBAction func spchRate(_ sender: Any) {
        
        settings.speechSettingUpdate(setting: .rate, value: spchRateRef.value)
        spchRateLbl.text = String(format: "Rate: %.2f",spchRateRef.value)
    }
    
    @IBOutlet weak var spchPitchLbl: UILabel!
    @IBOutlet weak var spchPitchRef: UISlider!
    @IBAction func spchPitch(_ sender: Any) {
        
        settings.speechSettingUpdate(setting: .pitch, value: spchPitchRef.value)
        spchPitchLbl.text = String(format: "Pitch: %.2f",spchPitchRef.value)
    }
    
    @IBOutlet weak var spchVolumeLbl: UILabel!
    @IBOutlet weak var spchVolumeRef: UISlider!
    @IBAction func spchVolume(_ sender: Any) {
        
        settings.speechSettingUpdate(setting: .volume, value: spchVolumeRef.value)
        spchVolumeLbl.text = String(format: "Volume: %.2f",spchVolumeRef.value)
    }
    
    @IBOutlet weak var spchPostDelayLbl: UILabel!
    @IBOutlet weak var spchPostDelayRef: UISlider!
    @IBAction func spchPostDelay(_ sender: Any) {
        
        settings.speechSettingUpdate(setting: .postDelay, value: spchPostDelayRef.value)
        spchPostDelayLbl.text = String(format: "Post Delay: %.2f",spchPostDelayRef.value)
    }
    
    @IBOutlet weak var hdgDampingLbl: UILabel!
    @IBOutlet weak var hdgDampingRef: UISlider!
    @IBAction func hdgDamping(_ sender: Any) {
        
        settings.hdgSettingUpdate( setting: .damping, value: Int(hdgDampingRef.value))
        hdgDampingLbl.text = String(format: "Hdg Damping: %.0f", hdgDampingRef.value)
    }
    
    @IBOutlet weak var simRef: UISwitch!
    
    @IBAction func simulator(_ sender: Any) {
        
        print("SimEnable: \(simRef.isOn)")
        settings.simEnable = simRef.isOn
    }
    
    @IBOutlet weak var darkModeRef: UISwitch!
    
    @IBAction func darkModeSwitch(_ sender: Any) {
        settings.darkModeUpdate(value: darkModeRef.isOn)
        print("Dark Mode: \(darkModeRef.isOn)")
    }
}
