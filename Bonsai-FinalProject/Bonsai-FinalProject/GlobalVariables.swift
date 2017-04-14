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

var curAirport:Airport? //the most important global variable - it is the current airport that the user has selected or used location to get
var airportType:AirportType = .location //used in update, determines which function to use when determining the wait times
var curAirportHasBonsai:Bool = true     //used to show request button or wait-time info - currently only needed for animations on the wait time page
var prevAirportHasBonsai:Bool = true    //used for transitions between airports, currently only needed for animations on the wait time page

