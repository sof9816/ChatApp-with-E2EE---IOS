//
//  ChatCell.swift
//  ChatApp
//
//  Created by Mustafa on 5/14/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit
import AVFoundation

class ChatCell: UICollectionViewCell {
    
    
    var message: Message?
    var chatLogController: ChatLogController?
    
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    
    lazy var playButton: UIButton = {
       let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "playbut")
        button.tintColor = UIColor.white
        button.setImage(image, for: UIControlState())
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handlePlay() {
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            print("Attempting to play video......???")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isEditable = false
        return tv
    }()
    
    static let blue = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
       let view = UIView()
        view.backgroundColor = blue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "profilePic2")
        
        return image
    }()
    
    lazy var messageImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return image
    }()
    
    @objc func handleZoomTap(tap: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        if let imageView = tap.view as? UIImageView {
            self.chatLogController?.performZoomInFor(imageView: imageView)
        }
    }
    
    var bubbuleWidthAnchor: NSLayoutConstraint?
    var bubbuleRightAnchor: NSLayoutConstraint?
    var bubbuleLeftAnchor: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImage)
        bubbleView.addSubview(messageImageView)
        
        
        // x, y, w, h
        messageImageView.snp.makeConstraints { (make) in
            make.left.equalTo(bubbleView)
            make.top.equalTo(bubbleView)
            make.width.equalTo(bubbleView)
            make.height.equalTo(bubbleView)
        }
        
        
        
        bubbleView.addSubview(playButton)
        // x,y,w,h
        playButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(bubbleView)
            make.centerX.equalTo(bubbleView)
            make.width.height.equalTo(50)
        }
        
        bubbleView.addSubview(activityIndicatorView)
        //x,y,w,h
        activityIndicatorView.snp.makeConstraints { (make) in
            make.centerX.equalTo(bubbleView)
            make.centerX.equalTo(bubbleView)
            make.width.height.equalTo(50)
        }

        // x,y,w,h
        profileImage.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(8)
            make.bottom.equalTo(self)
            make.width.height.equalTo(32)
        }

        // x,y,w,h
        bubbuleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbuleRightAnchor?.isActive = true
        
        bubbuleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbuleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbuleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        // x,y,w,h
        
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(bubbleView).offset(8)
            make.top.equalTo(self)
            make.right.equalTo(bubbleView)
            make.height.equalTo(self)
        }
       
     
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
}
