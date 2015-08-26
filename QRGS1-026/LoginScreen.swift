//
//  ViewController.swift
//  QRGS1-026
//
//  Created by Angelina Choi on 2015-07-16.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import Foundation

class LoginScreen: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var inputUsername: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputPHU: UITextField!
    
    @IBOutlet weak var loginViewSquare: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phuPicker: UIPickerView! // variable for text fields and logo imageView
    let publicHealthUnitList = ["", "Grey Bruce", "Hamilton", "Toronto", "Niagara", "Peel"] // List of PHUs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputPHU.delegate = self
        phuPicker.delegate = self
        phuPicker.hidden = true // PHU pickerView is hidden.
        self.loginViewSquare.layer.cornerRadius = 5
        self.loginButton.layer.cornerRadius = 5
        self.inputUsername.layer.cornerRadius = 5
        self.inputPassword.layer.cornerRadius = 5
        self.inputPHU.layer.cornerRadius = 5
        self.logoImage.hidden = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1 // returns number of columns in pickerView
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return publicHealthUnitList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return publicHealthUnitList[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        inputPHU.text = publicHealthUnitList[row]
        // Chosen PHU decides which logo to be shown on the screen.
        self.logoImage.hidden = false
        logoImage.backgroundColor = UIColor.lightTextColor()
        
        if inputPHU.text == "Grey Bruce" {
            logoImage.image = UIImage(named: "Grey Bruce Logo.png")!
        } else if inputPHU.text == "Hamilton" {
            logoImage.image = UIImage(named: "Hamilton Logo.png")!
        } else if inputPHU.text == "Toronto" {
            logoImage.image = UIImage(named: "Toronto Logo.png")!
        } else if inputPHU.text == "Niagara" {
            logoImage.image = UIImage(named: "Niagara Logo.png")!
        } else if inputPHU.text == "Peel" {
            logoImage.image = UIImage(named: "Peel Logo.png")!
        } else if inputPHU.text == "" { // If no PHU is selected, colours and logo are defaulted
            logoImage.image = UIImage(named: "Ontario Logo.png")!
        }
        phuPicker.hidden = true // After the PHU is selected, pickerView is hidden unless PHU text field is selected again.
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool { // When text field is edited, PHUpicker is hidden.
        self.view.endEditing(true)
        phuPicker.hidden = false
        return false
    }
    
    @IBAction func userLogIn(sender: AnyObject) { // User tries to log in
        //Check if user name and PIN are valid. If either is invalid, send an error message.
        
        if inputPHU.text == "" || inputUsername.text == "" || inputPassword.text == "" {
            
            let invalidDataAlert: UIAlertController = UIAlertController(title: "Error", message: "Please fill all the fields appropriately.", preferredStyle: UIAlertControllerStyle.Alert)
            invalidDataAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(invalidDataAlert, animated: true, completion: nil)
            // Message box alerts user that all fields need to be filled before transitioning.
            
        } else {
            // Insert code here that verifies username and password and allow to transition to the next screen.
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(inputPHU.text, forKey: "selectedPublicHealthUnit")
            userDefaults.setObject(inputUsername.text, forKey: "providerUsername")
            userDefaults.setObject("345345345345", forKey: "providerID")
            
            // Carry PHU value to other screens. Provider ID is dummy data. Implements for ID still in development.
            userDefaults.synchronize() // Carry Public Health Unit information
            
            self.performSegueWithIdentifier("LoginToWelcome", sender: self)
        }
    }
    
}
