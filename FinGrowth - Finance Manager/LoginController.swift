//
//  LoginController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 14/1/21.
//

import UIKit
import Foundation
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var email_txtfld: UITextField!
    
    @IBOutlet weak var password_txtfld: UITextField!
    
    @IBOutlet weak var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        message.text = ""
        // Do any additional setup after loading the view.
    }

    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func login_btn(_ sender: Any) {
        let email = email_txtfld.text
        let password = password_txtfld.text
        
        //Check for empty fields
        if(email != nil && password != nil){
            //Login with firebase authentication
            Auth.auth().signIn(withEmail: email!, password: password!) { (authResult, error) in
                if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    self.message.text = "System unable to login user"
                  // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                case .userDisabled:
                    self.message.text = "Account has been disabled"
                  // Error: The user account has been disabled by an administrator.
                case .wrongPassword:
                    self.message.text = "Invalid Password"
                  // Error: The password is invalid or the user does not have a password.
                case .invalidEmail:
                    self.message.text = "Invalid Email Address"
                  // Error: Indicates the email address is malformed.
                default:
                    print("Error: \(error.localizedDescription)")
                }
              } else {
                //Show success message
                self.message.textColor = .green
                self.message.text = "User signs in successfully"
                print("User signs in successfully")
                
                let userInfo = Auth.auth().currentUser
                let userId = userInfo?.uid
                
                //Navigate to main sotryboard -- show contents
                let storyboard = UIStoryboard(name: "Content", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Content") as UIViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
              }
            }
        }
        else{
            message.text = "Please enter all fields"
        }
    }
    
}

