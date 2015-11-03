//
//  Dot.swift
//  xBonjourDemo
//
//  Created by Johnson, Christopher P on 10/20/15.
//  Copyright © 2015 Johnson, Christopher P. All rights reserved.
//

import UIKit

let xColorArray = [ UIColor.redColor(), UIColor.blueColor(), UIColor.brownColor(), UIColor.greenColor(), UIColor.grayColor(), UIColor.yellowColor(), UIColor.orangeColor(), UIColor.lightGrayColor(), UIColor.purpleColor(), UIColor.cyanColor(), UIColor.darkGrayColor(), UIColor.magentaColor(), UIColor.cyanColor() ]

@IBDesignable class Dot: UIView {
    var xNum : Int = 0
    var isPlayer : Bool = true
    
    //@IBInspectable var outlineColor: UIColor = UIColor.blueColor()
    //@IBInspectable var counterColor: UIColor = UIColor.orangeColor()
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        let xColor : UIColor = xColorArray[ xNum ] as UIColor
        xColor.setFill()
        path.fill()
        
        //----add label
        let label = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        //label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.text = "\(xNum)"
        label.textColor = UIColor.whiteColor()
        self.addSubview(label)
        
        
    }
    
    func moveToSpot( xSpot: CGPoint ) {
        //---animate the dot to xSpot location
        let yPosition = xSpot.y - self.frame.size.width/2
        let xPostion = xSpot.x - self.frame.size.height/2
        
        UIView.animateWithDuration(0.5, animations: {
            self.frame = CGRectMake(xPostion, yPosition, self.frame.size.width, self.frame.size.height)
        })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let xPoint : CGPoint = (touch?.locationInView( superview ))!
        if isPlayer {
            moveToSpot(xPoint)
        }
    }
}