//
//  HomeController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 1/2/21.
//

import Foundation
import QuartzCore
import UIKit
import Firebase

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var catImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var amtLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
}

class HomeController:UIViewController {
    
    @IBOutlet weak var incomeIcon: UIImageView!
    @IBOutlet weak var expenseIcon: UIImageView!
    @IBOutlet weak var NoTransactionImage: UIImageView!
    
    @IBOutlet weak var netWorthLabel: UILabel!
    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var noTransactionLabel: UILabel!
    
    @IBOutlet weak var transactionList: UITableView!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var transactions:[Transaction] = []
    var wallets:[Wallet] = []
    var stocks:[Stocks] = []
    let userId = Auth.auth().currentUser?.uid
    
    var selectedTransaction:Transaction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactions = appDelegate.transactionList
        self.transactionList.reloadData() //Refresh data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        transactions = appDelegate.transactionList
        wallets = appDelegate.walletList
        stocks = appDelegate.stocksList
        self.transactionList.reloadData()
        
        // Add "Empty" Image if there is no transactions
        if transactions.count == 0 {
            let stringPath = Bundle.main.path(forResource: "empty", ofType: "jpg")
            NoTransactionImage.image = UIImage(contentsOfFile: stringPath ?? "")
            
            noTransactionLabel.text = "You did not have any transaction currently."
        }
        else {
            NoTransactionImage.image = nil
            noTransactionLabel.text = ""
        }
        
        // Calculate income & expenses
        var totalIncome = 0.0
        var totalExpenses = 0.0
        
        let dateFormatter = DateFormatter()
        let monthDateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current // set locale to system
        monthDateFormatter.locale = Locale.current // set locale to system
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        monthDateFormatter.dateFormat = "LLLL"
        
        for t in transactions {
            let date = dateFormatter.date(from:t.time)!
            let tMonth = monthDateFormatter.string(from: date)
            let currentMonth = monthDateFormatter.string(from: Date.init())
            if tMonth == currentMonth {
                if t.type == "Income" {
                    totalIncome += t.amount
                }
                else if t.type == "Expense" {
                    totalExpenses += t.amount
                }
            }
        }
        
        incomeLabel.text = "$\(totalIncome)"
        expenseLabel.text = "$\(totalExpenses)"

        // Get current month & year
        let now = Date()
        let yearDateFormatter = DateFormatter()
        yearDateFormatter.dateFormat = "yyyy"
        let yearString = yearDateFormatter.string(from: now)
        let monthString = monthDateFormatter.string(from: now)
        currentMonthLabel.text = monthString.capitalizingFirstLetter() + " " + yearString
        
        // Calculate net worth
        var netWorth = 0.0
        for w in wallets {
            netWorth += w.balance
        }
        for s in stocks {
            let value = s.priceBought * Double(s.quantity)
            netWorth += value
        }
        
        netWorthLabel.text = "$\(netWorth)"
    }
    
    // Add border, shadow and corner design to view
    func applyCardViewStyle(view: UIView) {
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = true;
        view.layer.borderColor = UIColor(red: 0.55, green: 0.33, blue: 0.83, alpha: 1.00).cgColor
        view.layer.borderWidth = 1.0
    }
    
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactions.count
        }
        
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        // Set the spacing between sections
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return CGFloat(15.0)
        }
        
        // Make the background color show through
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        
        let transaction = transactions[indexPath.section]
        if transaction.type == "Income" {
            cell.amtLabel?.textColor = UIColor(red: 0.22, green: 0.58, blue: 0.09, alpha: 1.00)
        }
        else if transaction.type == "Expense" {
            cell.amtLabel?.textColor = UIColor(red: 0.78, green: 0.05, blue: 0.05, alpha: 1.00)
        }
        
        cell.titleLabel?.text = transaction.name
        cell.amtLabel?.text = "$\(transaction.amount)"
        cell.dateTimeLabel?.text = transaction.time
        applyCardViewStyle(view: cell.cellView)
        
        let iconPath = Bundle.main.path(forResource: "transactionIcon-\(transaction.category)", ofType: "png")
        cell.catImage?.image = UIImage(contentsOfFile: iconPath!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = transactions[indexPath.section]
        let row = indexPath.section
        selectedTransaction = transaction
        performSegue(withIdentifier: "TransactionDetails", sender: row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "TransactionDetails" {
            let vc = segue.destination as! TransactionDetailsController
            vc.transaction = selectedTransaction
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
