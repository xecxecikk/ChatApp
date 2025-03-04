//
//  HomeTableViewCell.swift
//  ChatApp
//
//  Created by XECE on 22.02.2025.
//


import UIKit

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        imagePhoto.layer.cornerRadius = imagePhoto.frame.width / 2
        imagePhoto.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
