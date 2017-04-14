//
//  GlobalVariables.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/14/17.
//  Copyright © 2017 wustl. All rights reserved.
//

enum AirportType{
    case location
    case searchbar
}

var curAirport:Airport?
var curAirportHasBonsai:Bool = true     //used to see whether to show install button or wait time
var prevAirportHasBonsai:Bool = true    //used for transitions between airports
var airportType:AirportType = .location //used in update, determines which function to use when determining the wait times
