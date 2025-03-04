//
//  Common .swift
//  ChatApp
//
//  Created by XECE on 30.01.2025.
//


import Foundation
import UIKit

class Helper {
    
    static func dialogMessage(message:String, vc:UIViewController) {
        
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    static func imageLoad(imageView:UIImageView, url:String) {
        
        let downloadTask = URLSession.shared.dataTask(with: URL(string: url)!) { (data, urlResponse, error) in
            if error == nil && data != nil {
                let image = UIImage(data: data!)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
        downloadTask.resume()
    }
}
