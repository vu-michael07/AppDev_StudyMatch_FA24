//
//  GroupDetailViewController.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class GroupDetailViewController: UIViewController {
    
    // MARK: - Properties (Views)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let peopleStackView = UIStackView()
    private let tasksStackView = UIStackView()
    private let joinGroupButton = UIButton(type: .system)
    
    // MARK: - Properties (Data)
    private var group: Group
    
    // MARK: - Init
    init(group: Group) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = group.name
        
        setupScrollView()
        setupPeopleSection()
        setupTasksSection()
        setupJoinGroupButton()
        refreshGroupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshGroupData()  // Fetch the latest group data
    }
    
    // MARK: - Setup Views
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(joinGroupButton)
        contentView.addSubview(peopleStackView)
        contentView.addSubview(tasksStackView)
        
        joinGroupButton.translatesAutoresizingMaskIntoConstraints = false
        peopleStackView.translatesAutoresizingMaskIntoConstraints = false
        tasksStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            joinGroupButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            joinGroupButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            joinGroupButton.widthAnchor.constraint(equalToConstant: 120),
            joinGroupButton.heightAnchor.constraint(equalToConstant: 40),
            
            peopleStackView.topAnchor.constraint(equalTo: joinGroupButton.bottomAnchor, constant: 32),
            peopleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            peopleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tasksStackView.topAnchor.constraint(equalTo: peopleStackView.bottomAnchor, constant: 32),
            tasksStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tasksStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tasksStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPeopleSection() {
        peopleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        peopleStackView.axis = .vertical
        peopleStackView.spacing = 16
        
        let peopleLabel = UILabel()
        peopleLabel.text = "People"
        peopleLabel.font = .boldSystemFont(ofSize: 20)
        peopleLabel.textAlignment = .center
        peopleStackView.addArrangedSubview(peopleLabel)
        
        for user in group.users {
            let personView = PersonView(user: user, groups: [group])
            peopleStackView.addArrangedSubview(personView)
        }
    }
    
    private func setupTasksSection() {
        tasksStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tasksStackView.axis = .vertical
        tasksStackView.spacing = 16
        
        // Tasks label
        let tasksLabel = UILabel()
        tasksLabel.text = "Tasks"
        tasksLabel.font = .boldSystemFont(ofSize: 20)
        tasksLabel.textAlignment = .center
        tasksStackView.addArrangedSubview(tasksLabel)
        
        // Add Task Form
        let taskNameField = createTextField(placeholder: "Task Name")
        let taskDescriptionField = createTextField(placeholder: "Task Description")
        let taskDueDateField = createTextField(placeholder: "Due Date (YYYY-MM-DD)")
        
        let addTaskButton = UIButton(type: .system)
        styleButton(addTaskButton, title: "Add Task")
        addTaskButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        let addTaskStackView = UIStackView(arrangedSubviews: [taskNameField, taskDescriptionField, taskDueDateField, addTaskButton])
        addTaskStackView.axis = .vertical
        addTaskStackView.spacing = 8
        
        tasksStackView.addArrangedSubview(addTaskStackView)
        
        refreshTasks()
    }
    
    private func refreshTasks() {
        tasksStackView.arrangedSubviews.filter { $0 is TaskView }.forEach { $0.removeFromSuperview() }
        
        for task in group.tasks {
            let taskView = TaskView(
                task: task,
                onTaskDeleted: { [weak self] taskToDelete in
                    guard let self = self else { return }
                    self.refreshGroupData()  // Reload the entire group data after deletion
                },
                onTaskEdited: { [weak self] taskToEdit in
                    guard let self = self else { return }
                    self.refreshGroupData()  // Reload the group data after editing
                }
            )
            tasksStackView.addArrangedSubview(taskView)
        }
    }

    
    // MARK: - API Integration
    
    private func refreshGroupData() {
        APIService.shared.fetch("/groups/\(group.id)/", responseType: Group.self) { result in
            DispatchQueue.main.async {
                if case let .success(updatedGroup) = result {
                    self.group = updatedGroup
                    self.setupPeopleSection()
                    self.refreshTasks()
                    self.updateJoinGroupButtonState()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        return textField
    }
    
    private func styleButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    @objc private func addTask(_ sender: UIButton) {
        guard let stackView = sender.superview as? UIStackView,
              let nameField = stackView.arrangedSubviews[0] as? UITextField,
              let descriptionField = stackView.arrangedSubviews[1] as? UITextField,
              let dueDateField = stackView.arrangedSubviews[2] as? UITextField,
              let taskName = nameField.text, !taskName.isEmpty,
              let taskDescription = descriptionField.text, !taskDescription.isEmpty,
              let dueDate = dueDateField.text, !dueDate.isEmpty else {
            showAlert(title: "Error", message: "All fields are required.")
            return
        }

        let taskPayload: [String: Any] = [
            "task_name": taskName,
            "description": taskDescription,
            "due_date": dueDate
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: taskPayload, options: []) else {
            showAlert(title: "Error", message: "Failed to encode task payload.")
            return
        }

        APIService.shared.sendRequest(
            endpoint: "/groups/\(group.id)/tasks/",
            method: "POST",
            body: jsonData,
            responseType: Group.self
        ) { result in
            DispatchQueue.main.async {
                if case let .success(updatedGroup) = result {
                    self.group = updatedGroup
                    self.refreshTasks()
                    nameField.text = ""
                    descriptionField.text = ""
                    dueDateField.text = ""
                } else {
                    self.showAlert(title: "Error", message: "Failed to create task.")
                }
            }
        }
    }

    
    // MARK: - Join Group Logic
    private func setupJoinGroupButton() {
        joinGroupButton.layer.cornerRadius = 8
        joinGroupButton.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
        updateJoinGroupButtonState()
    }

    private func updateJoinGroupButtonState() {
        guard let currentUser = UserSessionManager.shared.currentUser else { return }

        if let userGroupId = currentUser.group_id {
            if userGroupId == group.id {
                configureJoinButton(title: "Already Joined", color: .systemGray, isEnabled: false)
            } else {
                configureJoinButton(title: "In Different Group", color: .systemRed, isEnabled: false)
            }
        } else {
            configureJoinButton(title: "Join Group", color: .systemBlue, isEnabled: true)
        }
    }

    private func configureJoinButton(title: String, color: UIColor, isEnabled: Bool) {
        joinGroupButton.setTitle(title, for: .normal)
        joinGroupButton.setTitleColor(.white, for: .normal)
        joinGroupButton.backgroundColor = color
        joinGroupButton.isEnabled = isEnabled
    }

    @objc private func joinGroup() {
        guard let currentUser = UserSessionManager.shared.currentUser, joinGroupButton.isEnabled else {
            showAlert(title: "Error", message: "Action not allowed.")
            return
        }

        let endpoint = "/users/\(currentUser.id)/"
        let payload: [String: Any] = ["group_id": group.id]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            showAlert(title: "Error", message: "Failed to encode request payload.")
            return
        }

        APIService.shared.sendRequest(
            endpoint: endpoint,
            method: "PUT",
            body: jsonData,
            responseType: Group.self
        ) { result in
            DispatchQueue.main.async {
                if case let .success(updatedGroup) = result {
                    self.group = updatedGroup
                    self.refreshGroupData()
                    self.updateJoinGroupButtonState()
                } else {
                    self.showAlert(title: "Error", message: "Failed to join the group.")
                }
            }
        }
    }
     
     // MARK: - Utility
     private func showAlert(title: String, message: String) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         present(alert, animated: true)
     }
 }
