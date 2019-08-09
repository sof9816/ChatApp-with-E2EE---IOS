//
//  LoginController+Handle.swift
//  ChatApp
//
//  Created by Mustafa on 5/11/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //// generate Client DH Keys
  
    func secDhKeyGen() -> DHKey {
        let secDHKeys = DHKeyExchangeManager.generateDHExchangeKeys(generator: self.g, primeNumber: self.p) // return object "DHKey"
        print("\(secDHKeys.privateKey!)\n")
        print("\(secDHKeys.publicKey!)\n")

        return secDHKeys
    }

    @objc func handleLoginRegisterSegment() {
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        // change height of input container view
        
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 120 : 200
        
        // Name Text Field Control
        nameTextFieldAnchor?.isActive = false
        nameTextFieldAnchor = nameTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 0 : 1/5)
        nameTextFieldAnchor?.isActive = true
        
        // email Text Field Control
        emailTextFieldAnchor?.isActive = false
        emailTextFieldAnchor = emailTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 1/3 : 1/5)
        emailTextFieldAnchor?.isActive = true
        
        // password Text Field Control
        passwordTextFieldAnchor?.isActive = false
        passwordTextFieldAnchor = passwordTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ?  1/3  : 1/5)
        passwordTextFieldAnchor?.isActive = true
        
        // public key Text Field Control
        publicTextFieldAnchor?.isActive = false
        publicTextFieldAnchor = publicTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 0 : 1/5)
        publicTextFieldAnchor?.isActive = true
        
        
        // password Text Field Control
        privateTextFieldAnchor?.isActive = false
        privateTextFieldAnchor = privateTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ?  1/3  : 1/5)
        privateTextFieldAnchor?.isActive = true
        
    }
    
    
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let pvtKey = privateTextField.text else {
            self.alert(title: "error", message: "Form is not valid")
            self.loadingView.stopAnimating()
            self.loadingView.removeFromSuperview()
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if  error != nil  {
                self.alert(title: "error", message: (error?.localizedDescription)!)
                self.loadingView.stopAnimating()
                self.loadingView.removeFromSuperview()
                return
            }
            if pvtKey.isEmpty {
                self.alert(title: "error", message:"Error !\n Private key field is empty")
                self.loadingView.stopAnimating()
                self.loadingView.removeFromSuperview()
                return
            }
            // Successful Login
            UserDefaults.standard.setPirvateKey(value: pvtKey)
            self.messagesController?.fetchUserAndSetupNavTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleLoginRegister() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(view!)
            make.height.equalTo(100)
            make.width.equalTo(150)
            
        }
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let pu = publicTextField.text,
        let pr = privateTextField.text else {
            self.alert(title: "error", message: "Form is not valid")
            self.loadingView.stopAnimating()
            self.loadingView.removeFromSuperview()
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if  error != nil {
                self.alert(title: "error", message: (error?.localizedDescription)!)
                self.loadingView.stopAnimating()
                self.loadingView.removeFromSuperview()
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
	
            // Successful
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image
               , let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            self.alert(title: "error", message: (error?.localizedDescription)!)
                            self.loadingView.stopAnimating()
                            self.loadingView.removeFromSuperview()
                            return
                        }
                        
                        if let url = metadata?.downloadURL()?.absoluteString {
                            let values = ["name": name, "email": email, "profileImageUrl": url, "pu": pu]
                            UserDefaults.standard.setPirvateKey(value: pr)
                            self.registerUserToDatabase(uid: uid, values: values)
                        }
                        
                    })
                }
            
            
            
        }
    }
    private func registerUserToDatabase(uid: String, values: [String: Any]) {
        let ref =  Database.database().reference()
        let userRef = ref.child("users").child(uid)
        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if  error != nil {
                self.alert(title: "error", message: (error?.localizedDescription)!)
                self.loadingView.stopAnimating()
                self.loadingView.removeFromSuperview()
                return
            }
            let user = User(dictionary: values)

            self.messagesController?.setupNavBarWith(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
