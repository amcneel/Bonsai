//
//  AlarmView.swift
//  Bonsai-FinalProject
//
//  Created by Tarun Chally on 4/7/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

//the view controller that displays the alarm stuff
//all global variables found in GlobalVariables.swift
class AlarmView: BonsaiViewController, UITextFieldDelegate, UIPickerViewDelegate{
    
    
    @IBOutlet weak var airportCode: UILabel!
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var theLocationButton: UIButton!
    @IBOutlet weak var theSearchButton: UIButton!
    
    @IBOutlet weak var theSearchTableView: UITableView!
    @IBOutlet weak var theMainView: UIView!
    
    @IBOutlet weak var alarmTime: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var date: UITextField!
    override func viewDidLoad(){
        
        //sets the superclasses, navbar buttons and searchviews to allow for it to work
        activityIndicator = theActivityIndicator
        locationButton = theLocationButton
        searchButton = theSearchButton
        mainView = theMainView
        searchTableView = theSearchTableView
        
        super.viewDidLoad()
        
        
        datePicker.minimumDate = Date()
        //datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        datePicker.datePickerMode = .countDownTimer
        datePicker.datePickerMode = .dateAndTime
        datePicker.tintColor = UIColor.white
        datePicker.addTarget(self, action: #selector(AlarmView.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        alarmTime.text = "Your alarm is not scheduled."
        airportCode.text = curAirport?.getCode()
        updateDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainView = theMainView
        mainView.backgroundColor = mainBackgroundColor
        if FBSDKAccessToken.current() == nil && FIRAuth.auth()?.currentUser == nil{
            self.view.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.tag = 100
            self.view.addSubview(blurEffectView)
            addGrayedText()
            addLoginBtn()
        }
        else{
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            }
            if let viewWithOtherTag = self.view.viewWithTag(99){
                viewWithOtherTag.removeFromSuperview()
            }
            if let viewWithBtnTag = self.view.viewWithTag(98){
                viewWithBtnTag.removeFromSuperview()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isUpdating{
            mainView = theMainView
            mainView.backgroundColor = mainBackgroundColor
            updateDisplay()
        }
        
        
    }
    
    func datePickerValueChanged (sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        var timeStr = dateFormatter.string(from: sender.date)
        dateFormatter.dateStyle = DateFormatter.Style.none
        dateFormatter.timeStyle = DateFormatter.Style.short
        timeStr = timeStr + " at " + dateFormatter.string(from: sender.date)
        alarmTime.text = "Your alarm is scheduled for " + timeStr + ". Press enter to confirm this time."
        //alarmTime.tintColor = UIColor.white
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateDisplay(){
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        self.airportCode.text = curAirport?.getCode()
    }
    
    //this method is called once the airport is updated, either through search bar or location button
    override func update(){
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async{
            switch airportType{
            case .location:
                self.searchButton.isEnabled = false
                self.locationButton.isEnabled = false
                self.locationManager.requestLocation()
                while curAirport == nil{
                    sleep(1)
                }
                break
            default:
                break
            }
            
            
            
            DispatchQueue.main.async {
                isUpdating = false
                self.locationButton.isEnabled = true
                self.searchButton.isEnabled = true
                self.setImageToCity()
                self.updateDisplay()
            }
        }
    }
    
    
    func addGrayedText(){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 600, height: 100))
        label.font = UIFont(name: "Futura", size: 30)
        label.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "login to use alarms"
        label.tag = 99
        self.view.addSubview(label)
    }
    
    func addLoginBtn(){
        let button = TitleButton(frame: CGRect(x: view.frame.size.width/2 - 69, y: view.frame.size.height/2 + 50, width: 137, height: 30))
        button.backgroundColor = UIColor.black
        button.setTitle("Login", for: .normal)
        button.layer.cornerRadius = 10.0
        button.tag = 98
        button.addTarget(self, action: #selector(addedLoginBtnTapped), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    func addedLoginBtnTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Initial")
        self.present(vc!, animated: true, completion: nil)
    }
    
}
