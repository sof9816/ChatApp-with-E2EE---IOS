//
//  Extensions.swift
//  ChatApp
//
//  Created by Mustafa on 5/12/18.
//  Copyright © 2018 Mustafa. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWith(urlString: String) {
        
         self.image = nil
        
        // see if the image is already in the cache
        if let cacheImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cacheImage
            return
        }
        
        // else put it in the cache
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
                if err != nil{
                    print(err!)
                    return
                }
                DispatchQueue.main.async {
                    
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                    }
                }
                
            }).resume()
        }
    }
}
