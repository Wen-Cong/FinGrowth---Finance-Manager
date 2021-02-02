//
//  WalletTableViewController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 1/2/21.
//

import Foundation
import UIKit
import Firebase

class WalletTableViewCell:UITableViewCell{
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var balLabel: UILabel!
}

class WalletTableViewController:UITableViewController{
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var walletList:[Wallet] = []
    let userId = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletList = appDelegate.walletList
        self.tableView.reloadData() //Refresh data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        walletList = appDelegate.walletList
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as! WalletTableViewCell
        
        let wallet = walletList[indexPath.row]
        cell.titleLabel?.text = wallet.name
        cell.balLabel?.text = "$\(wallet.balance)"
        let iconPath = Bundle.main.path(forResource: "walletIcon-\(wallet.walletIcon)", ofType: "png")
        
        let altIconPath = Bundle.main.path(forResource: "noProfile", ofType: "jpg")!
        cell.iconImage?.image = UIImage(contentsOfFile: iconPath ?? altIconPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let wallet = walletList[indexPath.row]
            let editAction = UITableViewRowAction(style: .default, title: "Update", handler: { (action, indexPath) in
                let alert = UIAlertController(title: "", message: "Update Wallet", preferredStyle: .alert)

                alert.addTextField(configurationHandler: { (textField) in
                    textField.text = wallet.name
                    textField.placeholder = "Wallet Name"
                })
                alert.addTextField(configurationHandler: { (textField1) in
                    textField1.text = "\(wallet.balance)"
                    textField1.placeholder = "Balance"
                })
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                    let name = alert.textFields?[0].text! ?? ""
                    let bal = Double((alert.textFields?[1].text!) ?? "0") ?? 0
                    
                    //Update wallet in firebase
                    let dbRef = Database.database().reference()
                    // Update balance
                    dbRef.child("users").child("\(self.userId!)").child("wallets")
                        .child("\(wallet.walletId)").child("balance").setValue(bal)
                    // Update name
                    dbRef.child("users").child("\(self.userId!)").child("wallets")
                        .child("\(wallet.walletId)").child("name").setValue(name)
                    
                    for item in self.appDelegate.walletList{
                        if item.walletId == wallet.walletId{
                            item.balance = bal
                            item.name = name
                        }
                    }
                    
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: false)
                
            })

            let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
                self.walletList.remove(at: indexPath.row)
                
                // Delete wallet & related transactions in current app data
                self.appDelegate.walletList.remove(at: indexPath.row)
                
                for i in 0...(self.appDelegate.transactionList.count-1) {
                    if self.appDelegate.transactionList[i].walletId == wallet.walletId{
                        self.appDelegate.transactionList.remove(at: i)
                    }
                }
                
                //Delete Data from Firebase
                let dbRef = Database.database().reference()
                dbRef.child("users").child("\(self.userId!)").child("wallets")
                    .child("\(wallet.walletId)").removeValue()
                
                tableView.reloadData()
            })
        editAction.backgroundColor = .darkGray
            return [deleteAction, editAction]
        }
}
