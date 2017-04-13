//
//  ViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/5/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit
import CoreLocation

enum AirportType{
    case location
    case searchbar
}

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var firstTimeLoading:Bool = true
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var airportType:AirportType = .location //used in update, determines which function to use when determining the wait times
    
    @IBOutlet weak var mainView: UIView!
    var curAirport:Airport?
    
    let locationManager = CLLocationManager()
    var airports:[Airport] = []
    
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    
    var airportSearchBar = UISearchBar()
    @IBOutlet weak var searchTableView: UITableView!
    
    var searchBarButtonItem: UIBarButtonItem?
    var curLocButtonItem: UIBarButtonItem?
    
    var updateTimer:Timer? = nil    //the updateTimer will poll the bonsai api once a minute incase wait times change
    
    
    var airportSearchArr:[Airport] = []    //the array of airports displayed when the search bar is in use
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    
    var bezierBorder:BezierBorder? = nil
    var borderBackground:CAShapeLayer? = nil
    var borderFront:CAShapeLayer? = nil
    
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
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "city_night")!)
        searchTableView.backgroundColor = .clear
        searchTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        //set the timer to poll once a minute
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateWaitTimeAndDisplay), userInfo: nil, repeats: true)
        
        
        //add a blur view - used in show search bar and hide search bar
        blurView.frame = self.view.bounds
        
        //set the text fields to blank and start animating the activity indicator until the airport data is loaded
        activityIndicator.startAnimating()
        airportLabel.alpha = 0
        waitLabel.alpha = 0
        
        
        //set the border to surround the wait label
        bezierBorder = BezierBorder(s: 10, r: waitLabel.frame)
        borderBackground = bezierBorder?.backgroundLayer
        borderFront = bezierBorder?.frontLayer
        mainView.layer.addSublayer(borderBackground!)
        mainView.layer.addSublayer(borderFront!)
        
        
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
    
    //the main function atm
    //once we obtain our location, it calculates the closest airport and wait time
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //this is our location, i think
        //on the mac labs it says we're in california, but it's always consitent
        let someLocation = locations[0]
        //print("Your location is \(someLocation)")
        curAirport = getClosestAirport(location: someLocation)
        
    }
    
    func updateWaitTimeAndDisplay(){
        let waitTime = getWaitTime(airport: curAirport!)
        //the next 4 lines of code are temporary, they just change the labels on the phone so we can see our location, the closest airport, and wait times.  It is ugly and should be changed
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
        print(airportSearchArr)
        searchTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airportSearchArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let myCell = searchTableView.dequeueReusableCell(withIdentifier: "AirportSearchCell", for: indexPath) as! AirportSearchCell
        let a = airportSearchArr[indexPath.row]
        //let aString = a.getCode()+" - "+a.getName()
        //myCell.textLabel?.text = aString
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
        
        print(myCell)
        print(myCell.tintColor)
        
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curAirport = airportSearchArr[indexPath.row]
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
        navigationItem.setRightBarButton(searchBarButtonItem, animated: true)
        navigationItem.setLeftBarButton(curLocButtonItem, animated: true)
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
        }, completion: { finished in
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
        })
    }
    
    
    func update(){
        
        DispatchQueue.global(qos: .userInitiated).async{
            switch self.airportType{
            case .location:
                self.locationManager.requestLocation()
                while self.curAirport == nil{
                    sleep(1)
                }
                break
            default:
                break
            }
            
            DispatchQueue.main.async {
                
                self.updateWaitTimeAndDisplay()
                //if this is the first time updating, have the labels fade in
                //if this is the location have the labels fade in
                if self.airportType == .location || self.firstTimeLoading{
                    self.updateFadeIn()
                }
            }
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

