//
//  VPSplashCircle.swift
//  VPSplashMenu
//
//  Created by Vitalii Popruzhenko on 12.05.16.
//  Copyright © 2016 VP. All rights reserved.
//

import Foundation
import UIKit

class VPSplashCircle : UIView {
    
    var radius: CGFloat {
        didSet {
            setup()
        }
    }
    
    var icon : UIImage? {
        didSet {
            self.drawImage()
        }
    }
    
    var imageScaleFactor : CGFloat = 1.0 {
        didSet {
            self.drawImage()
        }
    }
    
    var expectedCenter : CGPoint
    var angleToCenter : CGFloat = 0
    
    var color: UIColor = UIColor.redColor()
    
    var connectionLayer : CAShapeLayer?
    var ovalLayer : CAShapeLayer?
    var mainRadius : CGFloat = 0
    var animated : Bool = false
    
    
    //MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor) {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        self.radius = radius
        self.color = color
        self.expectedCenter = center
        super.init(frame: frame)        
        setup()
    }
    
    private func setup() {
        self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        let bezierPath = UIBezierPath(ovalInRect: CGRect(origin: CGPointZero, size: CGSize(width: radius * 2, height: radius * 2)))
        draw(bezierPath)
    }
    
    //MAR: Animation
    
    func animateMove(){
        self.layer.removeAllAnimations()
        self.connectionLayer?.removeAllAnimations()
        
        let duration = 0.7
        
        CATransaction.begin()
        CATransaction.setCompletionBlock{
            self.center = self.expectedCenter
            self.connectionLayer?.path = self.animatedPath(self.expectedCenter).CGPath
        }
        
        let distance = LiquidHelper.distanceBetween(expectedCenter, point2: self.center)
        
        let startCircle = CABasicAnimation(keyPath: "position")
        startCircle.fromValue = NSValue(CGPoint : self.center)
        startCircle.toValue = NSValue(CGPoint : LiquidHelper.circlePoint(self.center, radius: distance*1.5, rad: angleToCenter))
        startCircle.duration = duration/3.0
        
        let bounceCircle = CABasicAnimation(keyPath: "position")
        bounceCircle.fromValue =  startCircle.toValue
        bounceCircle.toValue = NSValue(CGPoint : LiquidHelper.circlePoint(self.center, radius: distance*0.75, rad: angleToCenter))
        bounceCircle.beginTime = startCircle.beginTime+startCircle.duration
        bounceCircle.duration = duration/3.0
        
        let endCircle = CABasicAnimation(keyPath: "position")
        endCircle.fromValue =  bounceCircle.toValue
        endCircle.toValue = NSValue(CGPoint : expectedCenter)
        endCircle.beginTime = bounceCircle.beginTime+bounceCircle.duration
        endCircle.duration = duration/3.0
        
        let start = CABasicAnimation(keyPath: "path")
        start.fromValue = animatedPath(self.center).CGPath
        start.toValue = animatedPath(LiquidHelper.circlePoint(self.center, radius: distance*1.5, rad: angleToCenter)).CGPath
        start.duration = duration/3.0
        
        let bounce = CABasicAnimation(keyPath: "path")
        bounce.fromValue =  start.toValue
        bounce.toValue = animatedPath(LiquidHelper.circlePoint(self.center, radius: distance*0.75, rad: angleToCenter)).CGPath
        bounce.beginTime = start.beginTime+start.duration
        bounce.duration = duration/3.0
        
        let end = CABasicAnimation(keyPath: "path")
        end.fromValue =  bounce.toValue
        end.toValue = animatedPath(expectedCenter).CGPath
        end.beginTime = bounce.beginTime+bounce.duration
        end.duration = duration/3.0
        
        let groupCircle = CAAnimationGroup()
        groupCircle.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        groupCircle.fillMode = kCAFillModeBoth // keep to value after finishing
        groupCircle.animations = [startCircle, bounceCircle, endCircle]
        groupCircle.duration = end.beginTime+end.duration
        groupCircle.removedOnCompletion = false
        
        let group = CAAnimationGroup()
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        group.fillMode = kCAFillModeBoth // keep to value after finishing
        group.animations = [start, bounce, end]
        group.duration = end.beginTime+end.duration
        group.removedOnCompletion = false
        
        self.layer.addAnimation(groupCircle, forKey: "animate position along path")
        self.connectionLayer?.addAnimation(group, forKey: "animate stretching")
        
        CATransaction.commit()
    }
    
    func animatedPath(tempCenter: CGPoint) -> UIBezierPath {
        return LiquidHelper.pathBetween(self.center,
                                        circleRadius: mainRadius,
                                        otherCenter: tempCenter,
                                        otherRadius: self.radius)
    }
    
    //MARK: Toggle methods
    
    func highlight(){
        if (!animated){
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.3
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 1.25
            scaleAnimation.fillMode = kCAFillModeBoth
            scaleAnimation.removedOnCompletion = false
            
            self.layer.addAnimation(scaleAnimation, forKey: "wobble")
            animated = true
        }
    }
    
    func unhighlight(){
        if (animated){
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.15
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            scaleAnimation.fromValue = 1.25
            scaleAnimation.toValue = 1.0
            scaleAnimation.removedOnCompletion = true
            self.layer.addAnimation(scaleAnimation, forKey: "wobble")
            
            animated = false
        }
    }
    
    //MARK: Drawing methods
    
    func draw(path: UIBezierPath) {
        self.layer.sublayers?.removeAll();
        
        let layer = CAShapeLayer(layer: self.layer)
        layer.lineWidth = 3.0
        layer.fillColor = self.color.CGColor
        layer.path = path.CGPath
        ovalLayer = layer
        self.layer.addSublayer(layer)
    }
    
    func drawImage(){
        if (self.layer.sublayers?.last?.name == "IconLayer"){
            self.layer.sublayers?.last?.removeFromSuperlayer()
        }
        var imageBounds = CGRectZero
        
        imageBounds.size.width = self.bounds.width*imageScaleFactor
        imageBounds.size.height = self.bounds.height*imageScaleFactor
        imageBounds.origin.x = (self.bounds.width-imageBounds.width)/2
        imageBounds.origin.y = (self.bounds.height-imageBounds.height)/2
        
        let imageLayer = CALayer()
        imageLayer.name = "IconLayer"
        imageLayer.frame = imageBounds
        
        if (tintColor != nil){
            imageLayer.contents = icon?.imageWithColor(tintColor!).CGImage
        } else {
            imageLayer.contents = icon?.CGImage
        }
        
        imageLayer.masksToBounds = true
        self.layer.addSublayer(imageLayer)
    }
    
    func circlePoint(rad: CGFloat) -> CGPoint {
        return LiquidHelper.circlePoint(self.center, radius: self.radius, rad: rad)
    }
    
    func cleanup(){
        self.ovalLayer?.removeFromSuperlayer()
        self.connectionLayer?.removeFromSuperlayer()
        self.removeFromSuperview()
    }
}

