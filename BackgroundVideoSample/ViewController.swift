//
//  ViewController.swift
//  BackgroundVideoSample
//
//  Created by Tatsuya Tanaka on 20180331.
//  Copyright © 2018年 tattn. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    deinit {
        if let observers = observers {
            NotificationCenter.default.removeObserver(observers.player)
            NotificationCenter.default.removeObserver(observers.willEnterForeground)
            observers.boundsObserver.invalidate()
        }
    }

    private var observers: (player: NSObjectProtocol, willEnterForeground: NSObjectProtocol, boundsObserver: NSKeyValueObservation)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        let path = Bundle.main.path(forResource: "sample", ofType: "mp4")!
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.actionAtItemEnd = .none // default: pause
        //player.isMuted = false // default: false
        player.play()

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.zPosition = -2
        view.layer.insertSublayer(playerLayer, at: 0)

        let dimOverlay = CALayer()
        dimOverlay.frame = view.bounds
        dimOverlay.backgroundColor = UIColor.black.cgColor
        dimOverlay.zPosition = -1
        dimOverlay.opacity = 0.4
        view.layer.insertSublayer(dimOverlay, at: 0)

        let playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak playerLayer] _ in
                playerLayer?.player?.seek(to: kCMTimeZero)
                playerLayer?.player?.play()
        }

        let willEnterForegroundObserver = NotificationCenter.default.addObserver(
            forName: .UIApplicationWillEnterForeground,
            object: nil,
            queue: .main) { [weak playerLayer] _ in
                playerLayer?.player?.play()
        }

        let boundsObserver = view.layer.observe(\.bounds) { [weak playerLayer, weak dimOverlay] view, _ in
            DispatchQueue.main.async {
                playerLayer?.frame = view.bounds
                dimOverlay?.frame = view.bounds
            }
        }

        observers = (playerObserver, willEnterForegroundObserver, boundsObserver)
    }

    private func setupUI() {
        let label = UILabel(frame: CGRect(x: 0, y: 100, width: 200, height: 40))
        label.text = "Hello!"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.textAlignment = .center
        label.center.x = view.center.x
        label.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        view.addSubview(label)

        let login = UIButton(frame: .init(x: 30, y: view.frame.height - 150, width: view.frame.width - 60, height: 50))
        login.setTitle("LOG IN", for: .normal)
        login.setTitleColor(.white, for: .normal)
        login.layer.borderWidth = 1
        login.layer.borderColor = UIColor.white.cgColor
        login.layer.cornerRadius = 4
        login.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(login)

        let signup = UIButton(frame: login.frame)
        signup.frame.origin.y = login.frame.minY - 60
        signup.setTitle("SIGN UP", for: .normal)
        signup.setTitleColor(.white, for: .normal)
        signup.backgroundColor = UIColor(red: 0, green: 168.0/255, blue: 107.0/255, alpha: 1)
        signup.layer.cornerRadius = 4
        signup.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(signup)
    }
}

