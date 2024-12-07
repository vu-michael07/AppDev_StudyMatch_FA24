//
//  GroupDetailViewController.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class GroupDetailViewController: UIViewController {
    
    // MARK: - Properties (views)
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let peopleStackView = UIStackView()
    private let tasksStackView = UIStackView()
    private let joinGroupButton = UIButton(type: .system)

    
    // MARK: - Properties (data)
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh group data from MockData
        if let updatedGroup = MockData.groups.first(where: { $0.id == group.id }) {
            group = updatedGroup
        }
        
        // Refresh UI
        refreshTasks()
        setupPeopleSection()
        updateJoinGroupButtonState() // Update the join/leave button state
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
            let personView = PersonView(user: user, groups: MockData.groups)
            peopleStackView.addArrangedSubview(personView)
        }
    }
    
    private func setupTasksSection() {
        tasksStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tasksStackView.axis = .vertical
        tasksStackView.spacing = 16
        
        // Add the Tasks label
        let tasksLabel = UILabel()
        tasksLabel.text = "Tasks"
        tasksLabel.font = .boldSystemFont(ofSize: 20)
        tasksLabel.textAlignment = .center
        tasksStackView.addArrangedSubview(tasksLabel)
        
        // Add the "Add Task" section
        let addTaskStackView = UIStackView()
        addTaskStackView.axis = .vertical
        addTaskStackView.spacing = 8
        
        let taskNameField = UITextField()
        taskNameField.placeholder = "Task Name"
        taskNameField.borderStyle = .roundedRect
        
        let taskDescriptionField = UITextField()
        taskDescriptionField.placeholder = "Task Description"
        taskDescriptionField.borderStyle = .roundedRect
        
        let taskDueDateField = UITextField()
        taskDueDateField.placeholder = "Due Date (YYYY-MM-DD)"
        taskDueDateField.borderStyle = .roundedRect
        
        let addTaskButton = UIButton(type: .system)
        styleButton(addTaskButton, title: "Add Task")
        addTaskButton.addTarget(self, action: #selector(addTask(_:)), for: .touchUpInside)
        
        addTaskStackView.addArrangedSubview(taskNameField)
        addTaskStackView.addArrangedSubview(taskDescriptionField)
        addTaskStackView.addArrangedSubview(taskDueDateField)
        addTaskStackView.addArrangedSubview(addTaskButton)
        
        tasksStackView.addArrangedSubview(addTaskStackView)
        
        refreshTasks()
    }
    
    private func refreshTasks() {
        tasksStackView.arrangedSubviews.filter { $0 is TaskView }.forEach { $0.removeFromSuperview() }
        
        for task in group.tasks {
            let taskView = TaskView(
                task: task,
                onDelete: { [weak self] taskToDelete in
                    self?.deleteTask(taskToDelete)
                },
                onEdit: { [weak self] taskToEdit in
                    self?.editTask(taskToEdit)
                }
            )
            tasksStackView.addArrangedSubview(taskView)
        }
    }



    @objc private func addTask(_ sender: UIButton) {
        guard let stackView = sender.superview as? UIStackView,
              let nameField = stackView.arrangedSubviews[0] as? UITextField,
              let descriptionField = stackView.arrangedSubviews[1] as? UITextField,
              let dueDateField = stackView.arrangedSubviews[2] as? UITextField,
              let taskName = nameField.text, !taskName.isEmpty,
              let taskDescription = descriptionField.text, !taskDescription.isEmpty,
              let dueDate = dueDateField.text, !dueDate.isEmpty else {
            return
        }
        
        let newTask = Task(
            id: MockData.tasks.count + 1,
            task_name: taskName,
            description: taskDescription,
            due_date: dueDate,
            group_id: group.id
        )
        
        // Update MockData
        if let groupIndex = MockData.groups.firstIndex(where: { $0.id == group.id }) {
            MockData.groups[groupIndex].tasks.append(newTask)
            group = MockData.groups[groupIndex] // Refresh local group
        }
        MockData.tasks.append(newTask)
        refreshTasks()
        
        nameField.text = ""
        descriptionField.text = ""
        dueDateField.text = ""
    }

    private func deleteTask(_ task: Task) {
        if let groupIndex = MockData.groups.firstIndex(where: { $0.id == group.id }),
           let taskIndex = MockData.groups[groupIndex].tasks.firstIndex(where: { $0.id == task.id }) {
            MockData.groups[groupIndex].tasks.remove(at: taskIndex)
            group = MockData.groups[groupIndex] // Refresh local group
        }
        if let mockIndex = MockData.tasks.firstIndex(where: { $0.id == task.id }) {
            MockData.tasks.remove(at: mockIndex)
        }
        refreshTasks()
    }

    private func editTask(_ task: Task) {
        // Alerts
        let alertController = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = task.task_name
            textField.placeholder = "Task Name"
        }
        
        alertController.addTextField { textField in
            textField.text = task.description
            textField.placeholder = "Task Description"
        }
        
        alertController.addTextField { textField in
            textField.text = task.due_date
            textField.placeholder = "Due Date (YYYY-MM-DD)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let nameField = alertController.textFields?[0].text, !nameField.isEmpty,
                  let descriptionField = alertController.textFields?[1].text, !descriptionField.isEmpty,
                  let dueDateField = alertController.textFields?[2].text, !dueDateField.isEmpty else { return }
            
            // Update the task
            if let groupIndex = MockData.groups.firstIndex(where: { $0.id == self?.group.id }),
               let taskIndex = MockData.groups[groupIndex].tasks.firstIndex(where: { $0.id == task.id }) {
                MockData.groups[groupIndex].tasks[taskIndex].task_name = nameField
                MockData.groups[groupIndex].tasks[taskIndex].description = descriptionField
                MockData.groups[groupIndex].tasks[taskIndex].due_date = dueDateField
                
                // Refresh the local group and UI
                self?.group = MockData.groups[groupIndex]
                self?.refreshTasks()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func styleButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func setupJoinGroupButton() {
        joinGroupButton.layer.cornerRadius = 8
        joinGroupButton.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
        updateJoinGroupButtonState() // Set initial button state
    }
    
    private func updateJoinGroupButtonState() {
        if group.users.contains(where: { $0.id == MockData.currentUser.id }) {
            joinGroupButton.setTitle("Leave Group", for: .normal)
            joinGroupButton.setTitleColor(.white, for: .normal)
            joinGroupButton.backgroundColor = .systemRed
        } else if MockData.currentUser.group_id != nil && MockData.currentUser.group_id != group.id {
            joinGroupButton.setTitle("In Different Group", for: .normal)
            joinGroupButton.setTitleColor(.white, for: .normal)
            joinGroupButton.backgroundColor = .black
        } else {
            joinGroupButton.setTitle("Join Group", for: .normal)
            joinGroupButton.setTitleColor(.white, for: .normal)
            joinGroupButton.backgroundColor = .systemBlue
        }
    }
    
    // MARK: - Actions
    
    @objc private func joinGroup() {
        if MockData.currentUser.group_id != nil && MockData.currentUser.group_id != group.id {
            // User is already in a different group
            joinGroupButton.setTitle("Failed", for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.updateJoinGroupButtonState()
            }
            return
        }
        
        guard let currentUserIndex = MockData.users.firstIndex(where: { $0.id == MockData.currentUser.id }) else { return }

        if group.users.contains(where: { $0.id == MockData.currentUser.id }) {
            // Leave Group
            MockData.users[currentUserIndex].group_id = nil
            group.users.removeAll { $0.id == MockData.currentUser.id }
        } else {
            // Join Group
            MockData.users[currentUserIndex].group_id = group.id
            group.users.append(MockData.users[currentUserIndex])
        }

        if let groupIndex = MockData.groups.firstIndex(where: { $0.id == group.id }) {
            MockData.groups[groupIndex].users = group.users
        }

        MockData.currentUser = MockData.users[currentUserIndex] // Does something

        setupPeopleSection()
        updateJoinGroupButtonState()
    }
}


