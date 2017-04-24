//
//  CreateAccountController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/23/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import CoreLocation
import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class CreateAccountController: UIViewController{
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func createAcctButtonTapped(_ sender: UIButton) {
        if emailInput.text == "" || passInput.text == ""{
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: emailInput.text!, password: passInput.text!) { (user, error) in
                
                if error == nil {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

