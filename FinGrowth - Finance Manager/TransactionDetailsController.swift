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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Transaction Details: \(transaction?.name ?? "Nil") loaded")
    }
}
