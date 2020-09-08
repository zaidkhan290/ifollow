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
    
    func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.lightGray.cgColor,
                   shadowOffset: CGSize = CGSize(width: 5.0, height: 5.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func setColor(){
        self.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white
    }
    
    func setPrivateChatColor(){
        self.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Theme.darkModePrivateChatColor : Theme.privateChatBackgroundColor
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
    
    public func resizeToBoundingSquare(_ boundingSquareSideLength : CGFloat) -> UIImage {
        let imgScale = self.size.width > self.size.height ? boundingSquareSideLength / self.size.width : boundingSquareSideLength / self.size.height
        let newWidth = self.size.width * imgScale
        let newHeight = self.size.height * imgScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return resizedImage!
    }
    
    func addFilter(filter : String) -> UIImage {
        let filter = CIFilter(name: filter)
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: self.fixedOrientation())
        filter?.setValue(ciInput, forKey: "inputImage")
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        //Return the image
        return UIImage(cgImage: cgImage!)
    }
    
    func fixedOrientation() -> UIImage
    {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        return UIImage(cgImage: ctx.makeImage()!)
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
