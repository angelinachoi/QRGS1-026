//
//  PatientInformationScreen.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-07-21.

import UIKit
import AVFoundation
import MobileCoreServices

class PatientInformationScreen: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    //, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var initiateButton: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    let ValidCharacterSet: NSCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890,")
    
    var isReading = false
    var patientCodeScanned = false
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var audioPlayer: AVAudioPlayer?
    var codeFrameView:UIView?
    var blinkStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoutButton.layer.cornerRadius = 5
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("labelBlinkAnimation"), userInfo: nil, repeats: true)
        
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.lblStatus.text = "Please tap the image to begin scanning."
        videoPreviewLayer?.borderColor = UIColor.lightGrayColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) { // keep camera rotation consistent with interface orientation
        switch UIDevice.currentDevice().orientation {
        case UIDeviceOrientation.Portrait:
            self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        case UIDeviceOrientation.LandscapeLeft:
            self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        case UIDeviceOrientation.LandscapeRight:
            self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        case UIDeviceOrientation.PortraitUpsideDown:
            self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
        default:
            () // Do nothing
        }
    }
    
    @IBAction func applicationLogout(sender: UIButton) {
        let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
        logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("PersonToLogin", sender: self)}))
        self.presentViewController(logoutConfirmation, animated: true, completion: nil)
    }
    
    @IBAction func BackToWelcome(sender: UIButton) {
        self.performSegueWithIdentifier("PersonToWelcome", sender: self)
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Right) {
            println("Swipe Right")
            self.performSegueWithIdentifier("PersonToWelcome", sender: self)
        }
    }
    
    func labelBlinkAnimation() {
        if (blinkStatus == false) {
            UIView.animateWithDuration(1.0, animations: {self.lblStatus.alpha = 0})
            blinkStatus = true
        } else {
            UIView.animateWithDuration(1.0, animations: {self.lblStatus.alpha = 1.0})
            blinkStatus = false
        }
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
            logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                self.performSegueWithIdentifier("PersonToLogin", sender: self)}))
            self.presentViewController(logoutConfirmation, animated: true, completion: nil)
            
            println("Device is face down")
        default:
            if (isReading == true) {
                self.stopReading()
                self.startReading()
            }
            println("Device is not face down")
        }
    }
    
    @IBAction func startScanning(sender: UIButton) {
        if (isReading == false) {
            self.startReading()
            //initiateButton.hidden = true
            self.lblStatus.text = "Aim the scanner at a patient code."
            isReading = true
        } else if (isReading == true) {
            self.stopReading()
            //initiateButton.hidden = false
            self.lblStatus.text = "Please tap the image to begin scanning."
            isReading = false
        }
    }
    
    func startReading () -> Bool {
        var error: NSError?
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        if (error != nil) {
            // If any error occurs, log the description of it and discontinue the program.
            println("\(error?.localizedDescription)")
            return false
        }
        captureSession = AVCaptureSession() // Initialize the captureSessionObject
        captureSession?.addInput(input as! AVCaptureInput) // Set the input device on the capture session.
        
        // Initialize a AVCaptureMetadaOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code]
        
        //logoImage: UIImageView!
        // self.view.backgroundColor = UIColor.blackColor()
        cameraImageView.hidden = true
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.bounds = cameraImageView.bounds
        videoPreviewLayer?.frame = cameraImageView.layer.frame
        videoPreviewLayer?.cornerRadius = 5
        videoPreviewLayer?.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        videoPreviewLayer?.borderWidth = 2.0
        videoPreviewLayer?.borderColor = UIColor.redColor().CGColor
        
        view.layer.addSublayer(videoPreviewLayer)
        captureSession?.startRunning() // Start video capture.
        
        // Initialize QR Code Frame to highlight the QR code
        codeFrameView = UIView()
        codeFrameView?.layer.borderColor = UIColor.clearColor().CGColor
        codeFrameView?.layer.borderWidth = 2
        view.addSubview(codeFrameView!)
        view.bringSubviewToFront(codeFrameView!)
        // view.bringSubviewToFront(lblStatus) // Move the message label to the top view
        view.bringSubviewToFront(initiateButton)
        
        return true
    }
    
    func captureOutput (captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            codeFrameView?.frame = CGRectZero
            videoPreviewLayer?.borderColor = UIColor.redColor().CGColor
            lblStatus.text = "No code detected"
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        videoPreviewLayer?.borderColor = UIColor.greenColor().CGColor
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label
            let codeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            codeFrameView?.frame = codeObject.bounds;
            
            if metadataObj.stringValue != nil {
                var patientCode = metadataObj.stringValue
                println("QR Code Detected")
                lblStatus.text = "QR Code Detected"
                qrCodePatientInfo(patientCode)
            }
        } else if metadataObj.type == AVMetadataObjectTypePDF417Code {
            // If the found metadata is equal to the QR code metadata then update the status label
            let pdfCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            codeFrameView?.frame = pdfCodeObject.bounds;
            //metadataObj.
            if metadataObj.stringValue != nil {
                var pdfCode = metadataObj.stringValue
                println("PDF417 Code Detected")
                lblStatus.text = "PDF417 Code Detected"
                pdfCodeInfo(pdfCode)
            }
        }
    }
    
    func pdfCodeInfo(pdfString: String) { // Function when a PDF417 Code is scanned
        patientCodeScanned = true
        let trimString = pdfString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if pdfString.rangeOfString("ON HC") != nil { // Identified PDF 417 code is Health Card Code
            var pdfmessage = ""
            
            let licenseIndex: String.Index = advance(pdfString.startIndex, 20)
            var cutString = pdfString.substringFromIndex(licenseIndex) // Cut first part of string (has a lot of useless characters in it)
            let numberIndex: String.Index = advance(cutString.startIndex, 10)
            var numberString = cutString.substringToIndex(numberIndex) // Segment of PDF string that has the HCN number
            let userDefaults = NSUserDefaults.standardUserDefaults()

            userDefaults.setObject(numberString, forKey: "pHCN") // Number string is labelled as patientHCN variable
            pdfmessage += "Health Card Number: \(numberString)\n"
            
            let nameIndex: String.Index = advance(cutString.startIndex, 10)
            var nameString = cutString.substringFromIndex(nameIndex) // Cut string to isolate the names in health card
            let nameArray = nameString.componentsSeparatedByString(" ") // separate each name by space character and turn them into an array
            
            var firstName: String = nameArray[0] // First element of namr array is always the first name
            userDefaults.setObject(firstName, forKey: "pFName")
            pdfmessage += "First Name: \(firstName)\n"
            
            let initialIndex: String.Index = advance(numberString.startIndex, 1)
            var firstInitial = userDefaults.stringForKey("pFName")?.substringToIndex(initialIndex) // Get the first character of the first name to make the patient's initials.
            
            if nameArray.count == 3 { // If three names are in the array that means there is a middle name.
                var middleName: String? = nameArray[1] // Second element of array is the middle name.
                userDefaults.setObject(middleName, forKey: "pMName")
                
                var lastName: String? = nameArray[2] // Third element of array is the last name.
                userDefaults.setObject(lastName, forKey: "pLName")
                
                var middleInitial = userDefaults.stringForKey("pMName")?.substringToIndex(initialIndex)
                var lastInitial = userDefaults.stringForKey("pLName")?.substringToIndex(initialIndex)
                let pInitials = firstInitial! + middleInitial! + lastInitial! // Get the first characters of the middle and last names to create the full initials
                userDefaults.setObject(pInitials, forKey: "pInit")
                pdfmessage += "Middle Name: \(middleName)\nLast Name: \(lastName)\nInitials: \(pInitials)\n"
                
            } else { // Patient has no middle name
                var lastName: String? = nameArray[1] // Second name in array is the last name
                userDefaults.setObject(lastName, forKey: "pLName")
                userDefaults.setObject("", forKey: "pMName")
                var lastInitial = userDefaults.stringForKey("pLName")?.substringToIndex(initialIndex)
                let pInitials = firstInitial! + lastInitial! // Initials are formed
                userDefaults.setObject(pInitials, forKey: "pInit")
                pdfmessage += "Last Name: \(lastName)\nInitials: \(pInitials)"
            }
            userDefaults.setObject("", forKey: "pMail")
            userDefaults.setObject("", forKey: "pGender")
            userDefaults.setObject("", forKey: "pDOB")
            userDefaults.synchronize()
            
            /*
            pdfmessage += "\n\nProceed with this client information?"
            let alert: UIAlertController = UIAlertController(title: "Health Card Scanned", message: pdfmessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                println("patient information captured!")
                self.performSegueWithIdentifier("CodeToInfo", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            // PDF 417 Information is displayed in a message box.
            */
            videoPreviewLayer?.borderColor = UIColor.greenColor().CGColor
            lblStatus.text = "PDF417 Code detected: Health Card"
            self.performSegueWithIdentifier("CodeToInfo", sender: self)
            
        } else if pdfString.rangeOfString("ANSI") != nil && pdfString.rangeOfString("DCS") != nil { // Identified PDF 417 code is Driver's License Code
            
            let stringArray = trimString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            var sublist = stringArray[6...17] // Trim string information in Driver's License (as most of the string is nonsensical garbage)
            var licenseInfo = ""
            
            for elem in sublist { // Each element in the Driver's License String is put in an array
                var elem = elem.stringByTrimmingCharactersInSet(ValidCharacterSet.invertedSet)
                licenseInfo += parseDriverLicenseInfo(elem) // Each element is analyzed through the parseDriverLicense function.
            }
            
            /*
            licenseInfo += "\n\nProceed with this client information?"
            let alert: UIAlertController = UIAlertController(title: "Driver's License Scanned", message: licenseInfo, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                println("patient information captured!")
                self.performSegueWithIdentifier("CodeToInfo", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            // PDF 417 Information is displayed in a message box.
            */
            videoPreviewLayer?.borderColor = UIColor.greenColor().CGColor
            lblStatus.text = "PDF417 Code detected: Driver's License"
            self.performSegueWithIdentifier("CodeToInfo", sender: self)
            
        } else {
            patientCodeScanned = false
            videoPreviewLayer?.borderColor = UIColor.redColor().CGColor
            lblStatus.text = "PDF417 Code detected: Invalid Code"
            
            /*
            let codeError: UIAlertController = UIAlertController(title: "PDF417 Error", message: "The PDF416 code scanned has invalid client information.", preferredStyle: UIAlertControllerStyle.Alert)
            codeError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(codeError, animated: true, completion: nil)
            */
        }
    }
    
    func parseDriverLicenseInfo(infoString: String) -> String { // Function to parse each element in the Driver's License
        let licenseIndex: String.Index = advance(infoString.startIndex, 3)
        let licenseString = infoString.substringToIndex(licenseIndex)
        var cutString = infoString.substringFromIndex(licenseIndex)
        var patientInitials: String
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("", forKey: "pMail")
        
        if licenseString == "DCS" { // Code for Last Name on License
            cutString = cutString.substringToIndex(advance(cutString.startIndex, count(cutString) - 1))
            userDefaults.setObject(cutString, forKey: "pLName")
            return "Last Name: \(cutString)\n"
            
        } else if licenseString == "DCT" { // Code for First and Middle Names on License
            if cutString.rangeOfString(",") != nil {
                let nameArray = cutString.componentsSeparatedByString(",")
                var firstName: String = nameArray[0] // First element of array: First Name
                var middleName: String = nameArray[1] // Second element of array: Middle Name
                userDefaults.setObject(firstName, forKey: "pFName")
                userDefaults.setObject(middleName, forKey: "pMName")
                
                return "First Name: \(firstName)\nMiddle Name: \(middleName)\n"
            } else {
                userDefaults.setObject(cutString, forKey: "pFName")
                return "First Name: \(cutString)\n"
            }
        } else if licenseString == "DBB" { // Code for Date of Birth of Patient
            // Have to separate the strings by character for year, month, and day
            let yearIndex: String.Index = advance(infoString.startIndex, 4)
            let yearString = cutString.substringToIndex(yearIndex) // Year String
            
            let startMonthIndex: String.Index = advance(infoString.startIndex, 7)
            let endMonthIndex: String.Index = advance(infoString.startIndex, 9)
            let monthRange = startMonthIndex..<endMonthIndex
            let monthDigits = infoString[monthRange] // Month String
            
            let dayIndex: String.Index = advance(infoString.startIndex, 9)
            let endDayIndex: String.Index = advance(infoString.startIndex, 11)
            let dayRange = dayIndex..<endDayIndex
            let dayDigits = infoString[dayRange] // Day String
            
            let birthDate = yearString + "/" + monthDigits + "/" + dayDigits
            userDefaults.setObject(birthDate, forKey: "pDOB")
            return  "Date of Birth: \(birthDate)\n"
            
        } else if licenseString == "DBC" { // Code for Gender
            if cutString == "1" {
                userDefaults.setObject("Male", forKey: "pGender")
                return  "Gender: Male\n"
            } else {
                userDefaults.setObject("Female", forKey: "pGender")
                return  "Gender: Female\n"
            }
        } else if licenseString == "DAI" { // Code for City (Can be PHU in this case)
            userDefaults.setObject(cutString, forKey: "pPHU")
            return "PHU: \(cutString)\n"
        } else if licenseString == "DBJ" { // Code for Province
            if cutString == "ON" {
                userDefaults.setObject("Ontario", forKey: "pPro")
            }
            
        } else if licenseString == "DAQ" { // Code for License Number (Can be HCN in this case)
            userDefaults.setObject(cutString, forKey: "pHCN")
            return  "License Number: \(cutString)"
        }
        
        let initialIndex: String.Index = advance(infoString.startIndex, 1)
        var firstInitial = userDefaults.stringForKey("pFName")?.substringToIndex(initialIndex)
        
        var lastInitial = userDefaults.stringForKey("pLName")?.substringToIndex(initialIndex)
        let pInitials = firstInitial! + lastInitial!
        userDefaults.setObject(pInitials, forKey: "pInit") // Create initials by getting first character of each name
        userDefaults.synchronize()
        
        return "" // returns string with front three identification characters chopped off
    }
    
    func retrieveJsonFromData(data: NSData) -> NSDictionary { // Now deserialize JSON object into dictionary
        var error: NSError?
        let jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
            options: .AllowFragments,
            error: &error)
        if  error == nil {
            println("Successfully deserialized...")
            if jsonObject is NSDictionary{
                let deserializedDictionary = jsonObject as! NSDictionary
                println("Deserialized JSON Dictionary = \(deserializedDictionary)")
                return deserializedDictionary
            } else {
                /* Some other object was returned. We don't know how to
                deal with this situation because the deserializer only
                returns dictionaries or arrays */
            }
        } else if error != nil {
            println("An error happened while deserializing the JSON data.")
        }
        return NSDictionary()
    }
    
    func qrCodePatientInfo(qrString: String) { // Function to extract patient demographics from QR Code
        if qrString.rangeOfString("application") == nil && qrString.rangeOfString("lastName") != nil && qrString.rangeOfString("firstName") != nil  {
            
            let qrStrCutFirst = (qrString.substringFromIndex(advance(qrString.startIndex,10)))
            let qrStrTrimEnd = qrStrCutFirst.substringToIndex(qrStrCutFirst.endIndex.predecessor())
            patientCodeScanned = true
            lblStatus.text = "Patient QR Code detected"
            
            let patientJSON = (qrString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            let patientDict: NSDictionary = retrieveJsonFromData(patientJSON!) // Use JSON to parse patient code
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(patientDict["firstName"] as! String!, forKey: "pFName")
            userDefaults.setObject(patientDict["lastName"] as! String!, forKey: "pLName")
            userDefaults.setObject(patientDict["middleName"] as! String!, forKey: "pMName")
            userDefaults.setObject(patientDict["initials"] as! String!, forKey: "pInit")
            userDefaults.setObject(patientDict["gender"] as! String!, forKey: "pGender")
            userDefaults.setObject(patientDict["hcn"] as! String!, forKey: "pHCN")
            userDefaults.setObject(patientDict["dob"] as! String!, forKey: "pDOB")
            userDefaults.setObject(patientDict["email"] as! String!, forKey: "pMail")
            userDefaults.setObject(patientDict["phu"] as! String!, forKey: "pPHU")
            userDefaults.synchronize()
            // Gets key-pair values of patient demographics and sets them as String objects to carry to other screens
            
            let fName: String = userDefaults.stringForKey("pFName")!
            let mName: String = userDefaults.stringForKey("pMName")!
            let lName: String = userDefaults.stringForKey("pLName")!
            let pinit: String = userDefaults.stringForKey("pInit")!
            let pGen: String = userDefaults.stringForKey("pGender")!
            let pHCN: String = userDefaults.stringForKey("pHCN")!
            let pDOB: String = userDefaults.stringForKey("pDOB")!
            let pMail: String = userDefaults.stringForKey("pMail")!
            let pPHU: String = userDefaults.stringForKey("pPHU")!
            
            var qrDemographics = "First Name: \(fName)\nMiddle Name: \(mName)\nLast Name: \(lName)\nInitials: \(pinit)\nGender: \(pGen)\nHealth Card Number: \(pHCN)\nDate of Birth: \(pDOB)\n Email: \(pMail)\nPHU: \(pPHU)\n\nProceed with this client information?"
            
            /*
            let qrviewController = UIAlertController(title: "QR Client Information", message: qrDemographics, preferredStyle: UIAlertControllerStyle.Alert)
            qrviewController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                println("patient information captured!")
                self.performSegueWithIdentifier("CodeToInfo", sender: self)
            }))
            qrviewController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(qrviewController, animated: true, completion: nil)
            // Message box displays information encoded within the QR Code
            */
            
            videoPreviewLayer?.borderColor = UIColor.greenColor().CGColor
            lblStatus.text = "QR Code detected: Yellow Card"
            self.performSegueWithIdentifier("CodeToInfo", sender: self)
            
            
        } else { // QR Code scanned is not legitimate information relevant to this app.
            patientCodeScanned = false
            videoPreviewLayer?.borderColor = UIColor.redColor().CGColor
            lblStatus.text = "QR Code detected: Invalid Code"
            
            /*
            let codeError: UIAlertController = UIAlertController(title: "QR Error", message: "The QR code scanned has invalid client information.", preferredStyle: UIAlertControllerStyle.Alert)
            codeError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(codeError, animated: true, completion: nil)
            */
        }
    }
    
    func stopReading () { // Stops the QR Reader camera process
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
        cameraImageView.hidden = false
    }
 }
