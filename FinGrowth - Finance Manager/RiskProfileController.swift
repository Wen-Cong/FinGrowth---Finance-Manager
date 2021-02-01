//
//  RiskProfileController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 29/1/21.
//

import Foundation
import QuartzCore
import UIKit

class RiskProfileController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var riskProfileImage: UIImageView!
    @IBOutlet weak var recommendationImage: UIImageView!
    
    @IBOutlet weak var riskProfile: UILabel!
    @IBOutlet weak var riskProfileDescription: UILabel!
    @IBOutlet weak var recommendationDescription: UILabel!
    
    @IBOutlet weak var recommendTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add style to scroll view
        applyCardViewStyle()
        
        // Load profile risk detail view
        var appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user:User = appDelegate.user ?? User(username: "", dob: "\(Date.init())", risk: "")
        switch user.riskProfile {
        case "noProfile":
            loadNoProfileContent()
            break
        case "conservative":
            loadConservativeProfileContent()
            break
        case "balanced":
            loadBalancedProfileContent()
            break
        case "aggressive":
            loadAggressiveProfileContent()
            break
        default:
            print("Invalid risk profile string")
        }
    }
    
    func loadNoProfileContent() {
        riskProfile.text = "No risk profile"
        let stringPath = Bundle.main.path(forResource: "noProfile", ofType: "jpg")
        riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
        
        recommendTitle.text = nil
        recommendationDescription.text = nil
        riskProfileDescription.text = nil
        recommendationImage.image = .none
        
    }
    
    func loadConservativeProfileContent() {
        riskProfile.text = "Conservative Investor"
        let stringPath = Bundle.main.path(forResource: "conservativeInvestor", ofType: "jpg")
        riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
        
        riskProfileDescription.text = "Conservative investors are willing to accept little to no volatility in their investment portfolios. Often, retirees who have spent decades building a nest egg are unwilling to allow any type of risk to their principal. A conservative investor targets vehicles that are guaranteed and highly liquid. Risk-averse individuals opt for bank certificates of deposit (CDs), money markets, or U.S. Treasuries for income and preservation of capital."
        
        let recommendStringPath = Bundle.main.path(forResource: "conservativeAllocation", ofType: "png")
        recommendationImage.image = UIImage(contentsOfFile: recommendStringPath!)
        
        recommendationDescription.text = "Conservative model portfolios generally allocate a large percentage of the total to lower-risk securities such as fixed-income and money market securities. The main goal of a conservative portfolio is to protect the principal value of your portfolio. That's why these models are often referred to as capital preservation portfolios. Even if you are very conservative and are tempted to avoid the stock market entirely, some exposure to stocks can help offset inflation. You can invest the equity portion in high-quality blue-chip companies or an index fund."
        
        // Enable auto height adjust for label
        riskProfileDescription.sizeToFit()
        recommendationDescription.sizeToFit()
    }
    
    func loadBalancedProfileContent() {
        riskProfile.text = "Balanced Investor"
        let stringPath = Bundle.main.path(forResource: "balancedInvestor", ofType: "jpg")
        riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
        
        riskProfileDescription.text = "Moderate investors accept some risk to the principal but adopt a balanced approach with intermediate-term time horizons of five to 10 years. Combining large-company mutual funds with less volatile bonds and riskless securities, moderate investors often pursue a 50/50 structure. A typical strategy might involve investing half of the portfolio in a dividend-paying, growth fund."
        
        let recommendStringPath = Bundle.main.path(forResource: "balancedAllocation", ofType: "png")
        recommendationImage.image = UIImage(contentsOfFile: recommendStringPath!)
        
        recommendationDescription.text = "Moderately aggressive model portfolios are often referred to as balanced portfolios since the asset composition is divided almost equally between fixed-income securities and equities. The balance is between growth and income. Since moderately aggressive portfolios have a higher level of risk than conservative portfolios, this strategy is best for investors with a longer time horizon (generally more than five years) and a medium level of risk tolerance."
        
        // Enable auto height adjust for label
        riskProfileDescription.sizeToFit()
        recommendationDescription.sizeToFit()
    }
    
    func loadAggressiveProfileContent() {
        riskProfile.text = "Aggressive Investor"
        let stringPath = Bundle.main.path(forResource: "aggressiveInvestor", ofType: "png")
        riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
        
        riskProfileDescription.text = "Aggressive investors tend to be market-savvy. A deep understanding of securities and their propensities allows such individuals and institutional investors to purchase highly volatile instruments, such as small-company stocks that can plummet to zero or options contracts that can expire worthlessly. While maintaining a base of riskless securities, aggressive investors reach for maximum returns with maximum risk."
        
        let recommendStringPath = Bundle.main.path(forResource: "aggressiveAllocation", ofType: "png")
        recommendationImage.image = UIImage(contentsOfFile: recommendStringPath!)

        recommendationDescription.text = "Aggressive portfolios mainly consist of equities, so their value can fluctuate widely from day-to-day. If you have an aggressive portfolio, your main goal is to achieve long-term growth of capital. The strategy of an aggressive portfolio is often called a capital growth strategy. To provide diversification, investors with aggressive portfolios usually add some fixed-income securities."
        
        // Enable auto height adjust for label
        riskProfileDescription.sizeToFit()
        recommendationDescription.sizeToFit()
    }
    
    func applyCardViewStyle() {
        contentView.layer.cornerRadius = 10;
        scrollView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = true;
        contentView.layer.borderColor = UIColor(red: 0.55, green: 0.33, blue: 0.83, alpha: 1.00).cgColor
        contentView.layer.borderWidth = 1.0
        // Add shadow
        scrollView.layer.masksToBounds = false
        scrollView.layer.shadowOffset = CGSize(width: 5, height: 5)
        scrollView.layer.shadowRadius = 5
        scrollView.layer.shadowOpacity = 0.5
        scrollView.layer.shadowPath = UIBezierPath(rect: scrollView.bounds).cgPath
    }
}
