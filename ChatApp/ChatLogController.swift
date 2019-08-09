//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Mustafa on 5/12/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MobileCoreServices
import AVFoundation

extension UICollectionView {
    func isIndexPathAvailable(_ indexPath: IndexPath) -> Bool {
        guard dataSource != nil,
            indexPath.section < numberOfSections,
            indexPath.item < numberOfItems(inSection: indexPath.section) else {
                return false
        }
        
        return true
    }
    
    func scrollToItemIfAvailable(at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        guard isIndexPathAvailable(indexPath) else { return }
        
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollToItemOrThrow(at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) throws {
        guard isIndexPathAvailable(indexPath) else {
            throw Error.invalidIndexPath(indexPath: indexPath, lastIndexPath: lastIndexPath)
        }
        
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    var lastIndexPath: IndexPath {
        let lastSection = numberOfSections - 1
        return IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                         section: lastSection)
    }
}

extension UICollectionView {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidIndexPath(indexPath: IndexPath, lastIndexPath: IndexPath)
        
        var description: String {
            switch self {
            case let .invalidIndexPath(indexPath, lastIndexPath):
                return "IndexPath \(indexPath) is not available. The last available IndexPath is \(lastIndexPath)"
            }
        }
    }
}
class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
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
    
    
    let cellId = "cellId"
    var user: User? {
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id  else {
            return
        }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            
            let myPr = UserDefaults.standard.getPirvateKey()! // my private key
            let hisPu = self.user!.pu! // his or her public key
            var cryptoDHKey = DHKeyExchangeManager.generateDHCryptoKey(privateDHKey: myPr, serverPublicDHKey: hisPu, primeNumber: self.p)
            if cryptoDHKey.count < 16{
                var i = 1
                while cryptoDHKey.count < 16 {
                    cryptoDHKey += cryptoDHKey.prefix(i)
                    i += 1
                }
            }
            
            let aes128 = AES(key: String(cryptoDHKey.prefix(16)), iv: self.iv)
            
            print(cryptoDHKey.prefix(16))
            //            print(UserDefaults.standard.getPirvateKey()!)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard var dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let text = aes128?.decrypt(data: Data(base64Encoded: dictionary["text"] as! String))
                dictionary["text"] = text as AnyObject
                self.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                if self.messages.count > 0 {
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItemIfAvailable(at: indexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        
        
        setupKeyboardObserver()
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
        
        
    }()
    
    
    @objc func handleUploadTap() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // select a video
            handleVideoSelectedFor(url: videoUrl)
            
        } else {
            // select an image
            handleImageSelectedFor(info: info)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func handleImageSelectedFor(info: [String: Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl,image: selectedImage)
            })
        }
        
    }
    private func handleVideoSelectedFor(url: NSURL) {
        let filename = UUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url as URL, metadata: nil, completion: { (metadata, err) in
            if err != nil {
                self.alert(title: "error", message: (err?.localizedDescription)!)
                
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.thumbnailImageFor(videoUrl: url as URL) {
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                    })
                    
                }
                
                
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            if let complateUnit = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(complateUnit)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
            
        }
    }
    private func thumbnailImageFor(videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
            
        } catch _ {
            
        }
        return nil
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message-images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if err != nil {
                    self.alert(title: "error", message: (err?.localizedDescription)!)
                    
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                    
                }
                
            })
        }
    }
    
    
    
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            self.collectionView?.scrollToItemIfAvailable(at: indexPath, at: .top, animated: true)
        }
    }
    
    
    func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewbottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewbottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    var containerViewbottomAnchor: NSLayoutConstraint?
    let p = "199193" // prime
    let iv = "abcdefghijklmnop" // 16 bytes for AES128
    let myPr = UserDefaults.standard.getPirvateKey()! // my private key
    @objc func handleSned() {
        let hisPu = user!.pu! // his or her public key
        
        var cryptoDHKey = DHKeyExchangeManager.generateDHCryptoKey(privateDHKey: self.myPr, serverPublicDHKey: hisPu, primeNumber: p)
        print("CryptoSharedDHKey before pending: \(cryptoDHKey)\n\n")
        if cryptoDHKey.count < 16{
            var i = 1
            while cryptoDHKey.count < 16 {
                cryptoDHKey += cryptoDHKey.prefix(i)
                i += 1
            }
        }

        print("CryptoSharedDHKey after pending: \(cryptoDHKey.prefix(16))\n\n")
        let inputText = inputContainerView.inputText.text!
        let aes128 = AES(key: String(cryptoDHKey.prefix(16)), iv: iv)
        let encText = aes128?.encrypt(string: inputText)!.base64EncodedString()
        //        print("The enc text : \(encText!)")
        //        print("The dec text : \(aes128?.decrypt(data: Data(base64Encoded: encText as! String)))")
        
        
        let properties = ["text": "\(encText!)"] as [String : Any]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let ref2 = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
        let rPu = user!.pu!
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var sPu:String?
        var values = ["toId": toId,"fromId": fromId,"recivedPublic": rPu, "timestamp": timestamp] as [String : Any]
        
        
        
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(dictionary: dictionary)
            sPu = user.pu
            values["sentPublic"] = sPu ?? ""
            
            properties.forEach({values[$0] = $1})
            
            childRef.updateChildValues(values) { (err, ref) in
                if err != nil {
                    self.alert(title: "error", message: (err?.localizedDescription)!)
                    return
                }
                self.inputContainerView.inputText.text = nil
                
                let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                let messageId = childRef.key
                userMessagesRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
            }
        }, withCancel: nil)
        
    }
    
    
    private func sendMessageWithImageUrl(imageUrl: String,image: UIImage) {
        
        let properties: [String: Any] = ["imageUrl": imageUrl,"imageWidth": image.size.width,"imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatCell
        
        cell.chatLogController = self
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.textView.isHidden = false
            cell.bubbuleWidthAnchor?.constant = estimateFrameFortext(text: text).width + 32
        } else if message.imageUrl != nil {
            cell.textView.isHidden = true
            cell.bubbuleWidthAnchor?.constant = 200
        }
        
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    func setupCell(cell: ChatCell, message: Message){
        
        if let url = self.user?.profileImageUrl {
            cell.profileImage.loadImageUsingCacheWith(urlString: url)
        }
        
        
        if message.fromId != Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.bubbuleRightAnchor?.isActive = false
            cell.bubbuleLeftAnchor?.isActive = true
            cell.profileImage.isHidden = false
        } else {
            cell.bubbleView.backgroundColor = ChatCell.blue
            cell.textView.textColor = UIColor.white
            cell.bubbuleRightAnchor?.isActive = true
            cell.bubbuleLeftAnchor?.isActive = false
            cell.profileImage.isHidden = true
        }
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWith(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameFortext(text: text).height + 20
        } else if let imageHeight = message.imageHeight?.floatValue, let imageWidth  = message.imageWidth?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameFortext(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        
        let option = NSStringDrawingOptions.usesDeviceMetrics.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    
    
    var frame: CGRect?
    var blackBackgroundView: UIView?
    var imageView: UIImageView?
    func performZoomInFor(imageView: UIImageView) {
        
        self.imageView = imageView
        self.imageView?.isHidden = true
        frame = imageView.superview?.convert(imageView.frame, to: nil)
        
        let zoomImageView = UIImageView(frame: frame!)
        zoomImageView.backgroundColor = UIColor.red
        zoomImageView.image = imageView.image
        zoomImageView.isUserInteractionEnabled = true
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWinow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWinow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWinow.addSubview(blackBackgroundView!)
            keyWinow.addSubview(zoomImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                let height = self.frame!.height / self.frame!.width * keyWinow.frame.width
                zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWinow.frame.width, height: height)
                zoomImageView.center = keyWinow.center
            }, completion: nil)
        }
    }
    
    
    @objc func handleZoomOut(tap: UITapGestureRecognizer) {
        if let zoomOutImageView = tap.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.frame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (done) in
                zoomOutImageView.removeFromSuperview()
                self.imageView?.isHidden = false
            })
            
        }
    }
}

