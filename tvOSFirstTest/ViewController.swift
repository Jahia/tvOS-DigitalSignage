//
//  ViewController.swift
//  tvOSFirstTest
//
//  Created by Serge Huber on 14.09.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let outputFilePath_1 = "lostdog.mp4"
    var player_1 : AVPlayer?
    var alreadyDisplaying = false
    var originalTextViewFrame : CGRect?
    var originalImageViewFrame : CGRect?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var lowerThirdTextView: UITextView!
    @IBOutlet weak var lowerThirdImageView: UIImageView!
    
    var timer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImageViewFrame = lowerThirdImageView.frame
        originalTextViewFrame = lowerThirdTextView.frame
        lowerThirdTextView.alpha = 0.0
        lowerThirdImageView.alpha = 0.0
        lowerThirdTextView.frame.origin.x += 1920;
        lowerThirdImageView.frame.origin.x += 1920;
        // Do any additional setup after loading the view, typically from a nib.
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateSignage:", userInfo: nil, repeats: true)
        
        let outputFilePath_1 = NSBundle.mainBundle().pathForResource("lostdog", ofType: "mp4")
        print(outputFilePath_1)
        let url_1 = NSURL.fileURLWithPath(outputFilePath_1!)
        let asset_1 = AVAsset(URL: url_1)
        let playerItem_1 = AVPlayerItem(asset: asset_1)
        player_1 = AVPlayer(playerItem: playerItem_1)
        let playerLayer_1 = AVPlayerLayer(player: player_1)
        
        playerLayer_1.frame = CGRect(x: 0, y: 0, width: videoView.frame.width, height: videoView.frame.height)
        
        print(videoView.layer)
        videoView.layer.insertSublayer(playerLayer_1, atIndex: 0)
        player_1!.play()
        player_1!.actionAtItemEnd = .None
        
        //set a listener for when the video ends
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "restartVideoFromBeginning",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player_1!.currentItem)
        
    }
    
    //function to restart the video
    func restartVideoFromBeginning()  {
        
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player_1!.seekToTime(seekTime)
        
        player_1!.play()
        
    }
    
    func updateSignage(timer:NSTimer) {
        let signageUrl:NSURL = NSURL(string: "http://localhost:8181/digitalSignage.json")!
        statusLabel.text = "Retrieving JSON profile from \(signageUrl)..."
        let signageData:NSData = try! NSData(contentsOfURL: signageUrl, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(signageData, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        if let profileID = jsonResult["itemId"] as? String {
            if (alreadyDisplaying) {
                return
            }
            let properties = jsonResult["properties"] as! [String:AnyObject]
            if let firstName = properties["firstName"] as? String,
               let city = properties["city"] as? String {
            lowerThirdTextView.text = "Hello \(firstName), don't carry your drinks to \(city), you can have them delived instead! Check your phone now for more information."
            displayLowerThird()
            alreadyDisplaying = true
            } else {
                print("First name or City property -not found")
            }
        } else {
            hideLowerThird()
            alreadyDisplaying = false
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayLowerThird() {
        UIView.animateWithDuration(3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.lowerThirdTextView.alpha = 1.0
            self.lowerThirdImageView.alpha = 1.0
            self.lowerThirdTextView.frame = self.originalTextViewFrame!
            self.lowerThirdImageView.frame = self.originalImageViewFrame!
            }, completion: { finished in
                print("displayLowerThird animation completed")
        })
    }
    
    func hideLowerThird() {
        UIView.animateWithDuration(3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.lowerThirdTextView.alpha = 0.0
            self.lowerThirdImageView.alpha = 0.0
            self.lowerThirdTextView.frame.origin.x += 1920;
            self.lowerThirdImageView.frame.origin.x += 1920;
            }, completion: { finished in
                print("hideLowerThird animation completed")
        })
    }

}

