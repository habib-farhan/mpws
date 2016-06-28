//
//  CHB.swift
//  mpws
//
//  Created by Alexander Neumann on 25.06.16.
//  Copyright © 2016 Alexander Neumann. All rights reserved.
//

import UIKit

class CHB: UIView {
    
    let barbg = UIColor.grayColor()
    let barheight:CGFloat = 10
    var currentPosition:CGFloat = 0.15
    let currentPositionColor = UIColor.whiteColor()
    
    var comments = [Comment(start: 0.136,end: 0.176,comment: "Dummy comment, this widget is so awesome! I love it <3"),Comment(start: 0.55,end: 0.59,comment: "Wow, this part is stunning!"),Comment(start: 0.75,end: 0.79,comment: "Just another Comment")]
    
    var delegate:CHBDelegate?
    var touching = false
    var subviewAdded = false
    var showComments = false
    var scrollView:UIScrollView?
    
    
    let fieldColor: UIColor = UIColor.whiteColor()
    let fieldFont = UIFont(name: "Helvetica Neue", size: 18)
    
    // set the line spacing to 6
    var paraStyle = NSMutableParagraphStyle()
    
    // set the Obliqueness to 0.1
    var skew = 0.1
    
    var c1Color = UIColor.blueColor()
    var c2Color = UIColor.redColor()
    var cColor = UIColor.blueColor()
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if(!subviewAdded){
            scrollView = UIScrollView(frame: CGRect(x: 0, y: barheight+5, width: rect.width, height: rect.height-barheight-5.0))
            scrollView?.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15)
            self.addSubview(scrollView!)
            subviewAdded = true
        }
        
        // Draw timeline
        let timeline = UIBezierPath()
        for i in 0...(Int(barheight)-1) {
            timeline.moveToPoint(CGPoint(x:rect.origin.x, y:rect.origin.y+CGFloat(i)))
            timeline.addLineToPoint(CGPoint(x:rect.width, y:rect.origin.y+CGFloat(i)))
        }
        timeline.closePath()
        barbg.set()
        timeline.stroke()
        timeline.fill()
        
        // Draw commented parts
        
        

        
        self.cColor = self.c1Color
        showComments = false
        var commentCounter = 0
        for c in comments {
            if c.start<=currentPosition && c.end>=currentPosition && !c.hidden{
                showComments = true
                commentCounter += 1
                if(!c.hidden){
                    paraStyle.lineSpacing = 6.0
                    let attributes: NSDictionary = [
                        NSForegroundColorAttributeName: fieldColor,
                        NSParagraphStyleAttributeName: paraStyle,
                        NSObliquenessAttributeName: skew,
                        NSFontAttributeName: fieldFont!
                    ]
                    c.comment.drawInRect(CGRectMake(5.0, barheight+10.0, rect.width-5.0, rect.height-barheight-10.0), withAttributes: attributes as? [String : AnyObject])
                }
                if commentCounter > 3 {
                    self.cColor = self.c2Color
                }
            }
        }
        if(showComments){
            scrollView?.hidden=false
        }else{
            scrollView?.hidden=true
        }
        
        
        for c in comments{
            let commentLine = UIBezierPath()
            for i in 0...(Int(barheight)-1) {
                commentLine.moveToPoint(CGPoint(x:c.start*rect.width, y:rect.origin.y+CGFloat(i)))
                commentLine.addLineToPoint(CGPoint(x:c.end*rect.width, y:rect.origin.y+CGFloat(i)))
            }
            commentLine.closePath()
            cColor.set()
            commentLine.stroke()
            commentLine.fill()
        }
        
        
        // Draw current position
        let currentLine = UIBezierPath()
        let realCurrentPosition = currentPosition*(rect.width)
        currentLine.moveToPoint(CGPoint(x: realCurrentPosition, y:rect.origin.y))
        currentLine.addLineToPoint(CGPoint(x: realCurrentPosition, y:rect.origin.y+CGFloat(barheight-1)))
        currentLine.closePath()
        currentPositionColor.set()
        currentLine.stroke()
        currentLine.fill()
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touching = true
        if touches.first != nil {
            currentPosition = (touches.first?.locationInView(self).x)!/self.bounds.width
            delegate!.updateTime(currentPosition)
            setNeedsDisplay()
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touching = false
    }
    
    
    func update(pos:CGFloat){
        currentPosition = pos
        setNeedsDisplay()
    }

}

class Comment{
    var start: CGFloat = 0.0
    var end: CGFloat = 0.0
    var comment = ""
    var hidden = false
    
    
    init (start: CGFloat, end: CGFloat, comment: String) {
        self.start = start
        self.end = end
        self.comment = comment
        
    }
}

protocol CHBDelegate {
    func updateTime(time:CGFloat)
}