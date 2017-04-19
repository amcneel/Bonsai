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
import MessageUI

//set up logout button so that it disconnects you from the SQL database, not just segways you back to the main page
class AccountController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate{
    
    //when fbButton is Clicked
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
    
    //when twitter button is Clicked
    @IBAction func twitterButtonClicked(_ sender: Any) {
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)) {
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            //TODO FIXME
            //add estimated time of wait later
            // either make additional json call or ask jesse how to get the number?
            
            socialController?.setInitialText("There's a 30 minute wait at the STL Airport! Find your wait with #Bonsai")
            
            //this line will be the link to the app store to get the bonsai app
            //socialController.addURL(someNSURLInstance)
            
            self.present(socialController!, animated: true, completion: nil)
            
        }
            //Case in that the iOS device doesnt have Facebook installed
            
        else{
            let alertController = UIAlertController(title: "Twitter Not Found", message:
                "Please install Twitter", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    //help for this found at 
    // http://stackoverflow.com/questions/26350220/sending-sms-in-ios-with-swift
    
    //code for sending messages when message button is clicked
    @IBAction func messagesClicked(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let messageController = MFMessageComposeViewController()
            messageController.body = "There's a 30 minute wait at the STL Airport! Find your wait with Bonsai!"
            messageController.messageComposeDelegate = self
            self.present(messageController, animated: true, completion: nil)
        }
       
    }
        func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
            //... handle sms screen actions
            self.dismiss(animated: true, completion: nil)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            self.navigationController?.isNavigationBarHidden = false
        }
    
    //code for sending email when email button is clicked
    //found at 
    //http://stackoverflow.com/questions/28963514/sending-email-with-swift
    
    @IBAction func emailButton(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setSubject("Check out Bonsai!")
        mailComposerVC.setMessageBody("There's a 30 minute wait at the STL Airport! Find your wait with Bonsai", isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismiss(animated: true, completion: nil)
        
    }

}





    


