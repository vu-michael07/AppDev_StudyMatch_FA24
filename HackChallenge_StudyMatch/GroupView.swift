//
//  GroupView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class GroupView: UIView {
    
    // MARK: - Init
    
    // Initializes the view with a `Group` object
    init(group: Group) {
        super.init(frame: .zero)
        setupView(with: group)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    
    // Sets up the view for a specific group
    private func setupView(with group: Group) {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = .systemGray6
        
        // Group name label
        let nameLabel = UILabel()
        nameLabel.text = group.name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        
        // Members label
        let membersLabel = UILabel()
        membersLabel.text = group.users.isEmpty
            ? "No members yet"
            : "Members: " + group.users.map { $0.name }.joined(separator: ", ")
        membersLabel.font = .systemFont(ofSize: 14)
        membersLabel.textAlignment = .left
        membersLabel.numberOfLines = 0
        
        // Tasks label
        let tasksLabel = UILabel()
        tasksLabel.text = group.tasks.isEmpty
            ? "No tasks assigned"
            : "\(group.tasks.count) task(s) assigned"
        tasksLabel.font = .italicSystemFont(ofSize: 14)
        tasksLabel.textColor = .darkGray
        tasksLabel.textAlignment = .left
        
        // Stack labels
        let stackView = UIStackView(arrangedSubviews: [nameLabel, membersLabel, tasksLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

