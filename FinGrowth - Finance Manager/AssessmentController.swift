//
//  AssessmentController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 2/2/21.
//

import Foundation
import QuartzCore
import UIKit
import Firebase

class AssessmentController: UIViewController {
    
    @IBOutlet weak var calculateBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init design layout
        applyCardViewStyle(view: scrollView)
        calculateBtn.layer.cornerRadius = 22
    }
    
    // Add border, shadow and corner design to view
    func applyCardViewStyle(view: UIScrollView) {
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = true;
        view.layer.borderColor = UIColor(red: 0.55, green: 0.33, blue: 0.83, alpha: 1.00).cgColor
        view.layer.borderWidth = 1.0

    }
}
