//
//  AccountController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/15/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import Foundation
import Social
import UIKit

//set up logout button so that it disconnects you from the SQL database, not just segways you back to the main page
class AccountController: UIViewController{
    
    @IBAction func fbButtonClicked(_ sender: Any) {
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            //TODO FIXME
            //add estimated time of wait later
            // either make additional json call or ask jesse how to get the number?
            
            socialController?.setInitialText("There's a 30 minute wait at the STL Airport! Find your wait with Bonsai")
            
            //this line will be the link to the app store to get the bonsai app
             //socialController.addURL(someNSURLInstance)
            
             self.present(socialController!, animated: true, completion: nil)
            
        }
        //Case in that the iOS device doesnt have Facebook installed
            
        else{
            let alertController = UIAlertController(title: "Facebook Not Found", message:
                "Please install Facebook", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
