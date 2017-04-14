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
        
        
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 2.0
        self.layer.borderColor = buttonColor.cgColor
        self.layer.backgroundColor = buttonColor.cgColor
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "Futura", size: 20)
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
        
    }
    
    
}
