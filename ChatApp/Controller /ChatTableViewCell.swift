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
        lbl.font = UIFont.systemFont(ofSize: 16)
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

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(viewRow)
        viewRow.addSubview(label)

        backgroundColor = .clear
        contentView.backgroundColor = UIColor.systemGray6 
        selectionStyle = .none

       
        leadingConstraint = viewRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = viewRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    }

    func configure(with message: ChatMessage, isIncoming: Bool) {
        label.text = message.message.isEmpty ? "Boş Mesaj" : message.message

        let incomingBubbleColor = UIColor(red: 1.0, green: 0.75, blue: 0.80, alpha: 1.0)
        let outgoingBubbleColor = UIColor(red: 0.70, green: 0.30, blue: 0.35, alpha: 1.0)

        viewRow.backgroundColor = isIncoming ? incomingBubbleColor : outgoingBubbleColor
        label.textColor = isIncoming ? .black : .white

        
        leadingConstraint.isActive = isIncoming
        trailingConstraint.isActive = !isIncoming

        updateConstraints(isIncoming: isIncoming)
    }

    private func updateConstraints(isIncoming: Bool) {
        NSLayoutConstraint.deactivate(viewRow.constraints)

        NSLayoutConstraint.activate([
            viewRow.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            viewRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            viewRow.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            label.topAnchor.constraint(equalTo: viewRow.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: viewRow.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: viewRow.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: viewRow.trailingAnchor, constant: -10)
        ])

        if isIncoming {
            leadingConstraint.constant = 16  //
        } else {
            trailingConstraint.constant = -16 //
        }
    }
}
