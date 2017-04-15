//
//  BezierBorder.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/12/17.
//  Copyright © 2017 wustl. All rights reserved.
//


import UIKit

/// A view for displaying a quantitative value. Set the `value` property to update the view.
/// To animate changes, call the `animateValue` method.
class BezierBorder {
    
    var backgroundLayer = CAShapeLayer()
    var frontLayer = CAShapeLayer()
    
    var size:Float
    let backgroundColor:UIColor = UIColor.clear
    
    var radius:CGFloat
    var center:CGPoint
    
    var oldColor:UIColor = UIColor.clear
    private var oldValue:CGFloat
    public var value:CGFloat
    
    let maxValue:CGFloat = 60 //1 hour = maximum circle
    
    var innerPath:UIBezierPath = UIBezierPath()
    
    var didLoad:Bool = false
    
    
    init(s:Float, r:CGRect){
        size = s
        radius = max(r.width, r.height)/1.9+CGFloat(size)
        center = CGPoint(x: r.midX, y: r.midY)
        print(center)
        print(r)
        
        backgroundLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-1*M_PI/2), endAngle: CGFloat(M_PI*3/2), clockwise: true).cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = backgroundColor.cgColor
        backgroundLayer.lineWidth = CGFloat(size)
        frontLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-1*M_PI/2), endAngle: CGFloat(M_PI*3/2), clockwise: true).cgPath
        frontLayer.fillColor = UIColor.clear.cgColor
        frontLayer.lineWidth = CGFloat(size)
        frontLayer.strokeEnd = 0
        
        oldValue = 0
        value = 0
    }
    
    func getPathColor() -> UIColor{
        //0 = green, 30 = yellow, 60 = red
        var v = value
        if v > maxValue{
            v = maxValue
        }
        v = v/maxValue  //normalize it to be between 0 and 1
        var red:CGFloat = 0
        var green:CGFloat = 0
        if v > 0.5{
            red = 1
            green = 2*(1-v)
            
        }
        else{
            green = 1
            red = 2*v
        }
        let c = UIColor(red: red, green: green, blue: 0, alpha: 1)
        return c
    }
    
    func setValue(v:CGFloat){
        oldValue = value
        value = v
        animate()
    }
    
    func loadBackgroundLayer(){
        let animcolor = CABasicAnimation(keyPath: "strokeColor")
        animcolor.fromValue         = UIColor.clear.cgColor
        animcolor.toValue           = UIColor.white.cgColor
        animcolor.duration          = 1.0;
        animcolor.isRemovedOnCompletion = false;
        animcolor.fillMode = kCAFillModeForwards;
        animcolor.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        backgroundLayer.add(animcolor, forKey: "strokeColor")
    }
    
    func animate(){
        
        if !didLoad{
            //this only happens before it has loaded, load it in once
            didLoad = true
            loadBackgroundLayer()
            //backgroundLayer.strokeColor = UIColor.white.cgColor
        }
        else{
            backgroundLayer.strokeColor = UIColor.white.cgColor
        }
        
        
        
        let drawAnimation = CABasicAnimation(keyPath:"strokeEnd")
        drawAnimation.repeatCount = 1.0
        
        let ov = oldValue/maxValue
        
        var v = value
        if v > maxValue{
            v = maxValue
        }
        v = v/maxValue
        
        
        
        // Animate from the full stroke being drawn to none of the stroke being drawn
        drawAnimation.fromValue = NSNumber(value: Double(ov))
        drawAnimation.toValue = NSNumber(value: Double(v))
        
        drawAnimation.duration = 1.0
        
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        drawAnimation.isRemovedOnCompletion = false;
        drawAnimation.fillMode = kCAFillModeForwards;
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        frontLayer.add(drawAnimation, forKey: "strokeEnd")
        
        //animate the color changing
        let newColor = getPathColor()
        let animcolor = CABasicAnimation(keyPath: "strokeColor")
        animcolor.fromValue         = oldColor.cgColor
        animcolor.toValue           = newColor.cgColor
        animcolor.duration          = 1.0;
        animcolor.isRemovedOnCompletion = false;
        animcolor.fillMode = kCAFillModeForwards;
        animcolor.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        frontLayer.add(animcolor, forKey: "strokeColor")
        
        oldColor = newColor
        
        //frontLayer.strokeEnd = v
    }
    
    
    
}
