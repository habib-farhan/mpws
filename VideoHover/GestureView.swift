//
//  GestureView.swift
//  Gesturebookmark
//
//  Created by Oliver Nowak on 6/23/16.
//  Copyright © 2016 BorchisAmy. All rights reserved.
//

import UIKit
import CoreGraphics;

class GestureView: UIView {
    
    let Add: Int
    let Remove: Int
    let Read: Int
    
    //Variables for the GestureRecognizer
    var middlePoint:CGPoint = CGPointZero
    var score:Float = 0
    var angle:Float = 0
    
    let recognizer: GLGestureRecognizer = GLGestureRecognizer()
    var delegate: GestureViewDelegate?
    
    //Describes the view's mode (Read, Add, Remove), changes the background color of the view depending to the mode and informs it's delegate about the mode
    var mode: Int{
        didSet{
            if mode == Add {
                self.backgroundColor = UIColor(red: 0, green: 0.7, blue: 1, alpha: 0.5)
            } else if mode == Remove {
                self.backgroundColor = UIColor(red: 1, green: 0.2, blue: 0, alpha: 0.5)
            }else {
                self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            }
            //
            delegate!.gestureViewModeChangedTo!(mode)
            setNeedsDisplay()
        }
    }
    var storingKey: String = "0"
    

    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        //Set constants
        Read = Int(recognizer.cRead())
        Add = Int(recognizer.cAdd())
        Remove = Int(recognizer.cRemove())
        
        //Checks if no Gesture.json exists, a new JSON file is created
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let path = documentsDirectory.stringByAppendingString("/Gestures.json");
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path){
            let string = "{}"
            try! string.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        }
        let jsonData: NSData! = try! NSData(contentsOfFile: path as String, options: NSDataReadingOptions.DataReadingMapped)
        mode = Read
        super.init(coder: aDecoder)
      
        //Loading the data from the File
        if jsonData === nil{
            print("json Data is nil")
            return
        }
        do{
            try recognizer.loadTemplatesFromJsonData(jsonData)
        } catch {
            print("Error loading gestures: %@", error);
            return;
        }
        
    }
    //Checks the done gesture and calls the delegate
    func processGestureData(){
        let storingKey = mode == Add ? self.storingKey : "0"
        let receivedKey = recognizer.findBestMatchCenter(&middlePoint, angle:&angle, score:&score, mode: Int32(mode), key: storingKey)
        if receivedKey != nil && mode == Read {
            delegate!.updateTime(CGFloat((receivedKey as NSString).floatValue))
        }
        mode = Read;
    }   
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        recognizer.resetTouches()
        recognizer.addTouches(touches, fromView: self)
        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        recognizer.addTouches(touches, fromView: self)
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        recognizer.addTouches(touches, fromView:self);
        
        processGestureData();
        recognizer.resetTouches()
        setNeedsDisplay();
    }
    
    //Draws lines between the each pair of touch points
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath();
        for pointValue in recognizer.touchPoints{
            let pointInView: CGPoint = pointValue.CGPointValue()
            if pointValue === recognizer.touchPoints[0]{
                path.moveToPoint(pointInView)
            }
            else{
                path.addLineToPoint(pointInView);
            }
        }
        if mode == Read {
            UIColor(red: 0, green: 0.7, blue: 1, alpha: 0.7).setStroke()
        }else {
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.7).setStroke()
        }
        
        path.lineCapStyle = CGLineCap.Round
        path.lineWidth = 10
        path.stroke()

    }    
}

@objc protocol GestureViewDelegate {
    func updateTime(time:CGFloat)
    optional func gestureViewModeChangedTo(mode:Int)
}
