//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-01-08.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import AVFoundation // This allows control of the device's camera.
import MobileCoreServices

class VaccineInformationScreen: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var lblStatus: UILabel!

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var initiateButton: UIButton!
    
    let routeList = ["ID: Intradermal", "IM: Intramuscular", "IN: Intranasal", "PO: Oral", "SC: Subcutaneous"]
    let siteList = ["Anterolateral Thigh Lt", "Anterolateral Thigh Rt", "Arm Lt", "Arm Rt", "Deltoid Lt", "Deltoid Rt", "Forearm Lt", "Forearm Rt", "Gluteal Lt", "Gluteal Rt", "Inferior Deltoid Lt", "Inferior Deltoid Rt", "Mouth", "Naris Lt", "Naris Rt", "Other", "Superior Deltoid Lt", "Superior Deltoid Rt", "Unknown"]
    // List for all possible sites and routes for vaccinations

    var isReading = false
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var audioPlayer: AVAudioPlayer?
    var codeFrameView:UIView?
    var blinkStatus = false
    var vaccineCodeScanned = false
    var fullVaccineInformation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad() // Do any additional setup after loading the view, typically from a nib.

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
        self.logoutButton.layer.cornerRadius = 5
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("labelBlinkAnimation"), userInfo: nil, repeats: true)
        
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.lblStatus.text = "Please tap the image to begin scanning."
        videoPreviewLayer?.borderColor = UIColor.lightGrayColor().CGColor
        
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
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
            logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                self.performSegueWithIdentifier("VaccineInformationToLogin", sender: self)}))
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
    
    @IBAction func applicationLogout(sender: UIButton) {
        let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
        logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("VaccineInformationToLogin", sender: self)}))
        self.presentViewController(logoutConfirmation, animated: true, completion: nil)
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
    
    @IBAction func backScreen(sender: UIButton) {
        self.performSegueWithIdentifier("VaccineInfoToPatientVerify", sender: self)
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Right) {
            println("Swipe Right")
            self.performSegueWithIdentifier("VaccineInfoToPatientVerify", sender: self)
        }
    }
    
    @IBAction func startScanning(sender: UIButton) {
        if (isReading == false) {
            self.startReading()
            //initiateButton.hidden = true
            self.lblStatus.text = "Aim the scanner at a vaccine code."
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
        let captureDevice = AVCaptureDevice .defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        if (error != nil) {
            // If any error occurs, log the description of it and discontinue the program.
            println("\(error?.localizedDescription)")
            return false
        }
        
        captureSession = AVCaptureSession() // Initialize the captureSessionObject
        captureSession?.addInput(input as! AVCaptureInput) // Set the input device on the capture session.
        cameraImageView.hidden = true
        
        // Initialize a AVCaptureMetadaOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeDataMatrixCode]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.bounds = cameraImageView.bounds
        videoPreviewLayer?.frame = cameraImageView.layer.frame
        videoPreviewLayer?.cornerRadius = 5
        videoPreviewLayer?.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        videoPreviewLayer?.borderWidth = 2.0
        videoPreviewLayer?.borderColor = UIColor.grayColor().CGColor
        
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
            videoPreviewLayer?.borderColor = UIColor.grayColor().CGColor
            lblStatus.text = "No vaccine code detected."
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            codeFrameView?.frame = barCodeObject.bounds;
        
            if metadataObj.stringValue != nil {
                var qrData = metadataObj.stringValue
                lblStatus.text = "QR Code detected"
                //if vaccine information, pass over the text data to final screen. Still haven't identified how to verify vaccine information.
                qrCodeVaccineInfo(qrData)
            }
        } else if metadataObj.type == AVMetadataObjectTypeDataMatrixCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            codeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                var matrixData = metadataObj.stringValue
                datamatrixVaccine(matrixData)
            }
        }
    }
    
    func qrCodeVaccineInfo(qrString: String) { // Function to extract patient demographics from QR Code
        if qrString.rangeOfString("agent") != nil && qrString.rangeOfString("lotNumber") != nil {
            var snomed = String()
            lblStatus.text = "Vaccine QR Code detected"
            videoPreviewLayer?.borderColor = UIColor.greenColor().CGColor
            
            let vaccineJSON = (qrString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            let vaccineDict: NSDictionary = retrieveJsonFromData(vaccineJSON!)
            
            let agent = vaccineDict["agent"] as! String!
            let lotNumber = vaccineDict["lotNumber"] as! String!
            let manufacturer = vaccineDict["manufacture"] as! String!
            let gtin = vaccineDict["gtin"] as! String!
            
            let route = vaccineDict["route"] as! String!
            let expiryDate = vaccineDict["expiryDate"] as! String!
            
            let brand = vaccineDict["brand"] as! String!
            let doseSize = vaccineDict["doseSize"] as! String!
            let antigen = vaccineDict["antigen"] as! String!
            let disease = vaccineDict["disease"] as! String!
            
            if qrString.rangeOfString("Snomed") != nil {
                snomed = vaccineDict["Snomed"] as! String!
            } else {
                snomed = snomedConvert(agent)
            }
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(snomed, forKey: "vaccSnomed")
            
            userDefaults.setObject(agent, forKey: "agent")
            userDefaults.setObject(lotNumber, forKey: "productLotNumber")
            userDefaults.setObject(manufacturer, forKey: "manufacture")
            userDefaults.setObject(gtin, forKey: "productGtin")
            userDefaults.setObject(route, forKey: "route")
            userDefaults.setObject(expiryDate, forKey: "productExpiryDate")
            
            userDefaults.setObject(brand, forKey: "brand")
            userDefaults.setObject(doseSize, forKey: "doseSize")
            userDefaults.setObject(antigen, forKey: "antigen")
            userDefaults.setObject(disease, forKey: "disease")
            
            userDefaults.setObject("QR", forKey: "vaccineInfoType")
            userDefaults.synchronize()
            
            fullVaccineInformation = "Agent: \(agent)\nLot Number: \(lotNumber)\nManufacture: \(manufacturer)\nGtin: \(gtin)\n\nWould you like to use this vaccine data?"
            
            /*
            let qrviewController = UIAlertController(title: "QR Vaccine Information", message: fullVaccineInformation, preferredStyle: UIAlertControllerStyle.Alert)
            qrviewController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                println("Vaccine information captured!")
                self.performSegueWithIdentifier("VaccineInfoToVerify", sender: self)
            })) // Insert respective segue here
            qrviewController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(qrviewController, animated: true, completion: nil)
            */
            
            
            vaccineCodeScanned = true
            self.performSegueWithIdentifier("VaccineInfoToVerify", sender: self)
            
        } else { // QR Code is not legitimate information relevant to this app.
            videoPreviewLayer?.borderColor = UIColor.redColor().CGColor
            lblStatus.text = "Invalid QR Code detected"
        }
    }
    
    func snomedConvert(agentName: String) -> String {
        let agentList: [String] = ["HA","HB-unspecified","Chol","inf-unspecified","D-Hib","MMR","Td","Var","LYM","IPV","Pneu-C-7","T","Hib","HAHB","Inf","HB","HB (dialysis)","MMR-Var","DTaP-IPV-Hib","Tdap-IPV","DTaP-IPV","HPV-4","DTaP-HB-IPV-Hib","Men-C-C","M","R","men-ACYW135 unspecified","Pneu-C-13","Men-C-ACYW135","T-IPV","Men-C"]
        let snomedList: [String] = ["14745005","34689006","35736007","46233009","48028008","61153008","59999009","108729007","116083002","125688000","125714002","333621002","333680004","333702001","7691000087100","8771000087109","8781000087106","419550004","7931000087106","7891000087104","7881000087101","7801000087108","7731000087108","359068008","386012008","386013003","420261000","448964007","7121000087107","7751000087104","8231000087103"]
        
        let agentIndex = find(agentList, agentName)
        if agentIndex != nil {
            return snomedList[agentIndex!]
        } else {
            return ""
        }
    }
    
    func datamatrixVaccine(scannedMatrix: String) {
        // Hardcoded vaccines in Swift
        println(scannedMatrix)
        var vaccineList: Array = [["gtin":"00697177004094","Lot Number":"C4380AA","Expiry Date":"2013-06-30",
            "Manufacture":"Sanofi Pasteur Limited",
            "Brand":"VAXIGRIP",
            "Route":"IH",
            "Agent":"Inf",
            "Dose Size":"0.5 ml",
            "Antigen":"Influenza (Inf)",
            "Disease":"Influenza",
            "Vaccine Description":"Inactivated Influenza Vaccine Trivalent Types A and B (Split Virion)",
            "Snowmed":"7691000087100"]]
        vaccineList.append(["gtin":"00697177004971","Lot Number":"C4636AA","Expiry Date":"2016-12-31","Manufacture": "Sanofi Pasteur Limited","Brand":"Tubersol","Route":"ID","Agent":"TB","Dose Size":"0.1 ml","Antigen":"Tuberculin (TB)","Disease":"Tuberculosis","Vaccine Description":"Tuberculin Purified Protein Derivative (Mantoux)","Snowmed":"333699008"])
        
        vaccineList.append(["gtin":"0069717700471117","Lot Number":"C3919AA","Expiry Date":"2013-11-00","Manufacture":"Sanofi Pasteur Limited","Brand":"Adacel","Route":"IH","Agent":"Tdap","Dose Size":"0.5 ml","Antigen":"Tetanus (T), Diphtheria (d), Pertussis (p)","Disease":"Tetanus, Diphtheria, Pertussis","Vaccine Description":"Tetanus Toxoid, Reduced Diphtheria. Toxoid and Acellular Pertussis Vaccine Adsorbed.","Snowmed":"7851000087109"])
        vaccineList.append(["gtin":"00697177004711","Lot Number":"C4248AA","Expiry Date":"2014-12-31","Manufacture": "Sanofi Pasteur Limited","Brand":"Adacel","Route":"IH","Agent":"Tdap","Dose Size":"0.5 ml","Antigen":"Tetanus (T), Diphtheria (d), Pertussis (p)","Disease":"Tetanus, Diphtheria, Pertussis","Vaccine Description":"Tetanus Toxoid, Reduced Diphtheria. Toxoid and Acellular Pertussis Vaccine Adsorbed.","Snowmed":"7851000087109"])
        vaccineList.append(["gtin":"00697177004933","Lot Number":"U4608AE","Expiry Date":"2014-12-17","Manufacture": "Sanofi Pasteur Limited","Brand":"Menactra","Route":"IH","Agent":"MEN-ACYW135","Dose Size":"0.5 ml","Antigen":"Meningococcal (Groups A, C, Y and W-135)","Disease":"Menigococcal, Diphtheria","Vaccine Description":"Meningococcal, Polysaccharide Diphtheria Toxoid Conjugate Vaccine.","Snowmed":"420261000"])
        vaccineList.append(["gtin":"00697177004674","Lot Number":"C4599AA","Expiry Date":"2016-08-17","Manufacture": "Sanofi Pasteur Limited","Brand":"Pediacel","Route":"IM","Agent":"DTaP-IPV-Hib","Dose Size":"0.5 ml","Antigen":"Tetanus (T), Diphtheria (d), Pertussis (p), Poliomyelitis (IPV), Haemophilus b","Disease":"Tetanus, Diphtheria, Pertussis, Polio, Haemophilus b","Vaccine Description":"Tetanus Toxoid, Diphtheria. Toxoid and Acellular Pertussis Vaccine Adsorbed Combined with Inactivated Poliomyelitis Vaccine and Haemophilius b Conjugate Vaccine.","Snowmed":"7931000087106"])
        
        /*
        vaccineList.append(["gtin":"00697177004094","Lot Number":"C4381AA","Expiry Date":"2013-06-30","Manufacture":"Sanofi Pasteur Limited","Brand":"VAXIGRIP","Route":"IH","Agent":"Inf","Dose Size":"0.5 ml","Antigen":"Influenza (Inf)","Disease":"Influenza","Vaccine Description":"Inactivated Influenza Vaccine Trivalent Types A and B (Split Virion)","Snowmed":"7691000087100"])
        vaccineList.append(["gtin":"00697177004094","Lot Number":"C4386AA","Expiry Date":"2013-06-30","Manufacture":"Sanofi Pasteur Limited","Brand":"VAXIGRIP","Route":"IH","Agent":"Inf","Dose Size":"0.5 ml","Antigen":"Influenza (Inf)","Disease":"Influenza","Vaccine Description":"Inactivated Influenza Vaccine Trivalent Types A and B (Split Virion)","Snowmed":"7691000087100"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"917759","Expiry Date":"2013-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"918170","Expiry Date":"2013-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"918566","Expiry Date":"2013-09-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"919555","Expiry Date":"2015-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"919567","Expiry Date":"2015-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"920384","Expiry Date":"2015-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"920477","Expiry Date":"2015-08-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"922538","Expiry Date":"2016-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"922677","Expiry Date":"2016-05-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G16722","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G32462","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G36462","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G72982","Expiry Date":"2015-11-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"H68695","Expiry Date":"2016-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"H91651","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"J02468","Expiry Date":"2016-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"J49840","Expiry Date":"2016-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"697177004506","Lot Number":"J8343-2","Expiry Date":"2013-05-31","Manufacture":"Sanofi Pasteur Limited","Brand":"Intanza","Route":"ID","Agent":"Inf","Dose Size":"0.1 ml","Antigen":"Influenza (Inf)","Disease":"Influenza","Vaccine Description":"Influenza Vaccine (Split Virion, Inactivated)","Snowmed":"7691000087100"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"F65384","Expiry Date":"2014-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"F98478","Expiry Date":"2014-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G17982","Expiry Date":"2015-01-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G63331","Expiry Date":"2015-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G71150","Expiry Date":"2015-03-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G83850","Expiry Date":"2015-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G86850","Expiry Date":"2015-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H05004","Expiry Date":"2015-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H09238","Expiry Date":"2015-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H22406","Expiry Date":"2016-02-29","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H22520","Expiry Date":"2016-01-29","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H45629","Expiry Date":"2015-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)","Snowmed":"448964007"])
        */
        
        // 01006971770047111713110010C3919AA
        var gtinDetected: Bool = false
        var lotNumDetected: Bool = false
        var expDateDetected: Bool = false
        
        // First, let's identify the gtin of the GS1
        for eachProduct in vaccineList {
            let productGtin = eachProduct["gtin"] as String!
            let gtinCount = count(productGtin) + 3
            let secondgtinCount = count(productGtin) + 2
            
            let firstscannedgtin = scannedMatrix.substringWithRange(Range<String.Index>(start: advance(scannedMatrix.startIndex, 3), end: advance(scannedMatrix.startIndex, gtinCount)))
            let secondscannedgtin = scannedMatrix.substringWithRange(Range<String.Index>(start: advance(scannedMatrix.startIndex, 2), end: advance(scannedMatrix.startIndex, secondgtinCount)))
            
            println("\(productGtin) and \(firstscannedgtin)") // Loop through each vaccine in the list to match gtin!
            let productLotNumber = eachProduct["Lot Number"] as String!
            let lotNumberCount = count(productLotNumber)
            let scannedLotNumber = scannedMatrix.substringWithRange(Range<String.Index>(start: advance(scannedMatrix.endIndex, -(lotNumberCount)), end: scannedMatrix.endIndex))
            
            let productExpiryDate = eachProduct["Expiry Date"] as String!
            let formattedExpDate = processProductExpiryDate(productExpiryDate)
            
            if (firstscannedgtin == productGtin || secondscannedgtin == productGtin) && scannedLotNumber == productLotNumber { // If the gtin and lot number of the scanned product matches a record in the list, then the expiry date is finaly compared.
                gtinDetected = true
                lotNumDetected = true // These variables are set as true
                
                let dateandlot = scannedMatrix.substringWithRange(Range<String.Index>(start: advance(scannedMatrix.endIndex, -(8 + lotNumberCount)), end: scannedMatrix.endIndex)) // First subtract the gtin and lot number from the matrix to isolate the expiry date.
                
                let scannedDate = dateandlot.substringWithRange(Range<String.Index>(start: dateandlot.startIndex, end: advance(dateandlot.startIndex, 6)))
                var yearAndMonth = dateandlot.substringWithRange(Range<String.Index>(start: dateandlot.startIndex, end: advance(dateandlot.startIndex, 4))) // Of the epiry date, the first four of six digits indicate the year and moth by two digits, respectively.
                let alternateDate = yearAndMonth + "00" // Some expiry dates on the vaccines only have the month and year, therefore not having a specific day. To accomodate that, the alternate version of an expiry date can be month, year, and 00 as day.
                println(alternateDate)
                
                if scannedDate == formattedExpDate || scannedDate == alternateDate { // The scanned matric and vaccine record is a perfect match if the scanned date matches the year, month, and day (if no day is specified on the vaccine)
                    videoPreviewLayer?.borderColor = UIColor.greenColor().CGColor
                    expDateDetected = true
                    vaccineCodeScanned = true
                    
                    let manufacture = eachProduct["Manufacture"] as String!
                    let brand = eachProduct["Brand"] as String!
                    let route = eachProduct["Route"] as String!
                    let agent = eachProduct["Agent"] as String!
                    let doseSize = eachProduct["Dose Size"] as String!
                    let antigen = eachProduct["Antigen"] as String!
                    let disease = eachProduct["Disease"] as String!
                    let vaccineDescription = eachProduct["Vaccine Description"] as String!
                    let snomed = eachProduct["Snomed"] as String!
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(productGtin, forKey: "productGtin")
                    userDefaults.setObject(productLotNumber, forKey: "productLotNumber")
                    userDefaults.setObject(productExpiryDate, forKey: "productExpiryDate")
                    
                    userDefaults.setObject(manufacture, forKey: "manufacture")
                    userDefaults.setObject(brand, forKey: "brand")
                    userDefaults.setObject(route, forKey: "route")
                    userDefaults.setObject(agent, forKey: "agent")
                    userDefaults.setObject(doseSize, forKey: "doseSize")
                    userDefaults.setObject(snomed, forKey: "vaccSnomed")
                    userDefaults.setObject(antigen, forKey: "antigen")
                    userDefaults.setObject(disease, forKey: "disease")
                    userDefaults.setObject(vaccineDescription, forKey: "vaccineDescription")
                    
                    //userDefaults.setObject(snomed, forKey: "vaccSnomed")
                    
                    userDefaults.setObject("dataMatrix", forKey: "vaccineInfoType") // Determines type of info Vaccine info is
                    userDefaults.synchronize()
                    
                    /*
                    let alert: UIAlertController = UIAlertController(title: "Vaccine Code", message: "Gtin Code: \(productGtin)\nProduct Lot Number: \(productLotNumber)\nExpiry Date: \(productExpiryDate)\nManufacture: \(manufacture)\nBrand: \(brand)\nRoute: \(route)\nAgent: \(agent)\nDose Size: \(doseSize)\nAntigen: \(antigen)\nDisease: \(disease)\nVaccine Description: \(vaccineDescription)\nDosage Form: SUSP\nTemperature Control Change: TCREF\n\nWould you like to use this vaccine data?", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                        println("Vaccine information captured!")
                        self.performSegueWithIdentifier("VaccineInfoToVerify", sender: self)
                    })) // Insert respective segue here
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    */
                    
                    lblStatus.text = "Datamatrix Code Detected: Vaccine Information"
                    videoPreviewLayer?.borderColor = UIColor.greenColor().CGColor
                    vaccineCodeScanned = true
                    self.performSegueWithIdentifier("VaccineInfoToVerify", sender: self)
                    
                }
            }
        }
        
        if expDateDetected == false || lotNumDetected == false || gtinDetected == false {
            videoPreviewLayer?.borderColor = UIColor.redColor().CGColor
            lblStatus.text = "Datamatrix Code Detected: Invalid Code"
            
            /*
            let errorAlert: UIAlertController = UIAlertController(title: "Error", message: "The information encoded in the scanned datamatrix do not fit any of the products stored in the database.", preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorAlert, animated: true, completion: nil)
            */
        }
    }
    
    func processProductExpiryDate (productDate: String) -> String {
        let yearStr = productDate.substringWithRange(Range<String.Index>(start: advance(productDate.startIndex, 2), end: advance(productDate.startIndex, 4)))
        let monthStr = productDate.substringWithRange(Range<String.Index>(start: advance(productDate.startIndex, 5), end: advance(productDate.startIndex, 7)))
        let dayStr = productDate.substringWithRange(Range<String.Index>(start: advance(productDate.startIndex, 8), end: productDate.endIndex))
        var formattedDate = yearStr + monthStr + dayStr
        return formattedDate
    }
    
    func JSONParseArray(jsonString: String) -> [AnyObject]{ // Function to parse Json array
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [AnyObject] {
                return array
            }
        }
        return [AnyObject]() }

    func stopReading () { // Stops the QR Reader camera process
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
        cameraImageView.hidden = false
    }

    func retrieveJsonFromData(data: NSData) -> NSDictionary {
        
        /* Now try to deserialize the JSON object into a dictionary */
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
            }
            else {
                /* Some other object was returned. We don't know how to
                deal with this situation because the deserializer only
                returns dictionaries or arrays */
            }
        }
        else if error != nil{
            println("An error happened while deserializing the JSON data.")
        }
        return NSDictionary()
    }
}

