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
    
    
    @IBOutlet weak var theLocationButton: UIButton!
    @IBOutlet weak var theSearchButton: UIButton!
    @IBOutlet weak var theSearchTableView: UITableView!
    @IBOutlet weak var theMainView: UIView!
    
    override func viewDidLoad(){
        
        //sets the superclasses, navbar buttons and searchviews to allow for it to work
        locationButton = theLocationButton
        searchButton = theSearchButton
        mainView = theMainView
        searchTableView = theSearchTableView
        
        super.viewDidLoad()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func update(){
        print("DO STUFF NOW.  Probably want to update an airport label or something.  Look in 'update' method in MapViewController.swift")
    }
    
}
