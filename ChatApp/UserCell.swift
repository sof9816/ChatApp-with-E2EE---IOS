//
//  UserCell.swift
//  ChatApp
//
//  Created by Mustafa on 5/13/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserCell:  UITableViewCell {
    
//    var ch: ChatLogController?{
//        didSet{
//            let pu = ch?.user?.pu
//            let myPr = UserDefaults.standard.getPirvateKey()! // my private key
//            let p = "12312312" // prime
//            let iv = "abcdefghijklmnop" // 16 bytes for AES128
//            let cryptoDHKey = DHKeyExchangeManager.generateDHCryptoKey(privateDHKey: myPr, serverPublicDHKey: pu!, primeNumber: p)
//            let cryptoDHKeyE:String = "\(cryptoDHKey + cryptoDHKey + cryptoDHKey.prefix(2))"
//            let aes128 = AES(key: cryptoDHKeyE, iv: iv)
//            
//            if (aes128 != nil){
//                self.detailTextLabel?.text = aes128?.decrypt(data: Data(base64Encoded: message!.text!))
//            }else{
//                self.detailTextLabel?.text = "Encrypted Message !"
//            }
//        }
//    }

    var message: Message? {
        didSet{
            setupNameAndImage()
            self.detailTextLabel?.text = "Encrypted Message !"

            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    
    
    
    private func setupNameAndImage() {
        
        if let id = message?.chatPartnerId(){
            let ref = Database.database().reference().child("users").child(id)
                ref.observe(.value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            self.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
                        }
                    }
                }, withCancel: nil)
            }
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)!, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)!, width: (detailTextLabel?.frame.width)!, height: (textLabel?.frame.height)!)
    }
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profilePic2")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(8)
            make.centerY.equalTo(self)
            make.width.height.equalTo(48)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.top.equalTo(self).offset(17)
            make.width.equalTo(100)
            make.height.equalTo((textLabel?.snp.height)!)
        }
       
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
}
