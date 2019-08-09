//
//  ChatInputContainerView.swift
//  ChatApp
//
//  Created by Mustafa on 5/19/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatLogController: ChatLogController? {
     
        didSet {
            sendBut.addTarget(chatLogController, action: #selector(ChatLogController.handleSned), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))

        }
    }

    lazy var inputText: UITextField = {
        let inputText = UITextField()
        inputText.placeholder = "Enter message..."
        inputText.translatesAutoresizingMaskIntoConstraints = false
        inputText.delegate = self
        return inputText
    }()
    
    let sendBut = UIButton(type: .system)
    
    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload-image")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isHidden = true
        return uploadImageView
    }()

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSned()
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
       
        addSubview(uploadImageView)
        
        // x , y ,w ,h
        
       
        
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        sendBut.setTitle("send", for: .normal)
        sendBut.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendBut)
        
        // x,y,w,h constraints
        
        sendBut.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendBut.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendBut.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendBut.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
        

        addSubview(self.inputText)
        
        // x,y,w,h constraints
        
        self.inputText.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 4).isActive = true
        self.inputText.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputText.rightAnchor.constraint(equalTo: sendBut.leftAnchor).isActive = true
        self.inputText.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
        let sperator = UIView()
        sperator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        sperator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sperator)
        
        // x,y,w,h constraints
        
        sperator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        sperator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        sperator.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        sperator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
