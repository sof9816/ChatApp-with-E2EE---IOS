//
//  LoadingView.swift
//  
//
//  Created by Mustafa-GTS on 4/30/18.
//
//

import UIKit
import SnapKit

class LoadingView: UIView {

    
    let activityIndicaterView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let textLabel = UILabel()

    override func draw(_ rect: CGRect) {
        self.addSubview(activityIndicaterView)
        self.addSubview(textLabel)

        activityIndicaterView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(10)
            
        }
        textLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(activityIndicaterView.snp.bottom).offset(10)
            make.width.equalTo(self)
        }
        
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 20)
        textLabel.text = "Loading..."
        textLabel.textAlignment = .center
        
        activityIndicaterView.startAnimating()
        
        
    }
    func stopAnimating(){
        self.activityIndicaterView.stopAnimating()
    }
 
    override func didMoveToWindow() {
        self.backgroundColor = UIColor(white: 0 , alpha: 0.6)
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true

    }

    
}
