//
//  AssetsController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 29/1/21.
//

import Foundation
import QuartzCore
import UIKit

class AssetsController: UIViewController {
    
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var stockView: UIView!
    @IBOutlet weak var analysisView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Init design layout
        applyCardViewStyle(view: walletView)
        applyCardViewStyle(view: stockView)
        applyCardViewStyle(view: analysisView)
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
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
}
