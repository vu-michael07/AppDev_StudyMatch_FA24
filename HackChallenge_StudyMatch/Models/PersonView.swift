//
//  PersonView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class PersonView: UIView {
    
    // MARK: - Init
    
    // Initializes a view for a specific user and displays their associated groups
    init(user: User, groups: [Group]) {
        super.init(frame: .zero)
        setupView(user: user, groups: groups)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    // Sets up the view's appearance and layout
    private func setupView(user: User, groups: [Group]) {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = .systemGray6
        
        // User's name label
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        
        // "Groups" title label
        let groupsLabel = UILabel()
        groupsLabel.text = "Groups:"
        groupsLabel.font = .boldSystemFont(ofSize: 16)
        groupsLabel.textAlignment = .left
        
        // User's groups label
        let groupsListLabel = UILabel()
        let userGroups = groups.filter { $0.users.contains(where: { $0.id == user.id }) }
        groupsListLabel.text = userGroups.isEmpty
            ? "No groups found"
            : userGroups.map { $0.name }.joined(separator: ", ")
        groupsListLabel.font = .systemFont(ofSize: 14)
        groupsListLabel.textAlignment = .left
        groupsListLabel.numberOfLines = 0
        
        // Organize labels into a vertical stack view
        let stackView = UIStackView(arrangedSubviews: [nameLabel, groupsLabel, groupsListLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

