//
//  TaskView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class TaskView: UIView {
    
    // MARK: - Properties
    private let deleteButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)
    private let task: Task
    private let onTaskDeleted: (Task) -> Void
    private let onTaskEdited: (Task) -> Void
    
    // MARK: - Init
    
    init(task: Task, onTaskDeleted: @escaping (Task) -> Void, onTaskEdited: @escaping (Task) -> Void) {
        self.task = task
        self.onTaskDeleted = onTaskDeleted
        self.onTaskEdited = onTaskEdited
        super.init(frame: .zero)
        setupView(task: task)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    
    private func setupView(task: Task) {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = .systemGray6
        
        // Task Name
        let nameLabel = UILabel()
        nameLabel.text = task.task_name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        
        // Task Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = task.task_description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        
        // Task Due Date
        let dueDateLabel = UILabel()
        dueDateLabel.text = "Due Date: \(task.due_date)"
        dueDateLabel.font = .systemFont(ofSize: 14)
        dueDateLabel.textAlignment = .left
        
        // Delete Task Button
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.layer.cornerRadius = 5
        deleteButton.addTarget(self, action: #selector(deleteTask), for: .touchUpInside)
        
        // Edit Task Button
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.backgroundColor = .systemBlue
        editButton.layer.cornerRadius = 5
        editButton.addTarget(self, action: #selector(editTask), for: .touchUpInside)
        
        // Button Stack
        let buttonStackView = UIStackView(arrangedSubviews: [editButton, deleteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        // Main Stack
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
    
    // MARK: - API Actions
    
    @objc private func deleteTask() {
        let endpoint = "/tasks/\(task.id)/"
        
        APIService.shared.sendRequest(
            endpoint: endpoint,
            method: "DELETE",
            body: nil,
            responseType: Task.self
        ) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.onTaskDeleted(self.task)
                } else {
                    self.showAlert(title: "Error", message: "Failed to delete task.")
                }
            }
        }
    }
    
    @objc private func editTask() {
        let alertController = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
        
        // Task Fields
        alertController.addTextField { [self] textField in
            textField.text = task.task_name
            textField.placeholder = "Task Name"
        }
        
        alertController.addTextField { [self] textField in
            textField.text = task.task_description
            textField.placeholder = "Task Description"
        }
        
        alertController.addTextField { [self] textField in
            textField.text = task.due_date
            textField.placeholder = "Due Date (YYYY-MM-DD)"
        }
        
        // Save Action
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let taskName = alertController.textFields?[0].text, !taskName.isEmpty,
                  let taskDescription = alertController.textFields?[1].text, !taskDescription.isEmpty,
                  let dueDate = alertController.textFields?[2].text, !dueDate.isEmpty else {
                self?.showAlert(title: "Error", message: "All fields are required.")
                return
            }
            
            let updatedTaskPayload: [String: Any] = [
                "task_name": taskName,
                "description": taskDescription,
                "due_date": dueDate
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: updatedTaskPayload) else {
                self.showAlert(title: "Error", message: "Failed to encode task data.")
                return
            }
            
            APIService.shared.sendRequest(
                endpoint: "/tasks/\(self.task.id)/",
                method: "PUT",
                body: jsonData,
                responseType: Group.self
            ) { result in
                DispatchQueue.main.async {
                    if case .success = result {
                        self.onTaskEdited(self.task)
                    } else {
                        self.showAlert(title: "Error", message: "Failed to update task.")
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true)
    }

    // MARK: - Utility
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}
