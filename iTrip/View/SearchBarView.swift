//
//  SearchBarView.swift
//  iTrip
//
//  Created by Simon Rothert on 29.03.19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit

@IBDesignable
class SearchBarView: BlurryBackgroundView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.cornerRadius = frame.height / 2
        
        layer.borderWidth = 1
        
        layer.borderColor = UIColor.black.cgColor
    }
}
