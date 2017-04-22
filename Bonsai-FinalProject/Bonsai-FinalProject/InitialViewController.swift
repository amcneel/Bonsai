//
//  InitialViewController.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/21/17.
//  Copyright © 2017 wustl. All rights reserved.
//

//
//  SignInController.swift
//  Bonsai-FinalProject
//
//  Created by Tarun Chally on 4/13/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import CoreLocation
import UIKit
class InitialViewController: UIViewController{
    
    override func viewDidLoad() {
        //loads the airports from the csv into the var airports
        super.viewDidLoad()
        loadAirportsFromCSV()
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
                let anumpic:Int = Int(csv[rowIndex][6])!
                let a = Airport(n: aname, c: acode, l: aloc, t: aterm, p: anumpic)
                airports.append(a)
            }
            
        } catch{
            print(error)
        }
        
    }
        
    
}
