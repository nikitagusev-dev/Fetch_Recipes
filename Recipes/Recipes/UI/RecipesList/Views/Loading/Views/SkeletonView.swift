//
//  SkeletonView.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/26/24.
//

import UIKit

final class SkeletonView: UIView {
    var highlightColor: UIColor = .white
    var cornerRadius: CGFloat?
    
    private var skeletonLayer = CALayer()
    private var gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius ?? frame.height / 2
        layer.cornerCurve = .continuous
        clipsToBounds = true
        
        startAnimating()
    }
}

// MARK: - Private methods
private extension SkeletonView {
    func startAnimating() {
        [skeletonLayer, gradientLayer].forEach { $0.removeFromSuperlayer() }
        
        let color = backgroundColor?.cgColor
        let hColor = highlightColor.cgColor
        
        skeletonLayer = CALayer()
        skeletonLayer.backgroundColor = color
        skeletonLayer.anchorPoint = .zero
        skeletonLayer.frame.size = UIScreen.main.bounds.size
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color, hColor, color].compactMap { $0 }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = UIScreen.main.bounds
        
        layer.mask = skeletonLayer
        layer.insertSublayer(skeletonLayer, at: 0)
        layer.insertSublayer(gradientLayer, at: 1)
        clipsToBounds = true
        let width = UIScreen.main.bounds.width
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 2
        animation.fromValue = -width
        animation.toValue = width
        animation.repeatCount = .infinity
        animation.autoreverses = false
        animation.fillMode = .forwards
        
        gradientLayer.add(animation, forKey: "gradientLayerShimmerAnimation")
    }
}
