//
//  GroupView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class GroupView: UIView {
    
    // MARK: - Init
    
    init(group: Group) {
        super.init(frame: .zero)
        setupView(group: group)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView(group: Group) {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = .systemGray6
        
        let nameLabel = UILabel()
        nameLabel.text = group.name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        
        let membersLabel = UILabel()
        membersLabel.text = "Members: \(group.users.map { $0.name }.joined(separator: ", "))"
        membersLabel.font = .systemFont(ofSize: 14)
        membersLabel.textAlignment = .left
        membersLabel.numberOfLines = 0
        
        let ratingLabel = UILabel()
        let averageRating = group.rates.isEmpty ? "N/A" : String(format: "%.2f", group.rates.map { $0.stars }.reduce(0.0) { $0 + Double($1) } / Double(group.rates.count))
        ratingLabel.text = "Average Rating: \(averageRating)"
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textAlignment = .left
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, membersLabel, ratingLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}




