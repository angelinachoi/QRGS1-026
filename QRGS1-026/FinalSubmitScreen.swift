//
//  IHRSubmit.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-01-14.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class FinalSubmitScreen: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var receiptText: UITextView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendDataButton: UIButton!
    @IBOutlet weak var sendReceiptButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var ihrEmailReceiptSent = Bool()
    
    var firstName = String()
    var middleName = String()
    var lastName = String()
    var initials = String()
    var gender = String()
    var healthCardNumber = String()
    var dateOfBirth = String()
    var email = String()
    var phu = String()
    var province = String()
    
    var vaccineType = String()
    var gtin = String()
    var agent = String()
    var lotNumber = String()
    var manufacture = String()
    var expDate = String()
    var brand = String()
    var route = String()
    var doseSize = String()
    var antigen = String()
    var disease = String()
    var snomed = String()
    
    var dateinformat = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)

        ihrEmailReceiptSent = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // segue SubmitScreenToLogin
        // segue SubmitScreenToWelcome
        // segue SubmitScreenToVaccVerify
    }
    override func viewWillAppear(animated: Bool) {
        self.logoutButton.layer.cornerRadius = 5
        self.sendDataButton.layer.cornerRadius = 5
        self.cancelButton.layer.cornerRadius = 5
        self.sendReceiptButton.layer.cornerRadius = 5
        self.receiptText.layer.cornerRadius = 5
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateinformat = dateFormatter.stringFromDate(date)

        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        firstName = userDefaults.stringForKey("pFName") as String!
        middleName = userDefaults.stringForKey("pMName") as String!
        lastName = userDefaults.stringForKey("pLName") as String!
        initials = userDefaults.stringForKey("pInit") as String!
        gender = userDefaults.stringForKey("pGender") as String!
        healthCardNumber = userDefaults.stringForKey("pHCN") as String!
        dateOfBirth = userDefaults.stringForKey("pDOB") as String!
        email = userDefaults.stringForKey("pMail") as String!
        phu = userDefaults.stringForKey("pPHU") as String!
        province = userDefaults.stringForKey("pPro") as String!
        
        snomed = userDefaults.stringForKey("vaccSnomed") as String!
        
        var patientDemographics = "First Name: \(firstName)\nMiddle Name: \(middleName)\nLast Name: \(lastName)\nInitials: \(initials)\nGender: \(gender)\nHealth Card Number: \(healthCardNumber)\nDate of Birth: \(dateOfBirth)\nEmail: \(email)\nPHU: \(phu)\nProvince: \(province)\n\n"
        var vaccineDemographics = String()
        gtin = userDefaults.stringForKey("productGtin") as String!
        agent = userDefaults.stringForKey("agent") as String!
        lotNumber = userDefaults.stringForKey("productLotNumber") as String!
        manufacture = userDefaults.stringForKey("manufacture") as String!
        
        expDate = userDefaults.stringForKey("productExpiryDate") as String!
        brand = userDefaults.stringForKey("brand") as String!
        route = userDefaults.stringForKey("route") as String!
        doseSize = userDefaults.stringForKey("doseSize") as String!
        antigen = userDefaults.stringForKey("antigen") as String!
        disease = userDefaults.stringForKey("disease") as String!
        
        vaccineType = userDefaults.stringForKey("vaccineInfoType") as String!
        
        if vaccineType == "QR" {
            vaccineDemographics = "Date immmunized: \(dateinformat)\nVaccine Code Type: QR\nGtin: \(gtin)\nAgent: \(agent)\nLot Number: \(lotNumber)\nManufacture: \(manufacture)\n\n"
            
        } else if vaccineType == "dataMatrix" {
            vaccineDemographics = "Date immmunized: \(dateinformat)\nVaccine Code Type: Datamatrix\nGtin: \(gtin)\nAgent: \(agent)\nLot Number: \(lotNumber)\nManufacture: \(manufacture)\nExpiration Date: \(expDate)\nBrand: \(brand)\nRoute: \(route)\nDose Size: \(doseSize)\nAntigen: \(antigen)\nDisease: \(disease)\n\n"
        }
        receiptText.text = "Full IHR Receipt Overview\n\nPatient Demographics\n" + patientDemographics + "Vaccine Details\n" + vaccineDemographics
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            self.performSegueWithIdentifier("SubmitScreenToLogin", sender: self)
            println("Device is face down")
        default:
            println("Device is not face down")
        }
    }

    @IBAction func manualLogout(sender: UIButton) {
        let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
        logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("SubmitScreenToLogin", sender: self)}))
        self.presentViewController(logoutConfirmation, animated: true, completion: nil)
    }
    @IBAction func cancelAll(sender: UIButton) { // If user wants to botch everything, return to main screen
        
        let screenAlert: UIAlertController = UIAlertController(title: "Back to Main Screen", message: "Once you go to the beginning, all information will be cleared. Continue?", preferredStyle: UIAlertControllerStyle.Alert)
        screenAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("SubmitScreenToWelcome", sender: self)
        }))
        screenAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(screenAlert, animated: true, completion: nil)
    }
    
    @IBAction func submitInfo(sender: UIButton) {
        if receiptText.text != "" {
            // self.postParameters("http://pportal.mybluemix.net/IHRreader") // Send data to server
            // self.postJSON("http://libertyjavaopal2.mybluemix.net/rest/api/client")
            
            // self.postJSON("http://192.168.2.11:8080/submit/qr/demo")
            self.postJSON("http://ihrsubmit.mybluemix.net/submit/qr/demo")

            
            cancelButton.setTitle("Back to Main", forState: UIControlState.Normal)
            
        } else {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "No valid code has been translated.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendEmailReceipt(sender: UIButton) {
        if ihrEmailReceiptSent == false {
            self.sendEmail()
        } else {
            let emailAlreadySent = UIAlertController(title: "Email Already Sent", message: "You have already sent an IHR receipt to this patient.", preferredStyle: UIAlertControllerStyle.Alert)
            emailAlreadySent.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emailAlreadySent, animated: true, completion: nil)
        }
    }
    
    func sendEmail() { // Function to send email for digital receipt
        var picker: MFMailComposeViewController = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Digital Receipt of Patient: \(String(firstName)) \(String(lastName))") // Subject of Email
        // Body of Email, outlining the information of patient and vaccinations administered
        let emailMessageBodyPart1 = "Medical Receipt of Patient \(String(firstName)) \(lastName)<br><br>First Name: \(String(firstName))<br>Last Name: \(String(lastName))<br>Initial: \(String(initials))<br>Gender: \(String(gender))<br>"
        let emailMessageBodyPart2 = "<br>Health Card Number: \(String(healthCardNumber))<br>Date of Birth: \(String(dateOfBirth))<br>Province: \(String(province))<br>Public Health Unit: \(phu)<br>"
        let emailMessageBodyPart3 = "<br>Vaccine Agent:\(agent)<br>Lot Number: \(lotNumber)<br>Manufacture: \(manufacture)<br>Gtin: \(gtin)<br><br>Please keep this email as a digital receipt of the immunization of \(String(firstName)) \(lastName) on \(dateinformat).<br><br>Sincerely,<br>Your PHU"
        let emailBody = emailMessageBodyPart1 + emailMessageBodyPart2 + emailMessageBodyPart3
        picker.setMessageBody(emailBody, isHTML: true)
        picker.setToRecipients(["\(String(email))"])
        
        presentViewController(picker, animated: true, completion: nil)
        ihrEmailReceiptSent = true
        cancelButton.setTitle("Back to Main", forState: UIControlState.Normal)
    }
    
    //MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            NSLog("Mail cancelled")
        case MFMailComposeResultSaved.value:
            NSLog("Mail saved")
        case MFMailComposeResultSent.value:
            NSLog("Mail sent")
        case MFMailComposeResultFailed.value:
            NSLog("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postJSON(url: String) { // Send POST requesnt using JSON transmission
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let date = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        var timeinformat: String = timeFormatter.stringFromDate(date)
        
        var patientParams: [NSString : AnyObject] = ["firstname": "\(firstName)",
            "lastname": "\(lastName)",
            "initials": "\(initials)",
            "middlename": "\(middleName)",
            "gender": "\(gender)",
            "hcn": "\(healthCardNumber)",
            "dob": "\(dateOfBirth)",
            "email": "\(email)",
            "phu":"\(phu)"] as Dictionary
        
        var vaccineParams: [NSString : AnyObject] = ["agent": agent,
            "lotNumber": lotNumber,
            "manufacture": manufacture,
            "gtin": gtin,
            "snowmed": snomed
        ] as Dictionary
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let selectedPHU = userDefaults.stringForKey("selectedPublicHealthUnit")
        let providerUsername = userDefaults.stringForKey("providerUsername")
        

        var providerParams = ["providerUserName": providerUsername,
            "providerID": "0000000000",
            "selectedPHU": selectedPHU]

        
        /*
        var mainParams:[NSString : AnyObject] = ["patient": patientParams,
            "vaccine": vaccineParams,
            "date": dateinformat
        ]
        */
        
        var mainParams:[NSString : AnyObject] = ["application": "QR-ME v1.0",
            "timestamp": timeinformat,
            "date": dateinformat,
            "patient": patientParams,
            "vaccine": vaccineParams
            ]

        var err: NSError?
        println(mainParams)
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(mainParams, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let jsonData = NSJSONSerialization.dataWithJSONObject(mainParams, options: .PrettyPrinted, error: &err)
        if let data = jsonData {
            if data.length > 0 && err == nil {
                println("Successfully serialized the dictionary into data")
                
                let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("JSON String = \(jsonString)")
            } else if data.length == 0 && err == nil {
                println("No data was returned after serialization")
            } else if err != nil {
                println("Ann error happened = \(err)")
            }
        }
        println("test")
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err)
            /*
            if ihrEmailReceiptSent == false {
            let emailOptional: UIAlertController = UIAlertController(title: "Digital Receipt", message: "Would you like to send this information through client's email as a digital receipt?", preferredStyle: UIAlertControllerStyle.Alert)
            emailOptional.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.sendEmail() // Function to send email to patient's email address
            self.performSegueWithIdentifier("SubmitScreenToWelcome", sender: self)}))
            emailOptional.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("SubmitScreenToWelcome", sender: self)}))
            self.presentViewController(emailOptional, animated: true, completion: nil)
            }
            */
            let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("JSON String = \(jsonString)")
            
            if (err != nil) { // Did the JSONOBjectData constructor return an error?
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                let errorAlert = UIAlertController(title: "Error: Data could not be sent.", message: "Application could not send the immunization information.\n\n\(jsonStr)", preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            }
            else { // The JSONObjectWithData constructor didn't return an error.
                // Should still check to ensure that json has a value using optional binding.
                if let parseJSON: AnyObject = json {
                    // The parsedJSON is here, let's get the value for success out of it.
                    var success = parseJSON["success"] as? Int
                    println("Success: \(success)")
                    let successAlert = UIAlertController(title: "Success", message: "Data was successfully sent. Application will now go to main screen so another immunization can be recorded.", preferredStyle: UIAlertControllerStyle.Alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                        if self.ihrEmailReceiptSent == false {
                            let emailOptional: UIAlertController = UIAlertController(title: "Digital Receipt", message: "Would you like to send this information through client's email as a digital receipt?", preferredStyle: UIAlertControllerStyle.Alert)
                            emailOptional.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                                self.sendEmail() // Function to send email to patient's email address
                                self.performSegueWithIdentifier("SubmitScreenToWelcome", sender: self)}))
                            emailOptional.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                                self.performSegueWithIdentifier("SubmitScreenToWelcome", sender: self)}))
                            self.presentViewController(emailOptional, animated: true, completion: nil)
                        }
                    }))
                    self.presentViewController(successAlert, animated: true, completion: nil)
                }
                else {
                    // json object was nil, something went wrong. Maybe server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON. Maybe server is down or something: \(jsonStr)")
                    let errorAlert = UIAlertController(title: "Error: Data could not be sent.", message: "Application could not send the immunization information.\n\n\(jsonStr)", preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        })
        task.resume()
    }
    
    func postParameters(url: String) { // Send POST request using parameters
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST" // Confirm type of request: POST
        
        let qrCodeID: Int = 1234567890 // QR Code ID not in yet. Using dummy ID for now.
        var bodyData = "First+Name=\(String(firstName))&Last+Name=\(String(lastName))&Middle+Name=\(middleName)&Initial=\(String(initials))&Gender=\(gender)&Date+Of+Birth=\(dateOfBirth)&Health+Card_Number=\(healthCardNumber)&Email=\(email)&Province=\(province)&Public+Health+Unit=\(phu)"
        // data of the fields to put in request.
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response: NSURLResponse!, data: NSData!, error: NSError!) in
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            }
    }

}