//
//  SignupController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 26/1/21.
//

import Foundation
import UIKit
import Firebase

class SignupController: UIViewController {

    @IBOutlet weak var username_txtfld: UITextField!
    
    @IBOutlet weak var dob_txtfld: UITextField!
    
    @IBOutlet weak var email_txtfld: UITextField!
    
    @IBOutlet weak var password_txtfld: UITextField!
    
    @IBOutlet weak var cfmPassword_txtfld: UITextField!
    
    private var datePicker: UIDatePicker?
    
    @IBOutlet weak var message: UILabel!
    
    var dbRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        message.text = ""
        
        //add date picker into input field
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(SignupController.dateChanged(datePicker:)), for: .valueChanged)
        
        //Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignupController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        dob_txtfld.inputView = datePicker
        
        //Connect with firebase database
        dbRef = Database.database().reference()
    }
    
    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dob_txtfld.text = formatter.string(from: datePicker.date)
    }
    
    
    @IBAction func Signup_btn(_ sender: Any) {
        let username = username_txtfld.text
        let dob = dob_txtfld.text
        let email = email_txtfld.text
        let pw = password_txtfld.text
        let cfm_pw = cfmPassword_txtfld.text
        
        //Ensure all fields are filled in
        if (username != nil && dob != nil && email != nil && pw != nil && cfm_pw != nil){
            //Check if passwords matched
            if(pw == cfm_pw){
                //Create user account
                Auth.auth().createUser(withEmail: email!, password: pw!) { authResult, error in
                    if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        self.message.text = "System unable to create account"
                      // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
                    case .emailAlreadyInUse:
                        self.message.text = "Email address is already used by another account"
                      // Error: The email address is already in use by another account.
                    case .invalidEmail:
                        self.message.text = "Invalid Email Address"
                      // Error: The email address is badly formatted.
                    case .weakPassword:
                        self.message.text = "Password must be 6 characters long or more"
                      // Error: The password must be 6 characters long or more.
                    default:
                        print("Error: \(error.localizedDescription)")
                    }
                  }else {
                    let newUserInfo = Auth.auth().currentUser
                    let userId = newUserInfo?.uid
                    
                    //Add new user to database
                    let user:NSDictionary = ["username": "\(username!)", "dob": "\(dob!)", "riskProfile": "noProfile"]
                    self.dbRef.child("users").child("\(userId!)").setValue(user)
                    
                    //Initialize wallet
                    let walletRef = self.dbRef.child("users").child("\(userId!)").child("wallets").childByAutoId()
                    let walletKey = walletRef.key
                    
                    let wallet: NSDictionary = ["id": "\(walletKey!)", "name": "Cash Wallet", "balance": 0, "icon": "Cash", "userId": "\(userId!)"]
                    walletRef.setValue(wallet)
                    
                    //Initialize transaction
                    let tRef = self.dbRef.child("users").child("\(userId!)").child("wallets")
                        .child("\(walletKey!)").child("transactions").childByAutoId()
                    let tKey = tRef.key
                    
                    let transaction: NSDictionary = ["id": "\(tKey!)", "name": "Create Wallet", "amount": 0, "time": "\(Date.init())", "category": "Others", "type": "Initialization", "walletId": "\(walletKey!)"]
                    tRef.setValue(transaction)
                    
                    self.message.textColor = .green
                    self.message.text = "User signs up successfully"
                  }
                }
            }
            else{
                message.text = "Password not matched!"
            }
        }
        else{
            message.text = "Please enter all fields"
        }
    }
    

}
