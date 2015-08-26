//
//  PatientInformationScreen.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-07-21.

import UIKit
import AVFoundation
import MobileCoreServices

class VaccineVerificationScreen: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    //, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource
    @IBOutlet weak var gtinText: UITextField!
    @IBOutlet weak var agentText: UITextField!
    @IBOutlet weak var lotNoText: UITextField!
    @IBOutlet weak var manufactureText: UITextField!
    @IBOutlet weak var expDateText: UITextField!
    @IBOutlet weak var BrandText: UITextField!
    @IBOutlet weak var routeText: UITextField!
    @IBOutlet weak var doseSizeText: UITextField!
    @IBOutlet weak var antigenText: UITextField!
    @IBOutlet weak var diseaseText: UITextField!

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var vaccineView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(animated: Bool) {
        // viewWillAppear
        //segue VaccVerifyToSubmit
        self.logOutButton.layer.cornerRadius = 5
        self.verifyButton.layer.cornerRadius = 5
        self.cancelButton.layer.cornerRadius = 5
        self.vaccineView.layer.cornerRadius = 5
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let vaccineType = userDefaults.stringForKey("vaccineInfoType")
        
        gtinText.text = userDefaults.stringForKey("productGtin")
        agentText.text = userDefaults.stringForKey("agent")
        lotNoText.text = userDefaults.stringForKey("productLotNumber")
        manufactureText.text = userDefaults.stringForKey("manufacture")
        expDateText.text = userDefaults.stringForKey("productExpiryDate")
        BrandText.text = userDefaults.stringForKey("brand")
        routeText.text = userDefaults.stringForKey("route")
        doseSizeText.text = userDefaults.stringForKey("doseSize")
        antigenText.text = userDefaults.stringForKey("antigen")
        diseaseText.text = userDefaults.stringForKey("disease")
        
        /*
        if vaccineType == "QR" {
            gtinText.text = userDefaults.stringForKey("vaccGtin")
            agentText.text = userDefaults.stringForKey("vaccAgent")
            lotNoText.text = userDefaults.stringForKey("vaccLotNo")
            manufactureText.text = userDefaults.stringForKey("vaccManufacture")
            
            expDateText.text = "N/A"
            BrandText.text = "N/A"
            routeText.text = "N/A"
            doseSizeText.text = "N/A"
            antigenText.text = "N/A"
            diseaseText.text = "N/A"
            
        } else if vaccineType == "dataMatrix" {
            gtinText.text = userDefaults.stringForKey("productGtin")
            agentText.text = userDefaults.stringForKey("agent")
            lotNoText.text = userDefaults.stringForKey("productLotNumber")
            manufactureText.text = userDefaults.stringForKey("manufacture")
            expDateText.text = userDefaults.stringForKey("productExpiryDate")
            BrandText.text = userDefaults.stringForKey("brand")
            routeText.text = userDefaults.stringForKey("route")
            doseSizeText.text = userDefaults.stringForKey("doseSize")
            antigenText.text = userDefaults.stringForKey("antigen")
            diseaseText.text = userDefaults.stringForKey("disease")
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutManual(sender: UIButton) {
        let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
        logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("VaccVerifyToLogin", sender: self)}))
        self.presentViewController(logoutConfirmation, animated: true, completion: nil)
    }
    @IBAction func BackToScan(sender: UIButton) {
        let backConfirmation: UIAlertController = UIAlertController(title: "Back to Scan Confirm", message: "Once you go back to the vaccine scanner, all current vaccine data will be lost. Continue?", preferredStyle: UIAlertControllerStyle.Alert)
        backConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("VaccVerifyToScan", sender: self)}))
        backConfirmation.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(backConfirmation, animated: true, completion: nil)
    }
    @IBAction func verifyVaccineData(sender: UIButton) {
        let verifyConfirmation: UIAlertController = UIAlertController(title: "Vaccine Data Confirm", message: "Once you go to the submit screen, data cannot be changed. Continue?", preferredStyle: UIAlertControllerStyle.Alert)
        verifyConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("VaccVerifyToSubmit", sender: self)}))
        verifyConfirmation.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(verifyConfirmation, animated: true, completion: nil)
    }
    @IBAction func cancelButton(sender: UIButton) {
        let backConfirmation: UIAlertController = UIAlertController(title: "Back to Scan Confirm", message: "Once you go back to the vaccine scanner, all current vaccine data will be lost. Continue?", preferredStyle: UIAlertControllerStyle.Alert)
        backConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("VaccVerifyToScan", sender: self)}))
        backConfirmation.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(backConfirmation, animated: true, completion: nil)
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            println("Swipe Left")
            // self.performSegueWithIdentifier("WelcomeToPatient", sender: self)
        } else if (sender.direction == .Right) {
            println("Swipe Right")
            self.performSegueWithIdentifier("VaccVerifyToScan", sender: self)
        }
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
            logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                self.performSegueWithIdentifier("VaccVerifyToLogin", sender: self)}))
            self.presentViewController(logoutConfirmation, animated: true, completion: nil)
            
            println("Device is face down")
        default:
            println("Device is not face down")
        }
    }

 }
