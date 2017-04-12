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
class BezierBorder: UIView {
    
    var timer:Timer? //used for animating between values, for now going to try doing it asynchronously <- update asynchronous didn't work, explanation in update method
    
    var size:Float
    var color:UIColor
    
    var outerColor:UIColor
    
    var radius:CGFloat = 0
    var radiusCenter:CGPoint = CGPoint(x: 0, y: 0)
    
    public var value: CGFloat {
        get {
            return innerVal
        }
        set(newValue) {
            oldInnerVal = innerVal
            innerVal = newValue
            update()
            
        }
    }
    
    private var oldInnerVal:CGFloat = 0
    private var innerVal:CGFloat = 0
    private var displayVal:CGFloat = 0
    
    let maxValue:CGFloat = 60 //1 hour = maximum circle
    
    var innerPath:UIBezierPath = UIBezierPath()
    
    override init(frame: CGRect) {
        color = UIColor.black
        outerColor = UIColor.white
        size = 10
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        
    }
    
    
    
    func getPathColor() -> UIColor{
        //0 = green, 30 = yellow, 60 = red
        var v = displayVal
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
    
    func setBounds(subject:CGRect){
        radius = max(subject.width, subject.height)/1.9+CGFloat(size)
        radiusCenter = CGPoint(x: subject.midX, y: subject.midY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Drawing code
        print("draw1")
        outerColor.setStroke()
        let outerPath = getOuterPath()
        outerPath.lineCapStyle = .square
        outerPath.lineWidth=CGFloat(size)
        outerPath.stroke()
        
        getPathColor().setStroke()
        let innerPath = getInnerPath()
        innerPath.lineCapStyle = .square
        innerPath.lineWidth=CGFloat(size)
        innerPath.stroke()
        print("draw2")
        
        
    }
    
    func animate(){
        print(displayVal, innerVal)
        if displayVal == innerVal{
            timer?.invalidate()
            timer = nil
            return
        }
        if displayVal > innerVal{
            displayVal -= 1
        }
        else{
            displayVal += 1
        }
        self.setNeedsDisplay()
    }
    
    func update(){
        
        let totalAnimationtime = CGFloat(0.5)
        let singleFrameAnimationTime = Double(totalAnimationtime/(abs(innerVal-oldInnerVal)))
        
        displayVal = oldInnerVal //the value we will animate
        
        timer = Timer.scheduledTimer(timeInterval: singleFrameAnimationTime, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
        
        /*
        //the issue with this portion of the code is that setNeedsDisplay (aka redrawing the view) doesn't work as intended when inside Async
        //going to use timer instead
        DispatchQueue.global(qos: .userInitiated).async{
            while(self.displayVal != self.innerVal){
                print(self.displayVal, self.innerVal)
                if self.displayVal > self.innerVal{
                    self.displayVal -= 1
                }
                else{
                    self.displayVal += 1
                }
                self.setNeedsDisplay()
                sleep(UInt32(singleFrameAnimationTime))
            }
            
            DispatchQueue.main.async {
         
            }
        }
         */
        
    }
    
    
    
    func getInnerPath() -> UIBezierPath {
        let path = UIBezierPath()
        let endA = displayVal/maxValue * CGFloat(M_PI*2)
        path.addArc(withCenter: radiusCenter, radius: radius, startAngle: 0, endAngle: endA, clockwise: false)
        return path
    }
    
    func getOuterPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.addArc(withCenter: radiusCenter, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        return path
    }
    
    
}
