//
//  VideoPlayer.swift
//  VideoHover
//
//  Created by Jörg Christian Kirchhof on 23/06/16.
//  Copyright © 2016 Media Computing Group of RWTH Aachen University. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayer : UIView {
    private var firstAppear = true
    var timer : NSTimer = NSTimer()
    var player : AVPlayer = AVPlayer()
    var hover : VideoHover = VideoHover()
    var chb = CHB()
    var playing = false
    
    override func drawRect(rect: CGRect) {
        if firstAppear {
            do {
                try playVideo()
                firstAppear = false
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource("Untitled", ofType:"mp4") else {
            throw AppError.InvalidResource("Untitled", "mp4")
        }
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        
        self.layer.addSublayer(playerLayer)
        playing = true
        player.play()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: #selector(VideoPlayer.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTime () {
        let seconds: CGFloat = CGFloat(((player.currentTime().value)*100) / (Int64)(player.currentTime().timescale))/100
        let videoLength = CMTimeGetSeconds(player.currentItem!.asset.duration)
        if(videoLength != 0 && !chb.touching){
            chb.update(seconds/CGFloat(videoLength))
        }
        if(chb.currentPosition==1){
            playing=false
        }
        
    }
    
}



enum AppError : ErrorType {
    case InvalidResource(String, String)
}
