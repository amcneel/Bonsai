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
    @IBOutlet weak var theSearchTableView: UITableView!
    @IBOutlet weak var theMainView: UIView!
    
    var terms = curAirport?.getTerm()
    
    override func viewDidLoad(){
        
        //sets the superclasses, navbar buttons and searchviews to allow for it to work
        locationButton = theLocationButton
        searchButton = theSearchButton
        mainView = theMainView
        searchTableView = theSearchTableView
        update()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func rightSwipe(_ sender: UISwipeGestureRecognizer) {
    }
    
    
    @IBAction func leftSwipe(_ sender: UISwipeGestureRecognizer) {
    }
    
    //this method is called once the airport is updated, either through search bar or location button
    override func update(){
        codeLabel.text = curAirport?.getCode()
        terms = curAirport?.getTerm()
        let count = terms?.components(separatedBy: ",").count
        pageControl.numberOfPages = count!
        let termArray = terms?.components(separatedBy: ",")
        let counter = 0
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
        mapImage.image = map
    }
    
}
