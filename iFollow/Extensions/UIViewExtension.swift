//
//  UIViewExtension.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func dropShadow(color: UIColor){
        self.backgroundColor = color
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
    }
    
    func roundTopCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func roundBottomCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
//    func startRotating(duration: Double = 1) {
//        let kAnimationKey = "rotation"
//        
//        if self.layer.animation(forKey: kAnimationKey) == nil {
//            let animate = CABasicAnimation(keyPath: "transform.rotation")
//            animate.duration = duration
//            animate.repeatCount = Float.infinity
//            animate.fromValue = 0.0
//            animate.toValue = Float(Double.pi * 2.0)
//            self.layer.add(animate, forKey: kAnimationKey)
//        }
//    }
}

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


extension UIImageView{
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
        
//        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureHandler(recognizer:)))
//        addGestureRecognizer(rotationGesture)
    }
    
    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
    
    @objc private func rotationGestureHandler(recognizer:UIRotationGestureRecognizer){
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
}
