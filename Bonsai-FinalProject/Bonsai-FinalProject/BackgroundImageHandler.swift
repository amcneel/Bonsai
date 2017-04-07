//
//  BackgroundImageHandler.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/7/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import Foundation


func getBackgroundImage(){
    let userAgent = "Bonsai App CJLM"
    if let url = NSURL(string: "http://www.omdbapi.com/?s=batman") {
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        var response:URLResponse? = nil;
        do{
            let data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
            //print(data)
        }
        catch{
            //print("error with getting data")
        }
        
        
    }
}

func testPost() {
    let session = URLSession.shared
    let request = NSMutableURLRequest(url: NSURL(string: "http://www.omdbapi.com/?s=batman")! as URL)
    request.setValue("Bonsai App Authentication String", forHTTPHeaderField: "User-Agent")
    request.httpMethod = "POST"
    let d = "4"
    let data = "x=4&y=\(d)"
    request.httpBody = data.data(using: String.Encoding.ascii)
    let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
        if let error = error {
            print(error)
        }
        if let data = data{
            print("data =\(data)")
        }
        if let response = response {
            print("url = \(response.url!)")
            print("response = \(response)")
            let httpResponse = response as! HTTPURLResponse
            print("response code = \(httpResponse.statusCode)")
            
            //if you response is json do the following
            do{
                /*
                let resultJSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())
                let arrayJSON = resultJSON as! NSArray
                for value in arrayJSON{
                    let dicValue = value as! NSDictionary
                    for (key, value) in dicValue {
                        print("key = \(key)")
                        print("value = \(value)")
                    }
                }
                */
                let resultJSON = JSON(data:data!)
                print(resultJSON)
                
            }catch _{
                print("Received not-well-formatted JSON")
            }
        }
    })
    task.resume()
}
