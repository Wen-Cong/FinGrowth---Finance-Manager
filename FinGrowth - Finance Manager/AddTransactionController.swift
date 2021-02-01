//
//  AddTransactionController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 1/2/21.
//

import Foundation
import UIKit
import Firebase
import QuartzCore

class AddTransactionController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var formView: UIView!
    
    @IBOutlet weak var titleFld: UITextField!
    @IBOutlet weak var amtFld: UITextField!
    @IBOutlet weak var walletFld: UITextField!
    @IBOutlet weak var catFld: UITextField!
    @IBOutlet weak var typeFld: UITextField!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let userId = Auth.auth().currentUser?.uid
    
    let walletPickerView:UIPickerView = UIPickerView()
    let categoryPickerView:UIPickerView = UIPickerView()
    let typePickerView:UIPickerView = UIPickerView()
    
    let catList:[String] = ["Food", "Shopping", "Entertainment", "Transport", "Utility", "Salary", "Investment", "Others"]
    
    let typeList:[String] = ["Expense", "Income"]
    
    var walletList:[Wallet] = []
    var selectedWallet:Wallet? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Design layout
        applyCardViewStyle(view: formView)
        applyTextFieldStyle(field: titleFld)
        applyTextFieldStyle(field: amtFld)
        applyTextFieldStyle(field: walletFld)
        applyTextFieldStyle(field: catFld)
        applyTextFieldStyle(field: typeFld)
        addBtn.layer.cornerRadius = 22
        
        // Get wallets
        walletList = appDelegate.walletList
        
        // Init picker view
        walletPickerView.delegate = self
        categoryPickerView.delegate = self
        typePickerView.delegate = self
        
        walletFld.inputView = walletPickerView
        catFld.inputView = categoryPickerView
        typeFld.inputView = typePickerView
        
        dismissPickerView()
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
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
    
    func applyTextFieldStyle(field:UITextField){
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1.0
        field.layer.cornerRadius = 10
    }
    
    @IBAction func addBtn(_ sender: Any) {
        if(titleFld.text != nil && amtFld.text != nil && selectedWallet != nil && catFld.text != nil && typeFld.text != nil){
            if((Double(amtFld.text!)) != nil){
                let wallet:Wallet = self.selectedWallet!
                let title = titleFld.text!
                let amt = Double(amtFld.text!)
                let selectedCat = catFld.text!
                let selectedType = typeFld.text!
                
                // Add transaction to firebase
                let dbRef = Database.database().reference()
                let tRef = dbRef.child("users").child("\(self.userId!)").child("wallets")
                    .child("\(wallet.walletId)").child("transactions").childByAutoId()
                let tKey = tRef.key
                
                let transaction: NSDictionary = ["id": "\(tKey!)", "name": "\(title)", "amount": amt!, "time": "\(Date.init())", "category": "\(selectedCat)", "type": "\(selectedType)", "walletId": "\(wallet.walletId)"]
                tRef.setValue(transaction)
                
                // Add transaction to current app data
                let transactionObj:Transaction = Transaction(id: tKey!, name: title, amt: amt!, time: "\(Date.init())", cat: selectedCat, type: selectedType, walletId: wallet.walletId)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.transactionList.append(transactionObj)
                
                // Update wallet balance
                if (selectedType == "Expense"){
                    let newWalletAmt:Double = wallet.balance - amt!
                    dbRef.child("users").child("\(self.userId!)").child("wallets")
                        .child("\(wallet.walletId)").child("balance").setValue(newWalletAmt)
                    
                    for item in appDelegate.walletList{
                        if item.walletId == wallet.walletId{
                            item.balance = newWalletAmt
                        }
                    }
                }
                else if (selectedType == "Income"){
                    let newWalletAmt:Double = wallet.balance + amt!
                    dbRef.child("users").child("\(self.userId!)").child("wallets")
                        .child("\(wallet.walletId)").child("balance").setValue(newWalletAmt)
                    
                    for item in appDelegate.walletList{
                        if item.walletId == wallet.walletId{
                            item.balance = newWalletAmt
                        }
                    }
                }
                
                // Success added transaction
                titleFld.text = ""
                amtFld.text = ""
                walletFld.text = ""
                catFld.text = ""
                typeFld.text = ""
                
                messageLabel.textColor = .green
                messageLabel.text = "Transaction Added!"
                
            }
            else{
                messageLabel.textColor = .red
                messageLabel.text = "Amount entered is invalid"
            }
        }
        else{
            messageLabel.textColor = .red
            messageLabel.text = "Fields cannot be empty"
        }
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        walletFld.inputAccessoryView = toolBar
        catFld.inputAccessoryView = toolBar
        typeFld.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == walletPickerView {
            return walletList.count
        }
        else if pickerView == categoryPickerView {
            return catList.count
        }
        else if pickerView == typePickerView {
            return typeList.count
        }
        else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == walletPickerView {
            return walletList[row].name
        }
        else if pickerView == categoryPickerView {
            return catList[row]
        }
        else if pickerView == typePickerView {
            return typeList[row]
        }
        else {
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == walletPickerView {
            let wallet = walletList[row] as Wallet
            selectedWallet = wallet
            walletFld.text = wallet.name
        }
        else if pickerView == categoryPickerView {
            let cat = catList[row] as String
            catFld.text = cat
        }
        else if pickerView == typePickerView {
            let type = typeList[row] as String
            typeFld.text = type
        }
        else {
            // Error
        }
    }
}
