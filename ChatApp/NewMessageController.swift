//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Mustafa on 5/11/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewMessageController: UITableViewController {

 

    let cellId = "CellId"
    let loadingView = LoadingView()
    
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(tableView!)
            make.height.equalTo(100)
            make.width.equalTo(150)
            
        }
       
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.title = "New Message"
       
        
     
 
        fetchUser()
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
        
       
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key

                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
            
        }, withCancel: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = "public key : \(user.pu ?? "")"

        if let profileImageUrl = user.profileImageUrl { // set profile image from  the fire base
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    

    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        let user = self.users[indexPath.row]
        self.messagesController?.showChatControllerFor(user: user)
    }
}
