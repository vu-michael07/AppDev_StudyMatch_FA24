//
//  SettingsView.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class SettingsView: UIViewController {
    
    // MARK: - Properties (data)
    private var currentUser: User
    private var groups: [Group]
    private let onUpdate: (User, [Group]) -> Void
    
    // MARK: - Properties (views)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let userNameTextField = UITextField()
    private let setNameButton = UIButton(type: .system)
    private let groupNameTextField = UITextField()
    private let createGroupButton = UIButton(type: .system)
    
    // MARK: - Init
    init(currentUser: User, groups: [Group], onUpdate: @escaping (User, [Group]) -> Void) {
        self.currentUser = currentUser
        self.groups = groups
        self.onUpdate = onUpdate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Settings"
        
        setupScrollView()
        setupContent()
    }
    
    // MARK: - Setup Views
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentView)
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
    }
    
    private func setupContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        
        userNameTextField.placeholder = "Enter your new name"
        userNameTextField.borderStyle = .roundedRect
        userNameTextField.text = currentUser.name
        
        setNameButton.setTitle("Set Name", for: .normal)
        setNameButton.addTarget(self, action: #selector(updateUserName), for: .touchUpInside)
        
        let nameStack = UIStackView(arrangedSubviews: [userNameTextField, setNameButton])
        nameStack.axis = .horizontal
        nameStack.spacing = 8
        
        stackView.addArrangedSubview(nameStack)
        
        groupNameTextField.placeholder = "Enter new group name"
        groupNameTextField.borderStyle = .roundedRect
        
        createGroupButton.setTitle("Create Group", for: .normal)
        createGroupButton.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
        
        let groupStack = UIStackView(arrangedSubviews: [groupNameTextField, createGroupButton])
        groupStack.axis = .horizontal
        groupStack.spacing = 8
        
        stackView.addArrangedSubview(groupStack)
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func updateUserName() {
        guard let newName = userNameTextField.text, !newName.isEmpty else { return }
        currentUser.name = newName
        onUpdate(currentUser, groups)
        showAlert(title: "Success", message: "Your name has been updated.")
    }
    
    @objc private func createGroup() {
        guard let groupName = groupNameTextField.text, !groupName.isEmpty else { return }
        let newGroup = Group(id: groups.count + 1, name: groupName, users: [currentUser], rates: [], tasks: [])
        groups.append(newGroup)
        onUpdate(currentUser, groups) 
        groupNameTextField.text = ""
        showAlert(title: "Success", message: "New group '\(groupName)' created.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

