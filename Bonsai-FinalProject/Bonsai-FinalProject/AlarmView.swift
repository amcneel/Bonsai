//
//  AlarmView.swift
//  Bonsai-FinalProject
//
//  Created by Tarun Chally on 4/7/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit


//the view controller that displays the alarm stuff
//all global variables found in GlobalVariables.swift
class AlarmView: BonsaiViewController, UITextFieldDelegate, UIPickerViewDelegate{
    
    
    @IBOutlet weak var theLocationButton: UIButton!
    @IBOutlet weak var theSearchButton: UIButton!
    
    @IBOutlet weak var theSearchTableView: UITableView!
    @IBOutlet weak var theMainView: UIView!
    
    @IBOutlet weak var alarmTime: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var date: UITextField!
    override func viewDidLoad(){
        
        //sets the superclasses, navbar buttons and searchviews to allow for it to work
        locationButton = theLocationButton
        searchButton = theSearchButton
        mainView = theMainView
        searchTableView = theSearchTableView
        
        super.viewDidLoad()
        
        datePicker.minimumDate = Date()
        //datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        datePicker.datePickerMode = .countDownTimer
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(AlarmView.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        alarmTime.text = "Your alarm is not scheduled."
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
    
    override func update(){
        print("DO STUFF NOW.  Probably want to update an airport label or something.  Look in 'update' method in AlarmView.swift")
    }
    
}
