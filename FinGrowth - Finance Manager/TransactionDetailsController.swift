//
//  TransactionDetailsController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 2/2/21.
//

import Foundation
import UIKit
import Firebase
import QuartzCore

class TransactionDetailsController: UIViewController {
    
    var transaction:Transaction? = nil
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let userId = Auth.auth().currentUser?.uid
    let dbRef = Database.database().reference()
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var amtLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var detailsView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Transaction Details: \(transaction?.name ?? "Nil") loaded")
        
        // Init design layout
        applyCardViewStyle(view: detailsView)
        deleteBtn.layer.cornerRadius = 22
        
        // Present data
        if transaction?.type == "Income" {
            amtLabel.textColor = UIColor(red: 0.22, green: 0.58, blue: 0.09, alpha: 1.00)
        }
        else if transaction?.type == "Expense" {
            amtLabel.textColor = UIColor(red: 0.78, green: 0.05, blue: 0.05, alpha: 1.00)
        }
        
        titleLabel.text = transaction?.name
        amtLabel.text = "$\(transaction?.amount ?? 0)"
        dateLabel.text = transaction?.time
        catLabel.text = transaction?.category
        typeLabel.text = transaction?.type
        
        for w in appDelegate.walletList {
            if w.walletId == transaction?.walletId {
                walletLabel.text = w.name
                break
            }
        }
        
        let iconPath = Bundle.main.path(forResource: "transactionIcon-\(transaction?.category ?? "Others")", ofType: "png")
        iconImage.image = UIImage(contentsOfFile: iconPath!)
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
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.5
    }
    
    @IBAction func deletebtn(_ sender: Any) {
        if (transaction != nil){
            // Recover wallet balance
            var amount = transaction?.amount
            if transaction?.type == "Expense" {
                amount = (amount!) * (-1)
            }
            for w in appDelegate.walletList {
                if w.walletId == transaction?.walletId {
                    let newAmount = (w.balance) - (amount!)
                    w.balance = newAmount
                    dbRef.child("users").child("\(userId!)").child("wallets")
                        .child("\(transaction!.walletId)").child("balance").setValue(newAmount)
                    
                    break
                }
            }
            
            // Delete transactions in current app data & firebase
            for i in 0...(self.appDelegate.transactionList.count - 1) {
                let t = self.appDelegate.transactionList[i]
                if self.appDelegate.transactionList[i].transactionId == transaction?.transactionId{
                    self.appDelegate.transactionList.remove(at: i)
                    
                    //Delete Data from Firebase
                    dbRef.child("users").child("\(userId!)").child("wallets")
                        .child("\(t.walletId)").child("transactions").child("\(t.transactionId)").removeValue(completionBlock: {error, ref in
                            if error == nil {
                                // Successfully deleted
                                _ = self.navigationController?.popToRootViewController(animated: true)
                            }
                            else{
                                print("Error deleting firabase data: \(String(describing: error))")
                            }
                        })
                    
                    break
                }
            }
        }
    }
    
}
