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
        player.play()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: #selector(VideoPlayer.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTime () {
        let hundredthseconds = (player.currentTime().value  * 100) / (Int64)(player.currentTime().timescale)
        let hundredth = (Float(hundredthseconds) / 100.0) % 1
        let seconds = (player.currentTime().value) / (Int64)(player.currentTime().timescale)
        
        hover.setTime(seconds, hundredth: hundredth)
        
        /*
        if player.rate == 0 {
            do {
                try playVideo()
                firstAppear = false
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }

        }*/
    }
}



enum AppError : ErrorType {
    case InvalidResource(String, String)
}
