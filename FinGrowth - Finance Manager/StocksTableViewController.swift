//
//  StocksTableViewController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 2/2/21.
//

import Foundation
import UIKit
import Firebase

class StocksTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

class StocksTableViewController:UITableViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var stocksList:[Stocks] = []
    let userId = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stocksList = appDelegate.stocksList
        self.tableView.reloadData() //Refresh data
        
        //Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StocksTableViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        stocksList = appDelegate.stocksList
        self.tableView.reloadData()
    }
    
    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocksList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StocksCell", for: indexPath) as! StocksTableViewCell
        
        let stocks = stocksList[indexPath.row]
        cell.nameLabel?.text = stocks.name
        cell.symbolLabel?.text = stocks.symbol.capitalized
        cell.valueLabel?.text = "$\(stocks.priceBought * Double(stocks.quantity))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let stocks = stocksList[indexPath.row]
            let editAction = UITableViewRowAction(style: .default, title: "Update", handler: { (action, indexPath) in
                let alert = UIAlertController(title: "", message: "Update Stocks", preferredStyle: .alert)

                alert.addTextField(configurationHandler: { (textField) in
                    textField.text = stocks.name
                    textField.placeholder = "Stocks Name"
                })
                alert.addTextField(configurationHandler: { (textField1) in
                    textField1.text = stocks.symbol.capitalized
                    textField1.placeholder = "Stock Symbol"
                })
                alert.addTextField(configurationHandler: { (textField2) in
                    textField2.text = "\(stocks.priceBought)"
                    textField2.placeholder = "Average Price Bought"
                })
                alert.addTextField(configurationHandler: { (textField3) in
                    textField3.text = "\(stocks.quantity)"
                    textField3.placeholder = "Quantity Owned"
                })
                
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                    let name = alert.textFields?[0].text! ?? stocks.name
                    let symbol = alert.textFields?[1].text!.capitalized ?? stocks.symbol
                    let price = Double((alert.textFields?[2].text!) ?? "\(stocks.priceBought)") ?? stocks.priceBought
                    let qty = Int((alert.textFields?[3].text!) ?? "\(stocks.quantity)") ?? stocks.quantity
                    
                    //Update wallet in firebase
                    let dbRef = Database.database().reference()
                    // Update symbol
                    dbRef.child("users").child("\(self.userId!)").child("stocks")
                        .child("\(stocks.id)").child("symbol").setValue(symbol)
                    // Update name
                    dbRef.child("users").child("\(self.userId!)").child("stocks")
                        .child("\(stocks.id)").child("name").setValue(name)
                    // Update price bought
                    dbRef.child("users").child("\(self.userId!)").child("stocks")
                        .child("\(stocks.id)").child("priceBought").setValue(price)
                    // Update quantity
                    dbRef.child("users").child("\(self.userId!)").child("stocks")
                        .child("\(stocks.id)").child("quantity").setValue(qty)
                    
                    for item in self.appDelegate.stocksList{
                        if item.id == stocks.id {
                            item.symbol = symbol.capitalized
                            item.name = name
                            item.priceBought = price
                            item.quantity = qty
                        }
                    }
                    
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: false)
                
            })

            let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
                self.stocksList.remove(at: indexPath.row)
                
                // Delete stocks in current app data
                self.appDelegate.stocksList.remove(at: indexPath.row)
                
                //Delete Data from Firebase
                let dbRef = Database.database().reference()
                dbRef.child("users").child("\(self.userId!)").child("stocks")
                    .child("\(stocks.id)").removeValue()
                
                tableView.reloadData()
            })
        editAction.backgroundColor = .darkGray
            return [deleteAction, editAction]
        }
}
