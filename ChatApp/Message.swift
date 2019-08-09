//
//  Message.swift
//  ChatApp
//
//  Created by Mustafa on 5/13/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    
    var timestamp: NSNumber?
    var fromId: String?
    var toId: String?
    var text: String?
    var sentPublic: String?
    var recivedPublic: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoUrl: String?
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
        //
        //        if fromId == Auth.auth().currentUser?.uid ? toId : fromId {
        //            return toId
        //        } else {
        //            retrun fromId
        //        }
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        sentPublic = dictionary["sentPublic"] as? String
        recivedPublic = dictionary["recivedPublic"] as? String
        fromId = dictionary["fromId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        videoUrl = dictionary["videoUrl"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        
        
    }
}

