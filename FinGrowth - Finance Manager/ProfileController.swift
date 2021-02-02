//
//  ProfileController.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 28/1/21.
//

import Foundation
import QuartzCore
import UIKit
import Firebase

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var riskProfileImage: UIImageView!
    
    @IBOutlet weak var infoView: UIView!

    @IBOutlet weak var riskProfileView: UIView!

    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var settings2View: UIView!
    
    @IBOutlet weak var username_lbl: UILabel!
    
    @IBOutlet weak var age_lbl: UILabel!

    @IBOutlet weak var riskProfile_lbl: UILabel!
    
    @IBOutlet weak var editImageBtn: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    let userId = (Auth.auth().currentUser)?.uid
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //-----------------------------Customise interface design---------------------------
        // customise info view
        infoView.layer.cornerRadius = 10;
        infoView.layer.masksToBounds = true;
        // Add shadow
        infoView.layer.masksToBounds = false
        infoView.layer.shadowOffset = CGSize(width: 3, height: 3)
        infoView.layer.shadowRadius = 5
        infoView.layer.shadowOpacity = 0.5
        infoView.layer.shadowPath = UIBezierPath(rect: infoView.bounds).cgPath

        
        // Circle profile image
        profileImage.layer.borderWidth = 1.5
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        // Customise risk profile view
        applyCardViewStyle(view: riskProfileView)
        
        // Customise settings option layout
        applyCardViewStyle(view: settingsView)
        applyCardViewStyle(view: settings2View)

        // Customise edit profile button
        editImageBtn.layer.cornerRadius = editImageBtn.frame.size.width / 2
        
        //--------------------------------Load data into view---------------------------------
        let user:User = appDelegate.user ?? User(username: "", dob: "\(Date.init())", risk: "")
        username_lbl.text = user.username
        
        // Convert string to date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current // set locale to system
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from:user.dob)!
        // Compare dob and current date to retrive age
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date.init())
        let age = ageComponents.year!
        // Set age value
        age_lbl.text = String(age)
        
        //load profile image
        let profileImageRef = Storage.storage().reference().child("users").child(userId!).child("profileImage.jpg")
        profileImageRef.getData(maxSize: 10 * 1204 * 1204) { data, error in
            if let error = error {
                print("Image failed to retrieve, error: \(error)")
            }
            else{
                self.profileImage.image = UIImage(data: data!)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let user:User = appDelegate.user ?? User(username: "", dob: "\(Date.init())", risk: "")

        // Load risk profile data
        switch user.riskProfile {
        case "noProfile":
            riskProfile_lbl.text = "No risk profile"
            let stringPath = Bundle.main.path(forResource: "noProfile", ofType: "jpg")
            riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
            break
        case "conservative":
            riskProfile_lbl.text = "Conservative Investor"
            let stringPath = Bundle.main.path(forResource: "conservativeInvestor", ofType: "jpg")
            riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
        case "balanced":
            riskProfile_lbl.text = "Balanced Investor"
            let stringPath = Bundle.main.path(forResource: "balancedInvestor", ofType: "jpg")
            riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
        case "aggressive":
            riskProfile_lbl.text = "Aggressive Investor"
            let stringPath = Bundle.main.path(forResource: "aggressiveInvestor", ofType: "png")
            riskProfileImage.image = UIImage(contentsOfFile: stringPath!)
        default:
            print("Invalid risk profile string")
        }
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
    
    // Change profile image
    @IBAction func editProfileImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Dismiss album
        self.dismiss(animated: true, completion: { () -> Void in })
        
        // Load image into view
        let image = info[.originalImage] as? UIImage
        profileImage.image = image
        
        // Upload image to firebase storage
        let imageData = image?.pngData()
        let profileImageRef = Storage.storage().reference().child("users").child(userId!).child("profileImage.jpg")
        
        profileImageRef.putData(imageData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Error when uploading
                print("Image upload failed!")
                return
            }
            let size = metadata.size
            print("Image uploaded successfully! size uploaded: \(size)")
        }
    }
    
    // Sign Out
    @IBAction func signout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            // Navigate to Main.Storyboard -- Back to login page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "login") as UIViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }catch{
            print("Unable to sign out")
        }
    }
}

