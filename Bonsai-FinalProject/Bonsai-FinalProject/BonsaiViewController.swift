//
//  BonsaiViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/14/17.
//  Copyright © 2017 wustl. All rights reserved.
//


import UIKit
import CoreLocation

enum AirportType{
    case location
    case searchbar
}

var curAirport:Airport?
var curAirportHasBonsai:Bool = true     //used to see whether to show install button or wait time
var prevAirportHasBonsai:Bool = true    //used for transitions between airports
var airportType:AirportType = .location //used in update, determines which function to use when determining the wait times

//the base class for the views that utilize the searchbar
class BonsaiViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mainView: UIView!
    
    let locationManager = CLLocationManager()
    var airports:[Airport] = []
    
    var airportSearchBar = UISearchBar()
    @IBOutlet weak var searchTableView: UITableView!
     
    var searchBarButtonItem: UIBarButtonItem?
    var curLocButtonItem: UIBarButtonItem?

    var airportSearchArr:[Airport] = []    //the array of airports displayed when the search bar is in use
    
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //loads the airports from the csv into the var airports
        loadAirportsFromCSV()
        
        //the main function at the moment is locationManager, as all the calculations happen once we know where we are
        //TODO: have the location manager run asyncronously, so that it doesn't freeze the app
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
        airportSearchBar.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isHidden = true
        
        //setup the navigation bar
        navigationItem.titleView = nil
        searchBarButtonItem = navigationItem.rightBarButtonItem
        curLocButtonItem = navigationItem.leftBarButtonItem
        airportSearchBar.showsCancelButton = true
        
        //set background image
        searchTableView.backgroundColor = .clear
        searchTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        //add a blur view - used in show search bar and hide search bar
        blurView.frame = self.view.bounds
        
        update()
    }
    
    func loadAirportsFromCSV(){
        
        //make sure you have a file called "airports.csv" in the same main directory, not the assets folder
        
        guard let csvPath = Bundle.main.path(forResource: "airports", ofType: "csv") else { return }
        do {
            let csvData = try String(contentsOfFile: csvPath, encoding: String.Encoding.macOSRoman)
            let csv = csvData.csvRows()
            let numRows = csv.count
            
            for rowIndex in 1..<numRows-1{
                let acode:String = csv[rowIndex][0]
                let aname:String = csv[rowIndex][1]
                let alat:CLLocationDegrees = Double(csv[rowIndex][3])!
                let along:CLLocationDegrees = Double(csv[rowIndex][2])!
                let aloc = CLLocation(latitude: alat, longitude: along)
                let a = Airport(n: aname, c: acode, l: aloc)
                airports.append(a)
            }
            
        } catch{
            print(error)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getClosestAirport(location:CLLocation)->Airport{
        var minDistance = CLLocationDistance(Double.infinity)
        var minAirport = airports[0]
        for a in airports{
            let l = a.getLoc()
            let d = l.distance(from: location)
            if d < minDistance{
                minDistance = d
                minAirport = a
            }
        }
        return minAirport
    }
    
    func getWaitTime(airport:Airport)->WaitTime{
        //because this is http and not https, the Info.plist must have "App Transport Security -> Allow Arbitrary Loads: YES"
        let baseURL = "http://bonsaiapi-dev.us-east-1.elasticbeanstalk.com/webApi/v1/locationStatusSummary/"
        let fullPath = baseURL+airport.getCode()
        let json = getJSON(path: fullPath)
        let wl = json["waitLower"].doubleValue
        let ew = json["expectedWait"].doubleValue
        let wu = json["waitUpper"].doubleValue
        let lk = json["locationKey"].stringValue
        let wt = WaitTime(lower: wl, expected: ew, upper: wu, locationKey: lk)
        return wt
    }
    
    
    //once we obtain our location, it calculates the closest airport and wait time
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //this is our location, i think
        //on the mac labs it says we're in california, but it's always consitent
        let someLocation = locations[0]
        //print("Your location is \(someLocation)")
        curAirport = getClosestAirport(location: someLocation)
        
        prevAirportHasBonsai = curAirportHasBonsai
        //THIS NEEDS TO CHANGE
        if curAirport?.getCode() == "STL" || curAirport?.getCode() == "BOS"{
            curAirportHasBonsai = false
        }
        else{
            curAirportHasBonsai = true
        }
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print(error)
    }
    
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        airportSearchArr = []
        //first append the airport if the code matches
        
        let st = searchText.uppercased()
        let searchLength = st.characters.count
        for a in airports{
            let acode = a.getCode().uppercased()
            if searchLength>acode.characters.count{
                //they entered text longer than the code, so it cannot be a code
                continue
            }
            let codeSubIndex = acode.index(acode.startIndex, offsetBy:searchLength)
            let codeSubstring = acode.substring(to: codeSubIndex)   //get the first n characters of the airport code
            if codeSubstring == st{
                airportSearchArr.append(a)
            }
        }
        //now add the airport if the name contains the searchText
        for a in airports{
            let aname = a.getName().uppercased()
            if aname.contains(st) && !airportSearchArr.contains(a){
                airportSearchArr.append(a)
            }
        }
        searchTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airportSearchArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myCell = searchTableView.dequeueReusableCell(withIdentifier: "AirportSearchCell", for: indexPath) as! AirportSearchCell
        let a = airportSearchArr[indexPath.row]
        myCell.code.text = a.getCode()
        myCell.name.text = a.getName()
        myCell.tintColor = UIColor.white
        return myCell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myCell = cell as! AirportSearchCell
        
        myCell.code.tintColor = UIColor.white
        myCell.code.shadowColor = UIColor.black
        myCell.name.tintColor = UIColor.white
        myCell.name.shadowColor = UIColor.black
        //myCell.backgroundColor = myCell.backgroundColor?.withAlphaComponent(0.1)
        myCell.backgroundColor = .clear
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curAirport = airportSearchArr[indexPath.row]
        
        prevAirportHasBonsai = curAirportHasBonsai
        //THIS NEEDS TO CHANGE
        if curAirport?.getCode() == "STL" || curAirport?.getCode() == "BOS"{
            curAirportHasBonsai = false
        }
        else{
            curAirportHasBonsai = true
        }
        
        hideSearchBar()
        airportType = .searchbar
        update()
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
        blurView.alpha = 0
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
    
    func hideSearchBar() {
        preconditionFailure("function 'hideSearchBar' must be overridden")
    }
    
    
    func update(){
        preconditionFailure("function 'update' must be overridden")
    }

    
    
}
