//
//  ViewController.swift
//  test02
//
//  Created by Angelina Choi on 2015-01-30.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import Foundation

class WelcomeScreen: UIViewController {
    
    @IBOutlet weak var InstructionText: UITextView!
    @IBOutlet weak var beginLabel: UILabel!
    @IBOutlet weak var instructionView: UIView!
    
    var blinkStatus = false
    var faceDownCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        InstructionText.text = "This application is for any immunization administrators to create, record, and upload Immunization Health Receipts to the immunization portal with parental or patient consent. This app can scan patient demographics, vaccine data, and submit them to the immunization portal.\n\nWith this application, one can scan patient and vaccine demographics in the form of QR codes, GS1 Datamatrix, and PDF417 codes. There is also the option to send the information to the server and printing a digital copy of the receipt for the patient.\n\nIf you need help, there is a help icon at the top right corner of each screen. To log out at any time, press the log out button or put the device face-down. If further assistance is required, please contact IBM or MOH, maybe they can do some magic. <Additional instructions required here probably>"
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        self.beginLabel.alpha = 0
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("labelBlinkAnimation"), userInfo: nil, repeats: true)
        self.instructionView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            println("Swipe Left")
            self.performSegueWithIdentifier("WelcomeToPatient", sender: self)
        } else if (sender.direction == .Right) {
            println("Swipe Right")
        }
    }
    
    func labelBlinkAnimation() {
        if (blinkStatus == false) {
            UIView.animateWithDuration(1.0, animations: {self.beginLabel.alpha = 0})
            blinkStatus = true
        } else {
            UIView.animateWithDuration(1.0, animations: {self.beginLabel.alpha = 1.0})
            blinkStatus = false
        }
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            println("Device is face down")
            if faceDownCounter == 0 {
                faceDownCounter = 1
                let logoutConfirmation: UIAlertController = UIAlertController(title: "Device has been put face down!", message: "By putting your device face down, that signals the application to log out. Would you like to log out immediately?\n\nWarning: No information will be saved. Next time this device is put face down, the application will automatically logout without this message.", preferredStyle: UIAlertControllerStyle.Alert)
                logoutConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    self.performSegueWithIdentifier("WelcomeBackToLogin", sender: self)}))
                logoutConfirmation.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(logoutConfirmation, animated: true, completion: nil)
            } else {
                let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
                logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    self.performSegueWithIdentifier("WelcomeBackToLogin", sender: self)}))
                self.presentViewController(logoutConfirmation, animated: true, completion: nil)
            }
        default:
            println("Device is not face down")
        }
    }

}

