//
//  ViewController.swift
//  ChatApp
//
//  Created by Mustafa on 5/10/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

extension UserDefaults{
    
   
    func setUserID(value: String){
        set(value, forKey: UserDefaultsKeys.userID.rawValue)
    }
    
    func getUserID() -> String?{
        return string(forKey: UserDefaultsKeys.userID.rawValue)
    }
    
    func setPirvateKey(value: String){
        set(value, forKey: UserDefaultsKeys.prK.rawValue)
    }
    func getPirvateKey() -> String?{
        return string(forKey: UserDefaultsKeys.prK.rawValue)
    }
   
}

enum UserDefaultsKeys : String {
//    case profileP ic
    case userID
    case prK
}
class MessagesController: UITableViewController {


    
    func alert(title:String, message:String,buttonTitle:String? = "OK", completion:(()->Void)? = nil ){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlert = UIAlertAction(title: buttonTitle, style: .default) { (action) in
            if let completion = completion{
                completion()
            }
        }
        alert.addAction(okAlert)
        self.present(alert, animated: true, completion: nil)
        
    }
    
 
    var cellId = "cellId"
    
    // params to key generation

   
    
    
    
  let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView?.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(tableView!)
            make.height.equalTo(100)
            make.width.equalTo(150)
            
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handLogout))
        let image = UIImage(named: "newMessage2")?.resizeWith(width: 30)
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain , target: self, action: #selector(handleNewMessage))
        
        // know user not logged in
        
        checkIfUserLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let message = self.messages[indexPath.row]
        
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (err, ref) in
                if err != nil {
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadTable()
  
            })
        }
            
        
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageWith(messageId: messageId)

            }, withCancel: nil)
            
        }, withCancel: nil)
    
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
        }, withCancel: nil)
    }
    
    private func fetchMessageWith(messageId: String) {
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    
                    
                }
                
                self.attemptReloadTable()
            }
            
        }, withCancel: nil)
    }
    func attemptReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    var timer: Timer?
    @objc func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (m1, m2) -> Bool in
            return (m1.timestamp?.intValue ?? 0) > (m2.timestamp?.intValue ?? 0)
        })
        if messages.count == 0 {
            loadingView.stopAnimating()
            loadingView.removeFromSuperview()
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
    }

    //FIXME:-
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]

        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId

            self.showChatControllerFor(user: user)

        }, withCancel: nil)
    }
    
    @objc func handleNewMessage() {
     let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let rootView = UINavigationController(rootViewController: newMessageController)
        present(rootView, animated: true, completion: nil)
    }
    
    func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavTitle()
        }
        
    }
  
    var nameOfNav = UserDefaults.standard.getUserID() ?? ""

    func fetchUserAndSetupNavTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if  nameOfNav != "" {
            self.navigationItem.title = nameOfNav
        }
        else {
            self.navigationItem.title = ""
        }

        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User(dictionary: dictionary)

                self.setupNavBarWith(user: user)
            }
            
            
        }, withCancel: nil)
    }
    
    

    
    func setupNavBarWith(user: User) {
        
   
        
        messagesDictionary.removeAll()
        messages.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
        observeUserMessages()

        let title = UIView()
        title.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        
        let profileImage = UIImageView()
        title.addSubview(profileImage)

        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 20
        profileImage.clipsToBounds = true
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        if let url = user.profileImageUrl {
            profileImage.loadImageUsingCacheWith(urlString: url)
        }


        profileImage.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true


        let name = UILabel()
        title.addSubview(name)

        name.text = user.name
        name.translatesAutoresizingMaskIntoConstraints = false

        name.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8).isActive = true
        name.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        name.rightAnchor.constraint(equalTo: title.rightAnchor).isActive = true
        name.heightAnchor.constraint(equalTo: profileImage.heightAnchor).isActive = true
        
   
        if !(name.text?.isEmpty)!{
              UserDefaults.standard.setUserID(value: user.name!)
        }

        self.navigationItem.titleView = title
        
     

    }
    @objc func showChatControllerFor(user: User) {
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.user = user
        navigationController?.pushViewController(chatLog, animated: true)
    }
    
    @objc func handLogout() {
        do {
        try Auth.auth().signOut()
        } catch let  loggoutError {
            alert(title: "logoutError", message: loggoutError.localizedDescription)
            self.loadingView.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
            
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }

}

extension UIImage {
    
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
}
