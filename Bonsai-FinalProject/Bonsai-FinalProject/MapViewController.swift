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
        terms = curAirport?.getTerm()
        let count = terms?.components(separatedBy: ",").count
        let termArray = terms?.components(separatedBy: ",")
        pageControl.numberOfPages = count!
        
        
        super.viewDidLoad()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this method is called once the airport is updated, either through search bar or location button
    override func update(){
        //terms = curAirport?.getTerm()
        //count = terms?.components(separatedBy: ",").count
        
        //airport = airport + "-"
        //let charset = CharacterSet(charactersIn: airport)
        //  let imageURL = Bundle.main.url(forResource: airport, withExtension: "png")
        //     print(imageURL)
    }
    
}
