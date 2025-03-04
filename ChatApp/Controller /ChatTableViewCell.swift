//
//  ChatTableViewCell.swift
//  ChatApp
//
//  Created by XECE on 23.02.2025.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let viewRow: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        addSubview(viewRow)
        addSubview(label)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            viewRow.topAnchor.constraint(equalTo: label.topAnchor, constant: -10),
            viewRow.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            viewRow.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10),
            viewRow.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10)
        ])
    }

    func configure(with message: Message, isIncoming: Bool) {
        label.text = message.message
        viewRow.backgroundColor = isIncoming ? .gray : .blue
        label.textAlignment = isIncoming ? .left : .right
    }
}
