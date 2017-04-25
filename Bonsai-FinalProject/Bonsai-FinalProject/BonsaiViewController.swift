//
//  BonsaiViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/14/17.
//  Copyright © 2017 wustl. All rights reserved.
//


import UIKit
import CoreLocation
import MapKit

//the base class for the views that utilize the searchbar
class BonsaiViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mainView: UIView!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    var airportSearchBar = UISearchBar()
    @IBOutlet weak var searchTableView: UITableView!
    
    var searchBarButtonItem: UIBarButtonItem?
    var curLocButtonItem: UIBarButtonItem?
    
    var airportSearchArr:[Airport] = []    //the array of airports displayed when the search bar is in use
    
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    var backgroundOperation = BlockOperation()
    
    override func viewDidLoad() {
                
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if airports.count == 0{
            loadAirportsFromCSV()
        }
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
        
        //add the navbar functions to the search and location buttons
        searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(useCurrentLocationButtonPressed), for: .touchUpInside)
        
        
        mainView.backgroundColor = mainBackgroundColor
        backgroundOperation.addExecutionBlock {
            self.update()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        backgroundOperation.cancel()
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
                let aterm:String = csv[rowIndex][5]
                let anumpics:Int = Int(csv[rowIndex][6])!
                let a = Airport(n: aname, c: acode, l: aloc, t: aterm, p: anumpics)
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
        curLocation = someLocation
        //print("Your location is \(someLocation)")
        curAirport = getClosestAirport(location: someLocation)
        
        updateBonsaiInstallationCheck()
        isUpdating = false
    }
    
    func updateBonsaiInstallationCheck(){
        
        prevAirportHasBonsai = curAirportHasBonsai
        //THIS NEEDS TO CHANGE
        if curAirport?.getCode() == "MCI" || curAirport?.getCode() == "BOS"{
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
        
        updateBonsaiInstallationCheck()
        
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
            self.airportSearchBar.placeholder="Search airports"
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
    
    
    //get the travel time in seconds (TimeInterval is really just a double)
    func getTravelTime() -> TimeInterval?{
        let request: MKDirectionsRequest = MKDirectionsRequest()
        let sourceCoord = curLocation?.coordinate
        let sourcePlacemark:MKPlacemark = MKPlacemark(coordinate: sourceCoord!)
        request.source = MKMapItem(placemark: sourcePlacemark)
        let destCoord = curAirport?.getLoc().coordinate
        let destPlacemark:MKPlacemark = MKPlacemark(coordinate: destCoord!)
        request.destination = MKMapItem(placemark: destPlacemark)
        
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        
        var eta:TimeInterval? = nil
        
        directions.calculate(completionHandler: {(response, error) in
            
            if let routeResponse = response?.routes {
                let quickestRouteForSegment: MKRoute =
                    routeResponse.sorted(by: {$0.expectedTravelTime <
                        $1.expectedTravelTime})[0]
                eta = quickestRouteForSegment.expectedTravelTime
            } else if let _ = error {
                print(error.debugDescription)
            }
        })
        
        return eta
        
    }
    
    func setImageToCity(i:UIImage){
        UIGraphicsBeginImageContext(self.mainView.frame.size)
        i.draw(in: self.mainView.bounds)
        let image: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        mainBackgroundColor = UIColor(patternImage: image)
        UIView.animate(withDuration: 0, animations: {
            self.mainView.backgroundColor = mainBackgroundColor
        })
        
        print("setImageDone")
    }
    
    private func getJSON(path: String) -> JSON {
        if let url=URL(string: path){
            do{
                let json = try Data(contentsOf: url)
                return JSON(data: json)
            }
            catch{
                return JSON.null
            }
        }
        else{
            return JSON.null
        }
        
    }
    
    func setBackgroundImage(){
        let acode = curAirport?.getCode()
        let url = "http://ec2-54-158-29-175.compute-1.amazonaws.com/bonsai/getBackgroundPhoto.php?code="+acode!
        print(url)
        let pictureURL = URL(string: url)!
        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        
        var image = UIImage(named: "city_night")
        let downloadPicTask = session.dataTask(with: pictureURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if (response as? HTTPURLResponse) != nil {
                    //print("Downloaded background picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        image = UIImage(data: imageData)
                        self.setImageToCity(i: image!)
                    } else {
                        print("Couldn't get background image: Image is nil")
                    }
                } else {
                    print("Couldn't get background image response code for some reason")
                }
            }
            
            DispatchQueue.main.sync(execute: {
                self.setImageToCity(i: image!)
            })
            

            
        }
        
        downloadPicTask.resume()
        
    }
    
    func update(){
        preconditionFailure("function 'update' must be overridden")
    }
    
    func updateDisplay(){
        preconditionFailure("function 'updateDisplay' must be overridden")
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        showSearchBar()
    }
    
    @IBAction func useCurrentLocationButtonPressed(_ sender: UIButton) {
        curAirport = nil
        airportType = .location
        update()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    

}


