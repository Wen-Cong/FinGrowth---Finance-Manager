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
    
    var dbRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        message.text = ""
        
        //Connect with firebase database
        dbRef = Database.database().reference()
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
                
                //Retrive all user data
                self.dbRef.child("users").child(userId!).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let username = value?["username"] as? String ?? ""
                    let dob = value?["dob"] as? String ?? ""
                    let riskProfile = value?["riskProfile"] as? String ?? ""
                    
                    var appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.user = User(username: username, dob: dob, risk: riskProfile)
                    
                    // Retrieve all wallets and transactions
                    var walletList:[Wallet] = []
                    var transactionList:[Transaction] = []
                    
                    // Get wallet data
                    let walletsValue = snapshot.childSnapshot(forPath: "wallets").children.allObjects as! [DataSnapshot]
                    for walletSnapshot in walletsValue {
                        let nsWallet = walletSnapshot.value as? NSDictionary
                        let walletName = nsWallet?["name"] as? String ?? ""
                        let walletBal = nsWallet?["balance"] as? Double ?? 0
                        let walletId = nsWallet?["id"] as? String ?? walletSnapshot.key
                        let walletIcon = nsWallet?["icon"] as? String ?? ""
                        let walletUser = nsWallet?["userId"] as? String ?? userId
                        
                        let wallet = Wallet(walletId: walletId, name: walletName, bal: walletBal, icon: walletIcon, userId: walletUser!)
                        walletList.append(wallet)
                        
                        // Get transaction data
                        let transactionsValue = snapshot.childSnapshot(forPath: "wallets").childSnapshot(forPath: walletId).childSnapshot(forPath: "transactions").children.allObjects as! [DataSnapshot]
                        for transactionSnapshot in transactionsValue {
                            let nsTransaction = transactionSnapshot.value as? NSDictionary
                            let tName = nsTransaction?["name"] as? String ?? ""
                            let tAmt = nsTransaction?["amount"] as? Double ?? 0
                            let tCat = nsTransaction?["category"] as? String ?? "Unspecified Category"
                            let tId = nsTransaction?["id"] as? String ?? ""
                            let tTime = nsTransaction?["time"] as? String ?? "Time Unspecified"
                            let tType = nsTransaction?["type"] as? String ?? ""
                            let tWalletId = nsTransaction?["name"] as? String ?? walletId
                            
                            let transaction = Transaction(id: tId, name: tName, amt: tAmt, time: tTime, cat: tCat, type: tType, walletId: tWalletId)
                            transactionList.append(transaction)
                        }
                    }
                    
                    appDelegate.transactionList = transactionList
                    appDelegate.walletList = walletList
                    print("Data loaded successfully!")
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
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

