//
//  TaskView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import UIKit

class TaskView: UIView {
    
    // MARK: - Init
    
    init(task: Task) {
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
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, dueDateLabel])
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

