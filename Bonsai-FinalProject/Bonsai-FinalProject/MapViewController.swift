//
//  MapViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/14/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit

//the view controller that displays all the airport maps
//all global variables found in GlobalVariables.swift
class MapViewController: BonsaiViewController{
    
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var theLocationButton: UIButton!
    @IBOutlet weak var theSearchButton: UIButton!
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var theSearchTableView: UITableView!
    @IBOutlet weak var theMainView: UIView!
    
    var terms = curAirport?.getTerm()
    var counter = 0
    
    
    override func viewDidLoad(){
        
        //sets the superclasses, navbar buttons and searchviews to allow for it to work
        
        activityIndicator = theActivityIndicator
        locationButton = theLocationButton
        searchButton = theSearchButton
        mainView = theMainView
        searchTableView = theSearchTableView
        
        super.viewDidLoad()
        
        update()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func rightSwipe(_ sender: UISwipeGestureRecognizer) {
        if (counter>0){
            counter-=1
            pageControl.currentPage = counter
            update()
        }
        
    }
    
    
    @IBAction func leftSwipe(_ sender: UISwipeGestureRecognizer) {
        if (counter<pageControl.numberOfPages-1){
            counter+=1
            pageControl.currentPage = counter
            update()
        }
    }
    
    func updateDisplay(){
        codeLabel.text = curAirport?.getCode()
        terms = curAirport?.getTerm()
        let count = terms?.components(separatedBy: ",").count
        pageControl.numberOfPages = count!
        if(counter>count!-1){
            counter = 0
            pageControl.currentPage = counter
        }
        let termArray = terms?.components(separatedBy: ",")
        let spaceName = termArray?[counter]
        let code = curAirport?.getCode()
        var formattedName = ""
        if (code == "ATL" || code == "BWI" || code == "DEN" ||  code == "RDU" ||  code == "SAN"){
            formattedName = (code! + "-" + (spaceName?.replacingOccurrences(of: " ", with: "-"))! + ".png")
        }
        else if (code == "MCI"){
            formattedName = ("Kansas-City-" + code! + "-" + (spaceName?.replacingOccurrences(of: " ", with: ""))! + ".jpg")
        }
        else{
            formattedName = (code! + "-" +  (spaceName?.replacingOccurrences(of: " ", with: "-"))!+".jpg")
        }
        let map = UIImage(named: formattedName)
        UIView.transition(with: mapImage, duration: 1, options: .transitionCrossDissolve, animations: {
            //http://300.dgljamaica.com/assets/images/unavailable_1.jpg
            if map == nil{
                self.mapImage.image = UIImage(named: "ICS.png")
            }
            else {
                self.mapImage.image = map
            }
        }, completion: nil)
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
                //curAirport = airports[0]
                while curAirport == nil{
                    sleep(1)
                }
                break
            default:
                break
            }
            
            
            
            DispatchQueue.main.async {
                isUpdating = false
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.locationButton.isEnabled = true
                self.searchButton.isEnabled = true
                self.updateDisplay()
            }
        }
    }
    
}
