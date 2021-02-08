//
//  AddWalletController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 29/1/21.
//

import Foundation
import UIKit
import QuartzCore
import Firebase

class AddWalletController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var formView: UIView!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var nameFld: UITextField!
    
    @IBOutlet weak var balFld: UITextField!
    
    @IBOutlet weak var iconPicker: UIPickerView!
    
    @IBOutlet weak var iconPreviewImage: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var selectedicon: String = "NoIcon"
    var iconList:[String] = ["Cash", "Card", "Money Bag", "Savings", "Safe"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init design layout
        applyCardViewStyle(view: formView)
        nameFld.layer.borderColor = UIColor.gray.cgColor
        nameFld.layer.borderWidth = 1.0
        nameFld.layer.cornerRadius = 10
        balFld.layer.borderColor = UIColor.gray.cgColor
        balFld.layer.borderWidth = 1.0
        balFld.layer.cornerRadius = 10
        addBtn.layer.cornerRadius = 22
        
        iconPicker.delegate = self
        
        //Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddWalletController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageLabel.text = ""
    }
    
    // Add border, shadow and corner design to view
    func applyCardViewStyle(view: UIView) {
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = true;
        view.layer.borderColor = UIColor(red: 0.55, green: 0.33, blue: 0.83, alpha: 1.00).cgColor
        view.layer.borderWidth = 1.0
        // Add shadow
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
    }
    
    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return iconList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return iconList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let iconName = iconList[row] as String
        selectedicon = iconName
        let iconPath = Bundle.main.path(forResource: "walletIcon-\(iconName)", ofType: "png")
        iconPreviewImage.image = UIImage(contentsOfFile: iconPath!)
    }
    
    @IBAction func addBtn(_ sender: Any) {
        if(nameFld.text != nil && balFld.text != nil){
            if((Double(balFld.text!)) != nil){
                let selectedIcon = self.selectedicon
                let walletName = nameFld.text
                let walletBal:Double = Double(balFld.text!)!
                
                // Get user ID
                let newUserInfo = Auth.auth().currentUser
                let userId = newUserInfo?.uid
                
                // Add wallet to firebase
                let dbRef = Database.database().reference()
                let walletRef = dbRef.child("users").child("\(userId!)").child("wallets").childByAutoId()
                let walletKey = walletRef.key
                
                let wallet: NSDictionary = ["id": "\(walletKey!)", "name": walletName!, "balance": walletBal, "icon": selectedIcon, "userId": "\(userId!)"]
                walletRef.setValue(wallet)
                
                // Add wallet to current app data
                let walletObj:Wallet = Wallet(walletId: walletKey!, name: walletName!, bal: walletBal, icon: selectedIcon, userId: userId!)
                var appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.walletList.append(walletObj)
                
                // Successfully added wallet
                nameFld.text = ""
                balFld.text = ""
                messageLabel.textColor = .green
                messageLabel.text = "Wallet Added!"
            }
            else{
                // Balance entered is not Double type
                messageLabel.textColor = .red
                messageLabel.text = "Invalid Balance Amount"
            }
        }
        else{
            // Field is empty
            messageLabel.textColor = .red
            messageLabel.text = "Fields cannot be empty"
        }
    }
    
}
