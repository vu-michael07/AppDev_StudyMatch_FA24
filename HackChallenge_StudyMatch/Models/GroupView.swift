//
//  GroupView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class GroupView: UIView {
    
    var onDeleteGroup: (() -> Void)?
    var onGroupTapped: (() -> Void)?
    
    init(group: Group, onDelete: @escaping () -> Void, onTap: @escaping () -> Void) {
        super.init(frame: .zero)
        self.onDeleteGroup = onDelete
        self.onGroupTapped = onTap
        setupView(with: group)
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(with group: Group) {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = .systemGray6
        
        let nameLabel = UILabel()
        nameLabel.text = group.name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        
        let membersLabel = UILabel()
        membersLabel.text = group.users.isEmpty
            ? "No members yet"
            : "Members: " + group.users.map { $0.name }.joined(separator: ", ")
        membersLabel.font = .systemFont(ofSize: 14)
        membersLabel.numberOfLines = 0
        
        let tasksLabel = UILabel()
        tasksLabel.text = group.tasks.isEmpty
            ? "No tasks assigned"
            : "\(group.tasks.count) task(s) assigned"
        tasksLabel.font = .italicSystemFont(ofSize: 14)
        tasksLabel.textColor = .darkGray
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete Group", for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.addTarget(self, action: #selector(deleteGroupTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, membersLabel, tasksLabel, deleteButton])
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
    
    @objc private func deleteGroupTapped() {
        onDeleteGroup?()
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(groupTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func groupTapped() {
        onGroupTapped?()
    }
}



