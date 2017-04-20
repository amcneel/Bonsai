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
    
    //@IBOutlet weak var UsernameCreate: UITextField!
    
    @IBOutlet weak var PasswordCreate: UITextField!
    
    //for sign in
    @IBOutlet weak var UsernameSignin: UITextField!
    
    @IBOutlet weak var PasswordSignin: UITextField!
    
    //////////////////////
    //at create Account
    @IBAction func createAccountBtn(_ sender: UIButton) {
        FIRAuth.auth()?.createUser(withEmail: EmailCreate.text!, password: PasswordCreate.text!){
            user, error in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: self.UsernameSignin.text!, password: self.PasswordSignin.text!)
            }
        }
    }
    
    //at login btn
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        FIRAuth.auth()?.signIn(withEmail: UsernameSignin.text!, password: PasswordSignin.text!)
    }
    
    
    
    
}
