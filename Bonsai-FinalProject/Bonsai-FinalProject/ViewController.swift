//
//  ViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/5/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseInstanceID

//the view that displays the wait time
//uses global variables stored in globalvariables.swift
class ViewController: BonsaiViewController {
    
    @IBOutlet weak var infoButton: UIButton!
    
    //these buttons need outlets because they need to be disabled while the app is searching it's own location or the app messes up
    @IBOutlet weak var theLocationButton: UIButton!
    @IBOutlet weak var theSearchButton: UIButton!
    
    @IBOutlet weak var requestViewActivityIndicator: UIActivityIndicatorView!
    
    //this view is shown when the airport does not have bonsai installed
    //it consists of a label saying that bonsai is not installed and a button requesting that bonsai be installed
    
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var requestViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestAirportNameLabel: UILabel!
    //blurs the background when the request button is showing for legibility
    @IBOutlet weak var requestBlurView: UIVisualEffectView!
    
    
    
    //this view is shows when the airport has bonsai installed
    //it has the corner airport view, the wait time, and the surrounding circle
    @IBOutlet weak var waitTimeView: UIView!
    @IBOutlet weak var waitTimeViewYConstraint: NSLayoutConstraint!
    
    var firstTimeLoading:Bool = true
    
    @IBOutlet weak var requestInstallationButton: BonsaiButton!
    
    
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!  //the activity indicator in the top left that appears when an airport is updating
    
    @IBOutlet weak var initialActivityIndicator: UIActivityIndicatorView!   //the activity indicator that appears when the view first loads
    
    @IBOutlet weak var theMainView: UIView!
    
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    
    @IBOutlet weak var theSearchTableView: UITableView!
    
    var updateTimer:Timer? = nil    //the updateTimer will poll the bonsai api once a minute incase wait times change
    
    var bezierBorder:BezierBorder? = nil
    var borderBackground:CAShapeLayer? = nil
    var borderFront:CAShapeLayer? = nil
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        mainView = theMainView
        mainView.backgroundColor = mainBackgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isUpdating && !firstTimeLoading{
            print("this is happening")
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            updateFadeIn()
            bonsaiInstallationCheck()
            updateDisplay()
            
        }
        else if firstTimeLoading{
            firstTimeLoading = false
        }
        
    }
    
    override func viewDidLoad() {
        //sets the superclasses, navbar buttons and searchviews to allow for it to work
        isUpdating = true
        
        activityIndicator = theActivityIndicator
        locationButton = theLocationButton
        searchButton = theSearchButton
        mainView = theMainView
        searchTableView = theSearchTableView
        
        //set background image
        
        //set the timer to poll once a minute
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
        
        //set the text fields to blank and start animating the activity indicator until the airport data is loaded
        initialActivityIndicator.startAnimating()
        airportLabel.alpha = 0
        waitLabel.text = ""
        waitLabel.alpha = 0
        minsLabel.alpha = 0
        activityIndicator.isHidden = true
        
        //move the request installation button to off the screen
        self.requestView.alpha = 0
        self.requestViewYConstraint.constant = mainView.frame.height
        
        requestBlurView.effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        requestBlurView.alpha = 0
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        update()

        //we can't set the bezierborder here because the constraints don't update until after viewdidload
        //we set bezierborder in updateWaitTimeDisplay
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func showSearchBar() {
        if curAirportHasBonsai{
            blurView.alpha = 0
        }
        else{
            blurView.alpha = 1
            requestBlurView.alpha = 0
        }
        super.showSearchBar()
    }
    
    override func hideSearchBar() {
        if !curAirportHasBonsai{
            blurView.alpha = 0
            requestBlurView.alpha = 1
        }
        super.hideSearchBar()
    }
    
    func updateFadeIn(){
        UIView.animate(withDuration: 0.3, animations: {
            self.initialActivityIndicator.alpha = 0
            self.airportLabel.alpha = 1
            self.waitLabel.alpha = 1
            self.minsLabel.alpha = 1
        }, completion: { finished in
            self.initialActivityIndicator.stopAnimating()
            self.initialActivityIndicator.isHidden = true
            
        })
    }
    
    
    //this function moves the request installation button onto the screen if bonsai is not installed and off the screen if bonsai is installed
    func bonsaiInstallationCheck(){
        if curAirportHasBonsai{
            UIView.animate(withDuration: 0.6, animations: {
                self.waitTimeView.alpha = 1
                self.waitTimeViewYConstraint.constant = 0
                
                self.requestView.alpha = 0
                self.requestViewYConstraint.constant = self.mainView.frame.height
                self.requestBlurView.alpha = 0
                
                
                self.view.layoutIfNeeded()
            }, completion: { finished in
                
                
            })
        }
        else{
            //doesnt have bonsai, load the request button
            
            //we have to move everything onto the screen if the previous airport did have bonsai
            if prevAirportHasBonsai == true{
                if (curAirport?.hasSubmittedRequest)!{
                    requestInstallationButton.disable()
                }
                else{
                    requestInstallationButton.enable()
                }
                self.requestAirportNameLabel.text = curAirport?.getName()
                if airportType == .searchbar{
                    requestBlurView.alpha = 1
                }
                UIView.animate(withDuration: 0.6, animations: {
                    self.waitTimeView.alpha = 0
                    self.waitTimeViewYConstraint.constant = -1*self.mainView.frame.height
                    
                    self.requestView.alpha = 1
                    self.requestViewYConstraint.constant = 0
                    self.requestBlurView.alpha = 1
                    
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.bezierBorder?.setValue(v: 0)
                    self.waitLabel.text = ""
                })
            }
            else{
                //stuff to do if you load an airport that doesn't have bonsai from an airport that did have bonsai
                
                
                
                UIView.animate(withDuration: 0.6, animations: {
                    self.requestAirportNameLabel.alpha = 0
                    self.requestInstallationButton.alpha=0
                }, completion: { finished in
                    self.requestAirportNameLabel.text = curAirport?.getName()
                    if (curAirport?.hasSubmittedRequest)!{
                        self.requestInstallationButton.disable()
                    }
                    else{
                        self.requestInstallationButton.enable()
                    }
                    UIView.animate(withDuration: 0.4, animations: {
                        self.requestInstallationButton.alpha = 1
                        self.requestAirportNameLabel.alpha = 1
                    })
                })
 
            }
            
        }
    }
    
    override func update(){
        isUpdating = true
        if !firstTimeLoading{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            requestViewActivityIndicator.isHidden = false
            requestViewActivityIndicator.startAnimating()
        }
        
        
        DispatchQueue.global(qos: .userInitiated).async{
            switch airportType{
            case .location:
                self.searchButton.isEnabled = false
                self.locationButton.isEnabled = false
                self.locationManager.requestLocation()
                while isUpdating{
                    sleep(1)
                }
                break
            default:
                isUpdating = false
                break
            }
            
            
            
            DispatchQueue.main.async {
                print("update async finished")
                
                
                
                self.locationButton.isEnabled = true
                self.searchButton.isEnabled = true
                self.bonsaiInstallationCheck()
                self.updateFadeIn()
                self.setBackgroundImage()
                self.updateDisplay()
            }
        }
        
        
    }
    
    override func updateDisplay(){
        self.mainView.backgroundColor = mainBackgroundColor
        self.mainView.setNeedsDisplay()
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        requestViewActivityIndicator.stopAnimating()
        requestViewActivityIndicator.isHidden = true
        
        //set background image
        
        
        
        if bezierBorder == nil{
            //set the border to surround the wait label
            bezierBorder = BezierBorder(s: 10, r: waitLabel.frame)
            borderBackground = bezierBorder?.backgroundLayer
            borderFront = bezierBorder?.frontLayer
            waitTimeView.layer.addSublayer(borderBackground!)
            waitTimeView.layer.addSublayer(borderFront!)
        }
        
        if curAirportHasBonsai{
            if curAirport == nil{
                return
            }
            let waitTime = getWaitTime(airport: curAirport!)
            let waitTimeString = String(Int(waitTime.expected))
            
            //make the labels transition smoothly
            let animation: CATransition = CATransition()
            animation.duration = 1.0
            animation.type = kCATransitionFade
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.airportLabel.layer.add(animation, forKey: "changeTextTransition")
            self.waitLabel.layer.add(animation, forKey: "changeTextTransition")
            
            waitLabel.text = waitTimeString
            airportLabel.text = curAirport?.getCode()
            
            bezierBorder?.setValue(v:CGFloat(Int(waitTime.expected)))
        }
        isUpdating = false
        //getTravelTime()
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = "flip"
        transition.subtype = kCATransitionFromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(infoVC!, animated: false)
    }
    
    
    @IBAction func requestBonsaiButtonPressed(_ sender: UIButton) {
        
        curAirport?.hasSubmittedRequest = true
        
        requestInstallationButton.disable()
        
    }
    
    
}

