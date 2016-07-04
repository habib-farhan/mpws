//
//  ViewController.swift
//  VideoHover
//
//  Created by Jörg Christian Kirchhof on 22/06/16.
//  Widget added by Farhan Habib on 3/07/16.
//  Copyright © 2016 Media Computing Group of RWTH Aachen University. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController, VideoHoverDelegate, CHBDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResult: UILabel!
    
    
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
    
    func pauseVideo() {
        videoPlayer!.player.rate = 0.0
    }
    
    func playVideo() {
        videoPlayer!.player.rate = 1.0
    }
    
    func jumpToNextFrame() {
        videoPlayer!.player.currentItem?.stepByCount(1)
    }
    
    func updateTime(time: CGFloat) {
        let videoLength = CMTimeGetSeconds((videoPlayer?.player.currentItem!.asset.duration)!)
        videoPlayer?.player.seekToTime(CMTimeMake(Int64(time*CGFloat(videoLength*1000)),1000), toleranceBefore:kCMTimeZero ,toleranceAfter:kCMTimeZero)
    }
    
    func currentTime() -> (Int64, Float) {
        let player = videoPlayer!.player
        
        let hundredthseconds = (player.currentTime().value  * 100) / (Int64)(player.currentTime().timescale)
        let hundredth = (Float(hundredthseconds) / 100.0) % 1
        let seconds = (player.currentTime().value) / (Int64)(player.currentTime().timescale)
        
        return (seconds, hundredth)
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
    var chb: CHB? = nil
    var videoPlayer : VideoPlayer? = nil
    
    override func viewDidLoad() {
        searchResult.text = " "
        
    }
    
    //searchbutton implementation to check for the contents
    @IBAction func searchButton(sender: AnyObject) {
        
        
        let search = searchBar.text
        
        //checking for the command in the search bar and mapping it to appropriate data and cideo frame
        if(search == "Müller"){
            searchResult.text = "Jumped to 0:05 "
            videoPlayer?.player.seekToTime(CMTimeMakeWithSeconds(5, 5))
            
        }
        if(search == "Boateng"){
            searchResult.text = "Jumped to 0:22 "
            videoPlayer?.player.seekToTime(CMTimeMakeWithSeconds(20, 10))
            
        }
        if(search == "Schürrle"){
            searchResult.text = "Jumped to 0:34 "
            videoPlayer?.player.seekToTime(CMTimeMakeWithSeconds(29, 5))
            
        }
        if(search == " Attack"){
            searchResult.text = "Jumped to 0:34 "
            videoPlayer?.player.seekToTime(CMTimeMakeWithSeconds(30, 5))
            
        }
        if(search == "Close call"){
            searchResult.text = "Jumped to 0:42 "
            videoPlayer?.player.seekToTime(CMTimeMakeWithSeconds(40, 20))
            
        }
        if(search == "Goal"){
            searchResult.text = "No goal was scored :( "
            //videoPlayer?.player.seekToTime(CMTimeMakeWithSeconds(5, 5))
            
        }
        if(search == "Foul"){
            searchResult.text = "No foul given "
            
            
        }
        if(search == "Hand"){
            searchResult.text = "No hand ball "
        
            
        }
      else
        {
            //searchResult.text = "Sorry content not available "
        }
        
        
        
    }
    

    
    override func viewDidAppear(animated: Bool) {
        
        for sv in self.view.subviews {
            if let vh = sv as? VideoHover {
                hover = vh
                hover?.setPlaying(true)
                hover?.delegate = self
                vh.showOverlays()
            }
        }
        
        for sv in self.view.subviews {
            if let vh = sv as? CHB {
                chb = vh
                chb!.delegate = self
            }
        }
        
        for sv in self.view.subviews {
            if let vp = sv as? VideoPlayer {
                vp.hover = hover!
                vp.chb = chb!
                videoPlayer = vp
            }
        }
        
        hover?.addHint(VideoHint(startSec: 0, startHundredth: 0, endSec: 10, endHundredth: 0, x: 150, y: 200, radius: 50, hint: "Boateng \nPA%\t89.2\nShots\t1 "))
        
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