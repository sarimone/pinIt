//
//  SearchBarView.swift
//  iTrip
//
//  Created by Simon Rothert on 29.03.19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit

class CustomIntensityVisualEffectView: UIVisualEffectView {
    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = intensity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private var animator: UIViewPropertyAnimator!
}

@IBDesignable
class BlurryBackgroundView: UIView {
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = CustomIntensityVisualEffectView(effect: blurEffect, intensity: 0.3)
        blurView.frame = self.frame
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        self.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.contentView.addSubview(vibrancyView)
        
        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurView.contentView.heightAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: blurView.contentView.widthAnchor),
            vibrancyView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])
        
        clipsToBounds = true
    }
}
