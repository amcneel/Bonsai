//
//  airport.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/5/17.
//  Copyright © 2017 wustl. All rights reserved.
//


import Foundation
import CoreLocation

//customstring convertible allows public var description to be used
class Airport: NSObject{
    
    private var name:String
    private var code:String
    private var loc:CLLocation
    private var term:String
    
    init(n:String, c:String, l:CLLocation, t:String) {
        name = n
        code = c
        loc = l
        term = t
    }
    
    func getName() -> String{
        return name
    }
    
    func getCode() -> String{
        return code
    }
    
    func getLoc() -> CLLocation{
        return loc
    }
    
    func getTerm() -> String{
        return term
    }
    
    override var hash: Int {
        let myString = name+" "+code
        return myString.hashValue
    }
    
    //for debugging use, when I wanted to print out the airports to make sure they loaded correctly
    override var description: String{
        let locString = String(describing: loc.coordinate)
        let s = "Code: "+code+", Name: "+name+", Coords: "+locString
        return s
    }
    
}

func ==(lhs: Airport, rhs: Airport) -> Bool {
    return lhs.getName() == rhs.getName() && lhs.getCode() == rhs.getCode()
}
