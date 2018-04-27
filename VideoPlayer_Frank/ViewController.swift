//
//  ViewController.swift
//  VideoPlayer_Frank
//
//  Created by BoTingDing on 2018/4/27.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4")!
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        addTimeOberver()
        videoView.layer.addSublayer(playerLayer)
        
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    func addTimeOberver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: {    [weak self] time in
            
            guard let currentItem = self?.player.currentItem else {return}
            
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playPressed(_ sender: UIButton) {
        if isVideoPlaying {
            player.pause()
            sender.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        }else {
            player.play()
            sender.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        }
        isVideoPlaying = !isVideoPlaying
    }
    
    @IBAction func backwardPressed(_ sender: Any) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 10
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(Int64(newTime * 1000), 1000)
        player.seek(to: time)
    }
    @IBAction func forwardPressed(_ sender: Any) {
        guard let duration = player.currentItem?.duration else {return}
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10
        
        if newTime < (CMTimeGetSeconds(duration) - 10.0) {
            let time: CMTime = CMTimeMake(Int64(newTime * 1000), 1000)
            player.seek(to: time)
        }
       
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(Int64(sender.value * 1000), 1000))
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLabel.text = getTimeString(from: player.currentItem!.duration)
        }
    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds])

        }
    }
}

