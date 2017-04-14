//
//  ViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/5/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: BonsaiViewController {
    
    //these buttons need outlets because they need to be disabled while the app is searching it's own location or the app messes up
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    
    @IBOutlet weak var theSearchTableView: UITableView!
    
    var updateTimer:Timer? = nil    //the updateTimer will poll the bonsai api once a minute incase wait times change
    
    var bezierBorder:BezierBorder? = nil
    var borderBackground:CAShapeLayer? = nil
    var borderFront:CAShapeLayer? = nil

    
    override func viewDidLoad() {
        
        searchTableView = theSearchTableView
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        //setup the navigation bar
        navigationItem.titleView = nil
        searchBarButtonItem = navigationItem.rightBarButtonItem
        curLocButtonItem = navigationItem.leftBarButtonItem
        airportSearchBar.showsCancelButton = true
        
        //set background image
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "city_night")!)
        
        //set the timer to poll once a minute
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateWaitTimeAndDisplay), userInfo: nil, repeats: true)
        
        //set the text fields to blank and start animating the activity indicator until the airport data is loaded
        activityIndicator.startAnimating()
        airportLabel.alpha = 0
        waitLabel.alpha = 0
        minsLabel.alpha = 0
        
        //set the border to surround the wait label
        bezierBorder = BezierBorder(s: 10, r: waitLabel.frame)
        borderBackground = bezierBorder?.backgroundLayer
        borderFront = bezierBorder?.frontLayer
        waitTimeView.layer.addSublayer(borderBackground!)
        waitTimeView.layer.addSublayer(borderFront!)
        
        //move the request installation button to off the screen
        self.requestView.alpha = 0
        self.requestViewYConstraint.constant = self.mainView.frame.height
        
        requestBlurView.effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        requestBlurView.alpha = 0
        
        update()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSearchBar() {
        airportSearchArr = []
        airportSearchBar.text = ""
        searchTableView.reloadData()
        navigationItem.titleView = airportSearchBar
        airportSearchBar.alpha = 0
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.setLeftBarButton(nil, animated: true)
        mainView.addSubview(blurView)
        if curAirportHasBonsai{
            blurView.alpha = 0
        }
        else{
            blurView.alpha = 1
            requestBlurView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.airportSearchBar.alpha = 1
            self.blurView.alpha = 1
        }, completion: { finished in
            self.airportSearchBar.becomeFirstResponder()
            self.searchTableView.isHidden = false
            
            //add a blur over the original image
            
            
            
        })
    }
    
    override func hideSearchBar() {
        navigationItem.setRightBarButton(searchBarButtonItem, animated: true)
        navigationItem.setLeftBarButton(curLocButtonItem, animated: true)
        if curAirportHasBonsai{
            blurView.alpha = 0
            requestBlurView.alpha = 1
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationItem.titleView = nil
            self.searchTableView.isHidden = true
            self.blurView.alpha = 0
        }, completion: { finished in
            self.blurView.removeFromSuperview()
        })
    }
    
    func updateFadeIn(){
        UIView.animate(withDuration: 0.3, animations: {
            self.activityIndicator.alpha = 0
            self.airportLabel.alpha = 1
            self.waitLabel.alpha = 1
            self.minsLabel.alpha = 1
        }, completion: { finished in
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
        })
    }
    
    
    //this function moves the request installation button onto the screen if bonsai is not installed and off the screen if bonsai is installed
    func bonsaiInstallationCheck(){
        print("Check")
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
                
                
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.requestAirportNameLabel.alpha = 0
                }, completion: { finished in
                    self.requestAirportNameLabel.text = curAirport?.getName()
                    UIView.animate(withDuration: 0.4, animations: {
                        self.requestAirportNameLabel.alpha = 1
                    })
                })
 
            }
            
        }
    }
    
    override func update(){
        
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
                self.locationButton.isEnabled = true
                self.searchButton.isEnabled = true
                self.bonsaiInstallationCheck()
                self.updateFadeIn() //this doesn't affect anything if the components have already faded in
                self.updateWaitTimeAndDisplay()
            }
        }
        
        
    }
    
    func updateWaitTimeAndDisplay(){
        
        if curAirportHasBonsai{
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
        
        
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        showSearchBar()
    }
    
    @IBAction func useCurrentLocationButtonPressed(_ sender: UIButton) {
        curAirport = nil
        airportType = .location
        update()
    }
    
}

