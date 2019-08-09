//
//  LoginController+ContraintsSetup.swift
//  ChatApp
//
//  Created by Mustafa on 5/11/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import Foundation
import UIKit

extension LoginController {

    
    func setupLoginRegisterSegment() { //setup constraints for login Register Segment x,y,w,h
        
        
        loginRegisterSegmentControl.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(inputsContainerView.snp.top).offset(-12)
            make.width.equalTo(inputsContainerView.snp.width).multipliedBy(1)
            make.height.equalTo(40)
        }

    }
    
    
    func setupProfileImageView() { //setup constraints for profile image x,y,w,h
        
        profileImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(loginRegisterSegmentControl.snp.top).offset(-10)
            make.width.equalTo(150)
            make.height.equalTo(150)
        }

    }
    
    func setupLoginRegButton() { //setup constraints for login button x,y,w,h
        
        loginRegisterButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(inputsContainerView.snp.bottom).offset(12)
            make.width.equalTo(inputsContainerView.snp.width).offset(-12)
            make.height.equalTo(50)
        }

    }
    
    func setupInputsConstraintView() { //setup constraints for registration view x,y,w,h
        
        
        inputsContainerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view).offset(-24)
        }

        inputContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 200)
        inputContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSperatorView)
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSperatorView)
        
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSperatorView)
        
        inputsContainerView.addSubview(publicTextField)
        inputsContainerView.addSubview(publicSperatorView)
        
        inputsContainerView.addSubview(privateTextField)
        
        
        //setup name constraints
        
        nameTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView).offset(12)
            make.top.equalTo(inputsContainerView)
            make.width.equalTo(inputsContainerView)
        }

        nameTextFieldAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        nameTextFieldAnchor?.isActive = true
        
        // setup name Sperator constraints
        nameSperatorView.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView)
            make.top.equalTo(nameTextField.snp.bottom)
            make.width.equalTo(nameTextField)
            make.height.equalTo(1)

        }

        //setup email constraints
        emailTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView).offset(12)
            make.top.equalTo(nameSperatorView.snp.bottom)
            make.width.equalTo(inputsContainerView)
        }

        emailTextFieldAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        emailTextFieldAnchor?.isActive = true
        
        // setup email Sperator constraints
        emailSperatorView.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView)
            make.top.equalTo(emailTextField.snp.bottom)
            make.width.equalTo(nameTextField)
            make.height.equalTo(1)
        }

        
        //setup password constraints
        passwordTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView).offset(12)
            make.top.equalTo(emailSperatorView.snp.bottom)
            make.width.equalTo(inputsContainerView)
        }

        passwordTextFieldAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        passwordTextFieldAnchor?.isActive = true
        
        // setup password Sperator constraints
        passwordSperatorView.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView)
            make.top.equalTo(passwordTextField.snp.bottom)
            make.width.equalTo(nameTextField)
            make.height.equalTo(1)
        }
        
        
        //setup password constraints
        publicTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView).offset(12)
            make.top.equalTo(passwordSperatorView.snp.bottom)
            make.width.equalTo(inputsContainerView)
        }
        
        publicTextFieldAnchor = publicTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        publicTextFieldAnchor?.isActive = true
        
        // setup password Sperator constraints
        publicSperatorView.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView)
            make.top.equalTo(publicTextField.snp.bottom)
            make.width.equalTo(nameTextField)
            make.height.equalTo(1)
        }
        
        
        //setup password constraints
        privateTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputsContainerView).offset(12)
            make.top.equalTo(publicSperatorView.snp.bottom)
            make.width.equalTo(inputsContainerView)
        }
        
        privateTextFieldAnchor = privateTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        privateTextFieldAnchor?.isActive = true
    }

}

