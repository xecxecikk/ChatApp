//
//  Common .swift
//  ChatApp
//
//  Created by XECE on 30.01.2025.
//

import UIKit

class Helper {
    static func dialogMessage(message: String, vc: UIViewController) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

    static func imageLoad(imageView: UIImageView, url: String) {
        guard let imageUrl = URL(string: url) else {
            print("Hata: Geçersiz URL: \(url)") 
            return
        }

        let downloadTask = URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
            if let error = error {
                print("Resim yükleme hatası: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
        downloadTask.resume()
    }

    }
