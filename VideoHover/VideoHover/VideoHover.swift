//
//  VideoHover.swift
//  VideoHover
//
//  Created by Jörg Christian Kirchhof on 22/06/16.
//  Copyright © 2016 Media Computing Group of RWTH Aachen University. All rights reserved.
//

import UIKit

class VideoHint {
    var startSec : Int64 = 0
    var startHundredth : Float = 0.0
    var endSec : Int64 = 0
    var endHundredth : Float = 0.0
    var x : Int = 0
    var y : Int = 0
    var radius : Int = 0
    var hint : String = ""
    var color : UIColor
    
    init(startSec: Int64, startHundredth: Float, endSec: Int64, endHundredth: Float, x: Int, y: Int, radius: Int, hint: String) {
        self.startSec = startSec
        self.startHundredth = startHundredth
        self.endSec = endSec
        self.endHundredth = endHundredth
        self.x = x
        self.y = y
        self.radius = radius
        self.hint = hint
        self.color = UIColor.whiteColor()
    }
    
    func setColor(color: UIColor) {
        self.color = color
    }
}


private struct VideoHoverTime : Hashable {
    var seconds : Int64
    var hundredth : Float
    
    var hashValue : Int {
        get {
            return seconds.hashValue
        }
    }
}

private func == (lhs: VideoHoverTime, rhs: VideoHoverTime) -> Bool {
    let floatsEq = Int(round(lhs.hundredth*10)) == Int(round(rhs.hundredth*10))
    return lhs.seconds == rhs.seconds && floatsEq
}

private class VideoBubble {
    var hint : VideoHint
    var shape : CAShapeLayer
    var visible : Bool
    var text : CATextLayer?
    
    var movement : [VideoHoverTime : CGPoint?]
    
    init (hint: VideoHint, shape: CAShapeLayer, visible: Bool) {
        self.hint = hint
        self.shape = shape
        self.visible = visible
        self.text = nil
        self.movement = [:]
    }
}

protocol VideoHoverDelegate {
    func pauseVideo()
    func playVideo()
    func jumpToNextFrame()
    func currentTime() -> (Int64, Float)
}

class VideoHover : UIView {
    
    private var seconds : Int64 = 0
    private var hundredth : Float = 0
    private var isEditing : Bool = false
    private var isPlaying : Bool = false
    private var movingBubble : VideoBubble? = nil
    private var showingOverlays = false
    private var editedBubble : VideoBubble?
    private var editedBubbleColor : UIColor?
    private var timer : NSTimer?
    private var currentTime : VideoHoverTime {
        get {
            return VideoHoverTime(seconds: seconds, hundredth: hundredth)
        }
    }
    
    var delegate : VideoHoverDelegate?
    
    private var hints : [VideoHint] = []
    private var bubbles : [VideoBubble] = []
    private var bubbleForTouch = [UITouch:VideoBubble]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        opaque = false
        self.layer.masksToBounds = true
        self.multipleTouchEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        opaque = false
        self.layer.masksToBounds = true
        self.multipleTouchEnabled = true
    }
    
    func addHint(hint :VideoHint) {
        hints.append(hint)
        
        //Create bubble for hint
        let circleLayer = createCircle(CGFloat(hint.radius), x: hint.x, y: hint.y, color: hint.color)
        let bubble = VideoBubble(hint: hint, shape: circleLayer, visible: false)
        bubbles.append(bubble)
    }
    
    private func bubbleBelongsToCurrentTime(bubble : VideoBubble) -> Bool {
        //First rough check, ensure that startSec <= seconds <= endSec
        if seconds < bubble.hint.startSec ||
            seconds > bubble.hint.endSec {
            return false
        }
        
        //First Second? => Check hundredth 
        //(ensure that startSec+startHundredth <= seconds+hundredth <= endSec)
        if seconds == bubble.hint.startSec &&
            hundredth < bubble.hint.startHundredth {
            return false
        }
        
        //Last Second? => Check hundredth
        //(ensure that startSec+startHundredth <= seconds+hundredth <= endSec+endHundredth)
        if seconds == bubble.hint.endSec &&
            hundredth > bubble.hint.endHundredth {
            return false
        }
        
        //Now we now, that we are in the right time window
        return true
    }
    
    private func hideBubbleAtIndex(i : Int) {
        //If there is a matching bubble...
        if self.layer.sublayers != nil &&
            self.layer.sublayers!.contains(bubbles[i].shape) {
            //...remove it
            let index = self.layer.sublayers!.indexOf(bubbles[i].shape)
            self.layer.sublayers!.removeAtIndex(index!)
            bubbles[i].visible = false
        }
    }
    
    private func showBubbleAtIndex(i : Int) {
        //If there is not a matching bubble or 
        //there do not exist sublayers at all...
        if (self.layer.sublayers != nil &&
            !(self.layer.sublayers!.contains(bubbles[i].shape))) ||
            self.layer.sublayers == nil {
            
            //Show bubble
            self.layer.addSublayer(bubbles[i].shape)
            bubbles[i].visible = true
            
            
        }
    }
    
    @objc private func updateTime() {
        var seconds : Int64 = 0
        var hundredth : Float = 0
        (seconds, hundredth) = delegate!.currentTime()
        
        //print("seconds \(seconds), hundredth \(hundredth)")
        
        var updateLayers = false
        if showingOverlays && seconds != self.seconds || hundredth != self.hundredth {
            updateLayers = true
        }
        self.seconds = seconds
        self.hundredth = hundredth
        if updateLayers {
            for i in bubbles.indices {
                if bubbleBelongsToCurrentTime(bubbles[i]) {
                    if bubbles[i].movement[currentTime] != nil {
                        let newPos = bubbles[i].movement[currentTime]!
                        bubbles[i].shape.position = CGPoint(x: newPos!.x, y: newPos!.y)
                        bubbles[i].shape.removeAnimationForKey("position")
                    }
                    showBubbleAtIndex(i)
                } else {
                    hideBubbleAtIndex(i)
                }
            }
        }
    }
    
    func showOverlays() {
        if (delegate == nil) {
            print("You forgot to set a delegate for VideoHover. Cannot start showing hints.")
            return
        }
        
        showingOverlays = true
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoHover.updateTime), userInfo: nil, repeats: true)
        for i in bubbles.indices {
            if bubbleBelongsToCurrentTime(bubbles[i]) {
                if bubbles[i].movement[currentTime] != nil {
                    let newPos = bubbles[i].movement[currentTime]!
                    bubbles[i].shape.position = CGPoint(x: newPos!.x, y: newPos!.y)
                    bubbles[i].shape.removeAnimationForKey("position")
                }
                showBubbleAtIndex(i)
            } else {
                hideBubbleAtIndex(i)
            }
        }
    }
    
    func hideOverlays() {
        self.layer.sublayers?.removeAll()
        showingOverlays = false
        timer?.invalidate()
        timer = nil
    }
    
    private func createCircle(radius: CGFloat, x: Int, y: Int, color: UIColor) -> CAShapeLayer {
        var circleLayer: CAShapeLayer!
        if circleLayer == nil {
            circleLayer = CAShapeLayer()
            circleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).CGPath
            circleLayer.position = CGPoint(x: x, y: y)
            
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            var a : CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            circleLayer.fillColor = UIColor(red: r, green: g, blue: b, alpha: 0.3).CGColor
            circleLayer.lineWidth = 2.0
            circleLayer.strokeColor = UIColor(red: r, green: g, blue: b, alpha: 1.0).CGColor
        }
        return circleLayer
    }
    
    func setEditing(isEditing: Bool) {
        self.isEditing = isEditing
        delegate?.pauseVideo()
        
        if isEditing == false {
            if editedBubble != nil {
                editedBubble?.hint.endSec = seconds
                editedBubble?.hint.endHundredth = hundredth
                editedBubble?.hint.color = editedBubbleColor!
                
                var r : CGFloat = 0
                var g : CGFloat = 0
                var b : CGFloat = 0
                var a : CGFloat = 0
                editedBubbleColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
                
                editedBubble!.shape.fillColor = UIColor(red: r, green: g, blue: b, alpha: 0.3).CGColor
                editedBubbleColor = nil
                editedBubble = nil
            }
            delegate?.playVideo()
            
        }
    }
    
    func setPlaying(isPlaying: Bool) {
        self.isPlaying = isPlaying
    }
    
// MARK: Touch handling
    
    private func bubbleForTouch(touch: UITouch) -> VideoBubble? {
        for bubble in bubbles {
            var touchLocation = touch.locationInView(self)
            touchLocation.x -= bubble.shape.position.x
            touchLocation.y -= bubble.shape.position.y
            if CGPathContainsPoint(bubble.shape.path, nil, touchLocation, true) &&
                bubble.visible {
                movingBubble = bubble
                return bubble
            }
        }
        return nil
    }
    
    private func showText(bubble: VideoBubble) {
        //Top left corner
        var x = bubble.hint.x
        var y = bubble.hint.y
        
        x = Int(bubble.shape.position.x)
        y = Int(bubble.shape.position.y)
        
        let size = bubble.hint.radius*2
        
        //Keep x centered
        x -= size/2
        
        let text : CATextLayer = CATextLayer()
        text.anchorPoint = CGPoint(x: 0, y: 1)
        y -= 15
        
        //Check if text needs to be below bubble for space reasons
        if y - size < 0 {
            y  += 2 * size + 30
        }
        
        //Check space to right side
        if x + size*2 > Int(self.frame.width) {
            x = Int(self.frame.width) - 2*size - 15
        }
        
        //Check space to left side
        if x < 0 {
            x = 15
        }
        
        let label = UILabel()
        label.text = bubble.hint.hint
        label.font = UIFont.systemFontOfSize(16.0)
        label.numberOfLines = 5
        var contentSize = label.intrinsicContentSize()
        
        //Do not let the text box get __too__ small
        if contentSize.width < CGFloat(size*2) {
            contentSize.width = CGFloat(size*2)
        }
        
        //Do not let the text box get __too__ small
        if contentSize.height < CGFloat(bubble.hint.radius*2) {
            contentSize.height = CGFloat(bubble.hint.radius*2)
        }
        
        //Setup the textbox
        text.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: contentSize)
        text.position = CGPoint(x: x, y: y)
        text.string = bubble.hint.hint
        text.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor
        text.foregroundColor = UIColor.whiteColor().CGColor
        text.fontSize = 16.0
        text.contentsScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(text)
        bubble.text = text
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches {
                
            //Editing? Adjust position of bubble
            if let movingBubble = editedBubble where self.isEditing {
                
                var touchLocation = touch.locationInView(self)
                touchLocation.x -= CGFloat(movingBubble.hint.radius)
                touchLocation.y -= CGFloat(movingBubble.hint.radius)
                
                //Stay within bounds
                let radius : CGFloat = CGFloat(movingBubble.hint.radius)
                if touchLocation.x+radius >= 0 && touchLocation.x+radius <= self.frame.width {
                    movingBubble.hint.x = Int(touchLocation.x)
                }
                if touchLocation.y+radius >= 0 && touchLocation.y+radius <= self.frame.height {
                    movingBubble.hint.y = Int(touchLocation.y)
                }
                
                //Adjust position
                movingBubble.shape.position = CGPoint(x: movingBubble.hint.x, y: movingBubble.hint.y)
                //These animations just make everything sluggish - therefore remove them
                movingBubble.shape.removeAnimationForKey("position")
                
                movingBubble.movement[currentTime] = CGPoint(x: movingBubble.hint.x, y: movingBubble.hint.y)
                
                delegate?.jumpToNextFrame()
            }
            
            
            if let bubble = bubbleForTouch(touch) {
                //print("Touch begin in bubble")
                if !isEditing {
                    if bubble.text == nil {
                        showText(bubble)
                    }
                } else if editedBubble == nil{
                    editedBubble = bubble
                    editedBubbleColor = editedBubble?.hint.color
                    editedBubble?.hint.startSec = seconds
                    editedBubble?.hint.startHundredth = hundredth
                    editedBubble?.shape.fillColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 0.5).CGColor
                }
                bubbleForTouch[touch] = bubble
            } else {
                //print("Touch begin")
            }
        }
        
        
    
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Info: I've tested doing the calculations asynchronously but the overhead for switching
        //      threads seems to make the system a little bit less responsive
        
        for touch in touches {
            let currentBubble = bubbleForTouch[touch]
            
            //Not editing? Maybe adjust position of text box
            if let mb = currentBubble, text = currentBubble?.text where !isEditing {
                
                if CGRectContainsPoint(text.frame, touch.locationInView(self)) {
                    //Check wether text is below or above bubble, then switch position
                    if text.position.y < CGFloat(mb.hint.y) {
                        //Check if there's enough space to move text
                        if text.position.y + text.frame.height + CGFloat(mb.hint.radius*2) + 30  < self.frame.height {
                            //Move text below bubble
                            text.position.y += CGFloat(mb.hint.radius*2) + text.frame.height + 30
                        }
                    } else {
                        //Check if there's enough space to move text
                        if text.position.y - 2 * text.frame.height - CGFloat(mb.hint.radius*2) - 30  > 0 {
                            //Move text above bubble
                            text.position.y -=  CGFloat(mb.hint.radius*2) + text.frame.height + 30
                        }
                    }
                }
            }
            
            //Editing? Adjust position of bubble
            if let movingBubble = currentBubble where self.isEditing {
                
                var touchLocation = touch.locationInView(self)
                touchLocation.x -= CGFloat(movingBubble.hint.radius)
                touchLocation.y -= CGFloat(movingBubble.hint.radius)
                
                //Stay within bounds
                let radius : CGFloat = CGFloat(movingBubble.hint.radius)
                if touchLocation.x+radius >= 0 && touchLocation.x+radius <= self.frame.width {
                    movingBubble.hint.x = Int(touchLocation.x)
                }
                if touchLocation.y+radius >= 0 && touchLocation.y+radius <= self.frame.height {
                    movingBubble.hint.y = Int(touchLocation.y)
                }
                
                //Adjust position
                movingBubble.shape.position = CGPoint(x: movingBubble.hint.x, y: movingBubble.hint.y)
                //These animations just make everything sluggish - therefore remove them
                movingBubble.shape.removeAnimationForKey("position")
                
                movingBubble.movement[currentTime] = CGPoint(x: movingBubble.hint.x, y: movingBubble.hint.y)
            }
            
            
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if let ct = bubbleForTouch[touch]?.text {
                ct.removeFromSuperlayer()
                bubbleForTouch[touch]?.text = nil
            }
            bubbleForTouch[touch] = nil
        }
        
        
        
        
    }
}