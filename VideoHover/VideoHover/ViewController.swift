//
//  ViewController.swift
//  VideoHover
//
//  Created by Jörg Christian Kirchhof on 22/06/16.
//  Copyright © 2016 Media Computing Group of RWTH Aachen University. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBAction func annotationSwitchChanged(sender: AnyObject) {
        let sw = sender as! UISwitch
        if sw.on {
            hover?.showOverlays()
        } else {
            hover?.hideOverlays()
        }
        
    }
    
    @IBAction func editingSwitchChanged(sender: AnyObject) {
        let sw = sender as! UISwitch
        hover?.setEditing(sw.on)
    }
    
    @IBAction func resetVideo(sender: AnyObject) {
        videoPlayer?.player.seekToTime(kCMTimeZero)
    }
    
    @IBAction func playPause(sender: AnyObject) {
        let button = sender as! UIButton
        if videoPlayer?.player.rate == 0.0 {
            videoPlayer!.player.rate = 1.0
            button.setTitle("Pause", forState: .Normal)
            hover?.setPlaying(true)
        } else {
            videoPlayer!.player.rate = 0.0
            button.setTitle("Play", forState: .Normal)
            hover?.setPlaying(false)
        }
    }
    
    
    var hover : VideoHover? = nil
    var videoPlayer : VideoPlayer? = nil
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        for sv in self.view.subviews {
            if let vh = sv as? VideoHover {
                vh.showOverlays()
                hover = vh
                hover?.setPlaying(true)
            }
        }
        for sv in self.view.subviews {
            if let vp = sv as? VideoPlayer {
                vp.hover = hover!
                videoPlayer = vp
            }
        }
        
        hover?.addHint(VideoHint(startSec: 2, startHundredth: 0, endSec: 10, endHundredth: 0, x: 150, y: 200, radius: 50, hint: "Boateng \nPA%\t89.2\nShots\t1 "))
        
        hover?.addHint(VideoHint(startSec: 12, startHundredth: 0, endSec: 20, endHundredth: 0, x: 0, y: 0, radius: 50, hint: "Boateng \nPA%\t89.2\nShots\t1 "))
        hover?.addHint(VideoHint(startSec: 12, startHundredth: 0, endSec: 20, endHundredth: 0, x: 850, y: 500, radius: 50, hint: "Boateng \nPA%\t89.2\nShots\t1 "))
        
        let blueHint = VideoHint(startSec: 21, startHundredth: 0, endSec: 25, endHundredth: 0, x: 200, y: 250, radius: 25, hint: "Boateng \nPA%\t89.2\nShots\t1 ")
        let redHint = VideoHint(startSec: 21, startHundredth: 0, endSec: 25, endHundredth: 0, x: 400, y: 250, radius: 50, hint: "Boateng \nPA%\t89.2\nShots\t1 ")
        let greenHint = VideoHint(startSec: 21, startHundredth: 0, endSec: 25, endHundredth: 0, x: 700, y: 250, radius: 75, hint: "Boateng \nPA%\t89.2\nShots\t1 ")
        blueHint.setColor(UIColor.blueColor())
        redHint.setColor(UIColor.redColor())
        greenHint.setColor(UIColor.greenColor())
        
        hover?.addHint(blueHint)
        hover?.addHint(redHint)
        hover?.addHint(greenHint)
        
    }
}