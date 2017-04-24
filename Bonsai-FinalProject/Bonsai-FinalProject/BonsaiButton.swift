//
//  BonsaiButton.swift
//  Bonsai-FinalProject
//
//  Created by Labuser on 4/13/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit

class BonsaiButton: UIButton{
    
    override func awakeFromNib() {
        
        let buttonColor = UIColor.init(red: 0, green: 130/255, blue: 0, alpha: 1)
        
        self.setTitle("Request Bonsai Installation", for: UIControlState.normal)
        self.setTitle("Request Submitted", for: .disabled)
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 2.0
        self.layer.borderColor = buttonColor.cgColor
        self.layer.backgroundColor = buttonColor.cgColor
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "Futura", size: 20)
        
    }
    
    func enable(){
        let buttonColor = UIColor.init(red: 0, green: 130/255, blue: 0, alpha: 1)
        self.isEnabled = true
        self.layer.borderColor = buttonColor.cgColor
        self.layer.backgroundColor = buttonColor.cgColor
    }
    
    func disable(){
        self.isEnabled = false
        self.backgroundColor = UIColor(red: 0, green: 0.4, blue: 0.0, alpha: 0.3)
        self.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3).cgColor
    }
    
    
}
