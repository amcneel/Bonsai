//
//  SignInController.swift
//  Bonsai-FinalProject
//
//  Created by Tarun Chally on 4/13/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit
import FirebaseAuth
class SignInController: UIViewController{
    
    override func viewDidLoad() {
        
    }
    
    //for creating account
    @IBOutlet weak var EmailCreate: UITextField!
    
    @IBOutlet weak var PasswordCreate: UITextField!
    
    //for sign in
    @IBOutlet var emailLogin: UITextField!
    @IBOutlet var passLogin: UITextField!
    
    
    //////////////////////
    //at create Account
    @IBAction func createAccountBtn(_ sender: UIButton) {
        if EmailCreate.text == "" || PasswordCreate.text == ""{
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: EmailCreate.text!, password: PasswordCreate.text!) { (user, error) in
                
                if error == nil {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Account")
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
    
    //at login btn
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        if self.emailLogin.text == "" || self.passLogin.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.signIn(withEmail: self.emailLogin.text!, password: self.passLogin.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    
    
    
}
