//
//  HomeTableViewCell.swift
//  ChatApp
//
//  Created by XECE on 22.02.2025.
//


import UIKit

class HomeTableViewCell: UITableViewCell {
    

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    override func awakeFromNib() {
          super.awakeFromNib()
          setupUI()
      }
      
      override func layoutSubviews() {
          super.layoutSubviews()
          setupUI()
      }
      
      private func setupUI() {
          userImage.layer.cornerRadius = userImage.frame.width / 2
          userImage.clipsToBounds = true
          userImage.contentMode = .scaleAspectFill
          userImage.layer.borderWidth = 1
          userImage.layer.borderColor = UIColor.lightGray.cgColor
      }
      
      override func prepareForReuse() {
          super.prepareForReuse()
          userImage.image = nil
      }
      
      func configureCell(name: String, imageUrl: String) {
          labelName.text = name
          
          if let url = URL(string: imageUrl), !imageUrl.isEmpty {
              Helper.imageLoad(imageView: userImage, url: imageUrl)
          } else {
              userImage.image = nil 
          }
      }
  }
