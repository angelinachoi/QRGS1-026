//
//  PatientInformationScreen.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-07-21.

import UIKit
import AVFoundation
import MobileCoreServices

class PatientVerificationScreen: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource  {
    //, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource
    // segue VerifyClientToVaccine

    @IBOutlet weak var clientInfoView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var middleName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var initials: UITextField!
    @IBOutlet weak var dateOfBirth: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var healthCardNumber: UITextField!
    @IBOutlet weak var phu: UITextField!
    @IBOutlet weak var province: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var genderPicker: UIPickerView! // The yellow one
    @IBOutlet weak var phuPicker: UIPickerView! // The red one
    @IBOutlet weak var provincePicker: UIPickerView! // The blue one
    
    @IBOutlet weak var editBlocker: UIView!
    let nonCharacterSet: NSCharacterSet = NSCharacterSet(charactersInString: "1234567890_+=!@#$%^&*(),./;~`[]{}|<>?:")
    let hcnNumberSet: NSCharacterSet = NSCharacterSet(charactersInString: "1234567890")
    
    let genderList = ["","Male", "Female", "Other"]
    let provinceList = ["", "British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Quebec", "New Brunswick", "Nova Scotia", "Prince Edward Island", "Newfoundland & Labrador"]
    let publicHealthUnitList = ["", "Grey Bruce", "Niagara", "Toronto", "Peel", "Hamilton"]
    
    var editText = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
        editText = false
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        genderPicker.hidden = true
        provincePicker.hidden = true
        phuPicker.hidden = true
        
        genderPicker.tag = 0
        provincePicker.tag = 1
        phuPicker.tag = 2 // Distinct tags for each pickerview
        
        genderPicker.delegate = self
        provincePicker.delegate = self
        phuPicker.delegate = self
        
        gender.delegate = self
        province.delegate = self
        phu.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        cancelButton.layer.cornerRadius = 5.0
        verifyButton.layer.cornerRadius = 5.0
        clientInfoView.layer.cornerRadius = 5.0
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        firstName.text = userDefaults.stringForKey("pFName")
        middleName.text = userDefaults.stringForKey("pMName")
        lastName.text = userDefaults.stringForKey("pLName")
        initials.text = userDefaults.stringForKey("pInit")
        gender.text = userDefaults.stringForKey("pGender")
        healthCardNumber.text = userDefaults.stringForKey("pHCN")
        dateOfBirth.text = userDefaults.stringForKey("pDOB")
        email.text = userDefaults.stringForKey("pMail")
        phu.text = userDefaults.stringForKey("pPHU") // carry info from previous screen
        
        province.text = "Ontario"
        lastName.autocapitalizationType = UITextAutocapitalizationType.Words
        firstName.autocapitalizationType = UITextAutocapitalizationType.Words // Auto-capitalize
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func allowTextEdit(sender: UIButton) {
        editBlocker.hidden = true
        firstName.becomeFirstResponder()
    }
    
    @IBAction func BackToScan(sender: UIButton) {
        self.performSegueWithIdentifier("BackToPatientScanning", sender: self)
    }

    @IBAction func applicationLogout(sender: UIButton) {
        let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
        logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("PatientVerifyToLogin", sender: self)}))
        self.presentViewController(logoutConfirmation, animated: true, completion: nil)
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            println("Swipe Left")
            // self.performSegueWithIdentifier("WelcomeToPatient", sender: self)
        } else if (sender.direction == .Right) {
            println("Swipe Right")
            self.performSegueWithIdentifier("BackToPatientScanning", sender: self)
        }
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            let logoutConfirmation: UIAlertController = UIAlertController(title: "Logout Confirm", message: "This application is now logging out.", preferredStyle: UIAlertControllerStyle.Alert)
            logoutConfirmation.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                self.performSegueWithIdentifier("PatientVerifyToLogin", sender: self)}))
            self.presentViewController(logoutConfirmation, animated: true, completion: nil)
            
            println("Device is face down")
        default:
            println("Device is not face down")
        }
    }
    
    @IBAction func cancelPatientFields(sender: UIButton) {
        let segueAlert: UIAlertController = UIAlertController(title: "Cancel Verification", message: "By cancelling, you will return to the previous screen to scan new client data.\nContinue?", preferredStyle: UIAlertControllerStyle.Alert)
        segueAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("BackToPatientScanning", sender: self)
        }))
        segueAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(segueAlert, animated: true, completion: nil)
    }

    @IBAction func dobFieldSelected(sender: UITextField) {
        phuPicker.hidden = true
        genderPicker.hidden = true
        provincePicker.hidden = true
        var datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.maximumDate = NSDate() // User date of birth cannot exceed current date.
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged) // Use UIDatePicker to input date of birth of user information.
    }
    @IBAction func dobEnd(sender: AnyObject) {
        dateOfBirth.resignFirstResponder()
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateOfBirth.text = dateFormatter.stringFromDate(sender.date)
        // This function formats the date into YYYY-MM-DD for proper format to be sent as a request to URL.
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return genderList[row]
        } else if pickerView.tag == 1 {
            return provinceList[row]
        } else if pickerView.tag == 2 {
            return publicHealthUnitList[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            gender.text = genderList[row]
            genderPicker.hidden = true
        } else if pickerView.tag == 1 {
            province.text = provinceList[row]
            provincePicker.hidden = true
        } else if pickerView.tag == 2 {
            phu.text = publicHealthUnitList[row]
            phuPicker.hidden = true
        }
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.view.endEditing(true) // Hides standard keyboard
        dateOfBirth.resignFirstResponder() // Ensures date keyboard disappears when gender field is selected.
        if textField == gender {
            genderPicker.hidden = false
        } else if textField == province {
            provincePicker.hidden = false
            genderPicker.hidden = true
            phuPicker.hidden = true
        } else if textField == phu {
            phuPicker.hidden = false
            genderPicker.hidden = true
            provincePicker.hidden = true
        }
        return false
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return genderList.count
        } else if pickerView.tag == 1 {
            return provinceList.count
        } else if pickerView.tag == 2 {
            return publicHealthUnitList.count
        }
        return 1
    }
    
    func isValidEmail(emailStr: String) -> Bool { // function to verify user's email address
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" // Valid Regex solution for email
        let range = emailStr.rangeOfString(emailRegEx, options: .RegularExpressionSearch)
        let result = range != nil ? true: false // Checks whether email address is valid.
        return result
    }
    
    func allFieldsValid() -> Bool {
        if (gender.text == "") || (phu.text == "") || (province.text == "") || (dateOfBirth.text == "") || (healthCardNumber.text == "") || (firstName.text == "") || (lastName.text == "") || (initials.text == "") {
            return false
        } else if count(initials.text) > 3 || initials.text.rangeOfCharacterFromSet(nonCharacterSet) != nil {
            println("here")
            return false
        } else if (firstName.text).rangeOfCharacterFromSet(nonCharacterSet) != nil || (lastName.text).rangeOfCharacterFromSet(nonCharacterSet) != nil || (middleName.text).rangeOfCharacterFromSet(nonCharacterSet) != nil {
            println("there")
            return false
        }
        return isValidEmail(email.text)
    }

    @IBAction func verifyAllPatientFields(sender: UIButton) {
        if allFieldsValid() == false {
            println("No")
            let rejectionAlert: UIAlertController = UIAlertController(title: "Submission Denied", message: "All fields must be properly filled with valid information.", preferredStyle: UIAlertControllerStyle.Alert)
            rejectionAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(rejectionAlert, animated: true, completion: nil)
        } else {
            println("Yes")
            let screenAlert: UIAlertController = UIAlertController(title: "Confirm Data", message: "Continue?", preferredStyle: UIAlertControllerStyle.Alert)
            screenAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(self.firstName.text, forKey: "pFName")
                userDefaults.setObject(self.lastName.text, forKey: "pLName")
                userDefaults.setObject(self.middleName.text, forKey: "pMName")
                
                userDefaults.setObject(self.initials.text, forKey: "pInit")
                userDefaults.setObject(self.healthCardNumber.text, forKey: "pHCN")
                userDefaults.setObject(self.gender.text, forKey: "pGender")

                userDefaults.setObject(self.dateOfBirth.text, forKey: "pDOB")
                userDefaults.setObject(self.email.text, forKey: "pMail")
                userDefaults.setObject(self.province.text, forKey: "pPro")
                userDefaults.setObject(self.phu.text, forKey: "pPHU")
                userDefaults.synchronize()
                
                self.performSegueWithIdentifier("VerifyClientToVaccine", sender: self)
            }))
            screenAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(screenAlert, animated: true, completion: nil)
        }
    }
 }
