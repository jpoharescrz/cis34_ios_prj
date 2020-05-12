//
//  GraphicsViewController.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/14/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import UIKit

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        //print("orig height: \(self.size.height), width: \(self.size.width)")
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        //UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        //print("new height: \(self.size.height), width: \(self.size.width)")
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

// Used to update main screen start/stop button
protocol RemoteStartStopDelegate {
    
    func startStopUpdate( run: Bool )
}

class GraphicsViewController: UIViewController, headingUpdateDelegate, speedUpdateDelegate, DarkModeChgDelegate  {
    
    var stop_x:Int = 0
    var stop_y:Int = 0
    var speedoRange: Double = 20.0
    
    var compassRoseAngle:Float = 0
    var compassRoseRhumblineSize: Int = 100
    var speedoNeedleSize: Double = 120
    
    var remStartStopDelegate: RemoteStartStopDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("Graphics view appeared")
        // Reflect running state in start/stop button
        if settings.running {
            graphicsStartBtnRef.setTitle("Stop", for: UIControl.State.normal)
        } else {
            graphicsStartBtnRef.setTitle("Start", for: UIControl.State.normal)
        }
        
        hdgGrphMutedLbl.isHidden = settings.hdgAudioEnable
        print("settings.hdgAudioEnable: \(settings.hdgAudioEnable)")
        spdGrphMutedLbl.isHidden = settings.spdAudioEnable
        
        darkModeChg(darkMode: settings.darkMode)
        speedUpdate(newSpeed: 0.0, updateDigits: true)
        headingUpdate(newHeading: 0.0, updateDigits: true)
        if settings.mphKnots {
             mphKnotsLbl.text = "MPH"
         } else {
             mphKnotsLbl.text = "Knots"
         }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up rhumbline size
        compassRoseRhumblineSize = Int(compassRoseCopy.image?.size.height ?? 100)/2
        
        // Set up speedometer needle size
        speedoNeedleSize = Double((speedometerCopy.image?.size.height ?? 120) * 0.68)
        
        // Setup to get heading and speed updates
        if let homeTab = self.tabBarController?.viewControllers?[0] as? HomeViewController {
        
            homeTab.hdgUpdateDelegate = self
            homeTab.spdUpdateDelegate = self
        }
 
         var tap = UITapGestureRecognizer(target: self, action: #selector(GraphicsViewController.compassTapFunction))
         compassRose.addGestureRecognizer(tap)
         compassRose.isUserInteractionEnabled = true
         
        tap = UITapGestureRecognizer(target: self, action: #selector(GraphicsViewController.speedoTapFunction))
         speedometer.addGestureRecognizer(tap)
         speedometer.isUserInteractionEnabled = true
        
        settings.darkModeChgDelegate = self
    }
    
    @IBOutlet weak var mphKnotsLbl: UILabel!
    @IBOutlet weak var screenView: UIView!
    func darkModeChg(darkMode: Bool) {
        print("Graphics darkMode: \(darkMode), visible cells: \(screenView.subviews.count)")
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
    
    @IBOutlet weak var hdgGrphMutedLbl: UILabel!
    @objc func compassTapFunction(sender:UITapGestureRecognizer) {
        
        settings.hdgSettingUpdate( setting: .audioEnable, value: !settings.hdgAudioEnable)
        hdgGrphMutedLbl.isHidden = settings.hdgAudioEnable
        //hdgGrphMutedLbl.attributedText = [NSAttributedString.Key.a : UIColor.black]
        
        print("hdg tap working")
    }
    
    @IBOutlet weak var spdGrphMutedLbl: UILabel!
    @objc func speedoTapFunction(sender:UITapGestureRecognizer) {
        
        settings.spdSettingUpdate( setting: .audioEnable, value: !settings.spdAudioEnable)
        spdGrphMutedLbl.isHidden = settings.spdAudioEnable
        
        print("spd tap working")
    }
    
    @IBOutlet weak var compassRose: UIImageView!
    
    @IBOutlet weak var compassRoseCopy: UIImageView!
    
    @IBOutlet weak var compassRoseCopyDark: UIImageView!
    @IBOutlet weak var hdgLabel: UILabel!

    
    func drawRhumbLineOnImage(startingImage: UIImage) -> UIImage {

         // Create a context of the starting image size and set it as the current one
         UIGraphicsBeginImageContext(startingImage.size)

         // Draw the starting image in the current context as background
         startingImage.draw(at: CGPoint.zero)

         // Get the current context
         let context = UIGraphicsGetCurrentContext()!

         // Draw a red line
         let rhumblineWidth:CGFloat = CGFloat( compassRoseRhumblineSize / 30)
         context.setLineWidth(rhumblineWidth)
         context.setStrokeColor(UIColor.red.cgColor)
         context.move(to: CGPoint(x: context.width/2, y: context.height/2))
         context.addLine(to: CGPoint(x: context.width/2, y: ((context.height/2)-compassRoseRhumblineSize)) )
         context.strokePath()
        
        //print("context.height: \(context.height)")

         // Draw a transparent green Circle
         /*
         context.setStrokeColor(UIColor.green.cgColor)
         context.setAlpha(0.5)
         context.setLineWidth(10.0)
         context.addEllipse(in: CGRect(x: 100, y: 100, width: 100, height: 100))
         context.drawPath(using: .stroke) // or .fillStroke if need filling
*/
         // Save the context as a new UIImage
        
        guard let myImage = UIGraphicsGetImageFromCurrentImageContext() else { return startingImage }
        
         UIGraphicsEndImageContext()
         // Return modified image
         return myImage
    }
    
    func drawNeedleOnDial(startingImage: UIImage, value: Float, range: Float) -> UIImage {

            //print("Range: \(range)")
             // Create a context of the starting image size and set it as the current one
             UIGraphicsBeginImageContext(startingImage.size)

             // Draw the starting image in the current context as background
             startingImage.draw(at: CGPoint.zero)

             // Get the current context
             let context = UIGraphicsGetCurrentContext()!

             // Draw a red line
             let speedoNeedleWidth:CGFloat = CGFloat(speedoNeedleSize / 30)
             context.setLineWidth(speedoNeedleWidth)
             context.setStrokeColor(UIColor.red.cgColor)
        context.move(to: CGPoint(x: context.width/2, y: Int(Float(context.height) * 0.68)))
             let needleLen:Double = speedoNeedleSize
        let y = sin((Double(value/range) * (.pi * 1.333)) - (.pi * 0.16666)) * needleLen
        let x = cos((Double(value/range) * (.pi * 1.333)) - (.pi * 0.16666)) * needleLen
        context.addLine(to: CGPoint(x: context.width/2 - Int(x), y: ((Int(Float(context.height) * 0.68))-Int(y))) )
             context.strokePath()

        // Save the context as a new UIImage
            
        guard let myImage = UIGraphicsGetImageFromCurrentImageContext() else { return startingImage }
            
        UIGraphicsEndImageContext()
            
             // Return modified image
        return myImage
    }
    
    func headingUpdate(newHeading: Float, updateDigits: Bool) {
        
        var rotatedImage: UIImage?
        
        //print("height: \(compassRoseCopy.image?.size.height ?? 0)")
        let newAngle = newHeading.degreesToRadians * -1
        
        if settings.darkMode {
            rotatedImage = compassRoseCopyDark.image?.rotate(radians: newAngle)
        } else {
            rotatedImage = compassRoseCopy.image?.rotate(radians: newAngle)
        }
 
        compassRose.image = drawRhumbLineOnImage(startingImage: rotatedImage!)
        /*
        let xDiff = compassRose.frame.size.width - compassRoseCopy.frame.size.width
        let yDiff = compassRose.frame.size.height - compassRoseCopy.frame.size.height
        compassRose.frame.origin.x = compassRoseCopy.frame.origin.x - (xDiff/2)
        compassRose.frame.origin.y = compassRoseCopy.frame.origin.y - (yDiff/2)
        */
        if updateDigits {
            hdgLabel.text = String( format: "%03.0f", Float(Int(newHeading)) )
        }
    }
    
    @IBOutlet weak var speedometer: UIImageView!
    @IBOutlet weak var speedometerCopy: UIImageView!
    
    @IBOutlet weak var speedometerCopyDark: UIImageView!
    
    @IBOutlet weak var speedoLabel: UILabel!
    @IBOutlet weak var speedoMidLabel: UILabel!
    @IBOutlet weak var speedoMaxLabel: UILabel!
    
    func speedUpdate(newSpeed: Float, updateDigits: Bool) {
        
        // Adjust range if necessary
        if newSpeed > Float(speedoRange) {
            if newSpeed > 20.0 {
                speedoRange = 40.0
                speedoMidLabel.text = "20"
                speedoMaxLabel.text = "40"
            }
            if newSpeed > 40.0 {
                speedoRange = 80.0
                speedoMidLabel.text = "40"
                speedoMaxLabel.text = "80"
            }
            if newSpeed > 80.0 {
                speedoRange = 160.0
                speedoMidLabel.text = "80"
                speedoMaxLabel.text = "160"
            }
        }
        
        var speedometerImage: UIImage?
        if settings.darkMode {
            speedometerImage = speedometerCopyDark.image
        } else {
            speedometerImage = speedometerCopy.image
        }
        speedometer.image = drawNeedleOnDial(startingImage: speedometerImage!, value: newSpeed, range: Float(speedoRange))
        
        if updateDigits {
            speedoLabel.text = String(format: "%.1f", newSpeed )
        }
    }
    
    @IBOutlet weak var graphicsStartBtnRef: UIButton!
    
    @IBAction func graphicsStartBtn(_ sender: Any) {
        
        if (String(graphicsStartBtnRef.currentTitle!) == "Start") {
            
            remStartStopDelegate?.startStopUpdate(run: true)
            graphicsStartBtnRef.setTitle("Stop", for: UIControl.State.normal)
            settings.running = true
        
        } else {
            remStartStopDelegate?.startStopUpdate(run: false)
            graphicsStartBtnRef.setTitle("Start", for: UIControl.State.normal)
            settings.running = false
        }
        print("\(String(graphicsStartBtnRef.currentTitle!)) pressed")
    }
    
}
