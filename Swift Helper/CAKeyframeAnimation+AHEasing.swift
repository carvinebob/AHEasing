//
//  CAKeyframeAnimation+AHEasing.swift
//  AHEasing
//
//  Created by Bob Carson on 7/16/15.
//  Copyright (c) 2015 All rights reserved.
//

import Foundation

extension CAKeyframeAnimation
{
    convenience init(path: String, function:((Double) -> Double), fromValue:CGFloat, toValue:CGFloat, keyframeCount:Int)
    {
        self.init()
        
        var values : [AnyObject]! = []
        
        var t : Double = 0.0
        var dt : Double = 1.0 / (Double(keyframeCount) - 1.0)
        for frame in 0...keyframeCount
        {
            var value = Double(fromValue + CGFloat(function(t)) * (toValue - fromValue));
            values.append(NSNumber(double: value))
            t += dt
        }
        self.keyPath = path
        self.values = values
    }
    
    convenience init(path: String, function:((Double) -> Double), fromTransform:CGAffineTransform, toTransform:CGAffineTransform, keyframeCount:Int)
    {
        self.init()
        
        var values : [AnyObject]! = []
        var fromTranslation = CGPointMake(fromTransform.tx, fromTransform.ty)
        var toTranslation = CGPointMake(toTransform.tx, toTransform.ty)

        var fromScale = hypot(fromTransform.a, fromTransform.c)
        var toScale = hypot(toTransform.a, toTransform.c)
        
        var fromRotation : CGFloat = atan2(fromTransform.c, fromTransform.a)
        var toRotation : CGFloat = atan2(toTransform.c, toTransform.a)

        var deltaRotation = toRotation - fromRotation
       
        if deltaRotation < CGFloat(-M_PI)
        {
            deltaRotation += CGFloat(2 * M_PI)
        }
        else if deltaRotation > CGFloat(M_PI)
        {
            deltaRotation -= CGFloat(2 * M_PI)
        }
        
        var t : Double = 0.0
        var dt : Double = 1.0 / (Double(keyframeCount) - 1.0)
        for frame in 0...keyframeCount
        {
            var interp : CGFloat = CGFloat(function(t))
            
            var translateX = fromTranslation.x + interp * (toTranslation.x - fromTranslation.x);
            var translateY = fromTranslation.y + interp * (toTranslation.y - fromTranslation.y);
            
            var scale = fromScale + interp * (toScale - fromScale);
            
            var rotate = fromRotation + interp * deltaRotation;
            
            var affineTransform = CGAffineTransformMake(scale * cos(rotate), -scale * sin(rotate),
                scale * sin(rotate), scale * cos(rotate),
                translateX, translateY);
            
            var transform = CATransform3DMakeAffineTransform(affineTransform);
            
            values.append(NSValue(CATransform3D: transform))
            t += dt
        }
        
        self.keyPath = path
        self.values = values
    }
}