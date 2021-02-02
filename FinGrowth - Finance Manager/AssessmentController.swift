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

class AssessmentController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var calculateBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var ansFld1: UITextField!
    @IBOutlet weak var ansFld2: UITextField!
    @IBOutlet weak var ansFld3: UITextField!
    @IBOutlet weak var ansFld4: UITextField!
    @IBOutlet weak var ansFld5: UITextField!
    @IBOutlet weak var ansFld6: UITextField!
    @IBOutlet weak var ansFld7: UITextField!
    @IBOutlet weak var ansFld8: UITextField!
    @IBOutlet weak var ansFld9: UITextField!
    @IBOutlet weak var ansFld10: UITextField!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userId = Auth.auth().currentUser?.uid
    
    let PickerView1:UIPickerView = UIPickerView()
    let PickerView2:UIPickerView = UIPickerView()
    let PickerView3:UIPickerView = UIPickerView()
    let PickerView4:UIPickerView = UIPickerView()
    let PickerView5:UIPickerView = UIPickerView()
    let PickerView6:UIPickerView = UIPickerView()
    let PickerView7:UIPickerView = UIPickerView()
    let PickerView8:UIPickerView = UIPickerView()
    let PickerView9:UIPickerView = UIPickerView()
    let PickerView10:UIPickerView = UIPickerView()
    
    let ansList1:[String] = ["A real risk avoider", "Cautious", "Willing to take risks after completing adequate research", "A real gambler"]
    
    let ansList2:[String] = ["$1,000 in cash", "A 50% chance at winning $5,000", "A 25% chance at winning $10,000", "A 5% chance at winning $100,000"]
    
    let ansList3:[String] = ["Not at all comfortable", "Somewhat comfortable", "Adequately Comfortable", "Very comfortable"]
    
    let ansList4:[String] = ["$200 gain best case; $0 gain/loss worst case", "$800 gain best case; $200 loss worst case", "$2,600 gain best case; $800 loss worst case", "$4,800 gain best case; $2,400 loss worst case"]
    
    let ansList5:[String] = ["A savings account or money market mutual fund", "A mutual fund that owns stocks and bonds", "A portfolio of 15 common stocks", "A portfolio of cryptocurrencies"]
    
    let ansList6:[String] = ["80% in low-risk investments, 20% in medium-risk investments", "60% in low-risk investments, 30% in medium-risk investments, 10% in high-risk investments", "30% in low-risk investments, 40% in medium-risk investments, 30% in high-risk investments", "10% in low-risk investments, 40% in medium-risk investments, 50% in high-risk investments"]
    
    let ansList7:[String] = ["Sell, and move your cash to a low-risk investment", "Consider selling enough to cover your original investment", "Do nothing, wait for higher growth", "Borrow money to buy more stock"]
    
    let ansList8:[String] = ["Dangerous", "Uncertainty", "Opportunity", "Thrill"]
    
    let ansList9:[String] = ["Weigh the risks and decide not to invest", "Invest an amount you can afford to write off", "Learn more about the company. If there’s potential, invest!", "All In!"]
    
    let ansList10:[String] = ["5%", "15%", "30%", "More than 50%"]
    
    var ansScore1 = 0
    var ansScore2 = 0
    var ansScore3 = 0
    var ansScore4 = 0
    var ansScore5 = 0
    var ansScore6 = 0
    var ansScore7 = 0
    var ansScore8 = 0
    var ansScore9 = 0
    var ansScore10 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init design layout
        applyCardViewStyle(view: scrollView)
        calculateBtn.layer.cornerRadius = 22
        applyTextFieldStyle(field: ansFld1)
        applyTextFieldStyle(field: ansFld2)
        applyTextFieldStyle(field: ansFld3)
        applyTextFieldStyle(field: ansFld4)
        applyTextFieldStyle(field: ansFld5)
        applyTextFieldStyle(field: ansFld6)
        applyTextFieldStyle(field: ansFld7)
        applyTextFieldStyle(field: ansFld8)
        applyTextFieldStyle(field: ansFld9)
        applyTextFieldStyle(field: ansFld10)
        
        // Init picker view
        PickerView1.delegate = self
        PickerView2.delegate = self
        PickerView3.delegate = self
        PickerView4.delegate = self
        PickerView5.delegate = self
        PickerView6.delegate = self
        PickerView7.delegate = self
        PickerView8.delegate = self
        PickerView9.delegate = self
        PickerView10.delegate = self
        
        ansFld1.inputView = PickerView1
        ansFld2.inputView = PickerView2
        ansFld3.inputView = PickerView3
        ansFld4.inputView = PickerView4
        ansFld5.inputView = PickerView5
        ansFld6.inputView = PickerView6
        ansFld7.inputView = PickerView7
        ansFld8.inputView = PickerView8
        ansFld9.inputView = PickerView9
        ansFld10.inputView = PickerView10

        dismissPickerView()
    }
    
    // Add border, shadow and corner design to view
    func applyCardViewStyle(view: UIScrollView) {
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = true;
        view.layer.borderColor = UIColor(red: 0.55, green: 0.33, blue: 0.83, alpha: 1.00).cgColor
        view.layer.borderWidth = 1.0

    }
    
    func applyTextFieldStyle(field:UITextField){
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1.0
        field.layer.cornerRadius = 10
    }
    
    @IBAction func calculateBtn(_ sender: Any) {
        // Check for empty field
        if(ansFld1 != nil && ansFld2 != nil && ansFld3 != nil && ansFld4 != nil && ansFld5 != nil && ansFld6 != nil && ansFld7 != nil && ansFld8 != nil && ansFld9 != nil && ansFld10 != nil){
            let totalScore = ansScore1 + ansScore2 + ansScore3 + ansScore4 + ansScore5 + ansScore6 +
            ansScore7 + ansScore8 + ansScore9 + ansScore10
            
            if totalScore < 20 {
                let profile = "conservative"
                // Update current app data
                appDelegate.user?.riskProfile = profile
                
                // Update risk profile to firebase
                let dbRef = Database.database().reference()
                dbRef.child("users").child("\(userId!)").child("riskProfile").setValue(profile, withCompletionBlock: {error, ref in
                    if error == nil {
                        // Return to profile page
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                    else{
                        print("Error updating database: \(String(describing: error))")
                    }
                })
            }
            else if totalScore < 30 {
                let profile = "balanced"
                // Update current app data
                appDelegate.user?.riskProfile = profile
                
                // Update risk profile to firebase
                let dbRef = Database.database().reference()
                dbRef.child("users").child("\(userId!)").child("riskProfile").setValue(profile, withCompletionBlock: {error, ref in
                    if error == nil {
                        // Return to profile page
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                    else{
                        print("Error updating database: \(String(describing: error))")
                    }
                })
                
            }
            else if totalScore < 40 {
                let profile = "aggressive"
                // Update current app data
                appDelegate.user?.riskProfile = profile
                
                // Update risk profile to firebase
                let dbRef = Database.database().reference()
                dbRef.child("users").child("\(userId!)").child("riskProfile").setValue(profile, withCompletionBlock: {error, ref in
                    if error == nil {
                        // Return to profile page
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                    else{
                        print("Error updating database: \(String(describing: error))")
                    }
                })
            }
            else{
                // Error
                print("Score calculation error, Score: \(totalScore)")
            }
        }
        else{
            // some field is empty, invalid
        }
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        ansFld1.inputAccessoryView = toolBar
        ansFld2.inputAccessoryView = toolBar
        ansFld3.inputAccessoryView = toolBar
        ansFld4.inputAccessoryView = toolBar
        ansFld5.inputAccessoryView = toolBar
        ansFld6.inputAccessoryView = toolBar
        ansFld7.inputAccessoryView = toolBar
        ansFld8.inputAccessoryView = toolBar
        ansFld9.inputAccessoryView = toolBar
        ansFld10.inputAccessoryView = toolBar

    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == PickerView1 {
            return ansList1.count
        }
        else if pickerView == PickerView2 {
            return ansList2.count
        }
        else if pickerView == PickerView3 {
            return ansList3.count
        }
        else if pickerView == PickerView4 {
            return ansList4.count
        }
        else if pickerView == PickerView5 {
            return ansList5.count
        }
        else if pickerView == PickerView6 {
            return ansList6.count
        }
        else if pickerView == PickerView7 {
            return ansList7.count
        }
        else if pickerView == PickerView8 {
            return ansList8.count
        }
        else if pickerView == PickerView9 {
            return ansList9.count
        }
        else if pickerView == PickerView10 {
            return ansList10.count
        }
        else{
            print("Assessment Controller: error")
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == PickerView1 {
            return ansList1[row]
        }
        else if pickerView == PickerView2 {
            return ansList2[row]
        }
        else if pickerView == PickerView3 {
            return ansList3[row]
        }
        else if pickerView == PickerView4 {
            return ansList4[row]
        }
        else if pickerView == PickerView5 {
            return ansList5[row]
        }
        else if pickerView == PickerView6 {
            return ansList6[row]
        }
        else if pickerView == PickerView7 {
            return ansList7[row]
        }
        else if pickerView == PickerView8 {
            return ansList8[row]
        }
        else if pickerView == PickerView9 {
            return ansList9[row]
        }
        else if pickerView == PickerView10 {
            return ansList10[row]
        }
        else {
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == PickerView1 {
            let ans = ansList1[row] as String
            ansFld1.text = ans
            ansScore1 = row + 1
        }
        else if pickerView == PickerView2 {
            let ans = ansList2[row] as String
            ansFld2.text = ans
            ansScore2 = row + 1
        }
        else if pickerView == PickerView3 {
            let ans = ansList3[row] as String
            ansFld3.text = ans
            ansScore3 = row + 1
        }
        else if pickerView == PickerView4 {
            let ans = ansList4[row] as String
            ansFld4.text = ans
            ansScore4 = row + 1
        }
        else if pickerView == PickerView5 {
            let ans = ansList5[row] as String
            ansFld5.text = ans
            ansScore5 = row + 1
        }
        else if pickerView == PickerView6 {
            let ans = ansList6[row] as String
            ansFld6.text = ans
            ansScore6 = row + 1
        }
        else if pickerView == PickerView7 {
            let ans = ansList7[row] as String
            ansFld7.text = ans
            ansScore7 = row + 1
        }
        else if pickerView == PickerView8 {
            let ans = ansList8[row] as String
            ansFld8.text = ans
            ansScore8 = row + 1
        }
        else if pickerView == PickerView9 {
            let ans = ansList9[row] as String
            ansFld9.text = ans
            ansScore9 = row + 1
        }
        else if pickerView == PickerView10 {
            let ans = ansList10[row] as String
            ansFld10.text = ans
            ansScore10 = row + 1
        }
        else{
            // Error
        }
    }
}
