//
//  TaskView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class TaskView: UIView {
    
    private let deleteButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)
    private let task: Task
    private let onDelete: (Task) -> Void
    private let onEdit: (Task) -> Void
    
    // MARK: - Init
    
    init(task: Task, onDelete: @escaping (Task) -> Void, onEdit: @escaping (Task) -> Void) {
        self.task = task
        self.onDelete = onDelete
        self.onEdit = onEdit
        super.init(frame: .zero)
        setupView(task: task)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView(task: Task) {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = .systemGray6
        
        let nameLabel = UILabel()
        nameLabel.text = task.task_name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = task.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        
        let dueDateLabel = UILabel()
        dueDateLabel.text = "Due Date: \(task.due_date)"
        dueDateLabel.font = .systemFont(ofSize: 14)
        dueDateLabel.textAlignment = .left
        
        deleteButton.setTitle("Delete Task", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.layer.cornerRadius = 5
        deleteButton.addTarget(self, action: #selector(deleteTask), for: .touchUpInside)
        
        editButton.setTitle("Edit Task", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.backgroundColor = .systemBlue
        editButton.layer.cornerRadius = 5
        editButton.addTarget(self, action: #selector(editTask), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [editButton, deleteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, dueDateLabel, buttonStackView])
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
    
    // MARK: - Actions
    
    @objc private func deleteTask() {
        onDelete(task)
    }
    
    @objc private func editTask() {
        onEdit(task)
    }
}


