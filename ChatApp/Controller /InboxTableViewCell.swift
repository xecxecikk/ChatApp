//
//  InboxTableViewCell.swift
//  ChatApp
//
//  Created by XECE on 7.03.2025.
//

import UIKit

class InboxTableViewCell: UITableViewCell {
  
        @IBOutlet weak var userImageView: UIImageView!
        @IBOutlet weak var nameLabel: UILabel!
    private let messageLabel: UILabel = {
           let label = UILabel()
           label.textColor = .darkGray
           label.font = UIFont.systemFont(ofSize: 14)
           label.numberOfLines = 2
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
       }()

       override func awakeFromNib() {
           super.awakeFromNib()
           setupUI()
       }

       private func setupUI() {
           userImageView.layer.cornerRadius = userImageView.frame.width / 2
           userImageView.clipsToBounds = true
           userImageView.contentMode = .scaleAspectFill
           userImageView.layer.borderColor = UIColor.lightGray.cgColor
           userImageView.layer.borderWidth = 1
           
           nameLabel.textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
           nameLabel.font = UIFont.boldSystemFont(ofSize: 18)

           contentView.addSubview(messageLabel)

          
           NSLayoutConstraint.activate([
               messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
               messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
               messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
               messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
           ])
       }

       func configureCell(name: String, message: String, imageUrl: String) {
           nameLabel.text = name
           messageLabel.text = message

           if !imageUrl.isEmpty {
               Helper.imageLoad(imageView: userImageView, url: imageUrl)
           } else {
               userImageView.image = UIImage(named: "default_profile") // 🔥 Resim yoksa default ata
           }
       }
   }
