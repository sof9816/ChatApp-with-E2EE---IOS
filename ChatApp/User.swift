//
//  User.swift
//  ChatApp
//
//  Created by Mustafa on 5/11/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var email: String?
    var pu: String?
    var profileImageUrl:String?
    var id: String?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.pu = dictionary["pu"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
