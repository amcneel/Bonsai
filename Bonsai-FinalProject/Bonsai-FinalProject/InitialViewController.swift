//
//  InitialViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/21/17.
//  Copyright © 2017 wustl. All rights reserved.
//

//
//  SignInController.swift
//  Bonsai-FinalProject
//
//  Created by Tarun Chally on 4/13/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import CoreLocation
import UIKit
import FirebaseAuth
import FBSDKLoginKit

class InitialViewController: UIViewController{
    
    override func viewDidLoad() {
        //loads the airports from the csv into the var airports
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil || FBSDKAccessToken.current() != nil{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            self.present(vc!, animated: true, completion: nil)
        }
    }
    @IBAction func signIn(_ sender: UIButton) {
        if FIRAuth.auth()?.currentUser != nil || FBSDKAccessToken.current() != nil{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            self.present(vc!, animated: true, completion: nil)
        }
        else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Signin")
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    
    
    
}
