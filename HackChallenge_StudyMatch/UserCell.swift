//
//  UserCell.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class UserCell: UICollectionViewCell {
    
    // MARK: - Properties (Views)
    private let nameLabel = UILabel()
    private let netidLabel = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupNameLabel()
        setupNetidLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    
    /// Sets up the content view with rounded corners and a border
    private func setupContentView() {
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.clipsToBounds = true
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.backgroundColor = .systemGray6
    }
    
    /// Sets up the user name label
    private func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .black
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    /// Sets up the user's NetID label
    private func setupNetidLabel() {
        netidLabel.font = .systemFont(ofSize: 14, weight: .regular)
        netidLabel.textColor = .darkGray
        
        contentView.addSubview(netidLabel)
        netidLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            netidLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            netidLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            netidLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            netidLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with a `User` object
    func configure(with user: User) {
        nameLabel.text = user.name
        netidLabel.text = "NetID: \(user.netid)"
    }
}


