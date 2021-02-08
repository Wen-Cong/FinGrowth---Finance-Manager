//
//  AddStocksController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 2/2/21.
//

import Foundation
import UIKit
import QuartzCore
import Firebase

class AddStocksController: UIViewController {
    
    @IBOutlet weak var nameFld: UITextField!
    @IBOutlet weak var symbolFld: UITextField!
    @IBOutlet weak var qtyFld: UITextField!
    @IBOutlet weak var priceFld: UITextField!
    @IBOutlet weak var dateFld: UITextField!
    
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    
    private var datePicker: UIDatePicker?
    
    var stocksIsOwned:Bool = false
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userId = Auth.auth().currentUser?.uid
    let dbRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init design layout
        applyCardViewStyle(view: formView)
        applyTextFieldStyle(field: nameFld)
        applyTextFieldStyle(field: symbolFld)
        applyTextFieldStyle(field: qtyFld)
        applyTextFieldStyle(field: priceFld)
        applyTextFieldStyle(field: dateFld)
        addBtn.layer.cornerRadius = 22
        
        // Init date picker
        //add date picker into input field
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(AddStocksController.dateChanged(datePicker:)), for: .valueChanged)
        
        //Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddStocksController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        dateFld.inputView = datePicker
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageLabel.text = ""
    }
    
    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func addBtn(_ sender: Any) {
        // Check for empty field
        if (nameFld != nil && symbolFld != nil && qtyFld != nil && priceFld != nil && dateFld != nil){
            if (Double(priceFld.text!) != nil && Int(qtyFld.text!) != nil){
                let name = nameFld.text!
                let symbol = symbolFld.text!.capitalized
                let qty = Int(qtyFld.text!)!
                let price = Double(priceFld.text!)!
                let date = dateFld.text!
                
                for s in appDelegate.stocksList {
                    // User already owned some of this shares - Update value instead of adding new stocks
                    if s.symbol == symbol {
                        stocksIsOwned = true
                        
                        let newQty = s.quantity + qty
                        // Calculate new average cost per share
                        let newAvgPrice = ((s.priceBought * Double(s.quantity)) + (price * Double(qty)))/Double(newQty)
                        
                        // Update firebase data
                        dbRef.child("users").child("\(userId!)").child("stocks").child("\(s.id)").child("quantity").setValue(newQty)
                        dbRef.child("users").child("\(userId!)").child("stocks").child("\(s.id)").child("priceBought").setValue(newAvgPrice)
                        dbRef.child("users").child("\(userId!)").child("stocks").child("\(s.id)").child("date").setValue(date)
                        
                        // Update current app session data
                        s.quantity = newQty
                        s.priceBought = newAvgPrice
                        s.DateBought = date
                        
                        break
                    }
                }
                
                if (!stocksIsOwned) {
                    print("Stock is not owned")
                    // Add stocks to firebase
                    let stockRef = dbRef.child("users").child("\(userId!)").child("stocks").childByAutoId()
                    let stockKey = stockRef.key
                    let stocksNS: NSDictionary = ["id": stockKey!, "name": name, "symbol": symbol.capitalized, "quantity": qty, "priceBought": price, "date": date]
                    stockRef.setValue(stocksNS)
                    
                    // Add stocks to current app data
                    let stocks = Stocks(id: stockKey ?? "", name: name, symbol: symbol, qty: qty, priceBought: price, date: date)
                    appDelegate.stocksList.append(stocks)
                }
                
                // Stocks add successfully
                messageLabel.textColor = .green
                messageLabel.text = "Stocks added successfully"
                
                // Clear text field & Reset stockIsOwned Status
                nameFld.text = ""
                qtyFld.text = ""
                dateFld.text = ""
                symbolFld.text = ""
                priceFld.text = ""
                stocksIsOwned = false
            }
            else{
                messageLabel.textColor = .red
                messageLabel.text = "Invalid Quantity or Price data type"
            }
        }
        else{
            // Empty field
            messageLabel.textColor = .red
            messageLabel.text = "Fields cannot be empty"
        }
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateFld.text = formatter.string(from: datePicker.date)
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
    
    func applyTextFieldStyle(field:UITextField){
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1.0
        field.layer.cornerRadius = 10
    }
}
