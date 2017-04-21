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

class SignInController: UIViewController, FBSDKLoginButtonDelegate{
    
    override func viewDidLoad() {
<<<<<<< HEAD
        //loads the airports from the csv into the var airports
        super.viewDidLoad()
        print("test")
        loadAirportsFromCSV()
    }
    
    func loadAirportsFromCSV(){
=======
        super.viewDidLoad()
        let loginButton = FBSDKLoginButton()
            loginButton.delegate = self
            loginButton.center = view.center
            view.addSubview(loginButton)
>>>>>>> origin/master
        
        //make sure you have a file called "airports.csv" in the same main directory, not the assets folder
        
        guard let csvPath = Bundle.main.path(forResource: "airports", ofType: "csv") else { return }
        do {
            let csvData = try String(contentsOfFile: csvPath, encoding: String.Encoding.macOSRoman)
            let csv = csvData.csvRows()
            let numRows = csv.count
            
            for rowIndex in 1..<numRows-1{
                let acode:String = csv[rowIndex][0]
                let aname:String = csv[rowIndex][1]
                let alat:CLLocationDegrees = Double(csv[rowIndex][3])!
                let along:CLLocationDegrees = Double(csv[rowIndex][2])!
                let aloc = CLLocation(latitude: alat, longitude: along)
                let aterm:String = csv[rowIndex][5]
                let a = Airport(n: aname, c: acode, l: aloc, t: aterm)
                airports.append(a)
            }
            
        } catch{
            print(error)
        }
        print(airports)
    }
    override func viewDidAppear(_ animated: Bool) {
        if FBSDKAccessToken.current() != nil{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            self.present(vc!, animated: true, completion: nil)
            }
        }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        return
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil){
            print(error.localizedDescription)
        }
        else{
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if error != nil {
            print(error!)
            return
            }
            else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(vc!, animated: true, completion: nil)
            }
        }
        }
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
