//
//  TitleButton.swift
//  Bonsai-FinalProject
//
//  Created by Tarun Chally on 4/13/17.
//  Copyright © 2017 wustl. All rights reserved.
//

import UIKit

class TitleButton: UIButton{
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height/2
       // self.layer.borderWidth = 3.0
       // self.layer.borderColor = UIColor.init(red: 0, green: 200/255, blue: 0, alpha: 1).cgColor
       // self.layer.backgroundColor = UIColor.init(red: 0, green: 140/255, blue: 0, alpha: 1).cgColor
       // self.setTitleColor(UIColor.green, for: .normal)
        self.titleLabel?.font = UIFont(name: "Futura", size: 16)
       // self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)

    }
    
    
}
